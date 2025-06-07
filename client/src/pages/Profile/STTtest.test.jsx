import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import STTtest from './STTtest';
import { vi } from 'vitest';
import { MemoryRouter } from 'react-router-dom';

// Mock Sidebar to avoid useNavigate errors
vi.mock('../../components/SideBar', () => ({ __esModule: true, default: () => <div /> }));

// Mock ProfileDropdown to expose toggle button for tests
vi.mock('./ProfileDropdown', () => ({
    __esModule: true,
    default: ({ onToggleSidebar }) => (
        <button data-testid="toggle-sidebar" onClick={onToggleSidebar}>Toggle Sidebar</button>
    ),
}));

describe('STTtest component', () => {
    const originalSpeechRecognition = window.SpeechRecognition;
    const originalWebkitSpeechRecognition = window.webkitSpeechRecognition;

    afterEach(() => {
        vi.restoreAllMocks();
        window.SpeechRecognition = originalSpeechRecognition;
        window.webkitSpeechRecognition = originalWebkitSpeechRecognition;
    });

    test('renders initial UI correctly', () => {
        render(
            <MemoryRouter>
                <STTtest />
            </MemoryRouter>
        );
        expect(screen.getByText('STT 테스트')).toBeInTheDocument();
        expect(screen.getByText('마이크 버튼을 클릭하면 음성이 텍스트로 변환됩니다.')).toBeInTheDocument();
        expect(screen.getByText('말하기 시작')).toBeInTheDocument();
        expect(screen.queryByText('결과')).toBeNull();
        const container = screen.getByText('STT 테스트').parentElement.parentElement;
        // initial sidebar open => margin-left: 260px
        expect(container).toHaveStyle('margin-left: 260px');
    });

    test('renders UI when sidebar is closed after toggle', () => {
        render(
            <MemoryRouter>
                <STTtest />
            </MemoryRouter>
        );
        const toggleBtn = screen.getByTestId('toggle-sidebar');
        fireEvent.click(toggleBtn);
        const container = screen.getByText('STT 테스트').parentElement.parentElement;
        // after toggle, sidebar closed => margin-left: 0px
        expect(container).toHaveStyle('margin-left: 0px');
    });

    test('alerts when STT is not supported', () => {
        const alertMock = vi.spyOn(window, 'alert').mockImplementation(() => { });
        window.SpeechRecognition = undefined;
        window.webkitSpeechRecognition = undefined;
        render(
            <MemoryRouter>
                <STTtest />
            </MemoryRouter>
        );
        fireEvent.click(screen.getByText('말하기 시작'));
        expect(alertMock).toHaveBeenCalledWith('이 브라우저는 STT를 지원하지 않습니다.');
    });

    test('handles successful speech recognition', () => {
        class MockRecognition {
            constructor() {
                this.lang = '';
                this.interimResults = false;
                this.maxAlternatives = 1;
                this.onstart = null;
                this.onresult = null;
                this.onerror = null;
                this.onend = null;
            }
            start() {
                this.onstart();
                this.onresult({ results: [[{ transcript: '테스트 완료' }]] });
                this.onend();
            }
        }
        window.SpeechRecognition = MockRecognition;
        render(
            <MemoryRouter>
                <STTtest />
            </MemoryRouter>
        );
        fireEvent.click(screen.getByText('말하기 시작'));
        expect(screen.getByText('결과')).toBeInTheDocument();
        expect(screen.getByText('테스트 완료')).toBeInTheDocument();
    });

    test('handles recognition error', () => {
        class MockRecognitionError {
            constructor() {
                this.onstart = null;
                this.onresult = null;
                this.onerror = null;
                this.onend = null;
            }
            start() {
                this.onerror({ error: 'network' });
                this.onend();
            }
        }
        window.SpeechRecognition = MockRecognitionError;
        const alertMock = vi.spyOn(window, 'alert').mockImplementation(() => { });
        render(
            <MemoryRouter>
                <STTtest />
            </MemoryRouter>
        );
        fireEvent.click(screen.getByText('말하기 시작'));
        expect(alertMock).toHaveBeenCalledWith('음성 인식 중 오류 발생: network');
        expect(screen.queryByText('결과')).toBeNull();
        expect(screen.getByText('말하기 시작')).toBeInTheDocument();
    });
});
