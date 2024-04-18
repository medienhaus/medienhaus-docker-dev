module.exports = {
  name: "medienhaus/spaces",
  authProviders: {
    matrix: {
      baseUrl: "http://matrix.localhost",
      allowCustomHomeserver: true,
    },
    etherpad: {
      path: "/write",
      baseUrl: "http://etherpad.localhost/p",
      myPads: {
        api: "http://etherpad.localhost/mypads/api",
      },
    },
    spacedeck: {
      path: "/sketch",
      baseUrl: "http://spacedeck.localhost",
    },
    tldraw: {
      path: "/draw",
    },
  },
  account: {
    allowAddingNewEmails: false,
  },
  chat: {
    pathToElement: "http://localhost/element",
  },
  contextRootSpaceRoomId: process.env.MEDIENHAUS_ROOT_CONTEXT_SPACE_ID,
  /* @NOTE: clear(!) client-side localStorage if value defined in `versionToken` is */
  /* *not_equal* to value stored in or does *not_exist* in client-side localStorage */
  // localStorage: {
  //   clearAfterUpgrade: true,
  //   versionToken: "1",
  // },
  templates: {
    // context: [
    //   "context",
    // ],
    item: [
      "etherpad",
      "spacedeck",
      "tldraw",
      "link",
    ],
  },
};
