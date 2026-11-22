# SlowDNS installer

Run the bundled installer as root:

```sh
bash SLDNS/install-sldns
```

SlowDNS requires a configured nameserver domain in `/root/nsdomain`. The installer also downloads legacy SlowDNS runtime files from the upstream `hopp` repository; those files are not part of this `hop` checkout and their upstream location is not controlled by `project.env`.
