import {
    splitText, isSimilar, calculateProgress,
    calculateAccuracy, getMatchedFlags,
} from './scriptUtils';

describe('scriptUtils', () => {
    it('splitText는 특수문자 제거 후 단어 분리', () => {
        expect(splitText('안녕하세요! 반갑습니다.')).toEqual(['안녕하세요', '반갑습니다']);
    });

    it('isSimilar는 유사도 판단', () => {
        expect(isSimilar('hello', 'helo')).toBe(true);
        expect(isSimilar('강아지', '고양이')).toBe(false);
    });

    it('calculateProgress 계산', () => {
        const result = calculateProgress('나는 밥을 먹는다', '나는 밥을');
        expect(result).toBeGreaterThan(0);
    });

    it('calculateAccuracy 계산', () => {
        const result = calculateAccuracy('나는 밥을 먹는다', '나는 밥을 먹는다');
        expect(result).toBeCloseTo(1);
    });

    it('getMatchedFlags 반환 길이 확인', () => {
        const flags = getMatchedFlags('나는 밥을 먹는다', '나는 밥을');
        expect(flags.length).toBe(3);
        expect(flags[0]).toBe(true);
    });
});
