import {
    WebSocketGateway,
    SubscribeMessage,
    OnGatewayConnection,
    OnGatewayDisconnect,
    WebSocketServer,
} from '@nestjs/websockets';
import { Inject } from '@nestjs/common';
import { Server, Socket } from 'socket.io';
import { admin } from '../auth/firebase-admin';
import { SpeechClient } from '@google-cloud/speech';

@WebSocketGateway({
    cors: {
        origin: [
            'http://localhost:5173',  // 로컬 환경
            'https://talkpilot.vercel.app'  // Vercel 프론트 도메인
        ],
        credentials: true,
    },
})

export class SttGateway implements OnGatewayConnection, OnGatewayDisconnect {
    private recognizeStreams = new Map<string, any>();
    private streamTimers = new Map<string, NodeJS.Timeout>();

    @WebSocketServer()
    server: Server;

    constructor(
        @Inject('SPEECH_CLIENT') private readonly client: SpeechClient
    ) { }

    async handleConnection(socket: Socket) {
        const token = socket.handshake.auth?.token;
        if (!token?.startsWith('Bearer ')) {
            socket.disconnect();
            return;
        }

        const idToken = token.split('Bearer ')[1];
        try {
            const decoded = await admin.auth().verifyIdToken(idToken);
            socket.data.user = decoded;
            console.log(`소켓 연결된 사용자: ${decoded.uid}`);
            console.log(`소켓 연결됨: ${socket.id}`);
        } catch (e) {
            console.warn(`토큰 인증 실패: ${e.message}`);
            socket.disconnect();
        }
    }

    handleDisconnect(socket: Socket) {
        this.closeStream(socket.id);
    }

    @SubscribeMessage('start-audio')
    handleAudioStart(socket: Socket) {
        this.startNewStream(socket);
    }

    @SubscribeMessage('audio-chunk')
    handleAudioChunk(socket: Socket, chunk: Buffer) {
        const stream = this.recognizeStreams.get(socket.id);
        if (stream) stream.write(chunk);
    }

    @SubscribeMessage('end-audio')
    handleAudioEnd(socket: Socket) {
        this.closeStream(socket.id);
    }

    private startNewStream(socket: Socket) {
        this.closeStream(socket.id);

        const stream = this.client
            .streamingRecognize({
                config: {
                    encoding: 'LINEAR16',
                    sampleRateHertz: 16000,
                    languageCode: 'ko-KR',
                    enableSpeakerDiarization: true,
                },
                interimResults: true,
            })
            .on('data', (data) => {
                const result = data.results?.[0];
                const transcript = result?.alternatives?.[0]?.transcript;
                if (transcript) {
                    const now = Date.now();
                    socket.emit('stt-result', {
                        transcript,
                        timestamp: now,
                    });
                }
            })
            .on('error', (e) => {
                console.error(`STT 스트림 오류: ${e.message}`);
                this.startNewStream(socket);
            });

        this.recognizeStreams.set(socket.id, stream);

        const timer = setTimeout(() => {
            this.startNewStream(socket);
        }, 290_000);
        timer.unref();
        this.streamTimers.set(socket.id, timer);
    }

    private closeStream(id: string) {
        const stream = this.recognizeStreams.get(id);
        if (stream) {
            stream.end();
            this.recognizeStreams.delete(id);
        }

        const timer = this.streamTimers.get(id);
        if (timer) {
            clearTimeout(timer);
            this.streamTimers.delete(id);
        }
    }
}