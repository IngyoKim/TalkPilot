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
import { join } from 'path';

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

    handleConnection(socket: Socket) {
        console.log(`Client connected: ${socket.id}`);
    }

    handleDisconnect(socket: Socket) {
        console.log(`Client disconnected: ${socket.id}`);
        this.closeStream(socket.id);
    }

    @SubscribeMessage('start-audio')
    handleAudioStart(socket: Socket) {
        this.startNewStream(socket);
    }

    @SubscribeMessage('audio-chunk')
    handleAudioChunk(socket: Socket, chunk: Buffer) {
        const stream = this.recognizeStreams.get(socket.id);
        if (stream) {
            stream.write(chunk);
        }
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
                const transcript = data.results?.[0]?.alternatives?.[0]?.transcript;
                if (transcript) {
                    socket.emit('stt-result', transcript);
                }
            })
            .on('error', (err) => {
                console.error(`Stream error: ${err.message}`);
                this.startNewStream(socket);
            });

        this.recognizeStreams.set(socket.id, stream);

        const timer = setTimeout(() => {
            console.log(`Auto restart stream for ${socket.id}`);
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
