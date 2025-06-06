import { getIdToken } from '@/utils/auth/auth';
import { UserModel } from '@/models/userModel';

const API_URL = `${import.meta.env.VITE_SERVER_URL}/user`;

const nicknameCache = new Map(); // 누락된 변수 보완

/// 유저 조회
export async function fetchUserByUid(uid) {
    const token = await getIdToken();
    const res = await fetch(`${API_URL}/${uid}`, {
        headers: { Authorization: `Bearer ${token}` },
    });
    if (!res.ok) throw new Error('사용자 정보 요청 실패');
    const json = await res.json();
    return UserModel(json.uid, json);
}

/// uid로 nickname을 가져옴
export async function fetchNicknameByUid(uid) {
    if (!uid) {
        console.warn('유효하지 않은 uid입니다. 닉네임 요청을 건너뜁니다.');
        return uid;
    }

    if (nicknameCache.has(uid)) {
        return nicknameCache.get(uid);
    }

    const token = await getIdToken();
    const res = await fetch(`${API_URL}/nickname/${uid}`, {
        headers: { Authorization: `Bearer ${token}` },
    });

    if (!res.ok) {
        console.error(`닉네임 요청 실패 (uid: ${uid})`);
        return uid;
    }

    const json = await res.json();
    const nickname = json.nickname || uid;

    nicknameCache.set(uid, nickname);
    return nickname;
}

/// 유저 정보 업데이트
export async function updateUser(updates) {
    const token = await getIdToken();
    const res = await fetch(`${API_URL}`, {
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
    const res = await fetch(`${API_URL}/init`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${token}` },
    });
    if (!res.ok) throw new Error('유저 초기화 실패');
    return await res.json();
}

/// 유저 삭제
export async function deleteUser() {
    const token = await getIdToken();
    const res = await fetch(`${API_URL}`, {
        method: 'DELETE',
        headers: { Authorization: `Bearer ${token}` },
    });
    if (!res.ok) throw new Error('유저 삭제 실패');
    return await res.json();
}
