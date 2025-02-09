import
  std/options,
  stew/byteutils,
  libp2p/switch,
  libp2p/builders,
  libp2p/crypto/crypto as libp2p_keys,
  eth/keys as eth_keys
import
  ../../../waku/v2/protocol/waku_message,
  ./common

export switch


# Switch

proc generateEcdsaKey*(): libp2p_keys.PrivateKey =
  libp2p_keys.PrivateKey.random(ECDSA, rng[]).get()

proc generateEcdsaKeyPair*(): libp2p_keys.KeyPair =
  libp2p_keys.KeyPair.random(ECDSA, rng[]).get()

proc generateSecp256k1Key*(): libp2p_keys.PrivateKey =
  libp2p_keys.PrivateKey.random(Secp256k1, rng[]).get()

proc ethSecp256k1Key*(hex: string): eth_keys.PrivateKey =
  eth_keys.PrivateKey.fromHex(hex).get()


proc newTestSwitch*(key=none(libp2p_keys.PrivateKey), address=none(MultiAddress)): Switch =
  let peerKey = key.get(generateSecp256k1Key())
  let peerAddr = address.get(MultiAddress.init("/ip4/127.0.0.1/tcp/0").get())
  return newStandardSwitch(some(peerKey), addrs=peerAddr)


# Waku message

export
  waku_message.DefaultPubsubTopic,
  waku_message.DefaultContentTopic


proc fakeWakuMessage*(
  payload: string|seq[byte] = "TEST-PAYLOAD",
  contentTopic = DefaultContentTopic,
  meta = newSeq[byte](),
  ts = now(),
  ephemeral = false
): WakuMessage =
  var payloadBytes: seq[byte]
  when payload is string:
    payloadBytes = toBytes(payload)
  else:
    payloadBytes = payload

  WakuMessage(
    payload: payloadBytes,
    contentTopic: contentTopic,
    meta: meta,
    version: 2,
    timestamp: ts,
    ephemeral: ephemeral
  )
