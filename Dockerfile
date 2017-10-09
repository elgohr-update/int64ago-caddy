FROM debian:stable as fetch

RUN apt-get update && apt install -y --no-install-recommends \
    tar \
    xz-utils \
    curl \
    ca-certificates

RUN curl --silent --show-error --fail --location -o - \
    "https://caddyserver.com/download/linux/amd64" \
    | tar --no-same-owner -C /usr/bin/ -xz caddy

RUN curl --silent --show-error --fail --location -o - \
    "https://github.com/upx/upx/releases/download/v3.94/upx-3.94-amd64_linux.tar.xz" \
    | tar --no-same-owner -C /usr/bin/ -xJ \
    --strip-components 1 upx-3.94-amd64_linux/upx

RUN ls -l /usr/bin/caddy
RUN /usr/bin/upx --ultra-brute /usr/bin/caddy
RUN ls -l /usr/bin/caddy

RUN /usr/bin/caddy -version


FROM scratch

COPY --from=fetch /usr/bin/caddy /bin/caddy
COPY Caddyfile /etc/Caddyfile

ENV CADDYPATH=/etc/.caddy
VOLUME /etc/.caddy

WORKDIR /srv
COPY index.html /srv/index.html

ENTRYPOINT ["/bin/caddy"]
CMD ["--conf", "/etc/Caddyfile", "--log", "stdout"]
