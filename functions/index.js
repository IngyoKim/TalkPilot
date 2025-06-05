/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */
// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started
//

/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const cors = require("cors");

var serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

exports.createCustomToken = functions.https.onRequest(async (request, response) => {
    cors({
        origin: ["http://localhost:5173", "http://127.0.0.1:5173", "https://talkpilot.vercel.app"],
        methods: ["POST"],
        credentials: false,
    })(request, response, async () => {

        const user = request.body;
        const uid = `kakao_${user.uid}`; // uid 형식 준수

        /// 필수로 받을 정보만 남기고, 선택 사항은 조건부로 포함
        const updateParams = {};
        if (user.email) updateParams.email = user.email;
        if (user.photoURL) updateParams.photoURL = user.photoURL;
        if (user.displayName) updateParams.displayName = user.displayName;

        try {
            /// 사용자 업데이트 또는 생성
            try {
                await admin.auth().updateUser(uid, updateParams);
                console.log("User updated:", uid);
            } catch (e) {
                /// 사용자가 없으면 새로 생성
                updateParams["uid"] = uid;
                await admin.auth().createUser(updateParams);
                console.log("User created:", uid);
            }

            /// 커스텀 토큰 생성
            const token = await admin.auth().createCustomToken(uid);
            response.json({ token });
        } catch (e) {
            console.error("e creating custom token:", e);
            response.status(500).json({ e: "error creating custom token" });
        }
    });
});