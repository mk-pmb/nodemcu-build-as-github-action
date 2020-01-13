#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-

s~^bin/0x[01]0+\.bin$~\r~

s~_IMAGE_NAME(\.)~\1~
s~/NodeMCU[._-]~\L&\E~g
s~^(bin|build)/nodemcu(_integer|_float|)\.(bin|map)$~firmware.\3~

s~^.*/~~
s~^\r$~//ignore//~
