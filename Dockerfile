FROM node:lts-alpine AS builder

RUN apk add --no-cache tini

ENV NODE_ENV production
USER node

WORKDIR /app

RUN npm install -g pnpm@8.15.9

ADD ./package.json /app/package.json
ADD ./pnpm-lock.yaml /app/pnpm-lock.yaml
ADD ./.npmrc /app/.npmrc

RUN pnpm install --frozen-lockfile

ADD ./ /app

FROM node:lts-alpine

ENV TZ=Asia/Shanghai

WORKDIR /app

COPY --from=builder /app ./

EXPOSE 3000

CMD [ "/sbin/tini", "--", "node", "app.js" ]
