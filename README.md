<p align="center">
  <img src="https://github.com/openpeeps/mailersend-nim/blob/main/.github/mailersend.png" width="210px" height="210px"><br>
  Asynchronous Nim 👑 client for interacting with the <a href="https://developers.mailersend.com/">MailerSend API</a>
</p>

<p align="center">
  <code>nimble install mailersend</code>
</p>

<p align="center">
  <a href="https://github.com/">API reference</a><br>
  <img src="https://github.com/openpeeps/mailersend-nim/workflows/test/badge.svg" alt="Github Actions">  <img src="https://github.com/openpeeps/mailersend-nim/workflows/docs/badge.svg" alt="Github Actions">
</p>

## 😍 Key Features
- Intuitive API interface
- Direct to object serialization via `pkg/jsony`
- Written in Nim 👑

## Examples
```
import pkg/mailersend

var
  mls = initMailersend(getEnv("api_key"))
  mail = newEmail()

mail.setSubject("Hello, this is a test")
    .setFrom("Example.com", "noreply@example.com")
    .setTo("Joël Chibuzo", "joel.chibuzo@test.com")
    .setText("This is a text/plain message")
    .setHtml("This is a <strong>text/html</strong> message")

let x: XHeaders = waitFor mls.send(mail)
echo x # (id: "660appx0cc4cf5d1c00xb113", paused: false)

# check current quota
let q = waitFor mls.getQuota()
echo q.remaining # 99
```

### ❤ Contributions & Support
- 🐛 Found a bug? [Create a new Issue](https://github.com/openpeeps/mailersend-nim/issues)
- 👋 Wanna help? [Fork it!](https://github.com/openpeeps/mailersend-nim/fork)
- 😎 [Get €20 in cloud credits from Hetzner](https://hetzner.cloud/?ref=Hm0mYGM9NxZ4)
- 🥰 [Donate via PayPal address](https://www.paypal.com/donate/?hosted_button_id=RJK3ZTDWPL55C)

### 🎩 License
MIT license. [Made by Humans from OpenPeeps](https://github.com/openpeeps).<br>
Copyright &copy; 2024 OpenPeeps & Contributors &mdash; All rights reserved.
