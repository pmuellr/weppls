weppls - WEb aPPLicationS
================================================================================

weppls is a platform to easily build the static files for a single-page
web application with multiple views, using

* [AngularJS](http://angularjs.org/)
* [Bootstrap](http://getbootstrap.com/)

and also throws in

* [jQuery](http://jquery.com/)
* [d3](http://d3js.org/)
* [font-awesome](http://fortawesome.github.io/Font-Awesome/)
* [CoffeeScript](http://coffeescript.org/)
* [browserify](http://browserify.org/) (for [Node.js-ish module](http://nodejs.org/api/modules.html) support)

You provide your angular views, controllers, services, directives and 
filters, along with the "shell" of the app (eg, `index.html`), along with
other random files of your choice.

Then run `weppls`, and the following things will happen:

* an `index.html` will be built from the shell of your app
* all the angular bits will be wired together
* all the modules that make up your angular bits will be 
  [browserify]'d into a single JavaScript file.
* all the built-in vendor files (jQuery, angular, etc) will
  be added

You should then be able to open the `index.html` file and see your app.

installation
--------------------------------------------------------------------------------

Install globally via: *(`sudo` not needed for windows)*

    sudo npm install weppls

This will install a global command `weppls`.


simple sample
--------------------------------------------------------------------------------

Look at the directory `samples/samples-01` in this project:

**`body.html`**

This file contains the "body" of your page, which would typically
be a bootstrap container with a row for the content, which will be
filled in by angular because it's an `ng-view`.

**`index.html`**

This file contains all the usual glorp associated with the web page
itself - which scripts to include, icons, title, etc.

**`menu.html`**

This file contains the bootstrap code to provide a "menu" for your application.
In this case, we're using a collapsible bootstrap nav bar.

**`images/icon-512.png`**

An icon for your app.

**`views/hello.coffee`**

The angular controller for your "hello" view.

**`views/hello.html`**

The angular HTML template for your "hello" view.

**`views/home.html`**

The angular HTML template for your "home" view.
The home view is special, in that it's considered
to be associated with the "root" of your application;
specifically, the url `/`, in the angular sense.


<!-- ============================== -->
### build the sample ###

Run:

    weppls --output <output directory> <sample-01 directory>

There should be an `index.html` file in `<output directory>` that you can
then open in a browser.


file/directory conventions
--------------------------------------------------------------------------------

In the root directory of your application, you should have the following files:

* `index.html`
* `body.html`
* `menu.html`

These files just let you split up the "shell" of your app into pieces a little
cleaner than sticking the whole wad in a single `index.html` file.

The `body.html` and `menu.html` files will be read, and then substituted into
the `index.html` file with the targets `{{body}}` and `{{menu}}` respetively.

All other files in the root directory are ignored.

The following subdirectories of your root directory are special:

* `views`
* `services`
* `directives`
* `filters`

<!-- ============================== -->
### the views directory ###

The `views` directory contains the angular HTML templates for your views, and
the controllers for those views.  The file name sans extension of the view
and controller files are matched up.  If you have a view file without a 
controller, a dummy controller will be added for you.  In addition, it's 
assumed you will have a controller associated with the `<body>` element 
of your page, named `body`, and so you can add a controller named `body`
to the `views` directory.  If you don't have a body controller, a dummy one
will be added for you.

The angular HTML templates can either be HTML files (`*.html`) or Markdown
files (`*.md`). Markdown files will be converted to HTML.

The controller files can either be JavaScript files (`*.js`) or CoffeeScript
files (`*.coffee`).  CoffeeScript files will be converted to JavaScript.

The controller files are expected to be Node.js-ish modules, which export
a single function named `controller`.  These controller functions will be
registered with angular via:

    module.controller(moduleName, controllerFunction)

In this case `module` is the angular module object that `weppls` creates 
for your app, and `moduleName` is the base name of the controller file.

Based on these files, a routing will also be created for your application.
The `home` view is a special one, which is assumed to be accessed via
the URL `/` (in the angular sense).  All other views are considered to
be accessed by the base name of the view file; eg, a `hello.html` file will
have a route of `/hello`.

> ** not yet implemented **
>
> in order to handle parameterized routes, you may place an annotation in
> your HTML to indicate the actual route URL:
>     
>      <!-- @route /foo/:bar -->


<!-- ============================== -->
### the services directory ###

The `services` directory contains the angular services for your application.

The service files can either be JavaScript files (`*.js`) or CoffeeScript
files (`*.coffee`).  CoffeeScript files will be converted to JavaScript.

The service files are expected to be Node.js-ish modules, which export
a single constructor function named `service`.  These service functions will be
registered with angular via:

    module.service(moduleName, serviceFunction)

In this case `module` is the angular module object that `weppls` creates 
for your app, and `moduleName` is the base name of the service file.


<!-- ============================== -->
### the filters directory ###

The `filters` directory contains the angular filters for your application.

The filter files can either be JavaScript files (`*.js`) or CoffeeScript
files (`*.coffee`).  CoffeeScript files will be converted to JavaScript.

The filter files are expected to be Node.js-ish modules, which export
a single function named `filter`.  These filter functions will be
registered with angular via:

    module.filter(moduleName, filterFunction)

In this case `module` is the angular module object that `weppls` creates 
for your app, and `moduleName` is the base name of the filter file.


<!-- ============================== -->
### the directives directory ###

not yet implemented


building `weppls`
--------------------------------------------------------------------------------

To hack on `weppls` code itself, you should first install 
[`jbuild`](https://github.com/pmuellr/jbuild).  Run `jbuild`
by itself in the project directory to see the tasks available.

To update the vendor files, edit the `bower-files.coffee` file and
then run `jbuild vendor`.

To rebuild from the source, run `jbuild build`.

To build the samples, run `jbuild test`.

To go into edit-compile mode, run `jbuild watch`, which will
do a `jbuild build` and then `jbuild test`, and then whenever
a source file changes will re-run those commands.  FOR EVER.


`weppls` home
--------------------------------------------------------------------------------

<https://github.com/pmuellr/weppls>


license
--------------------------------------------------------------------------------

Apache License Version 2.0

<http://www.apache.org/licenses/>
