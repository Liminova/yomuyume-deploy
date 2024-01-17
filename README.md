# Yomuyume deployment guide
Note: `client-server`: `yomuyume-client` + `yomuyume-server`

# Table of contents
- [Prerequisites](#prerequisites)
- [Install Docker Engine](#install-docker-engine)
- [Configuring the `client-server`](#configuring-the-client-server)
- [Reverse proxy](#reverse-proxy)
    - [Caddy](#caddy)
    - [Cloudflare Tunnel](#cloudflare-tunnel)
    - [Caddy + Cloudflare Tunnel](#caddy--cloudflare-tunnel)

## Prerequisites
- A domain: optional if you're not planning to use a reverse proxy.

- A server:
    - CPU: preferably `amd64` architecture. I don't have an ARM server to test.
    - RAM/storage: you decide, but here's the bare minimum for just to run:

        | Component                             | RAM          | Storage |
        |---------------------------------------|--------------|---------|
        | `client-server` | 6MB          | 44MB    |
        | `caddy`                               | 10MB to 20MB | 7MB     |
        | `cloudflare`                          | 25MB         | 60MB    |


## Install Docker Engine
Using [this guide](https://docs.docker.com/engine/install/), make sure to follow the post-installation steps. Skip if you already have Docker installed.

## Configuring the `client-server`
1. Clone/download this repo

2. Run `touch sqlite.db`

3. In `docker-compose.yml`
    > Note: how `ports` and `volumes` are defined: `<host>:<container>`
    - `yomuyume-server` > `volumes` > rewrite library path to your own
    > Note: run `openssl rand -hex 32` to generate a random string
    - `yomuyume-server` > `environment` > change `JWT_SECRET` and `SMTP` credentials

4. Run `docker compose up -d`

The `client-server` should be up and listening on port `8080` and `8081` respectively.

That's it. Bring-your-own-reverse-proxy or follow the guide below.

## Reverse proxy
> There are several configuration option you can choose from

0. Create a new docker network `docker network create yomuyume`

### Caddy
> Requires a domain. The server must be accessible *from the internet* to be exposed to the internet.

1. In `docker-compose.yml`
    - Remove the `ports`, uncomment the `networks` for `client-server`
    - Uncomment `caddy` service
    - Uncomment `networks` at the bottom

2. Prepare Caddy binary
    - Follow this [community guide](https://caddy.community/t/how-to-use-dns-provider-modules-in-caddy-2/8148) to download the Caddy binary with your DNS provider plugin
    - Rename the binary to `caddy`
    - Run `sudo chmod +x ./caddy`

3. In `./caddy/Caddyfile`
    - Replace your own domain
    - Replace `<PROVIDER>` and `<PROVIDER_TOKEN>` to your own

### Cloudflare Tunnel
> Requires a domain. The server can't or don't want to be exposed to the internet.

1. In `docker-compose.yml`
    - Remove the `ports`, uncomment the `networks` for `client-server`
    - Uncomment `cloudflared` service
    - Uncomment `networks` at the bottom

2. Go to [one.dash.cloudflare.com](https://one.dash.cloudflare.com/)
    - Do the basic steps to create a Team.
    - `Access` > `Tunnels` > create new tunnel > get the token at last step
    - `docker-compose.yml` > `services` > `cloudflared` > `environment` > replace `<TOKEN>` with your own

3. Adding hostname to Cloudflare on Cloudflare One dashboard
    - `Access` > `Tunnels` > modify > `Public Hostnames` tab
    - Create a new hostname for `yomuyume-client`
        - Subdomain, domain: your own
        - Path: leave blank
        - Type: `HTTP`
        - URL: `yomuyume-client:3000`
    - Create 4 new hostnames for `yomuyume-server` (one for each path)
        - Subdomain, domain: your own
        - Path: `/api`, `/swagger`, `/api-docs`, `/redoc`
        - Type: `HTTP`
        - URL: `yomuyume-server:3000`

4. Run `docker compose up -d`

The `client-server` should be up and running on your specified domain.

### Caddy + Cloudflare Tunnel
> Same as above, but using Caddy to handle routing instead of creating multiple hostnames in the Tunnel dashboard.

1. In `docker-compose.yml`
    - Remove the `ports`, uncomment the `networks` for `client-server`
    - Uncomment `caddy` and `cloudflared` service
    - Remove the `ports` for `caddy`
    - Uncomment `networks` at the bottom

2. Prepare Caddy binary (same as above)

3. In `./caddy/Caddyfile`
    - Replace your own domain
    - Remove the `tls` block
    - Add `http://` to before your domain to disable TLS
        ```
        ...
        @comic host http://<your-domain>
        handle @comic {
            ...
        ```

4. Create one hostname on Cloudflare One dashboard
    - Subdomain, domain: your own
    - Path: leave blank
    - Type: `HTTP`
    - URL: `caddy:80`

5. Run `docker compose up -d`

The `client-server` should be up and running on your specified domain.

## Upgrade
- Stop all containers: `docker compose down`
- Clear docker build cache: `docker builder prune -a`
- Remove images without containers: `docker image prune -a`
- Start all containers: `docker compose up -d --build`