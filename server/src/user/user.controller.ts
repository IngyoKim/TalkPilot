import { Controller, Get, Post, Patch, Delete, Req, Body, Logger, NotFoundException, Param } from '@nestjs/common';
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

    /// Firebase 인증 확인용 (간단한 사용자 식별 정보만 제공)
    @Get('me')
    getCurrentUser(@Req() req: Request) {
        const user = req['user'] as DecodedUser;
        this.logger.log(`인증 확인: ${user.uid}`);
        return { uid: user.uid };
    }

    /// 사용자 정보 조회
    @Get('user/:uid')
    async getUserById(@Param('uid') uid: string) {
        const user = await this.userService.readUser(uid);
        if (!user) throw new NotFoundException('User not found');
        return user;
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

    /// 사용자 삭제
    @Delete('user')
    async deleteUser(@Req() req: Request) {
        const uid = (req.user as admin.auth.DecodedIdToken).uid;
        await this.userService.deleteUser(uid);
        return { success: true };
    }
}
