# TODO: Watcher is not working at the moment because of the TODO at the specs.coffee file
module.exports = (gulp) ->

  gulp.task 'watch', ->
    gulp.watch [
      'src/*.coffee'
    ], ['specs']
