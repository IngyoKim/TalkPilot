import { Test, TestingModule } from '@nestjs/testing';
import { SttGateway } from '../src/stt/stt.gateway';

jest.mock('../src/auth/firebase-admin', () => {
    const verifyIdTokenMock = jest.fn();

    return {
        admin: {
            auth: jest.fn(() => ({
                verifyIdToken: verifyIdTokenMock,
            })),
        },
    };
});

import { admin } from '../src/auth/firebase-admin';

describe('SttGateway', () => {
    let gateway: SttGateway;

    const mockStreamingRecognize = jest.fn();
    const mockStream = {
        write: jest.fn(),
        end: jest.fn(),
        on: jest.fn().mockReturnThis(),
    };

    const mockSpeechClient = {
        streamingRecognize: mockStreamingRecognize,
    };

    const mockSocket = {
        id: 'socket123',
        handshake: {
            auth: {
                token: 'Bearer valid_token',
            },
        },
        data: {} as any,
        emit: jest.fn(),
        disconnect: jest.fn(),
    };

    beforeAll(() => {
        jest.spyOn(console, 'log').mockImplementation(() => { });
        jest.spyOn(console, 'warn').mockImplementation(() => { });
        jest.spyOn(console, 'error').mockImplementation(() => { });
    });

    beforeEach(async () => {
        jest.clearAllMocks();
        mockStreamingRecognize.mockReturnValue(mockStream);

        const module: TestingModule = await Test.createTestingModule({
            providers: [
                SttGateway,
                {
                    provide: 'SPEECH_CLIENT',
                    useValue: mockSpeechClient,
                },
            ],
        }).compile();

        gateway = module.get<SttGateway>(SttGateway);

        gateway['recognizeStreams'].set(mockSocket.id, mockStream);
        gateway['streamTimers'].set(mockSocket.id, setTimeout(() => { }, 1000));
    });

    it('should connect with valid token', async () => {
        (admin.auth().verifyIdToken as jest.Mock).mockResolvedValue({ uid: 'test_uid' });

        await gateway.handleConnection(mockSocket as any);

        expect(admin.auth().verifyIdToken).toHaveBeenCalledWith('valid_token');
        expect(mockSocket.data.user).toEqual({ uid: 'test_uid' });
        expect(mockSocket.disconnect).not.toHaveBeenCalled();
    });

    it('should disconnect if token invalid', async () => {
        (admin.auth().verifyIdToken as jest.Mock).mockRejectedValue(new Error('Invalid token'));

        await gateway.handleConnection(mockSocket as any);

        expect(mockSocket.disconnect).toHaveBeenCalled();
    });

    it('should start new stream on start-audio and close previous stream', () => {
        gateway.handleAudioStart(mockSocket as any);

        expect(mockStream.end).toHaveBeenCalled();

        expect(mockStreamingRecognize).toHaveBeenCalled();
    });

    it('should write chunk on audio-chunk', () => {
        gateway.handleAudioStart(mockSocket as any);

        const chunk = Buffer.from('test_chunk');
        gateway.handleAudioChunk(mockSocket as any, chunk);

        expect(mockStream.write).toHaveBeenCalledWith(chunk);
    });

    it('should close stream on end-audio', () => {
        gateway.handleAudioStart(mockSocket as any);

        gateway.handleAudioEnd(mockSocket as any);

        expect(mockStream.end).toHaveBeenCalled();
    });

    it('should close stream on disconnect', () => {
        gateway.handleAudioStart(mockSocket as any);

        gateway.handleDisconnect(mockSocket as any);

        expect(mockStream.end).toHaveBeenCalled();
    });

    it('should handle error event and restart stream', () => {
        gateway.handleAudioStart(mockSocket as any);

        const errorHandler = (mockStream.on as jest.Mock).mock.calls.find(
            (call) => call[0] === 'error'
        )[1];

        errorHandler(new Error('Test error'));

        expect(mockStreamingRecognize).toHaveBeenCalledTimes(2);

        expect(mockStream.end).toHaveBeenCalled();
    });

    it('should handle data event', () => {
        gateway.handleAudioStart(mockSocket as any);

        const dataHandler = (mockStream.on as jest.Mock).mock.calls.find(
            (call) => call[0] === 'data'
        )[1];

        const mockData = {
            results: [
                {
                    alternatives: [
                        { transcript: 'hello world' },
                    ],
                },
            ],
        };

        dataHandler(mockData);

        expect(mockSocket.emit).toHaveBeenCalledWith('stt-result', expect.objectContaining({
            transcript: 'hello world',
        }));
    });

    it('should start new stream on start-audio when no previous stream exists', () => {
        gateway['recognizeStreams'].delete(mockSocket.id);
        gateway['streamTimers'].delete(mockSocket.id);

        gateway.handleAudioStart(mockSocket as any);

        expect(mockStreamingRecognize).toHaveBeenCalled();
    });
});
