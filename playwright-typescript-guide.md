# Справочник Playwright + TypeScript для написания тестов

## 🚀 Базовая структура теста

```typescript
import { test, expect } from '@playwright/test';

test('базовый тест', async ({ page }) => {
  await page.goto('https://example.com');
  await expect(page).toHaveTitle(/Example/);
});
```

## 📝 Основные методы Page

### Навигация
```typescript
// Переход на страницу
await page.goto('https://example.com');
await page.goto('/relative-path');

// Навигация
await page.goBack();
await page.goForward();
await page.reload();
```

### Поиск элементов
```typescript
// По селектору
const button = page.locator('button');
const input = page.locator('#username');
const element = page.locator('.class-name');

// По тексту
const link = page.getByText('Войти');
const exactText = page.getByText('Войти', { exact: true });

// По роли
const button = page.getByRole('button', { name: 'Отправить' });
const textbox = page.getByRole('textbox', { name: 'Email' });

// По placeholder
const input = page.getByPlaceholder('Введите email');

// По label
const input = page.getByLabel('Пароль');

// По test-id
const element = page.getByTestId('submit-button');
```

## 🎯 Взаимодействие с элементами

```typescript
// Клики
await page.click('button');
await page.dblclick('button');
await page.click('button', { button: 'right' }); // правый клик

// Ввод текста
await page.fill('#username', 'admin');
await page.type('#password', 'secret', { delay: 100 });

// Очистка поля
await page.fill('#input', '');

// Нажатие клавиш
await page.press('#input', 'Enter');
await page.press('#input', 'Control+A');

// Выбор в select
await page.selectOption('#country', 'Russia');
await page.selectOption('#country', { label: 'Россия' });

// Чекбоксы и радиокнопки
await page.check('#agree');
await page.uncheck('#newsletter');

// Загрузка файлов
await page.setInputFiles('#file', 'path/to/file.pdf');
await page.setInputFiles('#files', ['file1.txt', 'file2.txt']);
```

## ✅ Assertions (Проверки)

### Проверки страницы
```typescript
// URL
await expect(page).toHaveURL('https://example.com/dashboard');
await expect(page).toHaveURL(/dashboard/);

// Заголовок
await expect(page).toHaveTitle('Dashboard');
await expect(page).toHaveTitle(/Dashboard/);
```

### Проверки элементов
```typescript
const element = page.locator('#element');

// Видимость
await expect(element).toBeVisible();
await expect(element).toBeHidden();

// Текст
await expect(element).toHaveText('Ожидаемый текст');
await expect(element).toContainText('часть текста');

// Значения
await expect(page.locator('#input')).toHaveValue('значение');

// Атрибуты
await expect(element).toHaveAttribute('class', 'active');
await expect(element).toHaveClass('btn btn-primary');

// Состояния
await expect(page.locator('#checkbox')).toBeChecked();
await expect(page.locator('#button')).toBeEnabled();
await expect(page.locator('#button')).toBeDisabled();

// Количество элементов
await expect(page.locator('.item')).toHaveCount(5);
```

## 🔄 Ожидания (Waits)

```typescript
// Ожидание элемента
await page.waitForSelector('#element');
await page.waitForSelector('#element', { state: 'visible' });

// Ожидание URL
await page.waitForURL('**/dashboard');

// Ожидание загрузки
await page.waitForLoadState('networkidle');
await page.waitForLoadState('domcontentloaded');

// Ожидание функции
await page.waitForFunction(() => window.innerWidth < 100);

// Ожидание события
await page.waitForEvent('response');

// Таймауты
await page.waitForSelector('#element', { timeout: 5000 });
```

## 🎭 Работа с фреймами и окнами

```typescript
// Новые вкладки/окна
const [newPage] = await Promise.all([
  context.waitForEvent('page'),
  page.click('a[target="_blank"]')
]);

// Iframe
const frame = page.frameLocator('#iframe');
await frame.locator('#button').click();
```

## 📊 Группировка тестов

