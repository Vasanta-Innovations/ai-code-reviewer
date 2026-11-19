import { ClassifiedFinding, GoldenComment } from '../../src/validation/schemas';
import { GoogleGenAI } from '@google/genai';

export interface MatchResult {
  matched: boolean;
  score: number; // 0.0 to 1.0
  reasoning: string;
}

/**
 * Evaluates whether an AI reviewer finding correctly identified a golden defect.
 * Uses Gemini LLM-as-a-judge if GEMINI_API_KEY is available, falling back to
 * lexical/location overlap for fast offline testing.
 */
export async function matchFindingToGolden(
  candidate: ClassifiedFinding,
  golden: GoldenComment,
  apiKey?: string
): Promise<MatchResult> {
  // If file path matches and line numbers are within +/- 3 lines, strong candidate
  const fileMatches = !candidate.file_path || !golden.file_path || candidate.file_path === golden.file_path;
  const lineDelta = (candidate.line_number !== undefined && golden.line_number !== undefined)
    ? Math.abs(candidate.line_number - golden.line_number)
    : 0;
  const locationClose = fileMatches && lineDelta <= 3;

  if (apiKey) {
    try {
      const ai = new GoogleGenAI({ apiKey });
      const prompt = `You are an expert code review evaluation judge.
Determine if the Candidate Finding describes the SAME core defect as the Ground Truth Finding.

GROUND TRUTH DEFECT:
File: ${golden.file_path || 'N/A'}
Line: ${golden.line_number || 'N/A'}
Severity: ${golden.severity || 'N/A'}
Issue Type: ${golden.issue_type || 'N/A'}
Comment: ${golden.comment}

CANDIDATE AI FINDING:
File: ${candidate.file_path || 'N/A'}
Line: ${candidate.line_number || 'N/A'}
Severity: ${candidate.severity}
Issue Type: ${candidate.issue_type}
Title: ${candidate.title}
Comment: ${candidate.comment}
Evidence: ${JSON.stringify(candidate.evidence)}

Answer in JSON:
{
  "matched": true | false,
  "score": number between 0.0 and 1.0,
  "reasoning": "brief explanation"
}`;

      const response = await ai.models.generateContent({
        model: 'gemini-2.5-flash',
        contents: prompt,
        config: {
          responseMimeType: 'application/json'
        }
      });

      const text = response.text?.trim() || '{}';
      const parsed = JSON.parse(text);
      return {
        matched: Boolean(parsed.matched),
        score: typeof parsed.score === 'number' ? parsed.score : (parsed.matched ? 1.0 : 0.0),
        reasoning: parsed.reasoning || 'Evaluated via Gemini judge',
      };
    } catch {
      // Fallback to lexical matching below
    }
  }

  // Fast deterministic fallback (offline / unit testing)
  const candidateWords = new Set(
    `${candidate.title} ${candidate.comment} ${candidate.issue_type}`.toLowerCase().split(/\W+/).filter(w => w.length > 3)
  );
  const goldenWords = golden.comment.toLowerCase().split(/\W+/).filter(w => w.length > 3);
  let overlapCount = 0;
  for (const word of goldenWords) {
    if (candidateWords.has(word)) overlapCount++;
  }

  const lexicalOverlap = goldenWords.length > 0 ? overlapCount / goldenWords.length : 0;
  const matched = locationClose && (lexicalOverlap >= 0.25 || candidate.issue_type === golden.issue_type);

  return {
    matched,
    score: matched ? (locationClose ? 0.9 : 0.6) : 0.1,
    reasoning: `Offline heuristic: locationClose=${locationClose}, lexicalOverlap=${lexicalOverlap.toFixed(2)}`
  };
}
