const chooseFavourite = require("./controllers/choose-favourite");

module.exports = {
  "/": {
    resetJourney: true,
    entryPoint: true,
    skip: true,
    next: "intro",
  },
  "/intro": {
    next: "choose-favourite",
  },
  "/choose-favourite": {
    controller: chooseFavourite,
    fields: ["toy"],
    next: "/oauth2/callback",
  },
};
