module.exports =

  edit:
    class AllSaver
      get: (command, stream) ->
        stream.pipeline.push name: 'all'
        return null

  modifier:
    class AllModifier
      modify: ({temp}) ->
        temp.type = 'warning' unless temp.type? and temp.type isnt ''
        return null