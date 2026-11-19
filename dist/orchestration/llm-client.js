"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.LLMReviewClient = void 0;
const genai_1 = require("@google/genai");
const schemas_1 = require("../validation/schemas");
const repair_hook_1 = require("../validation/repair-hook");
class LLMReviewClient {
    client = null;
    model;
    constructor(options) {
        this.model = options.model || 'gemini-2.5-flash';
        if (options.apiKey) {
            this.client = new genai_1.GoogleGenAI({ apiKey: options.apiKey });
        }
    }
    async executeReview(prompt) {
        if (!this.client) {
            throw new Error('GEMINI_API_KEY is not configured. Please supply an API key in the action inputs.');
        }
        try {
            const response = await this.client.models.generateContent({
                model: this.model,
                contents: prompt.userPrompt,
                config: {
                    systemInstruction: prompt.systemPrompt,
                    temperature: 0.1, // Low temperature for deterministic evaluation
                    responseMimeType: 'application/json',
                },
            });
            const rawText = response.text || '{}';
            const parsed = (0, repair_hook_1.safeParseJson)(rawText);
            const validated = schemas_1.ClassifiedOutputSchema.parse(parsed);
            return validated;
        }
        catch (err) {
            const error = err;
            throw new Error(`AI Code Review inference failed: ${error.message}`);
        }
    }
}
exports.LLMReviewClient = LLMReviewClient;
