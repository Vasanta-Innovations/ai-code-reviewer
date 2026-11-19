"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createCheckRun = createCheckRun;
async function createCheckRun(octokit, pr, findings, verdict) {
    const conclusion = verdict.approved ? 'success' : (verdict.blockingCount > 0 ? 'failure' : 'neutral');
    const annotations = findings
        .filter(f => f.file_path && f.line_number)
        .slice(0, 50) // GitHub Checks API limits annotations to 50 per call
        .map(f => {
        let annotation_level = 'notice';
        if (f.severity === 'blocking')
            annotation_level = 'failure';
        else if (f.severity === 'important')
            annotation_level = 'warning';
        return {
            path: f.file_path,
            start_line: f.line_number,
            end_line: f.line_number,
            annotation_level,
            message: `${f.comment}\nTrigger: ${f.evidence.trigger}\nConsequence: ${f.evidence.consequence}`,
            title: `[${f.severity.toUpperCase()}] ${f.title}`,
        };
    });
    try {
        await octokit.rest.checks.create({
            owner: pr.owner,
            repo: pr.repo,
            name: 'AI Code Review / Quality Gate',
            head_sha: pr.headSha,
            status: 'completed',
            conclusion: conclusion,
            output: {
                title: `AI Review: ${verdict.verdict} (${verdict.totalFindings} findings)`,
                summary: `Blocking: ${verdict.blockingCount} | Important: ${verdict.importantCount} | Minor: ${verdict.minorCount}`,
                annotations: annotations.length > 0 ? annotations : undefined,
            },
        });
    }
    catch (err) {
        const error = err;
        console.warn(`[ai-code-reviewer] Checks API notice: ${error.message}`);
    }
}
