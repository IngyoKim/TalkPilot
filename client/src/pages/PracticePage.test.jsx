import { render, screen } from '@testing-library/react';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import PracticePage from './PracticePage';
import * as projectAPI from '@/utils/api/project';

vi.mock('@/contexts/UserContext', () => ({
    useUser: () => ({
        user: { uid: 'test-user', nickname: 'MockUser' },
    }),
}));

vi.mock('@/utils/stt/SttSocket', () => {
    return {
        default: () => ({
            socket: { current: {} },
            connect: vi.fn(),
            disconnect: vi.fn(),
            transcriptText: '',
            transcripts: [],
            speakingDuration: 0,
            isConnected: true,
            clearTranscript: vi.fn(),
            endAudio: vi.fn(),
            sendAudioChunk: vi.fn(),
        }),
    };
});

vi.mock('@/utils/api/project');

describe('PracticePage', () => {
    it('프로젝트 정보 로딩 중 텍스트가 보여야 함', () => {
        render(
            <MemoryRouter initialEntries={['/practice/abc123']}>
                <Routes>
                    <Route path="/practice/:id" element={<PracticePage />} />
                </Routes>
            </MemoryRouter>
        );

        expect(screen.getByText(/프로젝트 정보 로딩 중/)).toBeInTheDocument();
    });

    it('프로젝트 로딩 후 버튼이 렌더링되어야 함', async () => {
        projectAPI.fetchProjectById.mockResolvedValue({
            id: 'abc123',
            title: '연습용 프로젝트',
            script: '안녕하세요 발표 연습입니다.',
        });

        render(
            <MemoryRouter initialEntries={['/practice/abc123']}>
                <Routes>
                    <Route path="/practice/:id" element={<PracticePage />} />
                </Routes>
            </MemoryRouter>
        );

        expect(await screen.findByText(/발표 연습 - 연습용 프로젝트/)).toBeInTheDocument();
        expect(screen.getByText('시작')).toBeInTheDocument();
        expect(screen.getByText('종료')).toBeInTheDocument();
    });
});
