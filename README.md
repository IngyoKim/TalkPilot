<h1 align="center" style="border-bottom: none">
    <b>
        <a href="https://github.com/IngyoKim/TalkPilot">TalkPilot</a><br>
    </b>
   ⭐️ The Open Source Help Your Presentation ⭐️<br>
</h1>

<p align="center">
    발표를 더 똑똑하게, 함께 준비해요. <br>
    <i>Make Your Speech Smarter</i>
</p>

<p align="center">
    <a href="https://flutter.dev/"><img src="https://img.shields.io/badge/Flutter-%2302569B.svg?logo=flutter&logoColor=white" alt="Flutter" /></a>
    <a href="https://react.dev/"><img src="https://img.shields.io/badge/React-%2361DAFB.svg?logo=react&logoColor=black" alt="React" /></a>
    <a href="https://nestjs.com/"><img src="https://img.shields.io/badge/NestJS-%23E0234E.svg?logo=nestjs&logoColor=white" alt="NestJS" /></a>
    <a href="https://firebase.google.com/"><img src="https://img.shields.io/badge/Firebase-%23FFCA28.svg?logo=firebase&logoColor=black" alt="Firebase" /></a>
    <a href="https://cloud.google.com/speech-to-text"><img src="https://img.shields.io/badge/Google%20Cloud%20STT-%234285F4.svg?logo=googlecloud&logoColor=white" alt="Google Cloud STT" /></a>
</p>

<p align="center">
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License: MIT" /></a>
    <a href="#"><img src="https://img.shields.io/badge/platform-iOS|Android|Web-blue.svg" alt="Platform" /></a>
</p>

---

## 소개 (Introduction)

TalkPilot은 발표자의 발표 역량 향상을 목표로 하는 오픈소스 플랫폼입니다.  
실시간 음성 인식과 대본 분석, 발표 연습 등의 기능을 통해 발표의 질을 개선할 수 있습니다.  
<i>(TalkPilot helps speakers improve their presentation skills with real-time transcription, script analysis.)</i>

---

## 주요 기능 (Key Features)

- **실시간 음성 인식 (Real-Time Speech Recognition)**  
  Google Cloud STT 기반 실시간 텍스트 변환

- **대본 분석 및 비교 (Script Analysis & Comparison)**  
  대본 분석을 통한 예상시간 계산과 실제 발화 내용 비교 시각화

- **발표 성과 분석 (Performance Analytics)**  
  발표 시간, CPM, 군더더기어 빈도 등 제공

- **스케쥴 관리(Schedule Controll)**
  발표 일정을 등록하여 한 눈에 확인 기능 제공

- **크로스플랫폼 지원 (Cross-Platform Support)**  
  모바일 앱(Android/iOS), 웹 클라이언트 제공

---

## 기술 스택 (Tech Stack)

| 구성 요소 (Component) | 기술 (Technology)                          |
| -------------------- | ------------------------------------------ |
| 모바일 앱             | Flutter (Dart)                             |
| 웹 프론트엔드         | React (TypeScript)                         |
| 백엔드 API            | NestJS (Node.js/TypeScript)                |
| 데이터베이스           | Firebase Realtime Database                 |
| 음성 인식              | Google Cloud Speech-to-Text API            |
| 사용자 인증            | Firebase Authentication                    |
| OAuth 로그인           | Google / Kakao SDK                         |

---

## 의존성 목록 (Dependencies Overview)

### 📱 Flutter App

| 패키지명                         | 버전    |
|---------------------------------|---------|
| flutter                         | (sdk)   |
| flutter_lints                   | ^5.0.0  |
| http                            | ^1.3.0  |
| intl                            | ^0.20.2 |
| cupertino_icons                 | ^1.0.8  |
| provider                        | ^6.1.4  |
| speech_to_text                  | ^7.0.0  |
| flutter_dotenv                  | ^5.2.1  |
| shared_preferences              | ^2.5.3  |
| google_sign_in                  | ^6.3.0  |
| kakao_flutter_sdk_common        | ^1.9.7+3|
| kakao_flutter_sdk_user          | ^1.9.7+3|
| firebase_core                   | ^3.13.0 |
| firebase_auth                   | ^5.5.2  |
| firebase_database               | ^11.3.5 |
| uuid                            | ^4.5.1  |
| fluttertoast                    | ^8.2.4  |
| archive                         | ^3.3.7  |
| xml                             | ^6.3.0  |
| file_picker                     | ^10.1.0 |
| table_calendar                  | ^3.0.9  |
| web_socket_channel              | ^3.0.3  |
| flutter_sound                   | ^9.2.13 |
| permission_handler              | ^11.0.1 |
| socket_io_client                 | ^3.1.2  |
| flutter_tts                     | ^3.8.3  |

