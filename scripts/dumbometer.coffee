# Description
#   keeps track of dumbfulness.
#

module.exports = (robot) ->

  Array::unique = ->
    output = {}
    output[@[key]] = @[key] for key in [0...@length]
    value for key, value of output

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

    possible_matches = []

    # Check for the mention name first - this is guaranteed unique by Hipchat.
    users = for userid, userobj of robot.brain.users() when userobj.mention_name is name
      userobj
    if users.length is 1
      return users[0]
    else if users.length > 1
      throw "Impossible! More than one user with the mention_name #{name}"
    else
      # If we're searching for @Pavel, and there's a @PavelLishin and a @PavelPushkin,
      # we want to save these two results as possible recommendations.
      users = for userid, userobj of robot.brain.users() when userobj.mention_name.toLowerCase().lastIndexOf(name.toLowerCase(), 0) is 0
        userobj
      possible_matches = possible_matches.concat users

    # Let's check their name
    users = robot.brain.usersForFuzzyName(name)
    robot.logger.debug("Found fuzzy users:", users)
    if users.length == 1
      return users[0]
    if users.length > 1
      possible_matches = possible_matches.concat users
      robot.logger.debug("Multiple fuzzy users, result is ", possible_matches)

    # Let's see who's in the room.
    # WELL, SHIT, HUBOT/HIPCHAT DON'T SUPPORT THAT
    # LOOKS LIKE I'LL HAVE TO FUCKING CALL THE API

    matches = for own userid, userobj of possible_matches
      "#{userobj.name} (@#{userobj.mention_name})"

    throw "Unable to find a user for '#{name}'. Did you mean:\n#{matches.unique().join('\n')}"

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
      msg.send( folksy_saying( user.name, get_score(user.id), "score" ) )
    catch error
      msg.send "Sorry: #{error}"

  folksy_saying = (username, score, action) ->
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

  # [\u00E0-\u00FC] - matches accented characters, as in René

  robot.hear /@?([\w .\-\u00E0-\u00FC]+) is dumb/i, dumbify
  robot.hear /@?([\w .\-\u00E0-\u00FC]+) is smart/i, smarten

  robot.hear /how smart is @?([\w .\-\u00E0-\u00FC]+)/i, show_score
  robot.hear /how dumb is @?([\w .\-\u00E0-\u00FC]+)/i, show_score
  robot.hear /is @?([\w .\-\u00E0-\u00FC]+) smart/i, show_score
  robot.hear /is @?([\w .\-\u00E0-\u00FC]+) dumb/i, show_score