```typescript
import { test, expect } from '@playwright/test';

test.describe('Группа тестов авторизации', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/login');
  });

  test('успешная авторизация', async ({ page }) => {
    await page.fill('#username', 'admin');
    await page.fill('#password', 'password');
    await page.click('#login');
    await expect(page).toHaveURL('/dashboard');
  });

  test('неверные данные', async ({ page }) => {
    await page.fill('#username', 'wrong');
    await page.fill('#password', 'wrong');
    await page.click('#login');
    await expect(page.locator('.error')).toBeVisible();
  });
});
```

## 🔧 Хуки (Hooks)

```typescript
test.beforeAll(async () => {
  // Выполняется один раз перед всеми тестами
});

test.afterAll(async () => {
  // Выполняется один раз после всех тестов
});

test.beforeEach(async ({ page }) => {
  // Выполняется перед каждым тестом
  await page.goto('/');
});

test.afterEach(async ({ page }) => {
  // Выполняется после каждого теста
});
```

## 🎨 Фикстуры (Fixtures)

```typescript
// Создание кастомных фикстур
import { test as base } from '@playwright/test';

type TestFixtures = {
  authenticatedPage: Page;
};

export const test = base.extend<TestFixtures>({
  authenticatedPage: async ({ page }, use) => {
    await page.goto('/login');
    await page.fill('#username', 'admin');
    await page.fill('#password', 'password');
    await page.click('#login');
    await page.waitForURL('/dashboard');
    await use(page);
  }
});

// Использование
test('тест с авторизацией', async ({ authenticatedPage }) => {
  await expect(authenticatedPage).toHaveURL('/dashboard');
});
```

## 📱 Мобильная эмуляция

```typescript
import { test, devices } from '@playwright/test';

test.use({ ...devices['iPhone 12'] });

test('мобильный тест', async ({ page }) => {
  await page.goto('/');
  // Тест для мобильного устройства
});
```

## 🖼️ Скриншоты

```typescript
// Скриншот страницы
await page.screenshot({ path: 'screenshot.png' });

// Скриншот элемента
await page.locator('#element').screenshot({ path: 'element.png' });

// Полная страница
await page.screenshot({ path: 'full.png', fullPage: true });
```

## 🌐 Работа с API

```typescript
test('API тест', async ({ request }) => {
  const response = await request.get('/api/users');
  expect(response.status()).toBe(200);
  
  const data = await response.json();
  expect(data.users).toHaveLength(10);
});

// POST запрос
test('создание пользователя', async ({ request }) => {
  const response = await request.post('/api/users', {
    data: {
      name: 'John Doe',
      email: 'john@example.com'
    }
  });
  expect(response.status()).toBe(201);
});
```

## 🔍 Отладка

```typescript
// Пауза для отладки
await page.pause();

// Консольные логи
page.on('console', msg => console.log(msg.text()));

// Логирование запросов
page.on('request', request => 
  console.log(request.method(), request.url())
);
```

## ⚡ Полезные паттерны

### Page Object Model
```typescript
export class LoginPage {
  constructor(private page: Page) {}

  async login(username: string, password: string) {
    await this.page.fill('#username', username);
    await this.page.fill('#password', password);
    await this.page.click('#login');
  }

  async getErrorMessage() {
    return await this.page.locator('.error').textContent();
  }
}

// Использование
test('логин через POM', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await page.goto('/login');
  await loginPage.login('admin', 'password');
});
```

### Параметризованные тесты
```typescript
const testData = [
  { username: 'admin', password: 'admin123', expected: '/dashboard' },
  { username: 'user', password: 'user123', expected: '/profile' }
];

testData.forEach(({ username, password, expected }) => {
  test(`логин для ${username}`, async ({ page }) => {
    await page.goto('/login');
    await page.fill('#username', username);
    await page.fill('#password', password);
    await page.click('#login');
    await expect(page).toHaveURL(expected);
  });
});
```

## 🎯 Лучшие практики

1. **Используйте data-testid** для стабильных селекторов
2. **Группируйте связанные тесты** в describe блоки
3. **Создавайте переиспользуемые фикстуры** для общих сценариев
4. **Используйте Page Object Model** для сложных страниц
5. **Добавляйте явные ожидания** вместо sleep
6. **Изолируйте тесты** - каждый тест должен быть независимым

