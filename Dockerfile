# -*- coding: utf-8, tab-width: 2 -*-

FROM marcelstoer/nodemcu-build:latest
COPY ./build-gha/ /opt/build-gha/
ENTRYPOINT ["/opt/build-gha/build.sh"]
