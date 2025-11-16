/* dnsconfig.js: dnscontrol configuration file for Kokomi Network. */
/// @ts-check
/// <reference path="types-dnscontrol.d.ts" />

DEFAULTS(
    CF_PROXY_DEFAULT_OFF,
);

var REG_NONE = NewRegistrar("none");
var DSP_CLOUDFLARE = NewDnsProvider("cloudflare");

D("kokomi.site", REG_NONE
        , DnsProvider(DSP_CLOUDFLARE)
        , DefaultTTL(1)
        , AAAA("*.homelab", "2409:8a1e:6e71:5eb0:be24:11ff:fec1:ba8d")
        , AAAA("pve.home", "2409:8a1e:6952:4d90:1e1b:dff:fe95:90d1")
        , TXT("_github-pages-challenge-enihsyou", '"a541ba78d7ee9a59d07f7142a0c675"')
        , TXT("_keybase", '"keybase-site-verification=9u4yaGI_FzeOM7y8v9aJ6rL9Hc9Hj-OOUbtM0qwWOqw"')
        , TXT("@", '"google-site-verification=jGigjx3nVD2fZAUURHAz3oJI1_1Y575uhY3H2LOg26E"')
        , AAAA("docker-mirror", "100::", CF_PROXY_ON)
)
