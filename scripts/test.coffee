module.exports = (robot) ->
  robot.respond /.*/i, (msg) ->
    if msg.message.user.name == 'Pavel Lishin'
      if Math.random() >= 0.5
        msg.send "(tableflip)"
        msg.send "Go back to work Pavel"
