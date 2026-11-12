// Stands for a test file that takes a while: it waits until the file "gate" exists.
const fs = require('fs');
const path = require('path');
const gate = path.join(__dirname, '..', 'gate');

test('slow', async () => {
  fs.appendFileSync(path.join(__dirname, '..', 'marks.log'), 'slow started\n');
  while (!fs.existsSync(gate)) await new Promise((resolve) => setTimeout(resolve, 20));
}, 600000);
