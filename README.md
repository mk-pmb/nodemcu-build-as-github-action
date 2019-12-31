
<!--#echo json="package.json" key="name" underline="=" -->
nodemcu-build-as-github-action
==============================
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
NodeMCU firmware images by just uploading the recipe and very few
meta data into a Github repo. Let's see how close we can get.





<!--#toc stop="scan" -->



Known issues
------------

* Needs more/better tests and docs.




&nbsp;


License
-------
<!--#echo json="package.json" key=".license" -->
ISC
<!--/#echo -->
