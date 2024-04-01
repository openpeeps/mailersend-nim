# Asynchronous Nim client for
# interacting with the MailerSend API
#
#     Official MailerSend Documentation:
#     https://developers.mailersend.com
#
# (c) 2024 George Lemon | MIT License
#          Made by Humans from OpenPeeps
#          https://github.com/openpeeps/mailersend-nim
import std/[base64, times]
import pkg/jsony
import ./meta

from std/strutils import parseBool

type
  Participant* = ref object
    name, email: string

  AttachmentDisposition* = enum
    attachInline = "inline"
    attachAttachment = "attachment"

  Attachment* = ref object
    id: string # optional
      # Can be used in content as `<img src="cid:*"/>`.
      # Must also set `disposition` as `attachInline`.
    filename: string        # required
    content: string         # required
      # Base64 encoded content of the attachment.
      # Max size of 25MB. After decoding Base64
    disposition: AttachmentDisposition # required
      # Use `inline` to make it accessible for content.
      # Use `attachment` to normal attachments
  
  XHeaders* = tuple[id: string, paused: bool]
  EmailPersonalization* = ref object
    ## See https://developers.mailersend.com/api/v1/features.html#advanced-personalization

  EmailSettings* = ref object
    track_clicks*, track_opens*, track_content*: bool

  EmailHeaders* = ref object
    name: string

  Email* = ref object
    `from`, reply_to: Participant
      # Not required if `template_id` is present
      # and template has default sender set.
      #
      # Note that `email` must be a verified domain or a
      # subdomain from a verified domain.
    to: seq[Participant] # required
      # min 1 `Participan`, maximum `50`
    cc: seq[Participant]
    bcc: seq[Participant]
    send_at: int64  # optional min: now, max: now + 72hours
      # Has to be a Unix timestamp. Please note that this
      # timestamp is a minimal guarantee and that the email
      # could be delayed due to server load.
    in_reply_to: string # optional
      # Alphanumeric which can contain `_`, `-`, `@` and `..`
    settings: EmailSettings
    subject: string
      # Not required if `template_id` is present
      # and template has default sender set.
    text: string
      # Email represented in a `text/plain` format.
      # Only required if there's no `html` or `template_id` present.
    html: string
      # Email represented in `text/html` format. 
      # Only required if there's no text or `template_id` present.
    personalization: seq[EmailPersonalization]
      # Allows using personalization in {{var}} syntax.
      # Can be used in the subject, html, text fields. Read more about
      # https://developers.mailersend.com/api/v1/features.html#advanced-personalization
    attachments: seq[Attachment] # optional
    template_id: string
      # Only required if there's no `text` or `html` present.
    tags: seq[string]  # optional
      # Limit is max 5 tags. If the template used already has tags,
      # then the request will override them.

proc newEmail*: Email =
  ## Initialize a new `Email`
  new(result)

proc newEmail*(sender: Participant): Email =
  ## Initialize a new `Email` containing `sender` details
  new(result)
  result.`from` = sender

proc newEmail*(name, address: string): Email =
  ## Intiialize a new `Email` containing `name`, `address`
  ## of the sender
  new(result)
  result.`from` = Participant(name: name, email: address)

# proc compose*(sender: Participant): Email =

proc setFrom*(email: Email, name, address: string): Email =
  result = email
  result.`from` = Participant(name: name, email: address)

proc setTo*(email: Email, name, address: string): Email =
  result = email
  add result.to, Participant(name: name, email: address)

proc setSubject*(email: Email, x: string): Email =
  ## Set a subject
  result = email
  result.subject = x

proc setText*(email: Email, x: string): Email {.discardable.} =
  ## Set a `text/plain` content to `email`
  result = email
  result.text = x

proc setHtml*(email: Email, x: string): Email {.discardable.} =
  ## Set a `text/html` content to `email`
  result = email
  result.html = x

proc setReplyTo*(email: Email, name, address: string): Email =
  ## Set a `replyto` header
  result = email
  result.reply_to = Participant(name: name, email: address)

proc skipHook*(v: Participant, key: string): bool =
  result = v == nil

proc skipHook*(v: EmailSettings, key: string): bool =
  result = v == nil

proc skipHook*(v: int64, key: string): bool =
  result = v == 0

proc skipHook*(v: string, key: string): bool =
  result = v.len == 0

proc skipHook*[T](v: seq[T], key: string): bool =
  result = v.len == 0

proc `$`*(email: Email): string =
  ## Serialize an `Email`
  toJSON email

proc send*(mls: MailerSend, email: Email): Future[XHeaders] {.async.} =
  ## Make a `POST` request to send an asynchronous email
  mls.uri = epEmail
  let res = await mls.post($email)
  let body = await res.body
  case res.code:
  of Http202:
    if res.headers.hasKey("X-Message-Id"):
      result[0] = res.headers["X-Message-Id"]
    if res.headers.hasKey("X-Send-Paused"):
      result[1] = res.headers["X-Send-Paused"].parseBool
  else: discard

when isMainModule:
  import pkg/dotenv
  from std/os import getEnv
  from std/macros import getProjectPath
  dotenv.load(getProjectPath())
  var mls = initMailerSend(getEnv("api_key"))
  let mail = newEmail()
  mail.setSubject("Test email - This is a subject")
      .setFrom("GoodGuest.ro", "noreply@goodguest.ro")
      .setTo("George Lemon", "georgelemon@protonmail.com")
      .setText("This is a plain text messsage")
  # echo waitFor mls.send(mail)
  echo waitFor mls.getQuota()
