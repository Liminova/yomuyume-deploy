# see all versions at https://hub.docker.com/r/oven/bun/tags
FROM oven/bun:alpine AS install

# Prepare
RUN apk add --no-cache git
RUN git clone --depth 1 https://github.com/Liminova/yomuyume-client.git /temp/yomuyume-client

# Build
WORKDIR /temp/yomuyume-client
RUN bun install
RUN bun --bun run build

# New stage for smaller image
FROM oven/bun:alpine
WORKDIR /usr/src/app
COPY --from=install /temp/yomuyume-client/.output /usr/src/app/public
EXPOSE 3000/tcp
ENTRYPOINT [ "bun", "--bun", "run", "public/server/index.mjs" ]