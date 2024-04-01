# Asynchronous Nim client for
# interacting with the MailerSend API
#
#     Official MailerSend Documentation:
#     https://developers.mailersend.com
#
# (c) 2024 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/mailersend-nim

import std/[asyncdispatch, httpclient, tables,
  strutils, sequtils, times]

import pkg/jsony
import std/json except fromJson

from std/httpcore import HttpMethod, HttpHeaders, newHttpheaders

export HttpMethod, HttpHeaders, newHttpheaders,
  asyncdispatch, httpclient, tables, sequtils

type
  MailerSendEndpoint* = enum
    epApiQuota = "api-quota"
    epEmail = "email"

  MailerSend* = ref object
    apiKey: string
    uri*: MailerSendEndpoint
    httpClient*: AsyncHttpClient
    query*: QueryTable
    multiQuery*: MultiQueryTable

  QueryTable* = OrderedTable[string, string]
  MultiQueryTable* = OrderedTable[string, seq[string]]

  MailerSendQuota* = object
    quota*, remaining*: int
    `reset`*: Time

  MailerSendClientError* = object of CatchableError

const baseMailerSendUri = "https://api.mailersend.com/v1/"

proc initMailerSend*(key: string): MailerSend =
  new(result)
  result.apiKey = key
  result.httpClient = newAsyncHttpClient()
  result.httpClient.headers = newHttpheaders({
    "Content-Type": "application/json",
    "X-Requested-With": "XMLHttpRequest",
    "Authorization": "Bearer " & result.apiKey
  })

proc `$`*(query: QueryTable): string =
  ## Convert `query` QueryTable to string
  if query.len > 0:
    add result, "&"
    add result, join(query.keys.toSeq.mapIt(it & "=" & query[it]), "&")

proc `$`*(quota: MailerSendQuota): string =
  ## Serialize an `MailerSendQuota`
  toJSON quota

proc `$`*(query: MultiQueryTable): string =
  ## Convert `query` MultiQuerytable to string
  if query.len > 0:
    add result, "?"
    var i = 0
    let len = query.len - 1
    for k, x in query:
      if x.len == 1:
        add result, k
        add result, "=" & x[0]
      else:
        add result, join(x.mapIt(k & "=" & it), "&")
      if i != len:
        add result, "&"
      inc i

#
# JSONY hooks
#
proc parseHook*(s: string, i: var int, v: var Time) =
  var str: string
  parseHook(s, i, str)
  v = parseTime(str, "yyyy-MM-dd'T'hh:mm:sszzz", local())

proc endpoint*(ep: MailerSendEndpoint,
    multiQuery: MultiQueryTable, query: QueryTable): string =
  ## Return the stringified URL of `ep` endpoint
  result = baseMailerSendUri & $ep & $multiQuery & $query

proc getQuota*(client: MailerSend): Future[MailerSendQuota] {.async.} =
  let uri = baseMailerSendUri & $epApiQuota
  let res = await client.httpClient.request(uri, HttpGet)
  let body = await res.body
  case res.code
  of Http200:
    result = fromJSON(body, MailerSendQuota)
  else:
    let msg = fromJSON(body)
    raise newException(MailerSendClientError,
      msg["message"].getStr)

proc post*(client: MailerSend, data: string): Future[AsyncResponse] {.async.} =
  ## Make a `POST` request to a specific endpoint
  let uri = client.uri.endpoint(client.multiQuery, client.query)
  result = await client.httpClient.request(uri, HttpPost, body = data)
