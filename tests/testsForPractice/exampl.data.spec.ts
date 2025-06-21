import { test, expect } from '../fixtures/fixtures';
import testData from '../data/users.json'
import fs from 'fs';

test('test with using fixture', async ({ testUsers, testProducts }) => {
    console.log(testUsers.admin.username);
    console.log(testProducts.product1.name);
});

test('test with using json', async ({ testUsers }, testInfo) => {
    const user = testData.users.find(user => user.role === 'admin');
    console.log(user);
});

test('test with using fs', async ({ testUsers }, testInfo) => {

    // save
    testInfo.annotations.push({ type: 'generated-id', description: 'user-123' });

    // create file
    const tempFilePath = testInfo.outputPath('temp-data.json');
    fs.writeFileSync(tempFilePath, JSON.stringify({ timestamp: Date.now() }));

    // read file
    const userId = testInfo.annotations.find(a => a.type === 'generated-id')?.description;
    console.log(`Using generated user ID: ${userId}`);
});