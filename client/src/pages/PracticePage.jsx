import { useState } from 'react';

import { useAuth } from '@/contexts/AuthContext';
import SpeechPractice from '../utils/SpeechPractice';

export default function PracticePage() {
    const { firebaseUser } = useAuth();
    const [isListening, setIsListening] = useState(false);
    const { transcripts, startSpeech, stopSpeech } = SpeechPractice(firebaseUser?.token);

    const handleToggle = async () => {
        if (isListening) {
            stopSpeech();
        } else {
            await startSpeech();
        }
        setIsListening((prev) => !prev);
    };

    return (
        <div style={{ padding: '24px' }}>
            <button onClick={handleToggle}>
                {isListening ? '발표 중지' : '발표 시작'}
            </button>

            <div style={{ marginTop: '20px' }}>
                {transcripts.map((t, i) => (
                    <div key={i}>[{new Date(t.timestamp).toLocaleTimeString()}] {t.transcript}</div>
                ))}
            </div>
        </div>
    );
}
