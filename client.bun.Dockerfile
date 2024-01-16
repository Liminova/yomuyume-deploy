# see all versions at https://hub.docker.com/r/oven/bun/tags
FROM oven/bun:alpine AS install
RUN apk add --no-cache git wget
RUN git clone --depth 1 https://github.com/Liminova/yomuyume-client.git /temp/yomuyume-client
RUN wget -O /temp/simple-http-server https://github.com/TheWaWaR/simple-http-server/releases/download/v0.6.8/x86_64-unknown-linux-musl-simple-http-server
RUN chmod +x /temp/simple-http-server
WORKDIR /temp/yomuyume-client
RUN bun install
RUN bun --bun run build

FROM oven/bun:alpine
WORKDIR /usr/src/app
COPY --from=install /temp/yomuyume-client/.output /usr/src/app/public
EXPOSE 3000/tcp
ENTRYPOINT [ "bun", "--bun", "run", "public/server/index.mjs" ]