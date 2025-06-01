import { Controller, Get, Post, Patch, Delete, Req, Body, Param, NotFoundException } from '@nestjs/common';
import { Request } from 'express';
import { UserService } from './user.service';

interface DecodedUser {
    uid: string;
    email?: string;
    name?: string;
    picture?: string;
    firebase?: { sign_in_provider?: string };
}

@Controller('user')
export class UserController {
    constructor(private readonly userService: UserService) { }

    @Get(':uid')
    async getUserById(@Param('uid') uid: string) {
        const user = await this.userService.readUser(uid);
        if (!user) throw new NotFoundException('User not found');
        return { uid, ...user };
    }

    @Get('nickname/:uid')
    async getNicknameByUid(@Param('uid') uid: string) {
        const user = await this.userService.readUser(uid);
        if (!user) throw new NotFoundException('User not found');
        return { nickname: user.nickname ?? uid };
    }

    @Post('init')
    async initUser(@Req() req: Request) {
        const user = req['user'] as DecodedUser;
        const loginMethod = user.firebase?.sign_in_provider ?? 'unknown';
        await this.userService.initUser(user, loginMethod);
        return { success: true };
    }

    @Patch()
    async updateUser(@Req() req: Request, @Body() updates: Record<string, any>) {
        const uid = (req['user'] as DecodedUser).uid;
        await this.userService.updateUser(uid, updates);
        return { success: true };
    }

    @Delete()
    async deleteUser(@Req() req: Request) {
        const uid = (req['user'] as DecodedUser).uid;
        await this.userService.deleteUser(uid);
        return { success: true };
    }
}
