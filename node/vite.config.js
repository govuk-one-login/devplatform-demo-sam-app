import { defineConfig } from "vite";
import path from "path";

export default defineConfig({
  build: {
    cssCodeSplit: true,
    rollupOptions: {
      input: {
        app: path.resolve(__dirname, "./src/public/javascripts/application.js"),
      },
      output: {
        assetFileNames: (asset) => {
          switch (asset.name.split(".").pop()) {
            case "css":
              return "public/stylesheets/[name]-[hash].css";
            case "png":
            case "jpg":
            case "ico":
            case "svg":
              return "public/images/[name][extname]";
            case "ttf":
            case "otf":
            case "woff":
            case "woff2":
              return "public/fonts/[name][extname]";
            default:
              return "public/other/[name][extname]";
          }
        },
        entryFileNames: "public/javascripts/[name]-[hash].js",
      },
    },
  },
});
