"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deriveVerdict = deriveVerdict;
/**
 * Deterministically derives the review verdict and approval boolean.
 * Invariant: The LLM NEVER outputs 'approved: true/false'. The framework computes it.
 */
function deriveVerdict(findings, preset = 'minor_only') {
    const blockingCount = findings.filter(f => f.severity === 'blocking').length;
    const importantCount = findings.filter(f => f.severity === 'important').length;
    const minorCount = findings.filter(f => f.severity === 'minor').length;
    const totalFindings = findings.length;
    let verdict = 'APPROVE';
    if (preset === 'minor_only') {
        if (blockingCount > 0) {
            verdict = 'REQUEST_CHANGES';
        }
        else if (importantCount > 0) {
            verdict = 'COMMENT';
        }
        else {
            verdict = 'APPROVE';
        }
    }
    else if (preset === 'no_blocking') {
        verdict = blockingCount > 0 ? 'REQUEST_CHANGES' : 'APPROVE';
    }
    else if (preset === 'no_comments') {
        verdict = totalFindings > 0 ? 'REQUEST_CHANGES' : 'APPROVE';
    }
    return {
        verdict,
        approved: verdict === 'APPROVE',
        blockingCount,
        importantCount,
        minorCount,
        totalFindings,
    };
}
