import { getIdToken } from '../auth/auth';
import { UserModel } from '../../models/userModel';

/// 유저 조회
export async function fetchUserByUid(uid) {
    const token = await getIdToken();
    const res = await fetch(`/api/user/${uid}`, {
        headers: { Authorization: `Bearer ${token}` },
    });
    if (!res.ok) throw new Error('사용자 정보 요청 실패');
    const json = await res.json();
    return UserModel(json.uid, json);
}

/// 유저 정보 업데이트
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

/// 유저 초기화 (서버에서 누락 필드 채우기 포함)
export async function initUser() {
    const token = await getIdToken();
    const res = await fetch('/api/user/init', {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` },
    });
    if (!res.ok) throw new Error('유저 초기화 실패');
    return await res.json();
}

/// 유저 삭제
export async function deleteUser() {
    const token = await getIdToken();
    const res = await fetch('/api/user', {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${token}` },
    });
    if (!res.ok) throw new Error('유저 삭제 실패');
    return await res.json();
}
