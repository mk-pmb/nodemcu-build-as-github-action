
<!--#echo json="package.json" key="name" underline="=" -->
nodemcu-firmware-build-as-github-action
=======================================
<!--/#echo -->

<!--#echo json="package.json" key="description" -->
A Github action that builds a custom NodeMCU firmware image for me.
<!--/#echo -->


An attempt to use
[frightanic](https://frightanic.com/)'s
[Docker builder image](https://github.com/marcelstoer/docker-nodemcu-build)
on Github infrastructure instead of
[his original cloud service](https://nodemcu-build.com/).

Ideally, having a Github action for this will allow us to build custom
[NodeMCU firmware](https://github.com/nodemcu/nodemcu-firmware/)
images by just uploading the custom ingredients and very few meta data
into a Github repo. Let's see how close we can get.



Beware the "master" branch
--------------------------

I'll try and keep the master branch pointing to the latest mostly-stable
version, but plese check if you might prefer to use one of the version
branches. They might be just as stable but more up-to-date.



Usage
-----

### Example repos for how to build a firmware:

* https://github.com/mk-pmb/nodemcu-firmware-daily-vanilla/
* https://github.com/mk-pmb/nodemcu-firmware-wifigpio-pmb/

### How to obtain a compatible `luac.cross`

see [docs/luac_cross.md](docs/luac_cross.md)



Notes on Github actions
-----------------------

* [How to upload and download artifacts](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/persisting-workflow-data-using-artifacts#passing-data-between-jobs-in-a-workflow)
* [Logging commands](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/development-tools-for-github-actions#logging-commands)



Known issues
------------

* Needs more/better tests and docs.







<!--#toc stop="scan" -->
&nbsp;


License
-------
<!--#echo json="package.json" key=".license" -->
ISC
<!--/#echo -->
