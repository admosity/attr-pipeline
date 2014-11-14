require('coffee-script/register');
var gulp = require('gulp')
  , mocha = require('gulp-mocha');


var paths = {
  all: ['lib/**/*.{js,coffee}', 'test/**/*.{js,coffee}']
};

var handleError = function(err) {
  console.log(err);
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




