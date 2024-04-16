FROM node:18.20.2@sha256:726dd917226a1bb5cc431e61d2e068a2275056fbf890dddf26b4458a420da371 AS builder

WORKDIR /app

COPY package.json package-lock.json ./
COPY /src ./src

RUN npm install
RUN npm run build

RUN npm prune

FROM node:18.20.2-alpine3.19@sha256:3bb0be4d2b8ff82fb25014db75686c1946bf4c51bd37a7e1208a7fc656988eba AS final

RUN ["apk", "--no-cache", "upgrade"]
RUN ["apk", "add", "--no-cache", "tini"]
RUN ["apk", "add", "--no-cache", "curl"]

WORKDIR /app

# Copy in compile assets and deps from build container
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./
COPY --from=builder /app/package-lock.json ./
COPY --from=builder /app/src ./src

# Add in dynatrace layer
COPY --from=khw46367.live.dynatrace.com/linux/oneagent-codemodules-musl:nodejs / /
ENV LD_PRELOAD /opt/dynatrace/oneagent/agent/lib64/liboneagentproc.so
ENV DT_LOGLEVELCON INFO

ENV NODE_ENV "production"
ENV PORT 8000
EXPOSE $PORT

HEALTHCHECK CMD curl --fail http://localhost:8000/healthcheck || exit 1

ENTRYPOINT ["tini", "--"]

CMD ["node", "src/app.js"]