## 🚨 Обработка ошибок и исключений

```typescript
// Мягкие проверки (не останавливают тест)
await expect.soft(page.locator('#optional')).toBeVisible();

// Условные проверки
const element = page.locator('#element');
if (await element.isVisible()) {
  await element.click();
}

// Try-catch для обработки ошибок
try {
  await page.waitForSelector('#element', { timeout: 5000 });
} catch (error) {
  console.log('Элемент не найден');
}
```

## 🔄 Повторы и условная логика

```typescript
// Повторы для конкретного теста
test.describe.configure({ retries: 2 });

test('нестабильный тест', async ({ page }) => {
  // Тест с повторами
});

// Пропуск тестов
test.skip('пропустить этот тест', async ({ page }) => {
  // Этот тест не будет выполнен
});

// Условный пропуск
test('условный тест', async ({ page, browserName }) => {
  test.skip(browserName === 'webkit', 'Не работает в Safari');
  // Тест
});
```

## 📋 Типы данных и интерфейсы

```typescript
// Интерфейсы для тестовых данных
interface User {
  username: string;
  password: string;
  role: 'admin' | 'user' | 'guest';
}

interface TestData {
  users: User[];
  urls: {
    login: string;
    dashboard: string;
  };
}

// Использование типов
const testData: TestData = {
  users: [
    { username: 'admin', password: 'admin123', role: 'admin' }
  ],
  urls: {
    login: '/login',
    dashboard: '/dashboard'
  }
};
```

## 🎪 Продвинутые техники

```typescript
// Перехват сетевых запросов
test('перехват API', async ({ page }) => {
  await page.route('/api/users', route => {
    route.fulfill({
      status: 200,
      body: JSON.stringify({ users: [] })
    });
  });

  await page.goto('/users');
});

// Работа с localStorage
test('localStorage', async ({ page }) => {
  await page.goto('/');

  // Установка значения
  await page.evaluate(() => {
    localStorage.setItem('token', 'abc123');
  });

  // Получение значения
  const token = await page.evaluate(() => {
    return localStorage.getItem('token');
  });

  expect(token).toBe('abc123');
});

// Работа с cookies
test('cookies', async ({ page, context }) => {
  // Установка cookie
  await context.addCookies([{
    name: 'session',
    value: 'abc123',
    domain: 'example.com',
    path: '/'
  }]);

  await page.goto('/');

  // Получение cookies
  const cookies = await context.cookies();
  expect(cookies).toHaveLength(1);
});
```

## 📊 Конфигурация TypeScript

```typescript
// playwright.config.ts
import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests',
  timeout: 30000,
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: 'http://localhost:3000',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],
});
```

## 🎨 Кастомные матчеры

```typescript
// Расширение expect
expect.extend({
  async toHaveValidEmail(received: Locator) {
    const value = await received.inputValue();
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

    return {
      pass: emailRegex.test(value),
      message: () => `Expected ${value} to be a valid email`
    };
  }
});

// Использование
await expect(page.locator('#email')).toHaveValidEmail();
```

## 🔧 Утилиты и хелперы

```typescript
// Утилитарные функции
export class TestUtils {
  static async waitForPageLoad(page: Page) {
    await page.waitForLoadState('networkidle');
  }

  static generateRandomEmail(): string {
    return `test${Date.now()}@example.com`;
  }

  static async clearAndFill(page: Page, selector: string, text: string) {
    await page.fill(selector, '');
    await page.fill(selector, text);
  }
}

// Использование
test('с утилитами', async ({ page }) => {
  await page.goto('/');
  await TestUtils.waitForPageLoad(page);

  const email = TestUtils.generateRandomEmail();
  await TestUtils.clearAndFill(page, '#email', email);
});
```

## 💡 Советы по производительности

1. **Используйте `page.locator()`** вместо `page.$()` для лучшей типизации
2. **Группируйте селекторы** в константы для переиспользования
3. **Используйте `test.step()`** для структурирования сложных тестов
4. **Настройте правильные таймауты** для стабильности
5. **Используйте параллельное выполнение** для ускорения тестов
