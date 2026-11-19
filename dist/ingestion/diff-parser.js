"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseUnifiedDiff = parseUnifiedDiff;
exports.isLineInDiff = isLineInDiff;
/**
 * Lightweight parser for unified diff text.
 * Extracts list of changed files and line numbers changed in the diff.
 */
function parseUnifiedDiff(rawDiff) {
    const changedFiles = [];
    const validLines = new Map();
    const lines = rawDiff.split('\n');
    let currentFile = null;
    let currentNewLine = 0;
    for (const line of lines) {
        // Detect file header: +++ b/path/to/file.ext or +++ path/to/file.ext
        if (line.startsWith('+++ ')) {
            let filePath = line.substring(4).trim();
            if (filePath.startsWith('b/')) {
                filePath = filePath.substring(2);
            }
            if (filePath !== '/dev/null') {
                currentFile = filePath;
                if (!changedFiles.includes(currentFile)) {
                    changedFiles.push(currentFile);
                }
                if (!validLines.has(currentFile)) {
                    validLines.set(currentFile, new Set());
                }
            }
            continue;
        }
        // Detect hunk header: @@ -10,5 +12,8 @@
        if (line.startsWith('@@') && currentFile) {
            const match = line.match(/@@ -\d+(?:,\d+)? \+(\d+)(?:,\d+)? @@/);
            if (match && match[1]) {
                currentNewLine = parseInt(match[1], 10);
            }
            continue;
        }
        if (currentFile && currentNewLine > 0) {
            if (line.startsWith('+')) {
                validLines.get(currentFile)?.add(currentNewLine);
                currentNewLine++;
            }
            else if (line.startsWith('-')) {
                // Line removed, does not increment new file line counter
            }
            else {
                // Context line
                validLines.get(currentFile)?.add(currentNewLine);
                currentNewLine++;
            }
        }
    }
    return {
        changedFiles,
        validLines,
        rawDiff,
    };
}
/**
 * Validates if an inline comment targets a line present within the PR diff.
 * Invariant: Prevents GitHub API 422 Unprocessable Entity errors.
 */
function isLineInDiff(parsedDiff, filePath, lineNumber) {
    if (!filePath || !lineNumber)
        return false;
    const fileLines = parsedDiff.validLines.get(filePath);
    if (!fileLines)
        return false;
    return fileLines.has(lineNumber);
}
