#!/bin/sh
cd /app
if [ "$CLEAN_PNPM" = "true" ]; then
  rm -rf .pnpm-store
fi
rm -rf yomuyume-client public

apk add --no-cache git
git clone --depth 1 https://github.com/Liminova/yomuyume-client.git
cd yomuyume-client

npm install -g pnpm
pnpm i
pnpm generate

mv .output/public ../public
cd ..
rm -rf yomuyume-client