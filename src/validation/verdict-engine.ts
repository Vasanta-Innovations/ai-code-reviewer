import { ClassifiedFinding } from './schemas';
import { ApprovalPreset } from '../config';

export type Verdict = 'APPROVE' | 'COMMENT' | 'REQUEST_CHANGES';

export interface VerdictResult {
  verdict: Verdict;
  approved: boolean;
  blockingCount: number;
  importantCount: number;
  minorCount: number;
  totalFindings: number;
}

/**
 * Deterministically derives the review verdict and approval boolean.
 * Invariant: The LLM NEVER outputs 'approved: true/false'. The framework computes it.
 */
export function deriveVerdict(
  findings: readonly ClassifiedFinding[],
  preset: ApprovalPreset = 'minor_only'
): VerdictResult {
  const blockingCount = findings.filter(f => f.severity === 'blocking').length;
  const importantCount = findings.filter(f => f.severity === 'important').length;
  const minorCount = findings.filter(f => f.severity === 'minor').length;
  const totalFindings = findings.length;

  let verdict: Verdict = 'APPROVE';

  if (preset === 'minor_only') {
    if (blockingCount > 0) {
      verdict = 'REQUEST_CHANGES';
    } else if (importantCount > 0) {
      verdict = 'COMMENT';
    } else {
      verdict = 'APPROVE';
    }
  } else if (preset === 'no_blocking') {
    verdict = blockingCount > 0 ? 'REQUEST_CHANGES' : 'APPROVE';
  } else if (preset === 'no_comments') {
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
