const fs = require('fs');
const path = require('path');

test('B1', async () => {
  await new Promise((resolve) => setTimeout(resolve, 300));
  fs.appendFileSync(path.join(__dirname, '..', 'marks.log'), 'b ran B1\n');
});
