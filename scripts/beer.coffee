module.exports = (robot) ->
  robot.hear /beer/i, (msg) ->
    if msg.message.user.name == 'Pavel Lishin'
      msg.send "No beer for you Pavel."
      msg.send "(content)"
    else
      msg.send "Did someone say beer? Here you go!"
      msg.send "(beer)"
