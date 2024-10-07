const fg = require("fast-glob");
// const path = require("path");

function loadAssets(app, assetPath, hashBetween = { start: "-", end: "." }) {
  const assets = fg.sync(assetPath);
  const pathsAndFiles = assets.map((asset) => {
    const pathParts = asset.split("/");
    const hashedFileName = pathParts[pathParts.length - 1];
    const fileName = hashedFileName.split(hashBetween.start)[0];
    const hashedExtension = hashedFileName.split(hashBetween.start)[1];
    const extension = hashedExtension.substring(
      hashedExtension.indexOf(hashBetween.end) + 1
    );
    return { hashedFileName, fileName: `${fileName}.${extension}` };
  });

  pathsAndFiles.forEach((pathAndFile) => {
    app.locals = app.locals || {};
    app.locals.assets = app.locals.assets || {};
    app.locals.assets[pathAndFile.fileName] = pathAndFile.hashedFileName;
  });
}

module.exports = {
  loadAssets,
};
