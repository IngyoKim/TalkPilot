import { MiddlewareConsumer, Module, NestModule, RequestMethod } from '@nestjs/common';
import { UserModule } from './user/user.module';
import { SttModule } from './stt/stt.module';
import { AuthModule } from './auth/auth.module';
import { AuthMiddleware } from './auth/auth.middleware';
import { DatabaseModule } from './database/database.module';
import { ProjectModule } from './project/project.module';

@Module({
  imports: [
    AuthModule,
    UserModule,
    ProjectModule,
    SttModule,
    DatabaseModule,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(AuthMiddleware)
      .forRoutes(
        { path: 'me', method: RequestMethod.ALL },
        { path: 'user', method: RequestMethod.ALL },
        { path: 'user/:uid', method: RequestMethod.ALL },
        { path: 'project', method: RequestMethod.ALL },
      );
  }
}
