import { useState, useEffect, useRef } from 'react';

import FullCalendar from '@fullcalendar/react';
import dayGridPlugin from '@fullcalendar/daygrid';
import interactionPlugin from '@fullcalendar/interaction';

import Sidebar from '@/components/SideBar';
import { useUser } from '@/contexts/UserContext';
import useProjects from '@/utils/userProjects';
import ProfileDropdown from '@/pages/Profile/ProfileDropdown';


export default function SchedulePage() {
    const { user, setUser } = useUser();
    const { projects } = useProjects(user, setUser);

    const [events, setEvents] = useState([]);
    const [isSidebarOpen, setIsSidebarOpen] = useState(true);
    const calendarRef = useRef(null);
    const selectedCellRef = useRef(null);

    useEffect(() => {
        const mapped = projects
            .filter((p) => p.scheduledDate)
            .map((p) => ({
                title: p.title,
                date: new Date(p.scheduledDate).toISOString().split('T')[0],
                id: p.id,
            }));
        setEvents(mapped);
    }, [projects]);

    useEffect(() => {
        setTimeout(() => {
            calendarRef.current?.getApi().updateSize();
        }, 300);
    }, [isSidebarOpen]);

    const handleDayHeaderDidMount = (args) => {
        const day = args.date.getDay();
        if (day === 0) args.el.style.color = 'red';
        else if (day === 6) args.el.style.color = 'blue';
    };

    const handleDayCellDidMount = (args) => {
        const day = args.date.getDay();
        if (day === 0) args.el.style.color = 'red';
        else if (day === 6) args.el.style.color = 'blue';

        args.el.style.cursor = 'pointer';

        args.el.onclick = () => {
            if (selectedCellRef.current) {
                selectedCellRef.current.style.backgroundColor = '';
                selectedCellRef.current.style.color = '';
            }
            // 현재 셀 선택 스타일 적용
            args.el.style.backgroundColor = '#D1C4E9';
            args.el.style.backgroundColor = 'rgba(103,58,183, 0.3)';
            selectedCellRef.current = args.el;
            calendarRef.current?.getApi().gotoDate(args.date);
        };
    };

    return (
        <div style={styles.container}>
            <Sidebar isOpen={isSidebarOpen} />
            <div style={{ ...styles.content, marginLeft: isSidebarOpen ? 240 : 0 }}>
                <ProfileDropdown
                    isSidebarOpen={isSidebarOpen}
                    onToggleSidebar={() => setIsSidebarOpen(prev => !prev)}
                />

                <div style={styles.calendarWrapper}>
                    <FullCalendar
                        ref={calendarRef}
                        plugins={[dayGridPlugin, interactionPlugin]}
                        initialView="dayGridMonth"
                        events={events}
                        height="auto"
                        dayHeaderDidMount={handleDayHeaderDidMount}
                        dayCellDidMount={handleDayCellDidMount}
                        headerToolbar={{
                            left: '',
                            center: 'title',
                            right: 'prev,next today'
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
