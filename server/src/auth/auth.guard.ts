import {
    Injectable,
    ExecutionContext,
    UnauthorizedException,
} from '@nestjs/common';
import { AuthGuard as BaseAuthGuard } from '@nestjs/passport';
import { Reflector } from '@nestjs/core';

@Injectable()
export class AuthGuard extends BaseAuthGuard('jwt') {
    constructor(private reflector: Reflector) {
        super();
    }

    canActivate(context: ExecutionContext) {
        const isPublic = this.reflector.getAllAndOverride<boolean>('isPublic', [
            context.getHandler(),
            context.getClass(),
        ]);
        if (isPublic) return true;
        return super.canActivate(context);
    }

    handleRequest(err, user, info) {
        if (err || !user) {
            throw new UnauthorizedException('로그인 후 사용이 가능합니다.');
        }
        return user;
    }
}
