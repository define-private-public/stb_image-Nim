Nim stb_image Wrapper
=====================

This is a Nim wrapper of the stb_image single header file libraries
(`stb_image.h`,`stb_image_write.h`, and `stb_image_resize.h`).  It is still a
work in progress, so all functions/features might not be fully exposed yet; do
hold tight.

Official repo page can be found here:
https://gitlab.com/define-private-public/stb_image-Nim

All other sites should be considered mirrors.

The used header files are included in this repo buy you may provide your own.
The versions that are used are:

 - `stb_image.h`: v2.13
 - `stb_image_write.h`: v1.02
 - `stb_image_resize.h`: v0.91

They can be found here: https://github.com/nothings/stb

If something is out of date or incorrect.  Please notify me on the GitLab issue
tracker so I can fix it.  Though if something like a header file is out of date,
you should be able to simply exchange it out (unless something was changed in
the API).



License
-------

In the nature of Sean Barret (a.k.a. "stb") putting his libraries in public
domain, so is this code.  Specifically it falls under the "Unlicense."  Please
check the file `LICENSE` for details.



Other Notes
-----------

TODO:
 - [ ] wrap `stb_image.h`
   - [x] Make a list of functions/exposables
 - [ ] wrap `stb_image_write.h`
   - [ ] Make a list of functions/exposables
 - [ ] wrap `stb_image_resize.h`
   - [ ] Make a list of functions/exposables
 - [ ] Provide some examples of each
   - [ ] Image read example
   - [ ] Image write example
   - [ ] Image resize example

