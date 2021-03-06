child = require 'child_process'
fs = require 'fs'
YamlKeyReader = require './yaml-key-reader'

module.exports = ->
    ymls = []
    atom.project.getPaths().forEach (pp) ->
      temp = child.spawnSync('find', ['-L', pp, '-name', '*.yml'])
        .stdout.toString().trim().split("\n")
        .filter (e) -> e.match(/\/\w{2}(-\w{2})?\./)
      ymls = ymls.concat(temp)

    keys = []
    promises = ymls.map (yml) ->
      new Promise (resolve) ->
        fs.readFile yml, (_, contents) ->
          reader = new YamlKeyReader(contents.toString())
          reader.keysWithRow().forEach ([key, value, line]) ->
            keys.push(key: key, value: value, file: yml, line: line)
          resolve()
    Promise.all(promises).then -> keys
