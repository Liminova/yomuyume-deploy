FROM node:21-alpine AS install

# Prepare
RUN apk add --no-cache git wget
RUN git clone --depth 1 https://github.com/Liminova/yomuyume-client.git /temp/yomuyume-client

# Server binary
RUN wget -O /temp/simple-http-server https://github.com/TheWaWaR/simple-http-server/releases/download/v0.6.8/x86_64-unknown-linux-musl-simple-http-server
RUN chmod +x /temp/simple-http-server

# Build
WORKDIR /temp/yomuyume-client
RUN npm install -g pnpm
RUN pnpm i
RUN pnpm generate

# New stage for smaller image
FROM alpine:latest
WORKDIR /usr/src/app
COPY --from=install /temp/yomuyume-client/dist ./public
COPY --from=install /temp/simple-http-server /usr/local/bin/simple-http-server
EXPOSE 3000/tcp
ENTRYPOINT [ "/usr/local/bin/simple-http-server", "--index", "--threads", "8", "--try-file", "public/404/index.html", "--port", "3000", "public" ]
