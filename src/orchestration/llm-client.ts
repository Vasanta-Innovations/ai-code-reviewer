import { GoogleGenAI } from '@google/genai';
import { SeparatedPrompt } from './trust-boundary';
import { ClassifiedOutput, ClassifiedOutputSchema } from '../validation/schemas';
import { safeParseJson } from '../validation/repair-hook';

export interface LLMReviewerOptions {
  apiKey?: string;
  model: string;
}

export class LLMReviewClient {
  private client: GoogleGenAI | null = null;
  private model: string;

  constructor(options: LLMReviewerOptions) {
    this.model = options.model || 'gemini-1.5-flash';
    if (options.apiKey) {
      this.client = new GoogleGenAI({ apiKey: options.apiKey });
    }
  }

  async executeReview(prompt: SeparatedPrompt): Promise<ClassifiedOutput> {
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
      const parsed = safeParseJson<unknown>(rawText);
      const validated = ClassifiedOutputSchema.parse(parsed);

      return validated;
    } catch (err: unknown) {
      const error = err as Error;
      throw new Error(`AI Code Review inference failed: ${error.message}`);
    }
  }
}
