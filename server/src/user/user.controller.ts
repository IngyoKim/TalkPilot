import { Controller, Get, Req } from '@nestjs/common';

@Controller('me')
export class UserController {
    @Get()
    getCurrentUser(@Req() req) {
        const user = req.user;
        return {
            uid: user.uid,
            email: user.email,
            name: user.name || null,
            picture: user.picture || null,
        };
    }
}
