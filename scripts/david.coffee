module.exports = (robot) ->

  # Annoyin' David

  pavel = '476250'
  david = '564539'

  get_seconds = () ->
    return Math.floor((new Date()).getTime() / 1000)

  # Only deny Dave something every 30 seconds at most
  last_denied = get_seconds()

  robot.hear /.*/i, (msg) ->
    if msg.message.user.id == david and Math.random() > 0.9
      if get_seconds() > last_denied + 30
        last_denied = get_seconds()
        msg.send "I'm sorry, Dave. I'm afraid I can't do that."

  robot.respond /.*/i, (msg) ->
    if msg.message.user.id == david
      if get_seconds() > last_denied + 30
        last_denied = get_seconds()
        msg.send "I'm sorry, Dave. I'm afraid I can't do that."
