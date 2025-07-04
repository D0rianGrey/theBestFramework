# Technical Context

## Technology Stack
- **Primary Language**: TypeScript
- **Test Framework**: Playwright
- **Runtime**: Node.js
- **Package Manager**: npm
- **Configuration**: TypeScript configuration files

## Development Environment
- **Platform**: Cross-platform (Windows, macOS, Linux)
- **Container Support**: Docker
- **CI/CD Ready**: Environment variable configuration
- **Parallel Execution**: Supported via Playwright configuration

## Current Configuration
- **Test Directory**: `./tests`
- **Parallel Execution**: Enabled (`fullyParallel: true`)
- **Browser**: Chromium (Desktop Chrome device emulation)
- **Reporting**: HTML reports
- **Traces**: On first retry for debugging
- **Headless Mode**: Conditional (based on CI environment)

## Architecture Patterns
- Page Object Model structure in `/tests/pages/`
- Fixtures pattern in `/tests/fixtures/`
- Data-driven testing with `/tests/data/`
- Utility functions in `/tests/utils/`
- Separation of UI and API tests

## Integration Points
- Environment variables via `.env` file
- Base URL configuration for testing environments
- Docker container detection for execution context
- Cross-platform script execution support
