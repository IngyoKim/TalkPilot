import {
    splitText,
    calculateProgressByLastMatch,
    calculateAccuracy,
    getMatchedFlags,
} from '../stt/ScriptUtils';

describe('scriptUtils', () => {
    describe('splitText', () => {
        it('특수문자 제거 후 단어 분리', () => {
            expect(splitText('안녕하세요! 반갑습니다.')).toEqual([
                '안녕하세요',
                '반갑습니다',
            ]);
        });
        it('공백 및 빈 문자열 처리', () => {
            expect(splitText('   abc   def  ')).toEqual(['abc', 'def']);
            expect(splitText('')).toEqual([]);
        });
    });

    describe('getMatchedFlags', () => {
        it('scriptChunks와 recognizedText로 플래그 배열 반환', () => {
            const script = '나는 밥을 먹는다';
            const chunks = splitText(script);
            const flags = getMatchedFlags(chunks, '나는 밥을');
            expect(flags).toEqual([true, true, false]);
        });
        it('recognizedText가 빈 문자열이면 모두 false', () => {
            const chunks = splitText('가 나 다');
            expect(getMatchedFlags(chunks, '')).toEqual([false, false, false]);
        });
        it('scriptChunks가 빈 배열이면 빈 배열 반환', () => {
            expect(getMatchedFlags([], '안녕')).toEqual([]);
        });
    });

    describe('calculateProgressByLastMatch', () => {
        it('매치 없으면 0 반환', () => {
            const chunks = splitText('가 나 다');
            expect(calculateProgressByLastMatch(chunks, '')).toBe(0);
            expect(calculateProgressByLastMatch([], '가')).toBe(0);
            expect(calculateProgressByLastMatch(chunks, '라')).toBe(0);
        });
        it('일부 매치 시 진행률 반환', () => {
            const chunks = splitText('가 나 다 라');
            expect(calculateProgressByLastMatch(chunks, '가 나')).toBe(2 / 4);
            expect(calculateProgressByLastMatch(chunks, '가 나 다')).toBe(3 / 4);
        });
        it('완전 매치 시 1 반환', () => {
            const chunks = splitText('가 나');
            expect(calculateProgressByLastMatch(chunks, '가 나')).toBe(1);
        });
    });

    describe('calculateAccuracy', () => {
        it('빈 입력 시 정확도 1 반환', () => {
            expect(calculateAccuracy([], '')).toBe(1);
            expect(calculateAccuracy(['가'], '')).toBe(1);
            expect(calculateAccuracy([], '가')).toBe(1);
        });
        it('동일한 입력 시 정확도 1 반환', () => {
            const chunks = splitText('가 나 다');
            expect(calculateAccuracy(chunks, '가 나 다')).toBeCloseTo(1);
        });
        it('부분 매치 비율 계산', () => {
            const chunks = splitText('가 나 다 라');
            // matchedCount=2, lastMatchedIndex=3 => 2/(3+1)=0.5
            expect(calculateAccuracy(chunks, '가 라')).toBeCloseTo(0.5);
        });
    });
});