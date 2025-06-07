import React from 'react';
import { render, screen, within } from '@testing-library/react';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import PresentationResultPage from '@/pages/ResultPage';
import * as projectAPI from '@/utils/api/project';
import { vi } from 'vitest';

vi.mock('@/utils/api/project');

// Utility to render page with mock project and router state
async function setup(mockProject, mockState) {
    projectAPI.fetchProjectById.mockResolvedValue(mockProject);
    render(
        <MemoryRouter initialEntries={[{ pathname: `/result/${mockProject.id}`, state: mockState }]}>
            <Routes>
                <Route path="/result/:id" element={<PresentationResultPage />} />
            </Routes>
        </MemoryRouter>
    );
    // Wait for header to indicate loading completed
    await screen.findByText('최종 결과');
}

describe('ResultPage interpretation', () => {
    it('shows 느림 when speaking is too slow (speedDiff < -30)', async () => {
        const project = { id: '1', script: '짧은', cpm: 300 };
        const state = { accuracy: 1.0, cpm: 100, recognizedText: '짧은', speakingDuration: 1000 };
        await setup(project, state);
        expect(screen.getByText('느림')).toBeInTheDocument();
    });

    it('shows 적당함 when speaking speed is within acceptable range (-30 <= speedDiff <= 30)', async () => {
        const project = { id: '2', script: '보통 길이의 스크립트', cpm: 300 };
        const state = { accuracy: 0.8, cpm: 330, recognizedText: '보통 길이의 스크립트', speakingDuration: 8000 };
        await setup(project, state);
        expect(screen.getByText('적당함')).toBeInTheDocument();
    });

    it('shows 빠름 when speaking is too fast (speedDiff > 30)', async () => {
        const project = { id: '3', script: '긴 스크립트'.repeat(10), cpm: 300 };
        const state = { accuracy: 1.0, cpm: 500, recognizedText: '긴 스크립트'.repeat(10), speakingDuration: 2000 };
        await setup(project, state);
        expect(screen.getByText('빠름')).toBeInTheDocument();
    });
});

describe('ResultPage score message', () => {
    it('shows failure message when score < 90', async () => {
        // accuracy=0.5 => 50*0.5 + (100-0)*0.5 = 25+50=75
        const project = { id: '4', script: '테스트', cpm: 300 };
        const state = { accuracy: 0.5, cpm: 300, recognizedText: '테스트', speakingDuration: 3000 };
        await setup(project, state);
        expect(screen.getByText('목표 점수를 넘지 못했습니다.')).toBeInTheDocument();
        expect(screen.getByText(/75\.0점/)).toBeInTheDocument();
    });

    it('shows success message when score >= 90', async () => {
        // accuracy=1 => 100*0.5 + (100-0)*0.5 = 50+50=100
        const project = { id: '5', script: '테스트', cpm: 300 };
        const state = { accuracy: 1.0, cpm: 300, recognizedText: '테스트', speakingDuration: 3000 };
        await setup(project, state);
        expect(screen.getByText('목표 점수를 넘었습니다!')).toBeInTheDocument();
        expect(screen.getByText(/100\.0점/)).toBeInTheDocument();
    });
});

it('uses default average CPM when project.cpm is nullish', async () => {
    // project.cpm undefined -> averageCpm defaults to 300
    const project = { id: '6', script: 'testscript' };
    const state = { accuracy: 0.5, cpm: 300, recognizedText: 'testscript', speakingDuration: 3000 };
    await setup(project, state);
    // 예상 시간 = script.length / 300 * 60 = 10/300*60 = 2초 (rounded)
    const expectedRow = screen.getByText('예상 시간').closest('div');
    expect(expectedRow).toBeInTheDocument();
    expect(within(expectedRow).getByText('2초')).toBeInTheDocument();
});

