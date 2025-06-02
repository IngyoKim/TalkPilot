import { useEffect, useRef, useState } from 'react';

/// 실시간으로 Cpm 계산산
export default function LiveCpm(userAverageCpm = 0) {
    const [cpm, setCpm] = useState(0);
    const [status, setStatus] = useState('대기 중');
    const totalCharRef = useRef(0);
    const startTimeRef = useRef(null);
    const timerRef = useRef(null);

    const start = () => {
        totalCharRef.current = 0;
        startTimeRef.current = Date.now();

        timerRef.current = setInterval(() => {
            const elapsedMin = (Date.now() - startTimeRef.current) / 60000;
            if (elapsedMin > 0.1) {
                const curCpm = totalCharRef.current / elapsedMin;
                setCpm(Math.round(curCpm));
                setStatus(getStatus(userAverageCpm, curCpm));
            }
        }, 1000);
    };

    const update = (text) => {
        totalCharRef.current = text.replace(/\s/g, '').length;
    };

    const stop = () => {
        clearInterval(timerRef.current);
        setStatus('종료');
    };

    const getStatus = (base, cur) => {
        if (cur < base * 0.7) return '느림';
        if (cur > base * 1.3) return '빠름';
        return '적당함';
    };

    return { cpm, status, start, update, stop };
}
