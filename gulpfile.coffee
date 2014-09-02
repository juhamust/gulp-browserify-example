###*
 * This is the main Gulp file, defining the tasks
 *
###
gulp = require('gulp')
optimist = require('optimist')
through = require('through2')
plugins = require('gulp-load-plugins')()

files =
  doc: 'doc/*',
  app: ['src/app.coffee', 'src/lib.coffee'],
  resources: ['src/app.html', 'src/images/*']
  styles: 'src/styles/*.less'

# Clean generated files
gulp.task 'clean', (cb) ->
  gulp.src(['build/app.*', 'dist/*'], {read: false})
    .pipe(plugins.using(
      prefix: 'Deleting'
      color: 'red'
    ))
    .pipe(plugins.rimraf())

###*
 * Build Sphinx powered documentation. Also accepts the optional
 * command line argument --target=../where/to/output
 * Defaults to dist/doc directory
###
gulp.task 'doc', () ->
  targetDir = if (optimist.argv and optimist.argv.target) then optimist.argv.target else 'dist/doc'
  gulp.src('doc/*.*')
    .pipe(plugins.shell([
      'sphinx-build -b singlehtml . ' + targetDir
    ]))
    .pipe(plugins.livereload())

gulp.task 'watch', ['build'], () ->
  gulp.watch(files.app, ['build'])
  gulp.watch(files.doc, ['doc'])
  gulp.watch(files.resources, ['build-resources'])
  gulp.watch(files.styles, ['build-styles'])

gulp.task 'build-styles', () ->
  # Convert less -> css
  gulp.src(files.styles)
    .pipe(plugins.plumber())
    .pipe(plugins.less())
    .pipe(gulp.dest('dist/styles'))
    .pipe(plugins.livereload())

gulp.task 'build-resources', () ->
  # Copy resources
  gulp.src(files.resources)
    .pipe(plugins.plumber())
    .pipe(gulp.dest('dist'))
    .pipe(plugins.livereload())

gulp.task 'build-coffee', () ->
  jsFilter = plugins.filter('*.js')
  appFilter = plugins.filter(['app.js'])
  libFilter = plugins.filter(['*.js', '!app.js'])

  # Names of external libraries (are put in lib.js)
  libNames = [
    'underscore', 'jquery',
    'backbone',
  ]

  # Build coffee
  gulp.src('src/**/*.coffee', { read: true })
    .pipe(plugins.plumber())
    .pipe(plugins.using(
      prefix: 'Building'
    ))
    .pipe(plugins.coffeelint())
    .pipe(plugins.coffeelint.reporter())
    .pipe(
      plugins.coffee(
        bare: false
        sourceMap: true
      )
      .on('error', plugins.util.log)
    )
    .pipe(gulp.dest('./dist/'))

    # Build lib bundle
    .pipe(libFilter)
    .pipe(plugins.using(
      prefix: 'Lib packaging'
    ))
    .pipe(plugins.browserify(
      transform: ['browserify-shim'],
      insertGlobals : false,
      debug : true
    ))
    .on 'prebundle', (bundle) ->
      bundle.require extLib for extLib in libNames
    .pipe(gulp.dest('./dist/'))
    .pipe(plugins.using(
      prefix: 'Output'
    ))
    .pipe(libFilter.restore())

    # Build app bundle
    .pipe(appFilter)
    .pipe(plugins.using(
      prefix: 'App packaging'
    ))
    .pipe(plugins.browserify(
      transform: ['browserify-shim'],
      insertGlobals : false,
      debug : true
    ))
    .on 'prebundle', (bundle) ->
      bundle.external extLib for extLib in libNames
    .pipe(gulp.dest('./dist/'))
    .pipe(plugins.using(
      prefix: 'Output'
    ))
    .pipe(plugins.livereload())

gulp.task('build', ['build-resources', 'build-styles', 'build-coffee'])
gulp.task('default', ['build'])