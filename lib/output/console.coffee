{$, $$, View} = require 'atom-space-pen-views'

ConsoleView = null
consoleview = null

buildHTML = (message, status, filenames) ->
  $$ ->
    status = '' if not status?
    status = 'info' if status is 'note'
    @div class: "bold text-#{status}", =>
      if filenames? and filenames.length isnt 0
        prev = -1
        for {file, row, col, start, end} in filenames
          @span message.substr(prev + 1, start - (prev + 1))
          @span class: "filelink highlight-#{status}", name: file, row: row, col: col, message.substr(start, end - start + 1)
          prev = end
        @span message.substr(prev + 1) if prev isnt message.length - 1
      else
        @span if message is '' then ' ' else message

module.exports =

  deactivate: ->
    consoleview.destroy()
    consoleview = null
    ConsoleView = null

  output:
    class Console

      getView: -> #Not part of API (Spec function)
        consoleview

      newQueue: (@queue) ->
        ConsoleView ?= require '../view/console'
        consoleview ?= new ConsoleView
        consoleview.setQueueCount @queue.queue.length
        consoleview.clear()

      newCommand: (@command) ->
        consoleview.showBox()
        consoleview.setHeader("#{@command.name} of #{@command.project}")
        consoleview.unlock()
        @stdout.lines = []
        @stderr.lines = []

      stdout:

        lines: []

        in: ({input, files}) ->
          @lines.push consoleview.printLine(buildHTML(input.input, input.type, files))

        setType: (status) ->
          last = @lines[@lines.length - 1]
          status = '' if not status?
          status = 'info' if status is 'note'
          $(last).prop('class', "bold text-#{status}")

        print: ({input, files}) ->
          _new = buildHTML(input.input, input.type, files)
          element = $(@lines[@lines.length - 1])
          element.prop('class', _new.prop('class'))
          element.html(_new.html())

        replacePrevious: (lines) ->
          for {input, files}, index in lines
            _new = buildHTML(input.input, input.type, files)
            element = $(@lines[@lines.length - lines.length + index])
            element.prop('class', _new.prop('class'))
            element.html(_new.html())

      stderr:

        lines: []

        in: ({input, files}) ->
          @lines.push consoleview.printLine(buildHTML(input.input, input.type, files))

        setType: (status) ->
          last = @lines[@lines.length - 1]
          status = '' if not status?
          status = 'info' if status is 'note'
          $(last).prop('class', "bold text-#{status}")

        print: ({input, files}) ->
          _new = buildHTML(input.input, input.type, files)
          element = $(@lines[@lines.length - 1])
          element.prop('class', _new.prop('class'))
          element.html(_new.html())

        replacePrevious: (lines) ->
          for {input, files}, index in lines
            _new = buildHTML(input.input, input.type, files)
            element = $(@lines[@lines.length - lines.length + index])
            element.prop('class', _new.prop('class'))
            element.html(_new.html())

      error: (message) ->
        consoleview.hideOutput()
        consoleview.setHeader("#{@command.name} of #{@command.project}: received #{message}")
        consoleview.lock()

      exitCommand: (code) ->
        if code is 0
          consoleview.setQueueLength @queue.queue.length
          consoleview.setHeader(
            "#{@command.name} of #{@command.project}: finished with exitcode #{code}"
          )
        else
          consoleview.setHeader(
            "#{@command.name} of #{@command.project}: " +
            "<span class='error'>finished with exitcode #{code}</span>"
          )

      exitQueue: (code) ->
        consoleview.finishConsole code
