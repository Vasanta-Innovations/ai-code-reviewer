"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.run = run;
const core = __importStar(require("@actions/core"));
const github = __importStar(require("@actions/github"));
const config_1 = require("./config");
const pr_loader_1 = require("./ingestion/pr-loader");
const trust_boundary_1 = require("./orchestration/trust-boundary");
const llm_client_1 = require("./orchestration/llm-client");
const verdict_engine_1 = require("./validation/verdict-engine");
const github_poster_1 = require("./delivery/github-poster");
const checks_annotator_1 = require("./delivery/checks-annotator");
async function run() {
    try {
        core.info('🤖 Starting Vasanta AI Code Reviewer...');
        // 1. Load runtime configuration
        const config = (0, config_1.loadConfig)();
        const octokit = github.getOctokit(config.githubToken);
        // 2. Stage 1: Ingestion
        core.info('📥 Fetching PR metadata and diff...');
        const pr = await (0, pr_loader_1.loadPullRequest)(octokit);
        core.info(`Fetched PR #${pr.pullNumber} (${pr.title}) by @${pr.author}. Diff size: ${pr.parsedDiff.rawDiff.length} chars.`);
        if (!pr.parsedDiff.rawDiff || pr.parsedDiff.rawDiff.trim().length === 0) {
            core.info('Empty diff detected. Skipping review.');
            return;
        }
        // 3. Stage 2: Orchestration & Trust Boundary
        core.info('🧠 Constructing trust-boundary prompt and executing review...');
        const prompt = (0, trust_boundary_1.buildSeparatedPrompt)({
            prUrl: pr.htmlUrl,
            prTitle: pr.title,
            prAuthor: pr.author,
            diff: pr.parsedDiff.rawDiff,
            maxFindings: config.maxFindings,
        });
        const llmClient = new llm_client_1.LLMReviewClient({
            apiKey: config.geminiApiKey,
            model: config.model,
        });
        const output = await llmClient.executeReview(prompt);
        core.info(`Received ${output.comments.length} findings from model.`);
        // 4. Stage 3: Validation & Verdict Derivation
        const verdict = (0, verdict_engine_1.deriveVerdict)(output.comments, config.approvalPreset);
        core.info(`Derived Verdict: ${verdict.verdict} (Approved: ${verdict.approved})`);
        // 5. Stage 4: Delivery
        core.info('📤 Delivering review comments and check annotations to GitHub...');
        await (0, github_poster_1.postReviewToGitHub)(octokit, pr, output.comments, verdict);
        await (0, checks_annotator_1.createCheckRun)(octokit, pr, output.comments, verdict);
        // 6. Set GitHub Action outputs
        core.setOutput('verdict', verdict.verdict);
        core.setOutput('approved', verdict.approved.toString());
        core.setOutput('findings-count', verdict.totalFindings.toString());
        if (!verdict.approved && verdict.blockingCount > 0) {
            core.setFailed(`AI Code Review requested changes: ${verdict.blockingCount} blocking defects detected.`);
        }
        else {
            core.info('✅ AI Code Review completed successfully.');
        }
    }
    catch (error) {
        const err = error;
        core.setFailed(`AI Code Review error: ${err.message}`);
    }
}
// Execute if run directly
if (require.main === module) {
    run();
}
