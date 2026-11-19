"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.postReviewToGitHub = postReviewToGitHub;
const diff_parser_1 = require("../ingestion/diff-parser");
const comment_formatter_1 = require("./comment-formatter");
async function postReviewToGitHub(octokit, pr, findings, verdict) {
    const inlineComments = [];
    const prLevelComments = [];
    for (const finding of findings) {
        if (finding.file_path && finding.line_number && (0, diff_parser_1.isLineInDiff)(pr.parsedDiff, finding.file_path, finding.line_number)) {
            inlineComments.push({
                path: finding.file_path,
                line: finding.line_number,
                body: (0, comment_formatter_1.formatInlineComment)(finding),
            });
        }
        else {
            prLevelComments.push((0, comment_formatter_1.formatInlineComment)(finding));
        }
    }
    let fullBody = (0, comment_formatter_1.formatSummaryReview)(verdict, findings);
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
    }
    catch (err) {
        const error = err;
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
