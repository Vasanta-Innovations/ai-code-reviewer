"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.loadConfig = loadConfig;
function loadConfig(env = process.env) {
    const githubToken = env.GITHUB_TOKEN || env.INPUT_GITHUB_TOKEN || '';
    if (!githubToken) {
        throw new Error('GITHUB_TOKEN is required to run the AI Code Reviewer');
    }
    const geminiApiKey = env.GEMINI_API_KEY || env.INPUT_GEMINI_API_KEY || '';
    const model = env.INPUT_MODEL || env.MODEL || 'gemini-2.5-flash';
    const approvalPreset = (env.INPUT_APPROVAL_PRESET || env.APPROVAL_PRESET || 'minor_only');
    const maxFindings = parseInt(env.INPUT_MAX_FINDINGS || '15', 10);
    return {
        githubToken,
        geminiApiKey,
        model,
        approvalPreset,
        maxFindings,
    };
}
