"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatInlineComment = formatInlineComment;
exports.formatSummaryReview = formatSummaryReview;
function formatInlineComment(finding) {
    const badgeMap = {
        blocking: '🔴 **[Blocking Defect]**',
        important: '🟡 **[Important Suggestion]**',
        minor: '🔵 **[Minor Notice]**',
    };
    const badge = badgeMap[finding.severity] || '⚪ **[Notice]**';
    let body = `${badge} **${finding.title}**  \n`;
    body += `*Category: \`${finding.issue_type}\`*  \n\n`;
    body += `${finding.comment}\n\n`;
    // Evidence section in clean markdown
    body += `<details>\n<summary><b>🔍 Evidence & Blast Radius</b></summary>\n\n`;
    body += `- **Trigger**: ${finding.evidence.trigger}\n`;
    body += `- **Consequence**: ${finding.evidence.consequence}\n`;
    body += `- **Code Checked**: \`${finding.evidence.code_checked}\`\n`;
    if (finding.rule) {
        body += `- **Rule Reference**: ${finding.rule}\n`;
    }
    body += `\n</details>\n\n`;
    // Suggested code fix if available
    if (finding.suggested_fix) {
        body += `**Suggested Fix:**\n\`\`\`suggestion\n${finding.suggested_fix}\n\`\`\`\n`;
    }
    return body;
}
function formatSummaryReview(verdict, findings) {
    const emojiMap = {
        APPROVE: '✅ **APPROVED**',
        COMMENT: '💬 **COMMENT / SUGGESTIONS ONLY**',
        REQUEST_CHANGES: '❌ **CHANGES REQUESTED**',
    };
    const verdictTitle = emojiMap[verdict.verdict] || verdict.verdict;
    let summary = `## 🤖 AI Automated Code Review Summary\n\n`;
    summary += `### Verdict: ${verdictTitle}\n\n`;
    summary += `| Metric | Count |\n`;
    summary += `|---|:---:|\n`;
    summary += `| 🔴 Blocking Defects | **${verdict.blockingCount}** |\n`;
    summary += `| 🟡 Important Issues | **${verdict.importantCount}** |\n`;
    summary += `| 🔵 Minor Items | **${verdict.minorCount}** |\n`;
    summary += `| **Total Findings** | **${verdict.totalFindings}** |\n\n`;
    if (findings.length === 0) {
        summary += `🎉 **Zero defects or risks identified.** The diff is clean and adheres to company engineering standards.\n`;
    }
    else {
        summary += `### Findings Overview:\n`;
        findings.forEach((f, idx) => {
            summary += `${idx + 1}. **[${f.severity.toUpperCase()}]** \`${f.issue_type}\` — ${f.title}`;
            if (f.file_path) {
                summary += ` (\`${f.file_path}${f.line_number ? `:${f.line_number}` : ''}\`)`;
            }
            summary += `\n`;
        });
    }
    summary += `\n---\n*Automated review powered by [Vasanta-Innovations/ai-code-reviewer](https://github.com/Vasanta-Innovations/ai-code-reviewer)*`;
    return summary;
}
