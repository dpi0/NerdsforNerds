FROM debian:stable-slim

RUN apt update && apt install -y \
    guile-3.0 \
    guile-gnutls \
    guile-library \
 && apt clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

EXPOSE 8006

CMD ["guile", "-L", ".", "nerd.scm"]
