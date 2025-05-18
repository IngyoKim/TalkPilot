import { Controller, Get, Req } from '@nestjs/common';
import { Request } from 'express';

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
    @Get('me')
    getCurrentUser(@Req() req: Request) {
        const user = req['user'] as DecodedUser;
        return {
            uid: user.uid,
            email: user.email,
            name: user.name,
            picture: user.picture,
            provider: user.firebase?.sign_in_provider,
        };
    }
}
