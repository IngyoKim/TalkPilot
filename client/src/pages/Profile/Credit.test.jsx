import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom'; // ✅ 추가
import CreditPage from './Credit';
import { describe, it, expect } from 'vitest';

const renderWithRouter = (ui) => render(<MemoryRouter>{ui}</MemoryRouter>);

describe('CreditPage', () => {
    it('GitHub 링크가 올바르게 렌더링된다', () => {
        renderWithRouter(<CreditPage />);
        const link = screen.getByRole('link', { name: /TalkPilot/i });
        expect(link).toBeInTheDocument();
        expect(link).toHaveAttribute('href', 'https://github.com/IngyoKim/TalkPilot');
    });

    it('기술 스택 뱃지 이미지들이 렌더링된다', () => {
        renderWithRouter(<CreditPage />);
        expect(screen.getByAltText('Flutter')).toBeInTheDocument();
        expect(screen.getByAltText('React')).toBeInTheDocument();
        expect(screen.getByAltText('NestJS')).toBeInTheDocument();
        expect(screen.getByAltText('Firebase')).toBeInTheDocument();
        expect(screen.getByAltText('Google Cloud STT')).toBeInTheDocument();
    });

    it('팀원 목록에 이름이 표시된다', () => {
        renderWithRouter(<CreditPage />);
        expect(screen.getByText('김민규')).toBeInTheDocument();
        expect(screen.getByText('김인교')).toBeInTheDocument();
        expect(screen.getByText('전상민')).toBeInTheDocument();
        expect(screen.getByText(/기타 참여 멤버들/i)).toBeInTheDocument();
    });

    it('MIT License 링크가 포함되어 있다', () => {
        renderWithRouter(<CreditPage />);
        const licenseLink = screen.getByRole('link', { name: /LICENSE 보기/i });
        expect(licenseLink).toBeInTheDocument();
        expect(licenseLink).toHaveAttribute(
            'href',
            'https://github.com/IngyoKim/TalkPilot/blob/main/LICENSE'
        );
    });

    it('CBNU 로고와 푸터 문구가 포함되어 있다', () => {
        renderWithRouter(<CreditPage />);
        expect(screen.getByAltText(/CBNU Logo/i)).toBeInTheDocument();
        expect(
            screen.getByText(/TalkPilot과 함께 발표를 더 스마트하게 준비하세요/i)
        ).toBeInTheDocument();
    });
});
