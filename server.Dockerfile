FROM rust:alpine3.19 AS install

# Add tools for building
RUN apk add --no-cache git openssl-dev g++
ENV OPENSSL_LIB_DIR=/usr/lib
ENV OPENSSL_INCLUDE_DIR=/usr/include

# Clone
RUN git clone --depth 1 https://github.com/Liminova/yomuyume-server.git /temp/yomuyume-server
WORKDIR /temp/yomuyume-server

# Build, add permissions
RUN cargo build --release
RUN chmod +x ./target/release/yomuyume-server

# New stage for smaller image
FROM alpine:3.19
COPY --from=install /temp/yomuyume-server/target/release/yomuyume-server /usr/local/bin/yomuyume-server
EXPOSE 3000/tcp

ENTRYPOINT [ "/usr/local/bin/yomuyume-server" ]