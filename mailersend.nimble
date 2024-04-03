# Package

version       = "0.1.0"
author        = "George Lemon"
description   = "Asynchronous Nim client for interacting with MailerSend API"
license       = "MIT"
srcDir        = "src"

# Dependencies

requires "nim >= 2.0.2"
# requires "jsony#head"
requires "https://github.com/georgelemon/jsony#extend-skip-hook"

task build_email, "build /email":
  exec "nim c -d:ssl -o:./bin/email src/mailersend/email.nim"
