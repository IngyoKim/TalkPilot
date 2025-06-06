module.exports = {
    moduleFileExtensions: ['js', 'json', 'ts'],
    rootDir: 'src',
    testRegex: '.*\\.spec\\.ts$',
    transform: {
        '^.+\\.(t|j)s$': 'ts-jest',
    },
    collectCoverageFrom: [
        '{auth,project,stt,user}/**/!(*.controller|*.module).ts',
        '!auth/firebase-admin.ts',
    ],
    coverageDirectory: '../coverage',
    testEnvironment: 'node',
};
