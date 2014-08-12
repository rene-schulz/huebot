# Description
#   keeps track of dumbfulness.
#


# TODO - make sure people can't smarten themselves
# TODO - detect circlejerks

# BUG - it thinks I'm NaN dumb
#  Ugh, Pavel Lishin is NaN worth of dumb.
# BUG - it can't fucking find René
#     [17:54] Pavel Lishin: @ReneSchulz is dumb
#     [17:54] Huebot !: Sorry, I don't really know who ReneSchulz is.
#     [17:54] Pavel Lishin: Rene Schulz is dumb
#     [17:54] Huebot !: Sorry, I don't really know who Rene Schulz is.
#     [17:54] Pavel Lishin: René Schulz is dumb
#     [17:54] Huebot !: Sorry, I don't really know who Schulz is.


module.exports = (robot) ->

  dumbify = (msg) ->
    name = msg.match[1].trim()
    users = robot.brain.usersForFuzzyName(name)
  
    if users.length is 1
      user = users[0]
      try
        new_dumbness = set_dumbness(user, -1).toFixed(2)
        msg.send "Ugh, #{user.name} is #{new_dumbness} worth of dumb."
      catch error
        msg.send "Uh-oh: #{error}"
    else if users.length > 1
      msg.send "Sorry, you have to be more specific which of #{users.length} dummies you mean."
    else
      msg.send "Sorry, I don't really know who #{name} is."

  smarten = (msg) ->
    name = msg.match[1].trim()
    users = robot.brain.usersForFuzzyName(name)
  
    if users.length is 1
      user = users[0]
      try
        new_dumbness = set_dumbness(user, 1).toFixed(2)
        msg.send "Wow, #{user.name} is #{new_dumbness} worth of genius!"
      catch error
        msg.send "Uh-oh: #{error}"
    else if users.length > 1
      msg.send "Sorry, you have to be more specific which of #{users.length} geniuses you mean."
    else
      msg.send "Sorry, I don't really know who #{name} is."

  set_dumbness = (user, direction) ->
    dumbfullness = robot.brain.get('dumbfullness') or {}
    if not user.id in dumbfullness
      dumbfullness[user.id] = 0.5

    # Move needle between 5 and 30% one direction or another.
    bonus = .05 + Math.random()/4;

    if direction == -1
      if dumbfullness[user.id] == 0
        throw "Sorry, #{user.name} literally cannot get any dumber."
      old_dumbfullness = dumbfullness[user.id]
      new_dumbfullness = Math.max(0, dumbfullness[user.id] - bonus)
      dumbfullness[user.id] = new_dumbfullness
    else if direction == 1
      if dumbfullness[user.id] == 1
        throw "Sorry, #{user.name}'s godlike intellect has nowhere to go but down."
      old_dumbfullness = dumbfullness[user.id]
      new_dumbfullness = Math.min(1, dumbfullness[user.id] + bonus)
      dumbfullness[user.id] = new_dumbfullness

    robot.logger.debug("Changing dumbfullness from #{old_dumbfullness} to #{new_dumbfullness}")

    robot.brain.set('dumbfullness', dumbfullness)

    return dumbfullness[user.id]

  robot.respond /RESET DUMBNESS$/, (msg) ->
    robot.brain.set('dumbfullness', {})
    msg.send "Enjoy the blank slate, idiots."

  robot.hear /@?([\w .\-]+) is dumb/i, dumbify
  robot.hear /@?([\w .\-]+) is smart/i, smarten
