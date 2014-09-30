###*
 * This is the main Gulp file, defining the tasks
 *
###
gulp = require('gulp')
util = require('util')
browserify = require('browserify')
source = require('vinyl-source-stream')
optimist = require('optimist')
through = require('through2')
plugins = require('gulp-load-plugins')()
pkg = require('./package.json')

files =
  doc: 'doc/*',
  app: ['src/app.coffee', 'src/lib.coffee'],
  resources: ['src/app.html', 'src/images/*']
  styles: 'src/styles/*.less'

# Clean generated files
gulp.task 'clean', (cb) ->
  gulp.src(['build/*', 'dist/*'], {read: false})
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

gulp.task 'build-resources', () ->
  # Copy resources
  gulp.src(files.resources)
    .pipe(plugins.plumber())
    .pipe(gulp.dest('dist'))

gulp.task 'serve', plugins.serve(
  root: ['dist']
  port: 8080
)

gulp.task 'bundle', ['bundle-lib', 'bundle-app']

gulp.task 'bundle-app', ['translate-app-coffee'], () ->
  return browserify()
    .add('./build/app.js')
    .external('jquery')
    .external('underscore')
    .external('backbone')
    .bundle()
    .on('error', plugins.util.log)
    .pipe(source('app.js'))
    .pipe(gulp.dest('./dist/'));

gulp.task 'bundle-lib', ['translate-lib-coffee'], () ->
  return browserify()
    .add('./build/lib.js')
    .require('jquery')
    .require('underscore')
    .require('backbone')
    .bundle()
    .on('error', plugins.util.log)
    .pipe(source('lib.js'))
    .pipe(gulp.dest('./dist/'))

gulp.task 'translate-app-coffee', () ->
  return gulp.src('src/app.coffee')
    .pipe(plugins.coffee(
      bare: false
      sourceMap: true
    )
    .on('error', plugins.util.log))
    .pipe(gulp.dest('build/'))

gulp.task 'translate-lib-coffee', () ->
  return gulp.src('src/lib.coffee')
    .pipe(plugins.coffee(
      bare: false
      sourceMap: true
    )
    .on('error', plugins.util.log))
    .pipe(gulp.dest('build/'))

gulp.task('build', ['bundle', 'build-resources', 'build-styles'])
gulp.task('default', ['build'])