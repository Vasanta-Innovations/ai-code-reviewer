import { z } from 'zod';

export const FINDING_SEVERITIES = ['blocking', 'important', 'minor'] as const;
export const FindingSeveritySchema = z.enum(FINDING_SEVERITIES);
export type FindingSeverity = z.infer<typeof FindingSeveritySchema>;

export const FINDING_ISSUE_TYPES = [
  'bug',
  'security',
  'concurrency',
  'data',
  'api',
  'perf',
  'test_gap',
  'doc_defect',
  'style'
] as const;
export const FindingIssueTypeSchema = z.enum(FINDING_ISSUE_TYPES);
export type FindingIssueType = z.infer<typeof FindingIssueTypeSchema>;

export const FindingEvidenceSchema = z.object({
  trigger: z.string().min(1).describe('The input, state, or sequence that triggers the defect.'),
  consequence: z.string().min(1).describe('What breaks when triggered (e.g. data loss, crash, auth bypass).'),
  code_checked: z.string().min(1).describe('Specific files and line ranges inspected to confirm this defect.'),
});
export type FindingEvidence = z.infer<typeof FindingEvidenceSchema>;

export const ClassifiedFindingSchema = z.object({
  title: z.string().min(1).describe('Single concise line naming the issue.'),
  comment: z.string().min(1).describe('Markdown explanation shown to PR author.'),
  file_path: z.string().optional().describe('Must match a file changed in the PR diff. Omit for PR-level.'),
  line_number: z.number().int().positive().optional().describe('Line number in the diff. Omit for file/PR-level.'),
  severity: FindingSeveritySchema,
  issue_type: FindingIssueTypeSchema,
  evidence: FindingEvidenceSchema,
  suggested_fix: z.string().optional().describe('Concrete code replacement or fix guidance.'),
  rule: z.string().optional().describe('Cited repository guideline or rule.'),
});
export type ClassifiedFinding = z.infer<typeof ClassifiedFindingSchema>;

export const ClassifiedOutputSchema = z.object({
  comments: z.array(ClassifiedFindingSchema).describe('List of findings. Empty array if clean.'),
});
export type ClassifiedOutput = z.infer<typeof ClassifiedOutputSchema>;

// Golden dataset schema for benchmark evaluation
export const GoldenCommentSchema = z.object({
  comment: z.string().min(1),
  file_path: z.string().optional(),
  line_number: z.number().int().positive().optional(),
  severity: FindingSeveritySchema.optional(),
  issue_type: FindingIssueTypeSchema.optional(),
});
export type GoldenComment = z.infer<typeof GoldenCommentSchema>;

export const GoldenDatasetEntrySchema = z.object({
  pr_id: z.string().min(1),
  approved: z.boolean().describe('Human ground truth: should this PR merge?'),
  base: z.string().optional(),
  head: z.string().optional(),
  comments: z.array(GoldenCommentSchema).default([]),
});
export type GoldenDatasetEntry = z.infer<typeof GoldenDatasetEntrySchema>;
