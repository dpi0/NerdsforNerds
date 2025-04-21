# nerdsfornerds

nerdsfornerds is a privacy-respecting frontend to GeeksforGeeks

Repo forked from [cobra/NerdsforNerds](https://git.vern.cc/cobra/NerdsforNerds)

Changes made in this fork:

- Add Dockerfile and publish GHCR image.

To run using docker-compose:

```yml
---
services:
  nerdsfornerds:
    image: ghcr.io/dpi0/nerdsfornerds:latest
    container_name: nerdsfornerds
    restart: unless-stopped
    ports:
      - 8006:8006
```

# Support

Join our [Matrix room](https://mto.vern.cc/#/#cobra-frontends:vern.cc) for support and other things related to nerdsfornerds

# Instances

See instances.json

# Run your own instance

## Dependencies

This program is written in Guile Scheme.

You will need need `guile`, `guile-gnutls`, and `guile-lib`.

## Running

0. Install the dependencies
1. Clone the repository using `git clone https://git.vern.cc/cobra/NerdsforNerds`
2. Run `guile -L . nerd.scm`
3. Connect to http://localhost:8006 (or point your reverse proxy to it)
4. Profit

## Environment

`PATCHES_URL` - Link to any patches that were applied. Necessary if there are any. Do not set if there aren't.

The following are optional.

`PORT` - What port to run on (default `8006`).

## TODO

- Category pages
- Remove infinite `span` elements, we don't have syntax highlighting
- Preferrably remove made up gfg elements

## Notes

When using a service manager (e.g. systemd), make sure the stop signal is set to SIGINT, or 2. This will prevent EADDRINUSE.
