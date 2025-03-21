# NerdsforNerds
NerdsforNerds is a privacy-respecting frontend to GeeksforGeeks

# Support
Join our [Matrix room](https://mto.vern.cc/#/#cobra-frontends:vern.cc) for support and other things related to NerdsforNerds

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
