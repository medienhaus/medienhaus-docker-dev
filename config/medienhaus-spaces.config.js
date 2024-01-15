module.exports = {
    name: 'medienhaus/spaces',
    authProviders: {
        matrix: {
            baseUrl: 'https://matrix.spaces.local',
            allowCustomHomeserver: true,
        },
        etherpad: {
            path: '/write',
            baseUrl: 'https://etherpad.spaces.local/p',
            myPads: {
                api: 'https://etherpad.spaces.local/mypads/api',
            },
        },
        spacedeck: {
            path: '/sketch',
            baseUrl: 'https://spacedeck.spaces.local',
        },
    },
    account: {
        allowAddingNewEmails: false,
    },
    chat: {
        pathToElement: 'https://spaces.local/element',
    },
    contextRootSpaceRoomId: process.env.MEDIENHAUS_ROOT_CONTEXT_SPACE_ID,
};
