path = require 'path'
QueueWorker = require '../pipeline/queue-worker'

splitQuotes = (cmd_string) ->
  args = []
  cmd_list = cmd_string.split(' ')
  instring = false
  getQuoteIndex = (line) ->
    return {index: c, character: '"'} if (c = line.indexOf('"')) isnt -1
    return {index: c, character: "'"} if (c = line.indexOf("'")) isnt -1
  while (cmd_list.length isnt 0)
    if not instring
      args.push cmd_list[0]
    else
      args[args.length - 1] += ' ' + cmd_list[0]
    qi = getQuoteIndex(cmd_list[0])
    if (qi = getQuoteIndex(cmd_list[0]))?
      if instring
        instring = false
      else
        if cmd_list[0].substr(qi.index + 1).indexOf(qi.character) is -1
          instring = true
    cmd_list.shift()
  (args[i] = a.slice(1, -1) for a, i in args when /[\"\']/.test(a[0]) and /[\"\']/.test(a[a.length - 1]))
  return args

module.exports =
  class Command
    constructor: ({@project, @name, @command, @wd, env, @modifier, @stdout, @stderr, @output, @version} = {}) ->
      @env = {}
      @env[k] = env[k] for k in Object.keys(env) if env?
      @output ?= {}
      @stdout ?= highlighting: 'nh'
      @stderr ?= highlighting: 'nh'
      @version ?= 1

    getSpawnInfo: ->
      args = splitQuotes @command
      @command = args[0]
      @args = args.slice(1)

    getWorker: ->
      new QueueWorker(queue: [new Command(this)])
