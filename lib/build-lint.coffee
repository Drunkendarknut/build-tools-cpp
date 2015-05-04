linterPath = atom.packages.getLoadedPackage("linter").path
Linter = require "#{linterPath}/lib/linter"
path = require 'path'
msgs = require './message-list.coffee'

class LinterBuildTools extends Linter
  @syntax: ['source.c++', 'source.cpp', 'source.c']

  cmd: ''
  regex: ''

  linterName: 'Build tools'

  constructor: (editor) ->
    super(editor)

  lintFile: (filePath, callback) ->
    if atom.config.get('build-tools-cpp.UseLinterIfAvailable') and (m=msgs.messages[path.basename(filePath)])?
      messages = []
      for item in m
        match = {
          message: item[4],
          col: 0,
          line: item[2],
        }
        if (r = @computeRange match)?
          messages.push({
            line: item[2],
            level: item[3],
            message: item[4],
            linter: @linterName,
            range: r
          })
      callback messages

module.exports = LinterBuildTools