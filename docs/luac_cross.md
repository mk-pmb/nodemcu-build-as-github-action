
Obtaining luac.cross
====================

When you build your firmware image in the cloud or use a pre-made one,
how can you cross-compile your LUA modules into an LFS?


luac.cross for same platform as cloud
=====================================

(Last verified: 2020-08-29)

In the cloud, a version of `luac.cross` is built for the OS and platform
used on the cloud server, and that one can be exposed as a build artifact.


luac.cross for other platforms
==============================

(Last verified: 2020-08-29)

If you need just `luac.cross` (e.g. because you already have a firmware),
you can save most of the time and effort that it would take to compile
the firmware. Instead,


1.  Set up a directory structure like this:

    * `just_luac_cross/`: Your base directory
      * `app/`
        * `lua/` and `uzlib/`: Copy from same path inside the firmware repo.
        * `include/`
          * `user_config.h` and `user_modules.h`: Your config (see below).

1.  Open a shell and chdir to `just_luac_cross/app/lua/luac_cross`.
1.  Run `make`
1.  Wait a bit. It should take very few minutes at most.
1.  Chdir back to `just_luac_cross/`.
1.  There should now be an executable file named `luac.cross`.
1.  (optional) If you want to install it as a global system command named
    `luac-for-nodemcu`, one way to do it is:
    `sudo mv --verbose --no-target-directory -- luac.cross /usr/local/bin/luac-for-nodemcu`
    * If you intend to cross-compile for several firmwares, you might want a
      different command name for each of them. Then again, in this case you
      probably won't install them as global commands.


Config files
------------

To ensure the cross-compiler is compatible with the target firmware,
it needs to know the settings that the firmware was built with.

The most reliable choice is to provide config files with the exact same
content as the effective configs used for the firmware build.
However, sometimes this would be overly complicated. A close enough
approximation might work as well — or, of course, might cause subtle bugs
far in the future, when you've long forgotten this warning. ;-)

* If you don't use too many of this github action's magic features, you can
  probably just use `config.h` and `modules.h` from your recipe repo's
  `esp8266.app.include/` directory.

* In the docs, in chapter "Compiling code" in its
  [current (2020-08-29) version][docs-compile-87030a8],
  the part near the bottom sounds like it might be enough to have the same
  setting of `LUA_NUMBER_INTEGRAL`.
  A quick glance at the `luac.cross` code shows that it also uses some other
  settings like `LUA_MAX_FLASH_SIZE`, `DEVELOPMENT_TOOLS`,
  and `DEVELOPMENT_USE_GDB`.








  [docs-compile-87030a8]: https://github.com/nodemcu/nodemcu-firmware/blob/87030a87ea545ac2bee8fa3787b7828b4e856227/docs/compiling.md
