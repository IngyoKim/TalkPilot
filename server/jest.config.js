module.exports = {
    moduleFileExtensions: ['js', 'json', 'ts'],
    rootDir: '.',
    testRegex: 'test/.*\\.spec\\.ts$',
    transform: {
        '^.+\\.(t|j)s$': 'ts-jest',
    },
    collectCoverageFrom: [
        'src/{auth,project,stt,user}/**/!(*.controller|*.module).ts',
        '!src/auth/firebase-admin.ts',
    ],
    coverageDirectory: './coverage',
    testEnvironment: 'node',
};
