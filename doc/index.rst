gulp-browserify-example
=======================
This is a simple but non-trivial example of using Browserify_ with Gulp_.
The example was created as an personal exercise while hopefully being
helpful for someone else too struggling with these tools.

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

      gulp build

#.  See generated resources at (also open ``app.html`` in browser)::

      dist/


Features
--------
This section briefly describes the contents of the repo.

**Gulp Shimming**
  Shimming rules are defined in ``package.json`` unlike, say, in require.js.
  These rules are taken from this repo:

  .. code-block:: javascript

    // Define shorthands for the downloaded components.
    // Note the name 'browser' instead of 'browserify'
    "browser": {
      "jquery": "./build/components/jquery/dist/jquery.min.js",
      "underscore": "./build/components/lodash/dist/lodash.underscore.js",
      "backbone": "./build/components/backbone/backbone.js"
    },

    // Define what non-CommonJS compatible components exports and what are their dependencies
    // Note how the name uses the ones defined in 'browser'
    "browserify-shim": {
      "jquery": "$",
      "underscore": "global:_",
      "backbone": {
        "exports": "Backbone",
        "depends": [
          "jquery:$",
          "underscore:_"
        ]
      }
    }



**Coffeescripted Gulp**
  TBD

**Multiple Bundles**
  TBD

**Styles with LESS**
  TBD

**CLI Argumnents**
  Using command line arguments with Gulp. Example::

    gulp build --watch

**Backbone**
  Backbone.js is included as an example of using an external library with Browserify.
  In this example, the Backbone is bundled in lib.js

**Livereload**
  Gulp script support the livereload, that makes it possible to reload
  browser whenever changes are done. Usage:

  #. Install `Chrome <https://chrome.google.com/webstore/detail/livereload/jnihajbhpnppcggbcgedagnkighmdlei?hl=en>`_ or  `Firefox <https://addons.mozilla.org/en-US/firefox/addon/livereload/>`_ -extension
  #. Start gulp: ``gulp``
  #. Enable livereload in browser
  #. Make a change in any of the source files and see how browser reloads itself

**Sphinx**
  This documentation is powered by excellent Sphinx_ documentation platform.
  The files are in ReStructuredText format (.rst) and can be built into HTLM with command::

    gulp doc --target=dist/doc

  In a case you don't have sphinx installed, run these first (requires python and pip)::

    pip install sphinx

References
----------
References and additional resources:

* Gulp examples: https://github.com/gulpjs/gulp/tree/master/docs/recipes



.. _Node: http://nodejs.org/
.. _Gulp: http://gulpjs.org/
.. _Sphinx: http://sphinx.pocoo.org/
.. _Browserify: http://browserify.org/