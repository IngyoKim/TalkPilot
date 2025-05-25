import { Module } from '@nestjs/common';
import { ProjectController } from './project.controller';
import { ProjectService } from './project.service';
import { DatabaseModule } from '../database/database.module';
import { UserModule } from 'src/user/user.module';

@Module({
    imports: [DatabaseModule, UserModule],
    controllers: [ProjectController],
    providers: [ProjectService],
})
export class ProjectModule { }
