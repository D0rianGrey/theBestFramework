import { test as base, Page } from '@playwright/test';

// Тестовые данные
const testUsers = {
    admin: { username: 'admin', password: 'admin123' },
    customer: { username: 'customer', password: 'customer123' }
};

// Тестовые продукты
const testProducts = {
    product1: { id: 'prod-1', name: 'Продукт 1', price: 19.99 },
    product2: { id: 'prod-2', name: 'Продукт 2', price: 29.99 }
};

// Определяем типы для наших фикстур
type TestFixtures = {
    testUsers: typeof testUsers;
    testProducts: typeof testProducts;
};

export const test = base.extend<TestFixtures>({
    
    // Фикстура для тестовых пользователей
    testUsers: async ({ }, use) => {
        await use(testUsers);
    },

    // Фикстура для тестовых продуктов
    testProducts: async ({ }, use) => {
        await use(testProducts);
    }
});

export { expect } from '@playwright/test';
