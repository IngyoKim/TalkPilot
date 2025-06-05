import 'dotenv/config';
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { initializeFirebase } from './auth/firebase-admin';

async function bootstrap() {
  await initializeFirebase();

  const app = await NestFactory.create(AppModule);

  app.enableCors({
    origin: [
      'http://localhost:5173',  // 로컬 환경
      'https://talkpilot.vercel.app'  // Vercel 프론트 도메인
    ],
    credentials: true,
  });

  await app.listen(process.env.PORT || 3000, '0.0.0.0');
}
bootstrap();
