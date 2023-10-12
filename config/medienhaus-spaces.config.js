const WebpackConfig = require('./webpack.config.js');

// eslint-disable-next-line no-undef
module.exports = {
    publicRuntimeConfig: {
        name: 'medienhaus/spaces',
        authProviders: {
            matrix: {
                baseUrl: 'http://matrix.localhost',
                allowCustomHomeserver: true,
            },
            etherpad: {
                path: '/write',
                baseUrl: 'http://etherpad.localhost/p',
                myPads: {
                    api: 'http://etherpad.localhost/mypads/api',
                },
            },
            spacedeck: {
                path: '/sketch',
                baseUrl: 'http://spacedeck.localhost',
            },
        },
        account: {
            allowAddingNewEmails: false,
        },
        chat: {
            pathToElement: 'http://localhost/element',
        },
        contextRootSpaceRoomId: '',
    },
    rewrites() {
        const rewriteConfig = [];

        if (this.publicRuntimeConfig.authProviders.etherpad) {
            rewriteConfig.push({
                source: this.publicRuntimeConfig.authProviders.etherpad.path,
                destination: '/etherpad',
            },
            {
                source: this.publicRuntimeConfig.authProviders.etherpad.path + '/:roomId',
                destination: '/etherpad/:roomId',
            });
        }

        if (this.publicRuntimeConfig.authProviders.spacedeck) {
            rewriteConfig.push({
                source: this.publicRuntimeConfig.authProviders.spacedeck.path,
                destination: '/spacedeck',
            },
            {
                source: this.publicRuntimeConfig.authProviders.spacedeck.path + '/:roomId',
                destination: '/spacedeck/:roomId',
            });
        }

        return rewriteConfig;
    },
    output: 'standalone',
    webpack: WebpackConfig,
};
