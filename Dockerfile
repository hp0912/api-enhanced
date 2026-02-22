# syntax=docker/dockerfile:1.7

FROM node:lts-alpine AS deps

RUN apk add --no-cache tini

WORKDIR /app

RUN corepack enable && corepack prepare pnpm@10.15.0 --activate

COPY package.json pnpm-lock.yaml ./
RUN --mount=type=cache,id=pnpm-store,target=/home/node/.local/share/pnpm/store \
  pnpm install --frozen-lockfile --prod

FROM node:lts-alpine AS builder

WORKDIR /app

COPY --from=deps /app/node_modules ./node_modules
COPY ./ ./

FROM node:lts-alpine

ENV TZ=Asia/Shanghai
ENV NODE_ENV=production

WORKDIR /app

RUN apk add --no-cache tini

COPY --from=builder /app ./

EXPOSE 3000

CMD [ "/sbin/tini", "--", "node", "app.js" ]
