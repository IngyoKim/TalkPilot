import { Controller, Get, Req, Logger } from '@nestjs/common';
import { Request } from 'express';
import { UserController } from 'src/user/user.controller';

interface DecodedUser {
    uid: string;
    email?: string;
    name?: string;
    picture?: string;
    firebase?: {
        sign_in_provider?: string;
    };
}

@Controller()
export class AuthController {
    private readonly logger = new Logger(UserController.name);

    @Get('me')
    getCurrentUser(@Req() req: Request) {
        const user = req['user'] as DecodedUser;

        this.logger.log(`요청된 사용자 정보: ${JSON.stringify(user)}`);

        return {
            uid: user.uid,
            email: user.email,
            name: user.name,
            picture: user.picture,
            provider: user.firebase?.sign_in_provider,
        };
    }
}
