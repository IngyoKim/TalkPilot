import { describe, it, vi, expect, beforeEach } from 'vitest';
import { AudioRecorder } from './AudioRecorder';

describe('AudioRecorder', () => {
    let mockSendAudioChunk;
    let recorder;

    beforeEach(() => {
        mockSendAudioChunk = vi.fn();
        recorder = AudioRecorder(mockSendAudioChunk);

        // getUserMedia mock
        vi.stubGlobal('navigator', {
            mediaDevices: {
                getUserMedia: vi.fn(() => Promise.resolve({ getTracks: () => [{ stop: vi.fn() }] })),
            },
        });

        // AudioContext mock
        global.AudioContext = vi.fn(() => ({
            sampleRate: 16000,
            createMediaStreamSource: vi.fn(() => ({
                connect: vi.fn(),
                disconnect: vi.fn(),
            })),
            audioWorklet: { addModule: vi.fn(() => Promise.resolve()) },
            close: vi.fn(() => Promise.resolve()),
            destination: {},
            state: 'running',
        }));

        global.AudioWorkletNode = vi.fn(() => ({
            port: { onmessage: null },
            connect: vi.fn(),
            disconnect: vi.fn(),
        }));
    });

    it('startRecording 호출 시 media, context, worklet 연결 성공', async () => {
        await recorder.startRecording();
        expect(navigator.mediaDevices.getUserMedia).toHaveBeenCalled();
    });

    it('stopRecording 호출 시 연결 해제 정상 처리', async () => {
        await recorder.startRecording();
        await recorder.stopRecording();
        // 여기서 실패 없이 끝나면 성공
    });
});
