"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.loadPullRequest = loadPullRequest;
const github = __importStar(require("@actions/github"));
const diff_parser_1 = require("./diff-parser");
async function loadPullRequest(octokit) {
    const context = github.context;
    if (!context.payload.pull_request) {
        throw new Error('This action can only run on pull_request events.');
    }
    const { owner, repo } = context.repo;
    const pullNumber = context.payload.pull_request.number;
    const title = context.payload.pull_request.title || '';
    const author = context.payload.pull_request.user?.login || 'unknown';
    const baseSha = context.payload.pull_request.base?.sha || '';
    const headSha = context.payload.pull_request.head?.sha || '';
    const htmlUrl = context.payload.pull_request.html_url || '';
    // Fetch the unified diff from GitHub API
    const response = await octokit.rest.pulls.get({
        owner,
        repo,
        pull_number: pullNumber,
        mediaType: {
            format: 'diff',
        },
    });
    const rawDiff = response.data;
    const parsedDiff = (0, diff_parser_1.parseUnifiedDiff)(rawDiff);
    return {
        owner,
        repo,
        pullNumber,
        title,
        author,
        baseSha,
        headSha,
        htmlUrl,
        parsedDiff,
    };
}
