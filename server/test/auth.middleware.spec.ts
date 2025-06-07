import { AuthMiddleware } from '../src/auth/auth.middleware';
import { UnauthorizedException } from '@nestjs/common';

jest.mock('../src/auth/firebase-admin', () => {
    const verifyIdTokenMock = jest.fn();

    return {
        admin: {
            auth: jest.fn(() => ({
                verifyIdToken: verifyIdTokenMock,
            })),
            __verifyIdTokenMock: verifyIdTokenMock,
        },
    };
});

import { admin } from '../src/auth/firebase-admin';

describe('AuthMiddleware', () => {
    let middleware: AuthMiddleware;

    beforeEach(() => {
        middleware = new AuthMiddleware();
    });

    it('should throw UnauthorizedException if no token provided', async () => {
        const req = { headers: {} } as any;
        const res = {} as any;
        const next = jest.fn();

        await expect(middleware.use(req, res, next)).rejects.toThrow(UnauthorizedException);
    });

    it('should throw UnauthorizedException if token invalid', async () => {
        ((admin as any).auth().verifyIdToken as jest.Mock).mockRejectedValue(new Error('Invalid token'));

        const req = { headers: { authorization: 'Bearer invalid_token' } } as any;
        const res = {} as any;
        const next = jest.fn();

        await expect(middleware.use(req, res, next)).rejects.toThrow(UnauthorizedException);
    });

    /// 예전에 여기서 막혔으니 유의
    it('should set req.user and call next if token valid', async () => {
        const mockDecodedToken = { uid: 'test_uid', email: 'test@example.com' };
        ((admin as any).auth().verifyIdToken as jest.Mock).mockResolvedValue(mockDecodedToken);

        const req = { headers: { authorization: 'Bearer valid_token' } } as any;
        const res = {} as any;
        const next = jest.fn();

        await middleware.use(req, res, next);

        expect(req.user).toEqual(mockDecodedToken);
        expect(next).toHaveBeenCalled();
    });
});
