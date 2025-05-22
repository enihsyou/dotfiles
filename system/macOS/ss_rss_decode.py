#!/usr/bin/env python3
from urllib.request import urlopen
from urllib.parse import unquote
import base64
import re

n3ro_rss_link = input("N3RO SIP002 URIs: ").strip()

data = urlopen(n3ro_rss_link).read()
links = base64.b64decode(data).decode()
for link in links.splitlines():
    matcher = re.match(r"ss://(.+)@(.+)#(.+)", link)
    a = base64.b64decode(matcher.group(1)).decode()
    b = matcher.group(2)
    c = unquote(matcher.group(3))

    ss_link = base64.b64encode((a + '@' + b).encode()).decode()
    remark = c[:c.index('#')].replace(' ', '')
    print('ss://' + ss_link + '#' + remark)
