import {
    Controller,
    Get,
    Post,
    Patch,
    Delete,
    Req,
    Body,
    Param,
    NotFoundException,
    InternalServerErrorException,
} from '@nestjs/common';
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
        console.log('[UserController] getUserById() 호출됨:', uid);

        try {
            const user = await this.userService.readUser(uid);

            if (!user) {
                console.warn(`[UserController] 유저 정보 없음: ${uid}`);
                throw new NotFoundException('User not found');
            }

            console.log('[UserController] 유저 정보 조회 성공:', user);
            return { uid, ...user };
        } catch (err) {
            console.error('[UserController] 유저 조회 중 오류:', err);
            throw new InternalServerErrorException('유저 정보를 불러오는 중 오류 발생');
        }
    }

    @Post('init')
    async initUser(@Req() req: Request) {
        const user = req['user'] as DecodedUser;
        const loginMethod = user.firebase?.sign_in_provider ?? 'unknown';
        console.log('[UserController] initUser() 호출됨:', user.uid, loginMethod);

        try {
            await this.userService.initUser(user, loginMethod);
            console.log('[UserController] 유저 초기화 완료:', user.uid);
            return { success: true };
        } catch (err) {
            console.error('[UserController] 유저 초기화 실패:', err);
            throw new InternalServerErrorException('유저 초기화 실패');
        }
    }

    @Patch()
    async updateUser(@Req() req: Request, @Body() updates: Record<string, any>) {
        const uid = (req['user'] as DecodedUser).uid;
        console.log('[UserController] updateUser() 호출됨:', uid, updates);

        try {
            await this.userService.updateUser(uid, updates);
            console.log('[UserController] 유저 업데이트 성공:', uid);
            return { success: true };
        } catch (err) {
            console.error('[UserController] 유저 업데이트 실패:', err);
            throw new InternalServerErrorException('유저 업데이트 실패');
        }
    }

    @Delete()
    async deleteUser(@Req() req: Request) {
        const uid = (req['user'] as DecodedUser).uid;
        console.log('[UserController] deleteUser() 호출됨:', uid);

        try {
            await this.userService.deleteUser(uid);
            console.log('[UserController] 유저 삭제 성공:', uid);
            return { success: true };
        } catch (err) {
            console.error('[UserController] 유저 삭제 실패:', err);
            throw new InternalServerErrorException('유저 삭제 실패');
        }
    }
}
