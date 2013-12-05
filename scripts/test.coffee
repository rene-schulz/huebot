module.exports = (robot) ->
  robot.hear /.*/i, (msg) ->
    if msg.message.user.name == 'Pavel Lishin'
      if Math.random() >= 0.75
        msg.send "(tableflip)"
        msg.send "Go back to work Pavel"
