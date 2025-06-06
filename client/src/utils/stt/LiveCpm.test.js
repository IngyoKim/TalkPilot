import { describe, it, vi, expect } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import LiveCpm from './LiveCpm';

vi.useFakeTimers();

describe('LiveCpm', () => {
    it('start → update → stop 흐름에서 cpm 및 상태 갱신', () => {
        const { result } = renderHook(() => LiveCpm(200));

        act(() => {
            result.current.start();
            result.current.update('테스트 문장입니다'); // 10글자
        });

        act(() => {
            vi.advanceTimersByTime(7000); // 7초 경과
        });

        // 상태가 바뀔 시간 제공
        expect(result.current.cpm).toBeGreaterThan(0);
        expect(['느림', '적당함', '빠름']).toContain(result.current.status);

        act(() => result.current.stop());
        expect(result.current.status).toBe('종료');
    });
});
