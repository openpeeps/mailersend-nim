# import unittest, mailersend

# import dotenv
# from std/os import getEnv
# from std/macros import getProjectPath

# test "can add":
#   dotenv.load(getProjectPath())
#   var mls = initMailerSend(getEnv("api_key"))
#   let mail = newEmail()
#   mail.setSubject("Test email - This is a subject")
#       .setFrom("GoodGuest.ro", "noreply@goodguest.ro")
#       .setTo("George Lemon", "georgelemon@protonmail.com")
#       .setText("This is a plain text messsage")
#   # echo waitFor mls.send(mail)
#   echo waitFor mls.getQuota()
