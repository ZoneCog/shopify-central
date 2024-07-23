import assert from 'assert';
import fs from 'fs';
import path from 'path';

export default function() {
  it('should only add comment to one file', () => {
    const expect = fs.readFileSync(path.join(__dirname, 'fixtures', 'expect-transpile-file'), 'utf8');

    // it's dumb but for some reason on circle transpiling folders via babel does not exit process
    // properly with child_process.spawn/exec so we're instead building the file below using an npm script
    const result = fs.readFileSync(path.join(__dirname, 'outManyFile.js'));

    assert(result, expect, 'output matched');
  });
}
