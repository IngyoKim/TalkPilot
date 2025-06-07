import { defineConfig, mergeConfig } from 'vitest/config';
import viteConfig from './vite.config.js';

export default mergeConfig(viteConfig, defineConfig({
    test: {
        globals: true,
        environment: 'jsdom',
        coverage: {
            provider: 'v8',
            reportsDirectory: './coverage',
            reporter: ['text', 'html', 'lcov'],
            include: ['src/pages/**/*.{js,jsx,ts,tsx}'],
            exclude: ['**/*.test.*', 'src/main.*', 'src/index.*'],
            all: false,
        },
    },
}));
