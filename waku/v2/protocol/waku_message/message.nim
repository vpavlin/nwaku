## Waku Message module.
##
## See https://github.com/vacp2p/specs/blob/master/specs/waku/v2/waku-message.md
## for spec.

when (NimMajor, NimMinor) < (1, 4):
  {.push raises: [Defect].}
else:
  {.push raises: [].}


import
  ../../utils/time,
  ./topics

const
  MaxMetaAttrLength* = 64 # 64 bytes

  MaxWakuMessageSize* = 1024 * 1024 # 1 Mibytes. Corresponds to PubSub default


type WakuMessage* = object
    # Data payload transmitted.
    payload*: seq[byte]
    # String identifier that can be used for content-based filtering.
    contentTopic*: ContentTopic
    # Application specific metadata.
    meta*: seq[byte]
    # Number to discriminate different types of payload encryption.
    # Compatibility with Whisper/WakuV1.
    version*: uint32
    # Sender generated timestamp. Deprecated. Superseded by `meta` attribute.
    timestamp*: Timestamp
    # The ephemeral attribute indicates signifies the transient nature of the
    # message (if the message should be stored).
    ephemeral*: bool
    # EXPERIMENTAL: Part of RFC 17: https://rfc.vac.dev/spec/17/
    when defined(rln):
      # The proof attribute indicates that the message is not a spam. This
      # attribute will be used in the rln-relay protocol.
      proof*: seq[byte]
