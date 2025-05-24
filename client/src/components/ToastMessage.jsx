import { useEffect } from 'react';

export default function ToastMessage({ message, onClose, duration = 3000 }) {
    useEffect(() => {
        const timer = setTimeout(() => onClose(), duration);
        return () => clearTimeout(timer);
    }, [onClose, duration]);

    return (
        <div style={styles.toast}>
            {message}
        </div>
    );
}

const styles = {
    toast: {
        position: 'fixed',
        bottom: '24px',
        right: '24px',
        backgroundColor: '#673AB7',
        color: '#fff',
        padding: '12px 20px',
        borderRadius: '12px',
        boxShadow: '0 4px 12px rgba(0,0,0,0.2)',
        fontSize: '14px',
        zIndex: 9999,
        animation: 'fadeSlideUp 0.4s ease',
    }
};
