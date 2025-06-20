import { test, expect } from './fixtures/fixtures';
import testData from './data/users.json'
import fs from 'fs';

test('fixture', async ({ testUsers }) => {
    console.log(testUsers.admin.username);
});

test('json', async ({ testUsers }, testInfo) => {
    const user = testData.users.find(user => user.role === 'admin');
    console.log(user);
});

test('fs', async ({ testUsers }, testInfo) => {

    // save
    testInfo.annotations.push({ type: 'generated-id', description: 'user-123' });

    // create file
    const tempFilePath = testInfo.outputPath('temp-data.json');
    fs.writeFileSync(tempFilePath, JSON.stringify({ timestamp: Date.now() }));


    // read
    const userId = testInfo.annotations.find(a => a.type === 'generated-id')?.description;
    console.log(`Using generated user ID: ${userId}`);
});