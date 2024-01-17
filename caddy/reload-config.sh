#!/bin/bash

./caddy fmt --overwrite && docker exec -w /etc/caddy caddy caddy reload