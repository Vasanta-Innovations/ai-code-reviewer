import fs from 'fs';
import path from 'path';
import { ClassifiedFinding, GoldenComment } from '../src/validation/schemas';
import { matchFindingToGolden } from './judge/semantic-matcher';
import { deriveVerdict } from '../src/validation/verdict-engine';

interface GoldenPr {
  pr_id: string;
  title: string;
  approved: boolean;
  diff: string;
  comments: GoldenComment[];
}

export interface BenchmarkMetrics {
  totalPrs: number;
  truePositives: number;
  falsePositives: number;
  falseNegatives: number;
  precision: number;
  recall: number;
  f1Score: number;
  verdictAccuracy: number;
  overBlockingRate: number;
}

/**
 * Runs evaluation metrics over a test run against the golden dataset.
 */
export async function evaluateRun(
  predictedReviews: Map<string, ClassifiedFinding[]>,
  apiKey?: string
): Promise<BenchmarkMetrics> {
  const datasetPath = path.join(__dirname, 'datasets', 'golden-prs.json');
  const rawData = fs.readFileSync(datasetPath, 'utf8');
  const goldenPrs: GoldenPr[] = JSON.parse(rawData);

  let tp = 0;
  let fp = 0;
  let fn = 0;
  let correctVerdicts = 0;
  let overBlocked = 0;

  for (const pr of goldenPrs) {
    const candidateFindings = predictedReviews.get(pr.pr_id) || [];
    const matchedGoldenIndices = new Set<number>();

    for (const finding of candidateFindings) {
      let isCandidateMatched = false;

      for (let i = 0; i < pr.comments.length; i++) {
        if (matchedGoldenIndices.has(i)) continue;
        const golden = pr.comments[i];
        const match = await matchFindingToGolden(finding, golden, apiKey);
        if (match.matched) {
          matchedGoldenIndices.add(i);
          isCandidateMatched = true;
          tp++;
          break;
        }
      }

      if (!isCandidateMatched) {
        fp++;
      }
    }

    // Unmatched golden comments are False Negatives
    const unmatched = pr.comments.length - matchedGoldenIndices.size;
    fn += unmatched;

    // Evaluate verdict accuracy
    const derived = deriveVerdict(candidateFindings, 'minor_only');
    if (derived.approved === pr.approved) {
      correctVerdicts++;
    } else if (!derived.approved && pr.approved) {
      overBlocked++;
    }
  }

  const precision = tp + fp > 0 ? tp / (tp + fp) : 1.0;
  const recall = tp + fn > 0 ? tp / (tp + fn) : 1.0;
  const f1Score = precision + recall > 0 ? (2 * precision * recall) / (precision + recall) : 0.0;
  const verdictAccuracy = goldenPrs.length > 0 ? correctVerdicts / goldenPrs.length : 1.0;
  const overBlockingRate = goldenPrs.length > 0 ? overBlocked / goldenPrs.length : 0.0;

  return {
    totalPrs: goldenPrs.length,
    truePositives: tp,
    falsePositives: fp,
    falseNegatives: fn,
    precision,
    recall,
    f1Score,
    verdictAccuracy,
    overBlockingRate,
  };
}

// Standalone execution
if (require.main === module) {
  console.log('--- Ground Truth AI Review Benchmark ---');
  console.log('Loading golden dataset...');

  // Mock test review to verify benchmark harness
  const mockPredictions = new Map<string, ClassifiedFinding[]>([
    [
      'pr-101-auth-bypass',
      [
        {
          title: 'SQL injection on admin endpoint',
          comment: 'User input concatenated directly into query',
          file_path: 'src/controllers/admin.ts',
          line_number: 15,
          severity: 'blocking',
          issue_type: 'security',
          evidence: {
            trigger: 'userId passed with SQL payload',
            consequence: 'Unauthorized data access',
            code_checked: 'src/controllers/admin.ts:12-18',
          },
        },
      ],
    ],
    [
      'pr-102-null-dereference',
      [
        {
          title: 'Potential null pointer dereference',
          comment: 'order.customer.address is dereferenced without check',
          file_path: 'src/services/shipping.ts',
          line_number: 26,
          severity: 'blocking',
          issue_type: 'bug',
          evidence: {
            trigger: 'Digital orders with null address',
            consequence: 'Unhandled runtime TypeError',
            code_checked: 'src/services/shipping.ts:24-27',
          },
        },
      ],
    ],
    ['pr-104-clean-refactor', []],
  ]);

  evaluateRun(mockPredictions).then(metrics => {
    console.log(`Evaluated ${metrics.totalPrs} PRs:`);
    console.log(`  True Positives:  ${metrics.truePositives}`);
    console.log(`  False Positives: ${metrics.falsePositives}`);
    console.log(`  False Negatives: ${metrics.falseNegatives}`);
    console.log(`  Precision:       ${(metrics.precision * 100).toFixed(1)}%`);
    console.log(`  Recall:          ${(metrics.recall * 100).toFixed(1)}%`);
    console.log(`  F1 Score:        ${(metrics.f1Score * 100).toFixed(1)}%`);
    console.log(`  Verdict Accuracy:${(metrics.verdictAccuracy * 100).toFixed(1)}%`);
    console.log(`  Over-blocking:   ${(metrics.overBlockingRate * 100).toFixed(1)}%`);
    console.log('--- Benchmark Complete ---');
  });
}
