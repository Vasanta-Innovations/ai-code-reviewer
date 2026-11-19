import * as github from '@actions/github';
import { ClassifiedFinding } from '../validation/schemas';
import { VerdictResult } from '../validation/verdict-engine';
import { isLineInDiff } from '../ingestion/diff-parser';
import { formatInlineComment, formatSummaryReview } from './comment-formatter';
import { PullRequestMetadata } from '../ingestion/pr-loader';

export async function postReviewToGitHub(
  octokit: ReturnType<typeof github.getOctokit>,
  pr: PullRequestMetadata,
  findings: ClassifiedFinding[],
  verdict: VerdictResult
): Promise<void> {
  const inlineComments: { path: string; line: number; body: string }[] = [];
  const prLevelComments: string[] = [];

  for (const finding of findings) {
    if (finding.file_path && finding.line_number && isLineInDiff(pr.parsedDiff, finding.file_path, finding.line_number)) {
      inlineComments.push({
        path: finding.file_path,
        line: finding.line_number,
        body: formatInlineComment(finding),
      });
    } else {
      prLevelComments.push(formatInlineComment(finding));
    }
  }

  let fullBody = formatSummaryReview(verdict, findings);
  if (prLevelComments.length > 0) {
    fullBody += `\n\n### 📌 General PR-Level Findings:\n\n` + prLevelComments.join('\n\n---\n\n');
  }

  // Map our derived verdict to GitHub Pull Request Review Event
  // Events: 'APPROVE' | 'REQUEST_CHANGES' | 'COMMENT'
  const event = verdict.verdict;

  try {
    await octokit.rest.pulls.createReview({
      owner: pr.owner,
      repo: pr.repo,
      pull_number: pr.pullNumber,
      commit_id: pr.headSha,
      body: fullBody,
      event: event,
      comments: inlineComments.length > 0 ? inlineComments : undefined,
    });
  } catch (err: unknown) {
    const error = err as Error;
    // Fallback if createReview fails due to permissions (e.g. PR author cannot review own PR)
    console.warn(`[ai-code-reviewer] Warning: Could not create formal PR review event (${error.message}). Falling back to PR issue comment.`);
    await octokit.rest.issues.createComment({
      owner: pr.owner,
      repo: pr.repo,
      issue_number: pr.pullNumber,
      body: fullBody,
    });
  }
}