---

### 🌐 Web (React Client)

| 패키지명                        | 버전    |
|--------------------------------|---------|
| react                          | ^19.0.0 |
| react-dom                      | ^19.0.0 |
| react-router-dom               | ^7.5.2  |
| firebase                       | ^11.6.1 |
| framer-motion                  | ^12.11.3|
| react-icons                    | ^5.5.0  |
| uuid                           | ^11.1.0 |
| @fullcalendar/core             | ^6.1.17 |
| @fullcalendar/daygrid          | ^6.1.17 |
| @fullcalendar/interaction      | ^6.1.17 |
| @fullcalendar/react            | ^6.1.17 |
| socket.io-client                | ^4.8.1  |
| mammoth                        | ^1.9.1  |

---

### 🖥️ Backend (NestJS Server)

| 패키지명                        | 버전    |
|--------------------------------|---------|
| @nestjs/common                  | ^11.0.1 |
| @nestjs/core                    | ^11.0.1 |
| @nestjs/passport                | ^11.0.5 |
| @nestjs/platform-express        | ^11.0.1 |
| @nestjs/platform-socket.io      | ^11.1.0 |
| @nestjs/websockets              | ^11.1.0 |
| socket.io                       | ^4.8.1  |
| socket.io-client                 | ^4.8.1  |
| firebase-admin                  | ^13.3.0 |
| @google-cloud/speech            | ^7.0.1  |
| passport                        | ^0.7.0  |
| passport-jwt                    | ^4.0.1  |
| dotenv                          | ^16.5.0 |
| rxjs                            | ^7.8.1  |
| reflect-metadata                | ^0.2.2  |

---

### 🔥 Firebase Functions

| 패키지명                        | 버전    |
|--------------------------------|---------|
| firebase-admin                  | ^12.6.0 |
| firebase-functions              | ^6.0.1  |
| cors                            | ^2.8.5  |

---


---

## 설치 및 실행 (Getting Started)

### 저장소 클론

```bash
git clone https://github.com/IngyoKim/TalkPilot.git
cd TalkPilot
```

### 모바일 앱 실행 (Flutter)

```bash
cd app
flutter pub get
flutter run
```

### 웹 클라이언트 실행 (React)

```bash
cd client
npm install
npm run dev
```

### 백엔드 서버 실행 (NestJS)

```bash
cd server
npm install
npm run start:dev
```

### Firebase 설정

- Firebase 프로젝트 생성
- Authentication (Google, Kakao) 활성화
- Realtime Database 활성화
- `client/src/firebaseConfig.js`, `app/lib/firebase_config.dart` 설정 추가

---

## 프로젝트 구조 (Project Structure)

```plaintext
TalkPilot/
├── app/             # Flutter 모바일 앱
├── client/          # React 웹 클라이언트
├── server/          # NestJS 백엔드 서버
├── functions/       # Firebase Cloud Functions
├── LICENSE/         # 프로젝트 LICENSE
└── README.md        # 프로젝트 README
```

---

## 데모 (Demo)

App Demo: [Android 앱 설치](https://github.com/IngyoKim/TalkPilot/releases/tag/v1.0.5)
Web Demo: [웹 링크](https://talkpilot.vercel.app)

---

## 기여 방법 (Contributing)

TalkPilot은 누구나 기여할 수 있는 오픈소스 프로젝트입니다.

1️⃣ 저장소 포크 후 브랜치 생성  
2️⃣ 변경사항 커밋  
3️⃣ 브랜치 푸시  
4️⃣ Pull Request 생성

GitHub Issues 및 Discussions에서 피드백과 기여를 환영합니다.

---

## 커뮤니티 (Community)

- [GitHub Discussions](https://github.com/IngyoKim/TalkPilot/discussions)
- [Discord](https://discord.gg/zrFVVUcY)
- 대표 참여자:
  - [김민규](https://github.com/Asdfuxk)  
    Email: asdfxxk777@gmail.com
    Phone: 010-8120-2338
  - [김인교](https://github.com/IngyoKim)  
    Email: a58276976@gmail.com
    Phone: 010-5802-5827
  - [전상민](https://github.com/A-X-Y-S-T)  
    Email: jeonsm0404@gmail.com
    Phone: 010-5028-4701

---

## Contributor

<a href="https://github.com/IngyoKim/TalkPilot/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=IngyoKim/TalkPilot" />
</a>

---

## 라이선스 (License)

MIT License  
[LICENSE](LICENSE) 파일 참조

---

<p align="center">
<b>© 2025 OmO Team — Open Source Software (OSS)</b><br>
TalkPilot과 함께 발표를 더 스마트하게 준비하세요!
</p>

