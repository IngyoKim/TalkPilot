import { getIdToken } from '../auth/auth';

/// Nest에서 uid로 유저 정보를 가져옴.
export async function fetchUserByUid(uid) {
    const token = await getIdToken();
    const res = await fetch(`/api/user/${uid}`, {
        headers: {
            Authorization: `Bearer ${token}`,
        },
    });

    if (!res.ok) throw new Error('사용자 정보 요청 실패');
    return await res.json();
}


export async function updateUser(updates) {
    const token = await getIdToken();

    const res = await fetch('/api/user', {
        method: 'PATCH',
        headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify(updates),
    });

    if (!res.ok) throw new Error('사용자 정보 업데이트 실패');
    return await res.json();
}