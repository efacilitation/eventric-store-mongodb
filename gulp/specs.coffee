mocha = require 'gulp-mocha'
exit = require 'gulp-exit'

module.exports = (gulp) ->

  gulp.task 'specs', ->
    gulp.src 'src/*.coffee'
      .pipe mocha()
      .pipe exit()
