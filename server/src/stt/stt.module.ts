import { Module } from '@nestjs/common';
import { SttGateway } from './stt.gateway';

@Module({
    providers: [SttGateway],
})
export class SttModule { }
