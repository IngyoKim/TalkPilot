import React from 'react';
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter as Router } from 'react-router-dom';
import FileUploadPage from './TextExtractPage';
import { vi } from 'vitest';

// 모킹: mammoth.extractRawText
vi.mock('mammoth/mammoth.browser', () => ({
    __esModule: true,
    default: {
        extractRawText: vi.fn().mockResolvedValue({ value: 'Docx content from mock' }),
    },
}));
vi.mock('./ToastMessage', () => ({
    __esModule: true,
    default: ({ messages }) => (
        <div data-testid="toast-wrapper">
            {messages.map((m) => (
                <div key={m.id}>{m.text}</div>
            ))}
        </div>
    ),
}));
// 모킹: ProfileDropdown 컴포넌트 (useUser 훅 무시)
vi.mock('../pages/Profile/ProfileDropdown', () => ({
    __esModule: true,
    default: () => null,
}));

describe('FileUploadPage', () => {
    const renderWithRouter = () =>
        render(
            <Router>
                <FileUploadPage />
            </Router>
        );

    it('렌더링 시 기본 요소들이 나타난다', () => {
        renderWithRouter();
        expect(screen.getByText(/파일 선택/i)).toBeInTheDocument();
        expect(screen.getByText(/복사하기/i)).toBeInTheDocument();
    });

    it('txt 파일 업로드 시 텍스트가 추출되어 textarea에 표시된다', async () => {
        const file = new File(['sample text content'], 'sample.txt', { type: 'text/plain' });
        const { container } = renderWithRouter();
        const input = container.querySelector('input[type="file"]');
        fireEvent.change(input, { target: { files: [file] } });

        await waitFor(() => {
            expect(screen.getByDisplayValue('sample text content')).toBeInTheDocument();
        });
    });

    it('docx 파일 업로드 시 mock된 텍스트가 표시된다', async () => {
        const file = new File(['dummy'], 'sample.docx', {
            type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        });
        file.arrayBuffer = () => Promise.resolve(new ArrayBuffer(8));
        const { container } = renderWithRouter();
        const input = container.querySelector('input[type="file"]');
        fireEvent.change(input, { target: { files: [file] } });

        await waitFor(() => {
            expect(screen.getByDisplayValue('Docx content from mock')).toBeInTheDocument();
        });
    });

    it('지원하지 않는 파일 형식 업로드 시 오류 메시지를 보여준다', async () => {
        const file = new File(['binary content'], 'image.png', { type: 'image/png' });
        const { container } = renderWithRouter();
        const input = container.querySelector('input[type="file"]');
        fireEvent.change(input, { target: { files: [file] } });

        await waitFor(() => {
            expect(screen.getByText(/지원하지 않는 파일 형식/i)).toBeInTheDocument();
        });
    });
    it('파일이 선택되지 않은 경우 동작하지 않는다', () => {
        const { container } = renderWithRouter();
        const input = container.querySelector('input[type="file"]');
        fireEvent.change(input, { target: { files: [] } }); // 또는 undefined

        // 아무 일도 일어나지므로, expect로 부작용이 없는지 체크
        expect(screen.getByText(/파일 선택/i)).toBeInTheDocument();
    });
});
