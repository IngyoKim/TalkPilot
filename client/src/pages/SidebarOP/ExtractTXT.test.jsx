import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import FileUploadPage from './ExtractTXT';
import { vi } from 'vitest';

vi.mock('@/contexts/UserContext', () => ({
    useUser: () => ({ user: { uid: 'user1' }, setUser: vi.fn() }),
}));
vi.mock('@/components/SideBar', () => ({
    default: ({ isOpen }) => <div data-testid="MockSidebar" style={{ display: isOpen ? 'block' : 'none' }} />,
}));
vi.mock('@/pages/Profile/ProfileDropdown', () => ({
    default: ({ onToggleSidebar }) => (
        <button data-testid="mock-toggle-btn" onClick={onToggleSidebar} />
    ),
}));
vi.mock('@/components/ToastMessage', () => ({
    default: ({ messages }) => (
        <div data-testid="MockToast">{messages.map(m => m.text).join('|')}</div>
    ),
}));

describe('ExtractTXT 기본 렌더링', () => {
    it('파일 선택 및 복사하기 버튼 및 초기 메시지 표시', () => {
        render(
            <MemoryRouter>
                <FileUploadPage />
            </MemoryRouter>
        );
        expect(screen.getByText('.txt 파일 업로드')).toBeInTheDocument();
        expect(screen.getByText('파일 선택')).toBeInTheDocument();
        expect(screen.getByText('복사하기')).toBeInTheDocument();
        expect(screen.getByText('선택된 파일이 없습니다.')).toBeInTheDocument();
    });

    it('복사하기 클릭 시 클립보드에 쓰기 및 토스트 메시지', () => {
        const writeSpy = vi.fn();
        Object.assign(navigator, { clipboard: { writeText: writeSpy } });

        render(
            <MemoryRouter>
                <FileUploadPage />
            </MemoryRouter>
        );
        fireEvent.click(screen.getByText('복사하기'));
        expect(writeSpy).toHaveBeenCalledWith('여기에 추출된 텍스트가 들어갑니다.');
        expect(screen.getByTestId('MockToast').textContent).toContain('텍스트가 복사되었습니다.');
    });
});

describe('파일 선택 동작', () => {
    it('파일을 선택하면 목록에 파일명이 표시되고 토스트 추가', () => {
        const file = new File(['hello'], 'example.txt', { type: 'text/plain' });
        const { container } = render(
            <MemoryRouter>
                <FileUploadPage />
            </MemoryRouter>
        );
        const input = container.querySelector('input[type="file"]');
        fireEvent.change(input, { target: { files: [file] } });
        expect(screen.getByText('example.txt')).toBeInTheDocument();
        expect(screen.getByTestId('MockToast').textContent).toContain('1개의 파일이 추가되었습니다.');
    });

    it('파일 선택 취소 시 경고 토스트 및 메시지 유지', () => {
        const { container } = render(
            <MemoryRouter>
                <FileUploadPage />
            </MemoryRouter>
        );
        const input = container.querySelector('input[type="file"]');
        fireEvent.change(input, { target: { files: [] } });
        const elems = screen.getAllByText('선택된 파일이 없습니다.');
        expect(elems.length).toBeGreaterThanOrEqual(1);
        expect(screen.getByTestId('MockToast').textContent).toContain('선택된 파일이 없습니다.');
    });

    it('파일 선택 버튼 클릭 시 hidden input 클릭', () => {
        const { container } = render(
            <MemoryRouter>
                <FileUploadPage />
            </MemoryRouter>
        );
        const input = container.querySelector('input[type="file"]');
        const spy = vi.spyOn(input, 'click');
        fireEvent.click(screen.getByText('파일 선택'));
        expect(spy).toHaveBeenCalled();
    });
});

describe('사이드바 토글 동작', () => {
    it('초기에는 사이드바 열림, content marginLeft:240px', () => {
        const { container } = render(
            <MemoryRouter>
                <FileUploadPage />
            </MemoryRouter>
        );
        const content = container.querySelector('div[style*="margin-left: 240px"]');
        expect(content).toBeTruthy();
    });

    it('토글 버튼 클릭 시 사이드바 닫히고 content marginLeft:0px', () => {
        const { container } = render(
            <MemoryRouter>
                <FileUploadPage />
            </MemoryRouter>
        );
        fireEvent.click(screen.getByTestId('mock-toggle-btn'));
        const content = container.querySelector('div[style*="margin-left: 0px"]');
        expect(content).toBeTruthy();
    });
});
