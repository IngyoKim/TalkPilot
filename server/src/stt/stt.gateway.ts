import {
    WebSocketGateway,
    SubscribeMessage,
    OnGatewayConnection,
    OnGatewayDisconnect,
    WebSocketServer,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { SpeechClient } from '@google-cloud/speech';
import { readFileSync } from 'fs';
import { admin } from '../auth/firebase-admin';

@WebSocketGateway({ cors: true })
export class SttGateway implements OnGatewayConnection, OnGatewayDisconnect {
    private client: SpeechClient;
    private recognizeStreams = new Map<string, any>();
    private streamTimers = new Map<string, NodeJS.Timeout>();

    @WebSocketServer()
    server: Server;

    constructor() {
        const path = process.env.STT_SERVICE_ACCOUNT_KEY_PATH || '/etc/secrets/stt-service-account.json';
        const credentials = JSON.parse(readFileSync(path, 'utf-8'));
        this.client = new SpeechClient({ credentials });
    }

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
        } catch {
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
                },
                interimResults: true,
            })
            .on('data', (data) => {
                const result = data.results?.[0];
                const transcript = result?.alternatives?.[0]?.transcript;
                if (transcript) {
                    socket.emit('stt-result', transcript.trim());
                }
            })
            .on('error', () => {
                this.startNewStream(socket);
            });

        this.recognizeStreams.set(socket.id, stream);

        const timer = setTimeout(() => {
            this.startNewStream(socket);
        }, 290_000);
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
