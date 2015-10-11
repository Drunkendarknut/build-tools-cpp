Tab = require './tab'

{Emitter} = require 'atom'

module.exports =
  class Console
    constructor: ->
      @tabs = {}
      @emitter = new Emitter

    destroy: ->
      @emitter.dispose()
      for k in Object.keys(@tabs)
        for k2 in Object.keys(@tabs[k])
          @removeTab @tabs[k][k2]
      @tabs = {}
      @emitter = null

    getTab: (command) ->
      return tab if (tab = @tabs[command.project]?[command.name])?
      @createTab(command)

    createTab: (command) ->
      @tabs[command.project] ?= {}
      tab = @tabs[command.project][command.name] = new Tab(command)
      tab.onClose =>
        @removeTab tab
      tab.focus = =>
        @focusTab tab
      @emitter.emit 'add', tab
      return tab

    removeTab: (tab) ->
      @emitter.emit 'remove', tab
      tab.destroy()
      delete @tabs[tab.command.project][tab.command.name]

    focusTab: (tab) ->
      @emitter.emit 'focus', tab

    onFocusTab: (callback) ->
      @emitter.on 'focus', callback

    onCreateTab: (callback) ->
      @emitter.on 'add', callback

    onRemoveTab: (callback) ->
      @emitter.on 'remove', callback
