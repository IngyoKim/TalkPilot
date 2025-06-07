import { defineConfig } from 'vite';
import viteConfig from './vite.config';
import react from '@vitejs/plugin-react';
import path from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, 'src'),
    },
  },
  test: {
    globals: true,                // describe/test 등을 전역으로 사용 가능
    environment: 'jsdom',         // DOM 환경 제공 (React 컴포넌트 테스트에 필요)
    setupFiles: './src/setupTests.js',  // jest-dom 등 초기화 스크립트
  },
});
