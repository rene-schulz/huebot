# Description
#   keeps track of dumbfulness.
#

module.exports = (robot) ->

  round = (number, places) ->
    return Math.round( number * Math.pow(10, places)) / Math.pow(10, places)

  dumbify = (msg) ->
    name = msg.match[1].trim()
    users = robot.brain.usersForFuzzyName(name)
  
    if users.length is 1
      user = users[0]
      try
        new_dumbness = set_dumbness(user, -1)
        msg.send( folksy_saying( user.name, new_dumbness, -1) )
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
        new_dumbness = set_dumbness(user, 1)
        msg.send( folksy_saying( user.name, new_dumbness, 1) )
      catch error
        msg.send "Uh-oh: #{error}"
    else if users.length > 1
      msg.send "Sorry, you have to be more specific which of #{users.length} geniuses you mean."
    else
      msg.send "Sorry, I don't really know who #{name} is."

  folksy_saying = (username, score, direction) ->
    adjective = "dumb"
    if direction == 1
      adjective = "smart"

    sayings = [
      "#{username} is as #{adjective} as #{round(score, 1)} cows",
      "#{username} has #{score} kiloheaps of #{adjective}",
      "#{username} is #{score} worth of #{adjective}",
    ]

    if direction == -1
      sayings.push("#{username} is dumber than a sack of #{round(score*100, 0)} hammers")
      sayings.push("#{username} is so dumb, someone sent him out for headlight fluid, and he brought back #{round(score*100, 0)} cans")
    if direction == 1
      sayings.push("#{username} is smarter than #{round(score*10, 0)} Einsteins")
      sayings.push("#{username} is has, like, #{round(score*10, 0)} brains")
      sayings.push("#{username} has the wit of #{round(score*10, 0)} Jesses")
      sayings.push("#{username} is so smart, he's beaten Brian's high score in every board game #{round(score*10, 0)} times")

    return sayings[ Math.floor(Math.random() * sayings.length) ] + " (Score: #{score})"

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

    dumb[user.id] = round(dumb[user.id], 2)

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
