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
    dumb = robot.brain.get('dumb') or {}
    if (not user.id in dumb) or isNaN(dumb[user.id]) or dumb < 0 or dumb > 1
      robot.logger.debug "Uh-oh, resetting dumbitude to 0.5"
      dumb[user.id] = 0.5

    # Move needle between 5 and 30% one direction or another.
    bonus = .05 + Math.random()/4;

    if direction == -1
      if dumb[user.id] == 0
        throw "Sorry, #{user.name} literally cannot get any dumber."
      old_dumb = dumb[user.id]
      new_dumb = Math.max(0, old_dumb - bonus)
      dumb[user.id] = new_dumb
    else if direction == 1
      if dumb[user.id] == 1
        throw "Sorry, #{user.name}'s godlike intellect has nowhere to go but down."
      old_dumb = dumb[user.id]
      new_dumb = Math.min(1, old_dumb + bonus)
      dumb[user.id] = new_dumb

    if isNaN(dumb[user.id])
      dumb[user.id] = 0.5
      brain.set('dumb', dumb)
      throw "User's dumbness was set to NaN! Tried to #{direction} a bonus of #{bonus} to #{old_dumb}, resulting in #{new_dumb}"

    if dumb[user.id] < 0 or dumb[user.id] > 1
      dumb[user.id] = 0.5
      brain.set('dumb', dumb)
      throw "User's dumbness was set to outside the valid range! Tried to #{direction} a bonus of #{bonus} to #{old_dumb}, resulting in #{new_dumb}"

    robot.logger.debug("Changing dumbfullness from #{old_dumb} to #{new_dumb}")

    robot.brain.set('dumb', dumb)

    return dumb[user.id]

  robot.respond /RESET DUMBNESS$/, (msg) ->
    robot.brain.set('dumb', {})
    msg.send "Enjoy the blank slate, idiots."

  robot.hear /@?([\w .\-]+) is dumb/i, dumbify
  robot.hear /@?([\w .\-]+) is smart/i, smarten
