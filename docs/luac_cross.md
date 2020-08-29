
Obtaining luac.cross
====================

When you build your firmware image in the cloud or use a pre-made one,
how can you cross-compile your LUA modules into an LFS?


### luac.cross for same platform as cloud

(Last verified: 2020-08-29)

In the cloud, a version of `luac.cross` is built for the OS and platform
used on the cloud server, and that one can be exposed as a build artifact.


### luac.cross for other platforms

(Last verified: 2020-08-29)

If you need just `luac.cross` (e.g. because you already have a firmware),
you can save most of the time and effort that it would take to compile
the firmware. Instead,


1.  Set up a directory structure like this:

    * `just_luac_cross/`: Your base directory
      * `app/`
        * `lua/` and `uzlib/`: Copy from same path inside the firmware repo
        * `include/`
          * `user_config.h` and `user_modules.h`:
            Ideally they should have the exact same content as the effective
            configs used for the firmware build, but a close approximation
            might work as well.
            If you don't use too many of this github action's magic features,
            you can probably just use `config.h` and `modules.h`
            from your recipe repo's `esp8266.app.include`.

1.  Open a shell and chdir to `just_luac_cross/app/lua/luac_cross`.
1.  Run `make`
1.  Wait a bit. It should take very few minutes at most.
1.  Chdir back to `just_luac_cross/`.
1.  There should now be an executable file named `luac.cross`.
1.  (optional) If you want to install it as a global system command,
    one easy way to do it is `sudo mv -v -- luac.cross /usr/local/bin/`.





