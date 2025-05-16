import { getIdToken } from '../auth/auth';

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
