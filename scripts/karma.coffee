# Description:
#   Upboats for everyone
#
# Commands:
#   hubot karma - shows your current karma
#   hubot karmas - shows karma leaderboard
#   hubot karma <user> - shows karma for <user>
#   hubot +1|upvote <user>[, <comment>] - upvotes <user> with optional comment
#
# Examples:
#   hubot +1 hubot good job hubot
#   hubot karma hubot

module.exports = (robot) ->

  getAmbiguousUserText = (users) ->
    "Be more specific, I know #{users.length} people named like that: #{(user.name for user in users).join(", ")}"

  robot.respond /karma$/i, (msg) ->
    user = robot.brain.userForId(msg.message.user.id)
    karma = robot.brain.get('karma') or {}
    if not karma[user.id] or karma[user.id].count == 0
      msg.send "#{user.name} has no karma. Boo hoo."
    else
      msg.send "#{user.name} has #{karma[user.id].count} karma:\n" + karma[user.id].votes.join('\n')

  robot.respond /karma @?([\w .\-]+)$/i, (msg) ->
    name = msg.match[1].trim()
    users = robot.brain.usersForFuzzyName(name)
    if users.length is 1
      user = users[0]
      karma = robot.brain.get('karma') or {}
      if not karma[user.id] or karma[user.id].count == 0
        msg.send "#{user.name} has no karma. Boo hoo."
      else
        msg.send "#{user.name} has #{karma[user.id].count} karma:\n" + karma[user.id].votes.join('\n')
    else if users.length > 1
      msg.send getAmbiguousUserText users
    else
      msg.send "#{name}? I don't know who that is."

  robot.respond /karmas$/i, (msg) ->
    karma = robot.brain.get('karma')
    sorted = (k for k of karma).sort (a,b) -> karma[b].count - karma[a].count
    msg.send "Karma Leaderboard:\n" + ("#{karma[k].count} - #{robot.brain.userForId(k).name}" for k in sorted).join('\n')

  robot.respond /(\+1|up[vote,boat]) @?([\w .\-]+)(, (.+))?$/i, (msg) ->
    matches = msg.match
    name = matches[2].trim()
    comment = if matches[4] then matches[4].trim() else false
    users = robot.brain.usersForFuzzyName(name)
    if users.length is 1
      user = users[0]
      if user == msg.message.user
        msg.send "Nice try, but you can't upvote yourself."
        return

      karma = robot.brain.get('karma') or {}
      karma[user.id] = karma[user.id] or {count: 0, votes: []}
      karma[user.id].count += 1
      karma[user.id].votes.push(msg.message.user.name + (if comment then " - #{comment}" else ''))
      robot.brain.set('karma', karma)
      msg.send "#{user.name} has #{karma[user.id].count} karma!"
    else if users.length > 1
      msg.send getAmbiguousUserText users
    else
      msg.send "#{name}? I don't know who that is."
