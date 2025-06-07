import { describe, it, vi, expect, beforeEach, afterEach } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import io from 'socket.io-client';
import useSttSocket from './SttSocket';

// 이벤트 핸들러 저장용
let eventHandlers = {};

// socket.io-client 모킹
vi.mock('socket.io-client', () => ({
    default: vi.fn(() => ({
        on: (event, cb) => { eventHandlers[event] = cb; if (event === 'connect') cb(); },
        emit: vi.fn(),
        disconnect: vi.fn(),
        connected: true,
    })),
}));

// AuthContext 모킹
import { useAuth } from '../../contexts/AuthContext';
vi.mock('../../contexts/AuthContext', () => ({ useAuth: vi.fn() }));

describe('useSttSocket', () => {
    beforeEach(() => {
        eventHandlers = {};
        vi.useFakeTimers();
        vi.mocked(useAuth).mockReturnValue({ authUser: { token: 'test-token' } });
    });

    afterEach(() => { vi.useRealTimers(); vi.clearAllMocks(); });

    it('connect 성공 시 isConnected true', async () => {
        const { result } = renderHook(() => useSttSocket());
        await act(() => result.current.connect());
        expect(result.current.isConnected).toBe(true);
    });

    it('connect 실패 시 토큰 없으면 reject 및 경고 로그', async () => {
        const consoleWarn = vi.spyOn(console, 'warn');
        vi.mocked(useAuth).mockReturnValue({ authUser: {} });
        const { result } = renderHook(() => useSttSocket());
        await expect(result.current.connect()).rejects.toThrow('No token');
        expect(consoleWarn).toHaveBeenCalledWith('[STT] 토큰 없음');
    });

    it('connect 호출 시 기존 소켓이 있으면 disconnect 호출', async () => {
        const { result } = renderHook(() => useSttSocket());
        await act(() => result.current.connect());
        await act(() => result.current.connect());
        const firstSocket = vi.mocked(io).mock.results[0].value;
        expect(firstSocket.disconnect).toHaveBeenCalled();
    });

    it('connect_error 이벤트 시 isConnected false 및 console.error 호출', async () => {
        const consoleErr = vi.spyOn(console, 'error');
        const { result } = renderHook(() => useSttSocket());
        // 연결 및 이벤트 핸들러 등록
        await act(() => result.current.connect());
        act(() => eventHandlers['connect_error'](new Error('fail')));
        expect(consoleErr).toHaveBeenCalledWith('[STT] 연결 실패:', new Error('fail'));
        expect(result.current.isConnected).toBe(false);
    });

    it('disconnect 호출 시 isConnected false', () => {
        const { result } = renderHook(() => useSttSocket());
        act(() => result.current.disconnect());
        expect(result.current.isConnected).toBe(false);
    });

    it('sendAudioChunk: 연결 없으면 경고', () => {
        const warn = vi.spyOn(console, 'warn');
        const { result } = renderHook(() => useSttSocket());
        act(() => result.current.sendAudioChunk(new Uint8Array([1])));
        expect(warn).toHaveBeenCalledWith('[Socket] 연결 안됨. 전송 실패');
    });

    it('sendAudioChunk: 연결 있으면 emit 호출', async () => {
        const { result } = renderHook(() => useSttSocket());
        await act(() => result.current.connect());
        const chunk = new Uint8Array([1, 2]);
        act(() => result.current.sendAudioChunk(chunk));
        const socket = vi.mocked(io).mock.results[0].value;
        expect(socket.emit).toHaveBeenCalledWith('audio-chunk', chunk);
    });

    it('stt-result 이벤트: transcript 없으면 무시', async () => {
        const { result } = renderHook(() => useSttSocket());
        await act(() => result.current.connect());
        act(() => eventHandlers['stt-result']({ transcript: '   ', timestamp: Date.now() }));
        expect(result.current.transcripts).toHaveLength(0);
        expect(result.current.recognizedText).toBe('');
    });

    it('stt-result 이벤트: savedText 및 transcripts 업데이트', async () => {
        const { result } = renderHook(() => useSttSocket());
        await act(() => result.current.connect());
        const t1 = 'hello';
        const ts1 = Date.now();
        act(() => eventHandlers['stt-result']({ transcript: t1, timestamp: ts1 }));
        act(() => { vi.advanceTimersByTime(1000); });
        expect(result.current.savedText).toBe('hello ');
        expect(result.current.transcripts).toEqual([{ transcript: t1, timestamp: ts1 }]);

        const t2 = 'hello world';
        const ts2 = ts1 + 500;
        act(() => eventHandlers['stt-result']({ transcript: t2, timestamp: ts2 }));
        act(() => { vi.advanceTimersByTime(1000); });
        expect(result.current.savedText).toBe('hello world ');
    });

    it('stt-result 이벤트: prefix mismatch 시 savedText 누적', async () => {
        const { result } = renderHook(() => useSttSocket());
        await act(() => result.current.connect());
        act(() => eventHandlers['stt-result']({ transcript: 'foo', timestamp: Date.now() }));
        act(() => { vi.advanceTimersByTime(1000); });
        act(() => eventHandlers['stt-result']({ transcript: 'bar', timestamp: Date.now() }));
        act(() => { vi.advanceTimersByTime(1000); });
        expect(result.current.savedText).toBe('foo bar ');
    });

    it('stt-result 이벤트: 정상 처리 및 콜백 호출', async () => {
        const onTranscript = vi.fn();
        const { result } = renderHook(() => useSttSocket());
        act(() => result.current.setOnTranscript(onTranscript));
        await act(() => result.current.connect());
        const data = { transcript: 'hey', timestamp: Date.now() };
        act(() => eventHandlers['stt-result'](data));
        act(() => { vi.advanceTimersByTime(1000); });
        expect(result.current.recognizedText).toBe('hey');
        expect(onTranscript).toHaveBeenCalledWith('hey');
    });

    it('endAudio: emit 및 speakingDuration 계산', async () => {
        const now = Date.now(); const OriginalDate = Date;
        // @ts-ignore
        global.Date = class extends Date { constructor(arg) { super(arg || now); } static now() { return now; } };

        const { result } = renderHook(() => useSttSocket());
        await act(() => result.current.connect());
        act(() => result.current.endAudio());
        const socket = vi.mocked(io).mock.results[0].value;
        expect(socket.emit).toHaveBeenCalledWith('end-audio');
        expect(result.current.speakingDuration).toBeGreaterThanOrEqual(0);

        global.Date = OriginalDate;
    });

    it('clearTranscript: 상태 및 refs 초기화', async () => {
        const { result } = renderHook(() => useSttSocket());
        await act(() => result.current.connect());
        act(() => eventHandlers['stt-result']({ transcript: 'x', timestamp: Date.now() }));
        act(() => { vi.advanceTimersByTime(1000); });
        act(() => result.current.clearTranscript());
        expect(result.current.transcripts).toEqual([]);
        expect(result.current.recognizedText).toBe('');
        expect(result.current.savedText).toBe('');
        expect(result.current.speakingDuration).toBe(0);
    });
});
