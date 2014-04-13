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
gulpif = require('gulp-if')

# Check if --watch flag is set and enable livereload/watch if enabled
watchEnabled = if (optimist.argv and optimist.argv.watch) then true else false
watchIf = () ->
  #return gulpif(watchEnabled, watch(arguments))
  return through.obj (file, enc, callback) ->
    this.push(file)
    if watchEnabled
      watch(arguments)
    return callback()

# Start livereload if --watch is set
reloadIf = () ->
  if watchEnabled
    livereload(arguments)
  return through.obj (file, enc, callback) ->
    this.push(file)
    return callback()


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
  console.log 'watch', watchEnabled
  gulp.src('doc/*.*')
    .pipe(watchIf())
    .pipe(shell([
      'sphinx-build -b singlehtml doc/ ' + targetDir
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
    .pipe(watchIf())
    .pipe(plumber())
    .pipe(less())
    .pipe(gulp.dest('dist/styles'))
    .pipe(reloadIf())

  # Copy resources
  gulp.src('src/app.html')
    .pipe(watchIf())
    .pipe(plumber())
    .pipe(gulp.dest('dist'))
    .pipe(reloadIf())

  gulp.src('src/images/*.*')
    .pipe(watchIf())
    .pipe(plumber())
    .pipe(gulp.dest('dist/images/'))

  # Build coffee
  gulp.src('src/**/*.coffee', { read: true })
    .pipe(watchIf(
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
    .pipe(reloadIf())


gulp.task('default', ['build'])