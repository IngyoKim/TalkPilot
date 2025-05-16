import { Controller, Get, Post, Patch, Delete, Req, Body, Logger } from '@nestjs/common';
import { Request } from 'express';
import { UserService } from './user.service';
import { admin } from '../auth/firebase-admin';

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
export class UserController {
    private readonly logger = new Logger(UserController.name);

    constructor(private readonly userService: UserService) { }

    /// 현재 로그인한 사용자 정보 조회
    @Get('me')
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

    /// Firebase 인증 후 최초 로그인 시 사용자 초기화
    @Post('user/init')
    async initUser(@Req() req: Request) {
        const user = req['user'] as DecodedUser;
        const loginMethod = user.firebase?.sign_in_provider ?? 'unknown';
        await this.userService.initUser(user, loginMethod);
        return { success: true };
    }

    /// 사용자 정보 수정
    @Patch('user')
    async updateUser(@Req() req: Request, @Body() updates: Record<string, any>) {
        const uid = (req.user as admin.auth.DecodedIdToken).uid;
        await this.userService.updateUser(uid, updates);
        return { success: true };
    }

    /// 사용자 삭제(아마 쓸 일은 없을 듯?)
    @Delete('user')
    async deleteUser(@Req() req: Request) {
        const uid = (req.user as admin.auth.DecodedIdToken).uid;
        await this.userService.deleteUser(uid);
        return { success: true };
    }
}
