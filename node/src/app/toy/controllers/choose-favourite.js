const BaseController = require("hmpo-form-wizard").Controller;

const {
  API: {
    PATHS: { FAVOURITE },
  },
} = require("../../../lib/config");

class ConfirmController extends BaseController {
  async saveValues(req, res, callback) {
    await super.saveValues(req, res, async () => {
      const headers = { "session-id": req.session.tokenId };

      const favourite = req.sessionModel.get("toy");

      try {
        await req.axios.post(`${FAVOURITE}`, { toy: favourite }, { headers });
        callback();
      } catch {
        callback();
      }
    });
  }
}

module.exports = ConfirmController;
