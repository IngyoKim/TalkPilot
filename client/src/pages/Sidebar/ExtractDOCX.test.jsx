import { render, screen, fireEvent } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import ExtractDOCX from './ExtractDOCX';
import { vi } from 'vitest';

vi.mock('@/contexts/UserContext', () => ({
    useUser: () => ({ user: { uid: 'test-user' }, setUser: vi.fn() }),
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

describe('ExtractDOCX 기본 렌더링', () => {
    it('파일 선택 및 복사하기 버튼이 보여야 한다', () => {
        render(
            <MemoryRouter>
                <ExtractDOCX />
            </MemoryRouter>
        );
        expect(screen.getByText('파일 선택')).toBeInTheDocument();
        expect(screen.getByText('복사하기')).toBeInTheDocument();
        expect(screen.getByText('선택된 파일이 없습니다.')).toBeInTheDocument();
    });

    it('복사하기 클릭 시 클립보드에 쓰기 호출 및 토스트 메시지', () => {
        const clipboardSpy = vi.fn();
        Object.assign(navigator, { clipboard: { writeText: clipboardSpy } });

        render(
            <MemoryRouter>
                <ExtractDOCX />
            </MemoryRouter>
        );
        fireEvent.click(screen.getByText('복사하기'));
        expect(clipboardSpy).toHaveBeenCalledWith('여기에 추출된 텍스트가 들어갑니다.');
        expect(screen.getByTestId('MockToast').textContent).toContain('텍스트가 복사되었습니다.');
    });
});

describe('파일 선택 동작', () => {
    it('파일을 선택하면 목록에 파일명이 표시되고 메시지가 추가된다', () => {
        const file = new File(['dummy'], 'test.docx', { type: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' });
        const { container } = render(
            <MemoryRouter>
                <ExtractDOCX />
            </MemoryRouter>
        );
        const input = container.querySelector('input[type="file"]');
        fireEvent.change(input, { target: { files: [file] } });
        expect(screen.getByText('test.docx')).toBeInTheDocument();
        expect(screen.getByTestId('MockToast').textContent).toContain('1개의 파일이 추가되었습니다.');
    });

    it('파일 선택 취소 시 메시지 유지 및 경고 토스트', () => {
        const { container } = render(
            <MemoryRouter>
                <ExtractDOCX />
            </MemoryRouter>
        );
        const input = container.querySelector('input[type="file"]');
        fireEvent.change(input, { target: { files: [] } });
        const noFileElems = screen.getAllByText('선택된 파일이 없습니다.');
        expect(noFileElems.length).toBeGreaterThanOrEqual(1);
        expect(screen.getByTestId('MockToast').textContent).toContain('선택된 파일이 없습니다.');
    });

    it('파일 선택 버튼 클릭 시 hidden input 클릭', () => {
        const { container } = render(
            <MemoryRouter>
                <ExtractDOCX />
            </MemoryRouter>
        );
        const input = container.querySelector('input[type="file"]');
        const clickSpy = vi.spyOn(input, 'click');
        fireEvent.click(screen.getByText('파일 선택'));
        expect(clickSpy).toHaveBeenCalled();
    });
});

describe('사이드바 토글 동작', () => {
    it('초기에는 사이드바 열림, content marginLeft:240px', () => {
        const { container } = render(
            <MemoryRouter>
                <ExtractDOCX />
            </MemoryRouter>
        );
        const contentDiv = container.querySelector('div[style*="margin-left: 240px"]');
        expect(contentDiv).toBeTruthy();
    });

    it('토글 버튼 클릭 시 사이드바 닫히고 content marginLeft:0px', () => {
        const { container } = render(
            <MemoryRouter>
                <ExtractDOCX />
            </MemoryRouter>
        );
        fireEvent.click(screen.getByTestId('mock-toggle-btn'));
        const contentDiv = container.querySelector('div[style*="margin-left: 0px"]');
        expect(contentDiv).toBeTruthy();
    });
});
