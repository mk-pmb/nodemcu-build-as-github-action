#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-

\:^(build/luac_cross/|)luac\.cross:{
  s~^.*/~~
  s~\.cross~~
  s!\.(int)$!-\1!
  s~$~-for-nodemcu~
}

s~^bin/0x0+\.bin$~#&~
s~^bin/0x10{4}\.bin$~spiffs.img~

# The actual firmware and its companions
s~/NodeMCU[._-]~\L&\E~g
s~^nodemcu_IMAGE_NAME\.(bin|map)$~firmware.float.\1~
s~^(bin|build)/nodemcu_((int)eger|(float))_IMAGE_NAME\.(bin|map|$\
  #1           2         34         5                    6 \
  )$~firmware\.\3\4.\5~
/\.map$/s~^~#~


s~^(app|components/platform)/include/user_~#&~
s~^sdkconfig\.~#&~
s~^build/~#&~

# Strip left-over leading directiry components:
s~^(#|).*/~\1~
