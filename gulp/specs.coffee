mocha = require 'gulp-mocha'
exit = require 'gulp-exit'

module.exports = (gulp) ->

  gulp.task 'specs', ->
    gulp.src 'src/**/*.coffee'
      .pipe mocha()
      # TODO: Add destroy function to each store adapter and use it within the eventric-store-specs repository specs
      # to close the connection of the active db. After that the spec run will terminate as expected.
      .pipe exit()
