"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.extractAndRepairJson = extractAndRepairJson;
exports.safeParseJson = safeParseJson;
/**
 * Pre-parse repair hook for LLM responses.
 * Cleans markdown code fences, locates outer JSON boundaries, and repairs syntax.
 */
function extractAndRepairJson(raw) {
    let cleaned = raw.trim();
    // 1. Remove markdown json code fences if present (```json ... ``` or ``` ...)
    if (cleaned.startsWith('```')) {
        cleaned = cleaned.replace(/^```[a-zA-Z]*\n?/, '').replace(/\n?```$/, '').trim();
    }
    // 2. Locate outermost matching braces '{' ... '}'
    const firstBrace = cleaned.indexOf('{');
    const lastBrace = cleaned.lastIndexOf('}');
    if (firstBrace !== -1 && lastBrace !== -1 && lastBrace > firstBrace) {
        cleaned = cleaned.substring(firstBrace, lastBrace + 1);
    }
    return cleaned;
}
function safeParseJson(raw) {
    const prepared = extractAndRepairJson(raw);
    try {
        return JSON.parse(prepared);
    }
    catch (err) {
        const error = err;
        throw new Error(`Failed to parse repaired LLM JSON output: ${error.message}\nRaw content snippet: ${raw.slice(0, 300)}`);
    }
}
