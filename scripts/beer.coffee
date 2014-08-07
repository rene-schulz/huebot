module.exports = (robot) ->
  
  pavel = '476250'
  david = '564539'
  
  robot.hear /beer/i, (msg) ->
    if msg.message.user.id == david
      msg.send " I'm sorry, Dave. I'm afraid I can't drink that."
    else
      msg.send "Did someone say beer? Here you go! (beer)"
