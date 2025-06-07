import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { MemoryRouter, Routes, Route } from 'react-router-dom';
import * as projectAPI from '@/utils/api/project';
import PracticePage from './PracticePage';
import { vi } from 'vitest';

const defaultSocketMock = {
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
};

vi.mock('@/contexts/UserContext', () => ({
    useUser: () => ({
        user: { uid: 'test-user', nickname: 'MockUser' },
    }),
}));
vi.mock('@/utils/api/project', () => ({
    fetchProjectById: vi.fn(),
}));

vi.mock('@/utils/stt/SttSocket', () => ({
    default: () => defaultSocketMock,
}));
vi.mock('@/utils/api/project', () => ({
    fetchProjectById: vi.fn().mockResolvedValue({
        id: 'abc123',
        title: '정상 연결 테스트',
        script: '테스트 스크립트',
    }),
}));

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
    it('로딩 중 텍스트가 표시되어야 함', () => {
        render(
            <MemoryRouter initialEntries={['/practice/abc123']}>
                <Routes>
                    <Route path="/practice/:id" element={<PracticePage />} />
                </Routes>
            </MemoryRouter>
        );
        expect(screen.getByText(/프로젝트 정보 로딩 중/)).toBeInTheDocument();
    });
    it('대본 단어 중 일부는 매칭되고 일부는 현재 단어로 표시되어야 함', async () => {
        projectAPI.fetchProjectById.mockResolvedValue({
            id: 'abc123',
            title: '하이라이팅 테스트',
            script: '하나 둘 셋 넷 다섯',
        });

        defaultSocketMock.transcriptText = '하나 둘 셋';
        defaultSocketMock.transcripts = [{ timestamp: new Date().toISOString() }];

        render(
            <MemoryRouter initialEntries={['/practice/abc123']}>
                <Routes>
                    <Route path="/practice/:id" element={<PracticePage />} />
                </Routes>
            </MemoryRouter>
        );

        expect(await screen.findByText(/하이라이팅 테스트/)).toBeInTheDocument();

        for (const word of ['하나', '둘', '셋', '넷', '다섯']) {
            expect(screen.getByText(word)).toBeInTheDocument();
        }
    });
    it('STT 소켓이 연결되지 않았을 때 시작 시 alert 호출', async () => {
        projectAPI.fetchProjectById.mockResolvedValue({
            id: 'abc123',
            title: '연결 실패 테스트',
            script: '테스트 스크립트',
        });

        defaultSocketMock.isConnected = false;
        defaultSocketMock.socket = { current: { connected: false } };

        const alertMock = vi.spyOn(window, 'alert').mockImplementation(() => { });

        render(
            <MemoryRouter initialEntries={['/practice/abc123']}>
                <Routes>
                    <Route path="/practice/:id" element={<PracticePage />} />
                </Routes>
            </MemoryRouter>
        );

        const startButton = await screen.findByText('시작');
        fireEvent.click(startButton);

        await waitFor(() => {
            expect(alertMock).toHaveBeenCalledWith(
                'STT 서버와 연결되지 않았습니다. 잠시 후 다시 시도하세요.'
            );
        });

        alertMock.mockRestore();
    });
    it('socket.current가 없으면 alert 호출', async () => {
        projectAPI.fetchProjectById.mockResolvedValue({
            id: 'abc123',
            title: '소켓 없음 테스트',
            script: '이건 테스트입니다.',
        });

        defaultSocketMock.socket = { current: null }; // ✅ null 처리
        defaultSocketMock.isConnected = false;

        const alertMock = vi.spyOn(window, 'alert').mockImplementation(() => { });

        render(
            <MemoryRouter initialEntries={['/practice/abc123']}>
                <Routes>
                    <Route path="/practice/:id" element={<PracticePage />} />
                </Routes>
            </MemoryRouter>
        );

        const startButton = await screen.findByText('시작');
        fireEvent.click(startButton);

        await waitFor(() => {
            expect(alertMock).toHaveBeenCalledWith(
                'STT 서버와 연결되지 않았습니다. 잠시 후 다시 시도하세요.'
            );
        });

        alertMock.mockRestore();
    });
    it('projectId가 없는 경우 project가 null인 상태로 return 분기를 따라간다', () => {
        render(
            <MemoryRouter initialEntries={['/practice/']}>
                <Routes>
                    {/* id 파라미터가 없음 → useParams().id === undefined */}
                    <Route path="/practice/" element={<PracticePage />} />
                </Routes>
            </MemoryRouter>
        );

        // 이 상태에서는 useEffect 내부의 fetch 호출 자체가 스킵됨
        // 따라서 project는 영원히 null → if (!project) return 분기가 정확히 실행됨
        expect(screen.getByText(/프로젝트 정보 로딩 중/)).toBeInTheDocument();
    });


});
