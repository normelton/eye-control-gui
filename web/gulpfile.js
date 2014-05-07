var gulp = require('gulp');
var haml = require('gulp-haml');
var sass = require('gulp-sass');
var coffee = require('gulp-coffee');
var changed = require('gulp-changed');
var livereload = require('gulp-livereload');

var paths = {
  haml: './src/**/*.haml',
  stylesheets: {
    sass: './src/**/*.scss',
    css:  './src/**/*.css'
  },
  scripts: {
    coffee: './src/**/*.coffee',
    js: './src/**/*.js'
  },
  data: './data/**/*',
  images: './src/images/**/*',
  output: './build'
};

gulp.task('default', ['haml', 'sass', 'css', 'coffee', 'js', 'images', 'data']);

gulp.task('haml', function () {
  gulp.src(paths.haml)
    .pipe(changed(paths.output, { extension: '.html' }))
    .pipe(haml())
    .pipe(gulp.dest(paths.output));
});

gulp.task('sass', function () {
  gulp.src(paths.stylesheets.sass)
    .pipe(changed(paths.output, { extension: '.css' }))
    .pipe(sass())
    .pipe(gulp.dest(paths.output));
});

gulp.task('css', function () {
  gulp.src(paths.stylesheets.css)
    .pipe(changed(paths.output))
    .pipe(gulp.dest(paths.output));
});

gulp.task('coffee', function () {
  gulp.src(paths.scripts.coffee)
    .pipe(changed(paths.output, { extension: '.js' }))
    .pipe(coffee())
    .pipe(gulp.dest(paths.output));
});

gulp.task('js', function () {
  gulp.src(paths.scripts.js)
    .pipe(changed(paths.output))
    .pipe(gulp.dest(paths.output));
});

gulp.task('images', function () {
  gulp.src(paths.images)
  .pipe(changed(paths.images))
  .pipe(gulp.dest(paths.output + "/images"));
});

gulp.task('data', function () {
  gulp.src(paths.data)
  .pipe(changed(paths.output))
  .pipe(gulp.dest(paths.output + "/data"));
});

gulp.task('watch', function () {
  var server = livereload();

  gulp.watch(paths.haml, ["haml"]);
  gulp.watch(paths.stylesheets.sass, ["sass"]);
  gulp.watch(paths.stylesheets.css, ["css"]);
  gulp.watch(paths.scripts.coffee, ["coffee"]);
  gulp.watch(paths.scripts.js, ["js"]);
  gulp.watch(paths.scripts.images, ["images"]);
  gulp.watch(paths.scripts.data, ["data"]);

  server = livereload();
  gulp.watch("./build/**", function(evt) { console.log(evt.path); server.changed(evt.path) });
});
