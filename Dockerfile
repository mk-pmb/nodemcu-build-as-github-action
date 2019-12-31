# -*- coding: utf-8, tab-width: 2 -*-

FROM marcelstoer/nodemcu-build:latest
COPY build.sh /nodemcu-build-as-github-action.sh
ENTRYPOINT ["/nodemcu-build-as-github-action.sh"]
