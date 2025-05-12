import { UserModule } from './user/user.module';
import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { FirebaseAuthMiddleware } from './middleware/firebase-auth.middleware';

@Module({
  imports: [UserModule],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(FirebaseAuthMiddleware)
      .forRoutes('me');
  }
}
