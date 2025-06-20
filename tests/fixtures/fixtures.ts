import { test as base, Page } from '@playwright/test';

// Тестовые данные
const testUsers = {
    admin: { username: 'admin', password: 'admin123' },
    customer: { username: 'customer', password: 'customer123' }
};

// Определяем типы для наших фикстур
type TestFixtures = {
    testUsers: typeof testUsers;
};

export const test = base.extend<TestFixtures>({
    // Фикстура для тестовых пользователей
    testUsers: async ({ }, use) => {
        await use(testUsers);
    },
});

export { expect } from '@playwright/test';
