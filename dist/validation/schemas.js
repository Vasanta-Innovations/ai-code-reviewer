"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GoldenDatasetEntrySchema = exports.GoldenCommentSchema = exports.ClassifiedOutputSchema = exports.ClassifiedFindingSchema = exports.FindingEvidenceSchema = exports.FindingIssueTypeSchema = exports.FINDING_ISSUE_TYPES = exports.FindingSeveritySchema = exports.FINDING_SEVERITIES = void 0;
const zod_1 = require("zod");
exports.FINDING_SEVERITIES = ['blocking', 'important', 'minor'];
exports.FindingSeveritySchema = zod_1.z.enum(exports.FINDING_SEVERITIES);
exports.FINDING_ISSUE_TYPES = [
    'bug',
    'security',
    'concurrency',
    'data',
    'api',
    'perf',
    'test_gap',
    'doc_defect',
    'style'
];
exports.FindingIssueTypeSchema = zod_1.z.enum(exports.FINDING_ISSUE_TYPES);
exports.FindingEvidenceSchema = zod_1.z.object({
    trigger: zod_1.z.string().min(1).describe('The input, state, or sequence that triggers the defect.'),
    consequence: zod_1.z.string().min(1).describe('What breaks when triggered (e.g. data loss, crash, auth bypass).'),
    code_checked: zod_1.z.string().min(1).describe('Specific files and line ranges inspected to confirm this defect.'),
});
exports.ClassifiedFindingSchema = zod_1.z.object({
    title: zod_1.z.string().min(1).describe('Single concise line naming the issue.'),
    comment: zod_1.z.string().min(1).describe('Markdown explanation shown to PR author.'),
    file_path: zod_1.z.string().optional().describe('Must match a file changed in the PR diff. Omit for PR-level.'),
    line_number: zod_1.z.number().int().positive().optional().describe('Line number in the diff. Omit for file/PR-level.'),
    severity: exports.FindingSeveritySchema,
    issue_type: exports.FindingIssueTypeSchema,
    evidence: exports.FindingEvidenceSchema,
    suggested_fix: zod_1.z.string().optional().describe('Concrete code replacement or fix guidance.'),
    rule: zod_1.z.string().optional().describe('Cited repository guideline or rule.'),
});
exports.ClassifiedOutputSchema = zod_1.z.object({
    comments: zod_1.z.array(exports.ClassifiedFindingSchema).describe('List of findings. Empty array if clean.'),
});
// Golden dataset schema for benchmark evaluation
exports.GoldenCommentSchema = zod_1.z.object({
    comment: zod_1.z.string().min(1),
    file_path: zod_1.z.string().optional(),
    line_number: zod_1.z.number().int().positive().optional(),
    severity: exports.FindingSeveritySchema.optional(),
    issue_type: exports.FindingIssueTypeSchema.optional(),
});
exports.GoldenDatasetEntrySchema = zod_1.z.object({
    pr_id: zod_1.z.string().min(1),
    approved: zod_1.z.boolean().describe('Human ground truth: should this PR merge?'),
    base: zod_1.z.string().optional(),
    head: zod_1.z.string().optional(),
    comments: zod_1.z.array(exports.GoldenCommentSchema).default([]),
});
