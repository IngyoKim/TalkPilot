import { Controller, Get, Req } from '@nestjs/common';
import { Request } from 'express';

interface DecodedUser {
    uid: string;
    email?: string;
    name?: string;
    picture?: string;
}

@Controller('me')
export class UserController {
    @Get()
    getCurrentUser(@Req() req: Request) {
        const user = req['user'] as DecodedUser;

        return {
            uid: user.uid,
            email: user.email ?? null,
            name: user.name ?? null,
            picture: user.picture ?? null,
        };
    }
}
