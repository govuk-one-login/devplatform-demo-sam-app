# node:20-alpine
FROM node@sha256:6178e78b972f79c335df281f4b7674a2d85071aae2af020ffa39f0a770265435 AS builder

WORKDIR /app

COPY package.json package-lock.json ./
COPY /src ./src

RUN npm install
RUN npm run build

RUN npm prune

# node:20-alpine
FROM node@sha256:6178e78b972f79c335df281f4b7674a2d85071aae2af020ffa39f0a770265435 AS final


ENV USER=nodeappuser \
    GROUP=nodeappgroup

RUN ["apk", "--no-cache", "upgrade"]
RUN ["apk", "add", "--no-cache", "tini"]
RUN ["apk", "add", "--no-cache", "curl"]

WORKDIR /app

# Create group and user
RUN addgroup -S ${GROUP} && \
    adduser -S -D ${USER} -G ${GROUP} && \
    mkdir -p /tmp/${USER} && \
    chown -R ${USER}:${GROUP} /tmp/${USER} && \
    chown -R ${USER}:${GROUP} /app

VOLUME [ "/tmp/${USER}" ]

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

# Switch to nodeappuser
USER ${USER}

ENV NODE_ENV "production"
ENV PORT 8000
EXPOSE $PORT

HEALTHCHECK CMD curl --fail http://localhost:8000/healthcheck || exit 1

ENTRYPOINT ["tini", "--"]

CMD ["node", "src/app.js"]
