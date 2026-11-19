import * as core from '@actions/core';
import * as github from '@actions/github';
import { loadConfig } from './config';
import { loadPullRequest } from './ingestion/pr-loader';
import { buildSeparatedPrompt } from './orchestration/trust-boundary';
import { LLMReviewClient } from './orchestration/llm-client';
import { deriveVerdict } from './validation/verdict-engine';
import { postReviewToGitHub } from './delivery/github-poster';
import { createCheckRun } from './delivery/checks-annotator';

export async function run(): Promise<void> {
  try {
    core.info('🤖 Starting Vasanta AI Code Reviewer...');

    // 1. Load runtime configuration
    const config = loadConfig();
    const octokit = github.getOctokit(config.githubToken);

    // 2. Stage 1: Ingestion
    core.info('📥 Fetching PR metadata and diff...');
    const pr = await loadPullRequest(octokit);
    core.info(`Fetched PR #${pr.pullNumber} (${pr.title}) by @${pr.author}. Diff size: ${pr.parsedDiff.rawDiff.length} chars.`);

    if (!pr.parsedDiff.rawDiff || pr.parsedDiff.rawDiff.trim().length === 0) {
      core.info('Empty diff detected. Skipping review.');
      return;
    }

    // 3. Stage 2: Orchestration & Trust Boundary
    core.info('🧠 Constructing trust-boundary prompt and executing review...');
    const prompt = buildSeparatedPrompt({
      prUrl: pr.htmlUrl,
      prTitle: pr.title,
      prAuthor: pr.author,
      diff: pr.parsedDiff.rawDiff,
      maxFindings: config.maxFindings,
    });

    const llmClient = new LLMReviewClient({
      apiKey: config.geminiApiKey,
      model: config.model,
    });

    const output = await llmClient.executeReview(prompt);
    core.info(`Received ${output.comments.length} findings from model.`);

    // 4. Stage 3: Validation & Verdict Derivation
    const verdict = deriveVerdict(output.comments, config.approvalPreset);
    core.info(`Derived Verdict: ${verdict.verdict} (Approved: ${verdict.approved})`);

    // 5. Stage 4: Delivery
    core.info('📤 Delivering review comments and check annotations to GitHub...');
    await postReviewToGitHub(octokit, pr, output.comments, verdict);
    await createCheckRun(octokit, pr, output.comments, verdict);

    // 6. Set GitHub Action outputs
    core.setOutput('verdict', verdict.verdict);
    core.setOutput('approved', verdict.approved.toString());
    core.setOutput('findings-count', verdict.totalFindings.toString());

    if (!verdict.approved && verdict.blockingCount > 0) {
      core.setFailed(`AI Code Review requested changes: ${verdict.blockingCount} blocking defects detected.`);
    } else {
      core.info('✅ AI Code Review completed successfully.');
    }
  } catch (error: unknown) {
    const err = error as Error;
    core.setFailed(`AI Code Review error: ${err.message}`);
  }
}

// Execute if run directly
if (require.main === module) {
  run();
}
