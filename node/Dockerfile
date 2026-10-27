FROM node:24-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
COPY src ./src

RUN npm ci
RUN npm run build

ENV NODE_ENV=production
RUN npm prune --omit=dev

FROM node:24-alpine AS final

ENV USER=nodeappuser \
    GROUP=nodeappgroup

RUN apk --no-cache upgrade && \
    apk add --no-cache tini && \
    addgroup -S ${GROUP} && \
    adduser -S -D ${USER} -G ${GROUP} && \
    mkdir -p /tmp/${USER} && \
    chown -R ${USER}:${GROUP} /tmp/${USER}

WORKDIR /app
RUN chown -R ${USER}:${GROUP} /app

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package.json ./
COPY --from=builder /app/package-lock.json ./
COPY --from=builder /app/src ./src

USER ${USER}

ENV NODE_ENV=production
ENV PORT=8000
EXPOSE $PORT

HEALTHCHECK CMD node -e "require('http').get('http://localhost:8000/healthcheck', r => process.exit(r.statusCode === 200 ? 0 : 1)).on('error', () => process.exit(1))"

ENTRYPOINT ["tini", "--"]

CMD ["node", "src/app.js"]
