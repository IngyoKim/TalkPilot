import React, { useState, useEffect, useRef } from 'react';
import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import interactionPlugin from '@fullcalendar/interaction';

import Sidebar from '../../components/SideBar';
import ProfileDropdown from '../Profile/ProfileDropdown';

export default function SchedulePage() {
    const [events, setEvents] = useState([]);
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const calendarRef = useRef(null);

    const handleDateClick = (info) => {
        const title = prompt('일정 제목을 입력하세요:');
        if (title) {
            setEvents([...events, {
                title,
                start: info.dateStr,
                allDay: true
            }]);
        }
    };

    useEffect(() => {
        setTimeout(() => {
            calendarRef.current?.getApi().updateSize();
        }, 300);
    }, [isSidebarOpen]);

    return (
        <div style={styles.container}>
            <Sidebar isOpen={isSidebarOpen} />
            <div
                style={{
                    ...styles.content,
                    marginLeft: isSidebarOpen ? 240 : 0,
                }}
            >
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(prev => !prev)}
                />
                <div style={styles.calendarWrapper}>
                    <h2>스케줄</h2>
                    <FullCalendar
                        ref={calendarRef}
                        plugins={[dayGridPlugin, interactionPlugin]}
                        initialView="dayGridMonth"
                        dateClick={handleDateClick}
                        events={events}
                        height="auto"
                        dayHeaderDidMount={(args) => {
                            const day = args.date.getDay();
                            if (day === 0) {
                                args.el.style.color = 'red';
                            } else if (day === 6) {
                                args.el.style.color = 'blue';
                            }
                        }}
                        dayCellDidMount={(args) => {
                            const day = args.date.getDay();
                            if (day === 0) {
                                args.el.style.color = 'red';
                            } else if (day === 6) {
                                args.el.style.color = 'blue';
                            }
                        }}
                    />
                </div>
            </div>
        </div>
    );
}

const styles = {
    container: {
        display: 'flex',
    },
    content: {
        flex: 1,
        transition: 'margin-left 0.3s ease',
    },
    calendarWrapper: {
        padding: '20px',
    },
};
