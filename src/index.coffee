###

  Multiplexing-demultiplexing of several object streams inside single object
  stream.

###

through = require 'through2'

module.exports = (options = {}) ->
  ###

    Create mux-demux stream.

    :param options: Object with options
    :option error: Propagate error on substreams (default ``false``)

  ###

  s = through.obj (chunk, enc, cb) ->
    pos = chunk.indexOf '|'
    name = chunk.substring 0, pos
    chunk = chunk.substring ++pos
    ss = s.streams[name]
    if not ss
      console.warn "orphaned data for stream #{name}"
    else
      ss.push chunk
    cb()

  s.streams = {}

  s.createStream = (name) ->
    ss = s.streams[name] = through.obj (chunk, enc, cb) ->
      s.push "#{name}|#{chunk}"
      cb()

    s.on 'end', -> ss.emit 'end'

    if options.error
      s.on 'error', -> ss.emit 'error'

    ss

  s
