FROM node:18.12.1@sha256:e9ad817b0d42b4d177a4bef8a0aff97c352468a008c3fdb2b4a82533425480df AS builder

WORKDIR /app

COPY package.json package-lock.json ./
COPY /src ./src

RUN npm install
RUN npm run build

RUN npm prune

FROM node:18.12.1-alpine3.16@sha256:67373bd5d90ea600cb5f0fa58d7a5a4e6ebf50b6e05c50c1d1cc22df5134db43 AS final


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
