## This code has been copied and addapted from `status-im/nimbu-eth2` project.
## Link: https://github.com/status-im/nimbus-eth2/blob/c585b0a5b1ae4d55af38ad7f4715ad455e791552/beacon_chain/nimbus_binary_common.nim
import
  std/[strutils, typetraits],
  chronicles,
  chronicles/log_output,
  chronicles/topics_registry


when (NimMajor, NimMinor) < (1, 4):
  {.push raises: [Defect].}
else:
  {.push raises: [].}


type
  LogLevel* = enum
    TRACE, DEBUG, INFO, NOTICE, WARN, ERROR, FATAL

  LogFormat* = enum
    TEXT, JSON

converter toChroniclesLogLevel(level: LogLevel): chronicles.LogLevel =
  ## Map logging log levels to the corresponding nim-chronicles' log level
  try:
    parseEnum[chronicles.LogLevel]($level)
  except:
    chronicles.LogLevel.NONE


## Utils

proc stripAnsi(v: string): string =
  ## Copied from: https://github.com/status-im/nimbus-eth2/blob/stable/beacon_chain/nimbus_binary_common.nim#L41
  ## Silly chronicles, colors is a compile-time property
  var
    res = newStringOfCap(v.len)
    i: int

  while i < v.len:
    let c = v[i]
    if c == '\x1b':
      var
        x = i + 1
        found = false

      while x < v.len: # look for [..m
        let c2 = v[x]
        if x == i + 1:
          if c2 != '[':
            break
        else:
          if c2 in {'0'..'9'} + {';'}:
            discard # keep looking
          elif c2 == 'm':
            i = x + 1
            found = true
            break
          else:
            break
        inc x

      if found: # skip adding c
        continue
    res.add c
    inc i

  res

proc writeAndFlush(f: File, s: LogOutputStr) =
  try:
    f.write(s)
    f.flushFile()
  except:
    logLoggingFailure(cstring(s), getCurrentException())


## Setup

proc setupLogLevel*(level: LogLevel) =
  # TODO: Support per topic level configuratio
  topics_registry.setLogLevel(level)

proc setupLogFormat*(format: LogFormat, color=true) =
  proc noOutputWriter(logLevel: chronicles.LogLevel, msg: LogOutputStr) = discard

  proc stdoutOutputWriter(logLevel: chronicles.LogLevel, msg: LogOutputStr) =
    writeAndFlush(io.stdout, msg)

  proc stdoutNoColorOutputWriter(logLevel: chronicles.LogLevel, msg: LogOutputStr) =
    writeAndFlush(io.stdout, stripAnsi(msg))


  when defaultChroniclesStream.outputs.type.arity == 2:
    case format:
    of LogFormat.Text:
      defaultChroniclesStream.outputs[0].writer = if color: stdoutOutputWriter
                                                  else: stdoutNoColorOutputWriter
      defaultChroniclesStream.outputs[1].writer = noOutputWriter

    of LogFormat.Json:
      defaultChroniclesStream.outputs[0].writer = noOutputWriter
      defaultChroniclesStream.outputs[1].writer = stdoutOutputWriter

  else:
    {.warning:
      "the present module should be compiled with '-d:chronicles_default_output_device=dynamic' " &
      "and '-d:chronicles_sinks=\"textlines,json\"' options" .}
