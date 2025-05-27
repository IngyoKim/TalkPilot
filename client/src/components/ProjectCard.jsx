import { useEffect, useRef, useState } from 'react';
import { Link } from 'react-router-dom';

const STATUS_COLORS = {
    진행중: '#4CAF50',
    보류: '#FFC107',
    완료: '#F44336',
};

export default function ProjectCard({ project, onEdit, onDelete, onStatusChange }) {
    const [activeDropdown, setActiveDropdown] = useState(null); // 'menu' or 'status'
    const dropdownRef = useRef();

    useEffect(() => {
        const handleClickOutside = (e) => {
            if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
                setActiveDropdown(null);
            }
        };
        document.addEventListener('mousedown', handleClickOutside);
        return () => document.removeEventListener('mousedown', handleClickOutside);
    }, []);

    return (
        <div style={{ position: 'relative' }} ref={dropdownRef}>
            <Link to={`/project/${project.id}`} style={{ textDecoration: 'none', color: 'inherit' }}>
                <div
                    style={{
                        padding: 16,
                        backgroundColor: '#fff',
                        borderRadius: 10,
                        boxShadow: '0 6px 16px rgba(0,0,0,0.3)',
                    }}
                >
                    <h3>{project.title}</h3>
                    <p>{project.description}</p>
                    <small>생성일: {new Date(project.createdAt).toLocaleDateString()}</small>
                    <br />
                    <small>수정일: {formatRelativeTime(project.updatedAt)}</small>
                </div>
            </Link>

            {/* 메뉴 버튼 */}
            <div
                style={{ position: 'absolute', top: 8, right: 32, cursor: 'pointer' }}
                onClick={() =>
                    setActiveDropdown((prev) => (prev === 'menu' ? null : 'menu'))
                }
            >
                ⋮
            </div>

            {/* 상태 점 버튼 */}
            <div
                style={{
                    position: 'absolute',
                    top: 8,
                    right: 8,
                    width: 14,
                    height: 14,
                    borderRadius: '50%',
                    border: '1px solid #ccc',
                    backgroundColor: STATUS_COLORS[project.status],
                    cursor: 'pointer',
                }}
                onClick={() =>
                    setActiveDropdown((prev) => (prev === 'status' ? null : 'status'))
                }
            />

            {/* 메뉴 드롭다운 */}
            {activeDropdown === 'menu' && (
                <div style={dropdownStyle}>
                    <div style={dropdownItemStyle} onClick={() => onEdit(project)}>수정</div>
                    <div style={dropdownItemStyle} onClick={() => onDelete(project.id)}>삭제</div>
                </div>
            )}

            {/* 상태 드롭다운 */}
            {activeDropdown === 'status' && (
                <div style={dropdownStyle}>
                    {Object.entries(STATUS_COLORS).map(([status, color]) => (
                        <div
                            key={status}
                            style={dropdownItemStyle}
                            onClick={() => onStatusChange(project.id, status)}
                        >
                            <div style={{ ...dotStyle, backgroundColor: color }} />
                            <span>{status}</span>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
}

const formatRelativeTime = (date) => {
    const seconds = Math.floor((new Date() - new Date(date)) / 1000);
    if (seconds < 60) return `${seconds}초 전`;
    const minutes = Math.floor(seconds / 60);
    if (minutes < 60) return `${minutes}분 전`;
    const hours = Math.floor(minutes / 60);
    if (hours < 24) return `${hours}시간 전`;
    const days = Math.floor(hours / 24);
    return `${days}일 전`;
};

const dropdownStyle = {
    position: 'absolute',
    top: 30,
    right: 8,
    backgroundColor: '#fff',
    border: '1px solid #ccc',
    borderRadius: 6,
    boxShadow: '0 2px 6px rgba(0,0,0,0.2)',
    zIndex: 10,
};

const dropdownItemStyle = {
    display: 'flex',
    alignItems: 'center',
    gap: 8,
    padding: '6px 12px',
    cursor: 'pointer',
    fontSize: 13,
};

const dotStyle = { width: 10, height: 10, borderRadius: '50%' };
