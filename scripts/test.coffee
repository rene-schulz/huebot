module.exports = (robot) ->
  robot.hear /.*/i, (msg) ->
    if msg.message.user.name == 'Pavel Lishin'
      if Math.random() >= 0.9
        msg.send "(tableflip)"
        msg.send "Go back to work Pavel"

  robot.hear /thanks/i, (msg) ->
    firstName = msg.message.user.name.split()[0]
    msg.send "You're welcome #{firstName}! (content)"
