# HTML sharing on nixpi

Public pages are served at `https://html.infiniter.tech/<name>`.
The NixOS option `services.infiniter.htmlSharing.enable` enables the nginx
virtual host and creates the upload directory, owned by `infiniter`.
`services.infiniter.htmlSharing.directory` defaults to `/var/www/html-sharing`.
The `html` DNS record is maintained by the existing Websupport DDNS service.

Upload a self-contained HTML file over SSH, then rename it atomically:

```sh
scp ./page.html infiniter@nixpi.tail6650cb.ts.net:/var/www/html-sharing/.example.html.upload
ssh infiniter@nixpi.tail6650cb.ts.net \
  'chmod 644 /var/www/html-sharing/.example.html.upload && mv /var/www/html-sharing/.example.html.upload /var/www/html-sharing/example.html'
```

Share `https://html.infiniter.tech/example`. The `.html` URL works too.
No rebuild is needed for uploading, replacing or removing a page. A page stays
available until its file is removed; there is no automatic expiration.

```sh
ssh infiniter@nixpi.tail6650cb.ts.net 'rm /var/www/html-sharing/example.html'
```

There is no upload API or public index. Dotfiles and symbolic links cannot be
served. HTML is served with `Cache-Control: no-store` and `X-Robots-Tag` to avoid
search indexing. These are public links: only put content intended for sharing
in the configured directory. Images can be embedded in a single HTML file.

For infrastructure changes, commit and push `master`, pull it on nixpi and run
`nixos-rebuild switch --flake /etc/nixos#nixpi` there without changing the lockfile.
Start `websupport-ddns.service` to create the DNS record immediately. If the
first certificate attempt precedes DNS propagation, retry
`acme-order-renew-html.infiniter.tech.service` once the hostname resolves to nixpi.
