import { render, screen } from '@testing-library/react';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import PresentationResultPage from '@/pages/ResultPage';
import * as projectAPI from '@/utils/api/project';

vi.mock('@/utils/api/project');

describe('ResultPage', () => {
    it('점수 및 결과 메시지가 표시되어야 함', async () => {
        projectAPI.fetchProjectById.mockResolvedValue({
            id: 'abc123',
            title: '테스트 프로젝트',
            script: '테스트 스크립트입니다.',
            cpm: 300,
        });

        const mockState = {
            accuracy: 0.8,
            cpm: 330,
            recognizedText: '테스트 스크립트입니다.',
            status: '적당함',
            speakingDuration: 8000,
        };

        render(
            <MemoryRouter initialEntries={[{ pathname: '/result/abc123', state: mockState }]}>
                <Routes>
                    <Route path="/result/:id" element={<PresentationResultPage />} />
                </Routes>
            </MemoryRouter>
        );

        expect(await screen.findByText(/최종 결과/)).toBeInTheDocument();
        expect(screen.getByText(/목표 점수를 넘/)).toBeInTheDocument();
        expect(screen.getByText(/대본 정확도/)).toBeInTheDocument();
    });
});
