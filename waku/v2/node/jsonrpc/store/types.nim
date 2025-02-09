when (NimMajor, NimMinor) < (1, 4):
  {.push raises: [Defect].}
else:
  {.push raises: [].}

import
  std/options
import
  ../../../protocol/waku_store/rpc,
  ../message

export message


type
  StoreResponse* = object
    messages*: seq[WakuMessageRPC]
    pagingOptions*: Option[StorePagingOptions]

  StorePagingOptions* = object
    ## This type holds some options for pagination
    pageSize*: uint64
    cursor*: Option[PagingIndexRPC]
    forward*: bool
