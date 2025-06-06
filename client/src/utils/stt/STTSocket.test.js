import { describe, it, vi, expect, beforeEach } from 'vitest';
import useSttSocket from './SttSocket';
import { renderHook, act } from '@testing-library/react';

vi.mock('socket.io-client', () => ({
    default: vi.fn(() => {
        return {
            on: vi.fn((event, cb) => {
                if (event === 'connect') cb();
            }),
            emit: vi.fn(),
            disconnect: vi.fn(),
        };
    }),
}));

vi.mock('@/contexts/AuthContext', () => ({
    useAuth: () => ({ authUser: { token: 'test-token' } }),
}));

describe('useSttSocket', () => {
    it('connect → isConnected true로 전환', async () => {
        const { result } = renderHook(() => useSttSocket());
        await act(() => result.current.connect());
        expect(result.current.isConnected).toBe(true);
    });

    it('disconnect → isConnected false로 전환', () => {
        const { result } = renderHook(() => useSttSocket());
        act(() => result.current.disconnect());
        expect(result.current.isConnected).toBe(false);
    });
});
