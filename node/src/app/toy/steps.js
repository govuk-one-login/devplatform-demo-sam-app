const chooseFavourite = require("./controllers/choose-favourite");

module.exports = {
  "/": {
    resetJourney: true,
    entryPoint: true,
    skip: true,
    next: "intro",
  },
  "/intro": {
    resetJourney: true,
    entryPoint: true,
    next: "choose-favourite",
  },
  "/choose-favourite": {
    controller: chooseFavourite,
    fields: ["toy"],
    next: "/oauth2/callback",
  },
};
