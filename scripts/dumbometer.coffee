# Description
#   keeps track of dumbfulness.
#

module.exports = (robot) ->

  random = (items) ->
    return items[ Math.floor(Math.random() * items.length) ]

  round = (number, places) ->
    return Math.round( number * Math.pow(10, places)) / Math.pow(10, places)

  get_score = (userid) ->
    scores = robot.brain.get('dumb') or {}
    if not userid in scores or typeof(scores[userid]) == "undefined" or scores[userid] == null or isNaN(scores[userid])
      robot.logger.debug("Invalid score detected in database: #{scores[userid]}")
      return 0.5
    if scores[userid] < 0
      return 0
    if scores[userid] > 1
      return 1
    return parseFloat(scores[userid])

  set_score = (userid, score) ->
    if typeof(score) == "undefined" or score == null or isNaN(score)
      throw "Can't set a score of #{score} for #{userid}"
    if score < 0
      score = 0
    if score > 1
      score = 1
    scores = robot.brain.get('dumb') or {}
    scores[userid] = round(score, 3)
    robot.brain.set('dumb', scores)

  find_single_user = (name, msg) ->
    # A better search than usersForFuzzyName
    # Throws error if a single user cannot be found.

    # Strongly prefers the user that's in the same room as msg

    # Uh, to be implemented later :)
    users = robot.brain.usersForFuzzyName(name)
    if users.length != 1
      throw "#{users.length} were found."

    return users[0]

  get_score_bonus = () ->
    return .05 + Math.random()/4;

  dumbify = (msg) ->
    name = msg.match[1].trim()
    try
      user = find_single_user(name, msg)
      score = get_score(user.id)
      if score == 0
        throw "#{user.name} is as dumb as they can get."
      set_score(user.id, score - get_score_bonus())
      msg.send( folksy_saying( user.name, get_score(user.id), "dumb" ) )
    catch error
      msg.send "Sorry: #{error}"

  smarten = (msg) ->
    name = msg.match[1].trim()
    try
      user = find_single_user(name, msg)
      score = get_score(user.id)
      if score == 1
        throw "#{user.name} is as smart as they can get."
      set_score(user.id, score + get_score_bonus())
      msg.send( folksy_saying( user.name, get_score(user.id), "smart" ) )
    catch error
      msg.send "Sorry: #{error}"


  show_score = (msg) ->
    name = msg.match[1].trim()
    try
      user = find_single_user(name, msg)
      score = get_score(user.id)

      robot.logger.debug(user)
      robot.logger.debug(user.name)

      msg.send( folksy_saying( user.name, get_score(user.id), "score" ) )
    catch error
      msg.send "Sorry: #{error}"

  folksy_saying = (username, score, action) ->
    robot.logger.debug(username)
    
    if action == "score"
      adjective = (score < 0.5 and "dumb") or "smart"
    else
      adjective = action

    sayings = [
      "#{username} is as #{adjective} as #{round(score*10, 1)} cows",
      "#{username} has #{score} kiloheaps of #{adjective}",
      "#{username} is #{score} worth of #{adjective}",
    ]

    if action == "dumb" or (action == "score" and score < 0.5)
      sayings.push("#{username} is dumber than a sack of #{round(score*100, 0)} hammers")
      sayings.push("#{username} is so dumb, someone sent him out for headlight fluid, and he brought back #{round(score*10, 0)} cans")
    if action == "smart" or (action == "score" and score >= 0.5)
      sayings.push("#{username} is smarter than #{round(score*10, 0)} Einsteins")
      sayings.push("#{username} is has, like, #{round(score*10, 0)} brains")

    return random(sayings) + " (Score: #{score})"


  robot.respond /.*RESET DUMBNESS.*/i, (msg) ->
    robot.brain.set('dumb', {})
    msg.send "Enjoy the blank slate, idiots."

  robot.hear /@?([\w .\-]+) is dumb/i, dumbify
  robot.hear /@?([\w .\-]+) is smart/i, smarten

  robot.hear /how smart is @?([\w .\-]+)/i, show_score
  robot.hear /how dumb is @?([\w .\-]+)/i, show_score
  robot.hear /is @?([\w .\-]+) smart/i, show_score
  robot.hear /is @?([\w .\-]+) dumb/i, show_score
