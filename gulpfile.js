require('coffee-script/register');
var gulp = require('gulp')
  , mocha = require('gulp-mocha')
  , bump = require('gulp-bump');


var paths = {
  all: ['lib/**/*.{js,coffee}', 'test/**/*.{js,coffee}']
};

var handleError = function(err) {
  if(err.stack) {
    console.log("GULP: ")
    console.log(err.stack);
  }
  return this.emit('end');
};

gulp.task("watch", ['test'], function() {
  gulp.watch(paths.all, {verbose: true}, function(files, cb) {

     console.log(files.path.toString().replace(__dirname, "File changed: "));
     gulp.start('test');
  });
});

gulp.task("test", function() {
  return gulp.src('test/**/*.{js,coffee}').pipe(mocha({
    reporter: 'spec'
  })).on('error', handleError);
});


gulp.task('bump-major', function(){
  gulp.src(['./package.json'])
  .pipe(bump({type:'major'}))
  .pipe(gulp.dest('./'));
});

gulp.task('bump-minor', function(){
  gulp.src(['./package.json'])
  .pipe(bump({type:'minor'}))
  .pipe(gulp.dest('./'));
});

gulp.task('bump-patch', function(){
  gulp.src(['./package.json'])
  .pipe(bump({type:'patch'}))
  .pipe(gulp.dest('./'));
});

