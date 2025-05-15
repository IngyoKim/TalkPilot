import { Controller, Get, Req, Logger } from '@nestjs/common';
import { Request } from 'express';

interface DecodedUser {
    uid: string;
    email?: string;
    name?: string;
    picture?: string;
}

@Controller('me')
export class UserController {
    private readonly logger = new Logger(UserController.name);

    @Get()
    getCurrentUser(@Req() req: Request) {
        const user = req['user'] as DecodedUser;

        this.logger.log(`요청된 사용자 정보: ${JSON.stringify(user)}`);

        return {
            uid: user.uid,
            email: user.email ?? null,
            name: user.name ?? null,
            picture: user.picture ?? null,
        };
    }
}
