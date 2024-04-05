FROM node:18.20.1@sha256:9f8f424027560a652e243fb8e3d03780397d00a3790cc5d4db74bfbfbdb69a05 AS builder

WORKDIR /app

COPY package.json package-lock.json ./
COPY /src ./src

RUN npm install
RUN npm run build

RUN npm prune

FROM node:18.20.1-alpine3.19@sha256:cbd31807a8b4621a9dea342a03f14e8c53f5ca78a395f426bb5bd0e7f071c47c AS final

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
