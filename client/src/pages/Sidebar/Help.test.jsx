import React from 'react';
import { render, screen, fireEvent } from '@testing-library/react';
import Help from './Help';
import { vi } from 'vitest';

// Sidebar 목킹
vi.mock('@/components/SideBar', () => ({
    __esModule: true,
    default: () => <div data-testid="mock-sidebar" />,
}));

// ProfileDropdown 목킹: 토글 버튼으로 onToggleSidebar 호출
vi.mock('@/pages/Profile/ProfileDropdown', () => ({
    __esModule: true,
    default: ({ onToggleSidebar }) => (
        <button data-testid="mock-toggle-btn" onClick={onToggleSidebar} />
    ),
}));

describe('Help 페이지', () => {
    test('검색창이 렌더링된다', () => {
        render(<Help />);
        expect(
            screen.getByPlaceholderText(
                '검색어를 입력하세요, 만약 없으면 Contact Us에 들어가서 문의하세요'
            )
        ).toBeInTheDocument();
    });

    test('초기에는 모든 항목이 렌더링된다', () => {
        render(<Help />);
        [
            'TalkPilot이 뭔가요?',
            '처음엔 어떻게 사용하나요?',
            '다른 사용자들은 어떻게 초대하나요?',
            '프로젝트는 무슨 기능이 있나요?'
        ].forEach(text => {
            expect(screen.getByText(text)).toBeInTheDocument();
        });
    });

    test('검색어 입력 시 필터링 작동', () => {
        render(<Help />);
        const input = screen.getByPlaceholderText(
            '검색어를 입력하세요, 만약 없으면 Contact Us에 들어가서 문의하세요'
        );
        fireEvent.change(input, { target: { value: '초대' } });

        expect(screen.getByText('다른 사용자들은 어떻게 초대하나요?')).toBeInTheDocument();
        expect(screen.queryByText('TalkPilot이 뭔가요?')).not.toBeInTheDocument();
        expect(input).toHaveValue('초대');
    });

    test('없는 검색어 입력 시 결과 없음 메시지 표시', () => {
        render(<Help />);
        const input = screen.getByPlaceholderText(
            '검색어를 입력하세요, 만약 없으면 Contact Us에 들어가서 문의하세요'
        );
        fireEvent.change(input, { target: { value: '없는 키워드' } });
        expect(screen.getByText('검색 결과가 없습니다.')).toBeInTheDocument();
    });

    test('사이드바 토글 버튼 클릭 시 content margin-left 분기', () => {
        const { container } = render(<Help />);
        const contentDiv = container.querySelector('div[style*="padding: 20px"]');
        // 초기: sidebar open -> margin-left:240px
        expect(contentDiv).toHaveStyle({ marginLeft: '240px' });

        fireEvent.click(screen.getByTestId('mock-toggle-btn'));
        // 토글 후: margin-left:0px
        expect(contentDiv).toHaveStyle({ marginLeft: '0px' });
    });
});
