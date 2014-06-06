module.exports = (robot) ->

  # Annoyin' David

  pavel = '476250'
  david = '564539'

  robot.hear /.*/i, (msg) ->
    if msg.message.user.id == david and Math.random() > 0.9
      msg.send "I'm sorry, Dave. I'm afraid I can't do that."

  robot.respond /.*/i, (msg) ->
    if msg.message.user.id == david
      msg.send "I'm sorry, Dave. I'm afraid I can't do that."
