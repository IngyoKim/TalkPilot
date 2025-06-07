// vitest.config.js
import { defineConfig, mergeConfig } from 'vitest/config'
import baseConfig from './vite.config.js'

export default mergeConfig(
    baseConfig,
    defineConfig({
        test: {
            globals: true,
            environment: 'jsdom',
            coverage: {
                provider: 'v8',                   // 또는 빌드 환경 문제 시 'istanbul' 사용
                reportsDirectory: './coverage',
                reporter: ['text', 'text-summary', 'html'],
                all: false,                         // include 패턴에 걸린 파일 모두 0%라도 찍는다
                include: [
                    'src/**/*.{js,jsx,ts,tsx}',     // src 내부 전부
                ],
                exclude: [
                    'src/**/*.d.ts',                // 선언 파일
                    'node_modules/',
                    'dist/',
                    '**/*.test.*',                  // 테스트 파일
                    'src/setupTests.js',           // 셋업 파일(필요시)
                ],
            },
        },
    })
)
