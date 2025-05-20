import { useState } from "react";

export default function ProjectForm({ onSubmit }) {
    const [title, setTitle] = useState("");
    const [description, setDescription] = useState("");
    const [date, setDate] = useState("");
    const [presenters, setPresenters] = useState("");

    const handleSubmit = (e) => {
        e.preventDefault();
        onSubmit({ title, description, date, presenters: presenters.split(',') });
    };

    return (
        <form onSubmit={handleSubmit} className="project-form">
            <label>프로젝트 제목</label>
            <input value={title} onChange={e => setTitle(e.target.value)} required />

            <label>발표 날짜</label>
            <input type="date" value={date} onChange={e => setDate(e.target.value)} required />

            <label>설명</label>
            <textarea value={description} onChange={e => setDescription(e.target.value)} />

            <label>발표자 (쉼표로 구분)</label>
            <input value={presenters} onChange={e => setPresenters(e.target.value)} />

            <button type="submit">프로젝트 생성</button>
        </form>
    );
}
