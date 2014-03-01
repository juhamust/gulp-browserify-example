gulp-browserify-example
=======================
This is a simple but non-trivial example of using browserify with gulp.
The example was created as an personal exercise while hopefully being
helpful for someone else too struggling with Gulp_ and Browserify_.

.. note::

  This repo is a working-in-progress: I'm also learning by doing.
  Your insight and suggestions about the topic are very welcome!


**Get started**

#.  Check out the sources::

      git checkout https://github.com/juhamust/gulp-browserify-example.git
      cd gulp-browserify-example

#.  Install Node_ if you don't have one yet (suggested version: v0.10.x)
#.  Install dependencies (may take some time)::

      npm install

#.  Build::

      gulp

#.  See generated resources at (also open ``app.html`` in browser)::

      dist/


Features
--------
This section briefly describes the contents of the repo.

**Gulp**
  TBD

**Coffeescript**
  TBD

**Bundles**
  TBD

**LESS**
  TBD

**Backbone**
  Backbone.js is included as an example of an external library and
  have something to show in browser. The Backbone is bundled in lib.js

**Livereload**
  Gulp script support the livereload, that makes it possible to reload
  browser whenever changes are done. Usage:

  #. Install `Chrome <https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei?hl=en>`_ or  `Firefox <https://addons.mozilla.org/en-US/firefox/addon/livereload/>`_ -extension
  #. Start gulp: ``gulp``
  #. Enable livereload in browser
  #. Make a change in any of the source files and see how browser reloads itself


.. _Node: http://nodejs.org/
.. _Gulp: http://gulpjs.org/
.. _Browserify: http://browserify.org/

**Sphinx**
  TBD
