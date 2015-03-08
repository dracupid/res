{kit} = require 'nobone'
kit.require 'jhash'
kit.require 'colors'
Promise = kit.Promise

module.exports = (task) ->
    task 'hash', ->
        hash = {}

        kit.glob '?(config|dot|style)/**/*.*', all: yes
        .then (files)->
            files = files.sort()
            Promise.all files.map (fpath)->
                kit.readFile(fpath).then (str) ->
                    hash[fpath] = kit.jhash.hash str
                    kit.logs fpath.yellow, '-->', hash[fpath].blue
        .then (q)->
            kit.outputJSON 'hash.json', hash, space: 2

    task 'default', ['hash']
