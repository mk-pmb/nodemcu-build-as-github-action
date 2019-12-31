# -*- coding: utf-8, tab-width: 2 -*-

FROM marcelstoer/nodemcu-build:latest
COPY . /opt/baga/
ENTRYPOINT ["/opt/baga/build.sh"]
