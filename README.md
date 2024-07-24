# NerdsforNerds
NerdsforNerds is a privacy-respecting frontend to geeksforGeeks

# Support
Join our [Matrix room](https://mto.vern.cc/#/#cobra-frontends:vern.cc) for support and other things related to NerdsforNerds

# Instances
See instances.json

# Run your own instance
## Dependencies
This program is written in Guile Scheme.

You will need need `guile`, `guile-gnutls`, `guile-lib`, and `guile-libxml2`.
`guile-libxml2` is a submodule in this repository, and requires `libxml2`, `libgumbo`, and `gumbo-libxml` to be installed.

You will also need a POSIX regex implementation available, which shouldn't be a problem on most OSes.

## Running
1. Clone the repository using `git clone --recurse-submodules https://git.vern.cc/cobra/NerdsforNerds`
2. `cd` into `guile-libxml2`
3. Follow the build instructions there
4. `cd` back to the main repo
5. Run `guile -L . -L guile-libxml2 nerd.scm`
6. Connect to http://localhost:8006 (or point your reverse proxy to it)
7. Profit

## Environment
`PATCHES_URL` - Link to any patches that were applied. Necessary if there are any. Do not set if there aren't.

The following are optional.

`PORT` - What port to run on (default `8006`).

`LIBXML2_LOCATION` (Used by guile-libxml2) - Path to `libxml2.so` (default `libxml2`, which checks `LD_LIBRARY_PATH`).

`GUMBO_LIBXML_LOCATION` (Used by guile-libxml2) - Path to `libgumbo_xml.so` (default `./gumbo-libxml/.libs/libgumbo_xml.so`, can be edited to `libgumbo_xml`, which does the same thing as `libxml2` in `LIBXML2_LOCATION`)

## Notes
When using a service manager (e.g. systemd), make sure the stop signal is set to SIGINT, or 2. This will prevent EADDRINUSE.
