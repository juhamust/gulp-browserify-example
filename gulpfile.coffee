###*
 * This is the main Gulp file, defining the tasks
 *
###
gulp = require('gulp')
watch = require('gulp-watch')
browserify = require('gulp-browserify')
coffee = require('gulp-coffee')
gutil = require('gulp-util')
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


# Clean generated files
gulp.task 'clean', (cb) ->
  gulp.src(['build/app.*', 'dist/*'], {read: false})
    .pipe(using(
      prefix: 'Deleting'
      color: 'red'
    ))
    .pipe(clean())

gulp.task 'doc', () ->
  gulp.src('doc/*.*')
    .pipe(watch())
    .pipe(shell([
      'sphinx-build -b singlehtml doc/ dist/doc'
    ]))


gulp.task 'build', () ->
  jsFilter = filter('*.js')
  appFilter = filter(['app.js'])
  libFilter = filter(['*.js', '!app.js'])

  # Names of external libraries (are put in lib.js)
  libNames = [
    'underscore', 'jquery',
    'backbone',
  ]

  # Convert less -> css
  gulp.src('src/styles/*.less')
    .pipe(watch())
    .pipe(plumber())
    .pipe(less())
    .pipe(gulp.dest('dist/styles'))
    .pipe(livereload())

  # Copy resources
  gulp.src('src/app.html')
    .pipe(watch())
    .pipe(plumber())
    .pipe(gulp.dest('dist'))
    .pipe(livereload())

  gulp.src('src/images/*.*')
    .pipe(watch())
    .pipe(plumber())
    .pipe(gulp.dest('dist/images/'))

  # Build coffee
  gulp.src('src/**/*.coffee', { read: true })
    .pipe(watch(
      emit: 'all'
    ))
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
      .on('error', gutil.log)
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
    # Finally, live reload
    .pipe(livereload())


gulp.task('default', ['build'])