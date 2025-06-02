import { useEffect, useState } from 'react';

const TOAST_COLORS = {
    green: '#4CAF50',
    red: '#F44336',
    yellow: '#FFC107',
    blue: '#2196F3',
    info: '#2196F3',
};

export default function ToastMessage({ messages, setMessages }) {
    if (!Array.isArray(messages)) return null;

    const remove = (id) => {
        setMessages((prev) => prev.filter((m) => m.id !== id));
    };

    return (
        <div style={styles.stack}>
            {messages.map((m) => {
                if (!m || typeof m !== 'object' || !m.id) return null;
                return (
                    <Toast
                        key={m.id}
                        message={m.text || ''}
                        duration={m.duration || 3000}
                        onClose={() => remove(m.id)}
                        type={m.type || 'info'}
                    />
                );
            })}
        </div>
    );
}

function Toast({ message, duration, onClose, type }) {
    const [fadeOut, setFadeOut] = useState(false);

    useEffect(() => {
        const t1 = setTimeout(() => setFadeOut(true), duration - 500);
        const t2 = setTimeout(onClose, duration);
        return () => {
            clearTimeout(t1);
            clearTimeout(t2);
        };
    }, [duration, onClose]);

    return (
        <div
            style={{
                ...styles.toast,
                backgroundColor: TOAST_COLORS[type] || TOAST_COLORS.info,
                opacity: fadeOut ? 0 : 1,
                transform: fadeOut ? 'translateY(10px)' : 'translateY(0)',
                transition: 'all 0.5s ease',
            }}
        >
            {message}
        </div>
    );
}

const styles = {
    stack: {
        position: 'fixed',
        bottom: '24px',
        right: '24px',
        display: 'flex',
        flexDirection: 'column-reverse',
        gap: '12px',
        zIndex: 9999,
    },
    toast: {
        color: '#fff',
        padding: '12px 20px',
        borderRadius: '12px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.2)',
        fontSize: '14px',
        maxWidth: '300px',
    },
};
