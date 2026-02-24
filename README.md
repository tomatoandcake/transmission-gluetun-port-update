# transmission-gluetun-port-update

A lightweight container that automatically syncs the forwarded port from [Gluetun](https://github.com/qdm12/gluetun) to [Transmission](https://transmissionbt.com/), keeping your torrent client's peer port up to date whenever it changes.

## Why?

When using a VPN with port forwarding (e.g. ProtonVPN via Gluetun), the forwarded port can change on VPN reconnects. If Transmission doesn't know about the new port, incoming peer connections fail and download speeds suffer. This container polls Gluetun's control API and automatically updates Transmission's peer port to match.

## How It Works

1. Polls Gluetun's `/v1/portforward` API endpoint on a configurable interval
2. Compares the returned port to Transmission's current peer port
3. If the port has changed, updates Transmission via its RPC API
4. Includes retry logic with configurable error thresholds

## Quick Start

### Docker Compose

```yaml
transmission-port-update:
  image: ghcr.io/tomatoandcake/transmission-gluetun-port-update:latest
  container_name: transmission-port-update
  depends_on:
    gluetun:
      condition: service_healthy
    transmission:
      condition: service_started
  network_mode: "service:gluetun"
  environment:
    - GLUETUN_API_KEY=your-api-key-here
    - TRANSMISSION_RPC_HOST=127.0.0.1
    - TRANSMISSION_RPC_PORT=9091
    - TRANSMISSION_RPC_USERNAME=your-username
    - TRANSMISSION_RPC_PASSWORD=your-password
    - GLUETUN_CONTROL_HOST=127.0.0.1
    - GLUETUN_CONTROL_PORT=8000
    - INITIAL_DELAY_SEC=10
    - CHECK_INTERVAL_SEC=60
    - ERROR_INTERVAL_SEC=5
    - ERROR_INTERVAL_COUNT=5
  restart: unless-stopped
```

> **Important:** This container must share the same network namespace as Gluetun (`network_mode: "service:gluetun"`) so it can reach both the Gluetun control API and Transmission's RPC on localhost.

## Environment Variables

| Variable | Required | Default | Description |
|---|---|---|---|
| `GLUETUN_API_KEY` | Yes | — | API key for Gluetun's control server authentication |
| `TRANSMISSION_RPC_HOST` | No | `127.0.0.1` | Transmission RPC host |
| `TRANSMISSION_RPC_PORT` | No | `9091` | Transmission RPC port |
| `TRANSMISSION_RPC_USERNAME` | Yes | — | Transmission RPC username |
| `TRANSMISSION_RPC_PASSWORD` | Yes | — | Transmission RPC password |
| `GLUETUN_CONTROL_HOST` | No | `127.0.0.1` | Gluetun control server host |
| `GLUETUN_CONTROL_PORT` | No | `8000` | Gluetun control server port |
| `INITIAL_DELAY_SEC` | No | `10` | Seconds to wait before first port check |
| `CHECK_INTERVAL_SEC` | No | `60` | Seconds between port checks |
| `ERROR_INTERVAL_SEC` | No | `5` | Seconds to wait after an error |
| `ERROR_INTERVAL_COUNT` | No | `5` | Consecutive errors before backing off to `CHECK_INTERVAL_SEC` |

## Gluetun Authentication Setup

Recent versions of Gluetun require API authentication for the control server. Create a TOML config file at the path specified by `HTTPCONTROL_AUTHCONFIGFILEPATH` in your Gluetun container:

```toml
[[roles]]
name = "admin"
auth = "apikey"
apikey = "your-api-key-here"
routes = ["GET /v1/portforward"]
```

Then set the same key in `GLUETUN_API_KEY` for this container.

## Images

Available from both registries:

```
ghcr.io/tomatoandcake/transmission-gluetun-port-update:latest
tomatoandcake/transmission-gluetun-port-update:latest
```

## Built With

- Alpine Linux
- curl & jq
- Shell script

## License

MIT
