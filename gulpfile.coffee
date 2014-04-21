###*
 * This is the main Gulp file, defining the tasks
 *
###
gulp = require('gulp')
optimist = require('optimist')
through = require('through2')
watch = require('gulp-watch')
browserify = require('gulp-browserify')
coffee = require('gulp-coffee')
util = require('gulp-util')
clean = require('gulp-clean')
cat = require('gulp-cat')
using = require('gulp-using')
less = require('gulp-less')
concat = require('gulp-concat')
cat = require('gulp-cat')
coffeelint = require('gulp-coffeelint')
livereload = require('gulp-livereload')
filter = require('gulp-filter')
plumber = require('gulp-plumber')
shell = require('gulp-shell')
gulpif = require('gulp-if')

files = 
  doc: 'doc/*',
  app: ['src/app.coffee', 'src/lib.coffee'],
  resources: ['src/app.html', 'src/images/*']
  styles: 'src/styles/*/*.less'

# Clean generated files
gulp.task 'clean', (cb) ->
  gulp.src(['build/app.*', 'dist/*'], {read: false})
    .pipe(using(
      prefix: 'Deleting'
      color: 'red'
    ))
    .pipe(clean())

###*
 * Build Sphinx powered documentation. Also accepts the optional
 * command line argument --target=../where/to/output
 * Defaults to dist/doc directory
###
gulp.task 'doc', () ->
  targetDir = if (optimist.argv and optimist.argv.target) then optimist.argv.target else 'dist/doc'
  gulp.src('doc/*.*')
    .pipe(shell([
      'sphinx-build -b singlehtml doc/ ' + targetDir
    ]))

gulp.task 'watch', ['build'], () ->
  gulp.watch(files.app, ['build'])
  gulp.watch(files.doc, ['doc'])
  gulp.watch(files.resources, ['build-resources'])
  gulp.watch(files.styles, ['build-styles'])
  #livereload()

gulp.task 'build-styles', () ->
  # Convert less -> css
  gulp.src('src/styles/*.less')
    .pipe(plumber())
    .pipe(less())
    .pipe(gulp.dest('dist/styles'))

gulp.task 'build-resources', () ->
  # Copy resources
  gulp.src(files.resources)
    .pipe(plumber())
    .pipe(gulp.dest('dist'))

gulp.task 'build-coffee', () ->
  jsFilter = filter('*.js')
  appFilter = filter(['app.js'])
  libFilter = filter(['*.js', '!app.js'])

  # Names of external libraries (are put in lib.js)
  libNames = [
    'underscore', 'jquery',
    'backbone',
  ]

  # Build coffee
  gulp.src('src/**/*.coffee', { read: true })
    .pipe(plumber())
    .pipe(using(
      prefix: 'Building'
    ))
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())
    .pipe(
      coffee(
        bare: false
        sourceMap: true
      )
      .on('error', util.log)
    )
    .pipe(gulp.dest('./dist/'))

    # Build lib bundle
    .pipe(libFilter)
    .pipe(using(
      prefix: 'Lib packaging'
    ))
    .pipe(browserify(
      transform: ['browserify-shim'],
      insertGlobals : false,
      debug : true
    ))
    .on 'prebundle', (bundle) ->
      bundle.require extLib for extLib in libNames
    .pipe(gulp.dest('./dist/'))
    .pipe(using(
      prefix: 'Output'
    ))
    .pipe(libFilter.restore())

    # Build app bundle
    .pipe(appFilter)
    .pipe(using(
      prefix: 'App packaging'
    ))
    .pipe(browserify(
      transform: ['browserify-shim'],
      insertGlobals : false,
      debug : true
    ))
    .on 'prebundle', (bundle) ->
      bundle.external extLib for extLib in libNames
    .pipe(gulp.dest('./dist/'))
    .pipe(using(
      prefix: 'Output'
    ))

gulp.task('build', ['build-resources', 'build-styles', 'build-coffee'])
gulp.task('default', ['build'])