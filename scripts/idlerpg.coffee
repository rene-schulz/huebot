# Description:
#   The easiest RPG to play, the hardest RPG to win.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# TODO:
#   - listen to privmsg for registration - only class is required
#
#   - need a STATUS command
#
#   - how do I detect quits, vs. parts?
#
#   - items!
#       - random(0, 1.5*LEVEL)
#       - legendary items!
#           - Norton's +( random(LEVEL, 2*LEVEL) ) DOGECOIN
#           - Alain's +( random(LEVEL, 2*LEVEL) ) ACCENT
#       - idlerpg formula:
#         for each 'number' from 1 to YOUR_LEVEL*1.5
#           you have a 1 / ((1.4)^number) chance to find an item at this level
#         end for
#
#   - dueling!
#
#   - alignments
#    - punish for switching too often?
#    - ooh, location alignments? Austin vs New York vs SF vs wherever

Util = require "util"

ORGANIZATION_ID = process.env.ORGANIZATION_ID or "67748"
IDLERPG_ROOM = process.env.IDLERPG_ROOM or "idlerpg"

PLAYING = false
LOOP_INTERVAL = 10
LOOP_TIMEOUT = undefined
LAST_TIMESTAMP = undefined


ADMINS = [
    '67748_476250@chat.hipchat.com' # Pavel
]

ITEM_TYPES = [
    "sword", "shield", "helmet",
    "keyboard", "mouse", "laptop", "monitor"
]

LEGENDARY_ITEMS = [
    "Norton's Dogecoin",
    "Alain's Accent"
]

HELP_TEXT = """
Welcome to IdleRPG - like http://idlerpg.net/ except not as good yet!

The following commands should be typed in the IdleRPG room,
or privately messaged to this bot with the prefix "IDLERPG"

HELP
 Prints this help text.

REGISTER <character class>
 This registers you as an idlerpg player, with that character class.
 This is a p0 action.

LOGIN
 This marks you as "in the game".
 This is a p0 action.
 (no password is necessary; Hipchat is our auth.)

LOGOUT
 This marks you as "out of the game".
 This is a p20 action!

SCORE
 Messages you the current players and their scores
 This is a p0 action.
"""

module.exports = (robot) ->

    ####################
    # Helper functions
    ####################

    in_room = (msg) ->
        return msg.envelope.room == IDLERPG_ROOM or msg.envelope.room == "#{ORGANIZATION_ID}_#{IDLERPG_ROOM}@conf.hipchat.com"

    is_private = (msg) ->
        return msg.envelope.room == undefined && msg.message.user.jid == msg.message.user.reply_to

    is_admin = (msg) ->
        return msg.message.user.jid in ADMINS

    get_timestamp = () ->
        return Math.floor( (new Date()).getTime() / 1000)

    get_user_title = (userid) ->
        idlerpg = robot.brain.get('idlerpg') or {}
        if ! idlerpg[userid]?
            throw new Error("User #{userid} is not registered.")

        return "#{idlerpg[userid]['name']} the #{idlerpg[userid]['charclass']}"

    get_user_level_title = (userid) ->
        idlerpg = robot.brain.get('idlerpg') or {}
        if ! idlerpg[userid]?
            throw new Error("User #{userid} is not registered.")

        return "#{idlerpg[userid]['name']} the level #{idlerpg[userid]['level']} #{idlerpg[userid]['charclass']}"


    time_for_next_level = (level) ->
        return Math.floor(600 * Math.pow(1.16, level))

    time_for_penalty = (penalty, level, message) ->
        robot.logger.debug("time_for_penalty(#{penalty}, #{level}, #{message})")
        time = 0
        try
            switch penalty.toLowerCase()
                when "part"   then time = Math.floor(200 * Math.pow(1.14, parseInt(level)))
                when "quit"   then time = Math.floor(20 * Math.pow(1.14, parseInt(level)))
                when "logout" then time = Math.floor(20 * Math.pow(1.14, parseInt(level)))
                when "talk"   then time = Math.floor(message.length * Math.pow(1.14, parseInt(level)))
                else               robot.logger.error("Invalid penalty #{penalty}")
        catch error
            robot.logger.error("Unable to determine penalty: ", error)
        robot.logger.debug("Penalty is #{penalty}")
        return time


    set_time = (userid, time) ->
        robot.logger.info("Setting time remaining for #{userid} to #{time}")

        idlerpg = robot.brain.get('idlerpg') or {}
        if ! idlerpg[userid]?
            throw new Error("User #{userid} is not registered.")

        idlerpg[userid]['remaining'] = time
        robot.brain.set('idlerpg', idlerpg)

    announce = (message) ->
        robot.logger.info("Announcing: #{message}")
        robot.send("#{ORGANIZATION_ID}_#{IDLERPG_ROOM}@conf.hipchat.com", message)

    level_up = (userid) ->
        robot.logger.info("Leveling #{userid} up!")

        idlerpg = robot.brain.get('idlerpg') or {}

        if ! idlerpg[userid]?
            robot.logger.error "User #{userid} is not registered."
            return
        if idlerpg[userid]['remaining'] > 0
            robot.logger.error "User #{userid} still has #{idlerpg[userid]['remaining']} seconds left"
            return
        idlerpg[userid]['level'] += 1
        idlerpg[userid]['remaining'] = time_for_next_level(idlerpg[userid]['level']) + idlerpg[userid]['remaining']

        title = get_user_title(userid)
        announce("#{title} is now level #{idlerpg[userid]['level']}! #{idlerpg[userid]['remaining']} seconds until next level.")

        search_for_item(userid)

    penalize = (userid, time, reason) ->
        robot.logger.info("Penalizing #{userid} with #{time} for #{reason}")
        idlerpg = robot.brain.get('idlerpg') or {}
        idlerpg[userid]['remaining'] += time
        robot.brain.set('idlerpg', idlerpg)

        title = get_user_level_title(userid)
        announce("#{title} was penalized #{time} seconds: #{reason}")

    search_for_item = (userid) ->
        idlerpg = robot.brain.get('idlerpg') or {}
        if ! idlerpg[userid]?
            robot.logger.error "User #{userid} is not registered."
            return

        # Items not yet implemented
        robot.logger.info "Items not yet implemented"
        return

        # TODO - if item found, announce to room


    ####################
    # Interaction functions
    ####################

    help = (msg) ->
        userid = msg.message.user.jid
        robot.send( { user: userid }, HELP_TEXT )

    score = () ->
        # message player the current scores
        robot.logger.info "Score method is not yet implemented."

    register = (msg) ->
        idlerpg = robot.brain.get('idlerpg') or {}

        userid = msg.message.user.jid
        charclass = msg.match[1]

        robot.logger.info "Trying to register #{msg.message.user.name} #{userid}"

        # Is this user already registered?
        if idlerpg[userid]?
            robot.logger.info "User #{msg.message.user.name} #{userid} already registered"
            return robot.send( { user: userid }, "You have already registered." )

        # register user with character class
        robot.logger.info "Registering #{msg.message.user.name} #{userid} as #{charclass}"

        idlerpg[userid] =
            userid:    userid
            name:      msg.message.user.name
            charclass: charclass
            level:     1
            remaining: time_for_next_level(1)
            logged_in: true
            items: {}

        robot.brain.set('idlerpg', idlerpg)

    login = (msg) ->
        userid = msg.message.user.jid

        idlerpg = robot.brain.get('idlerpg') or {}

        robot.logger.info("User #{userid} logging in.")

        unless idlerpg[userid]
            robot.logger.info("User #{userid} is not yet registered.")
            return robot.send( { user: userid }, "You have not registered yet." )

        unless ! idlerpg[userid]['logged_in']
            robot.logger.info("User #{userid} is already in.")
            return robot.send( { user: userid }, "You are already logged in." )

        title = get_user_level_title(userid)
        announce("#{title} is now logged in! #{idlerpg[userid]['remaining']} seconds until next level.")

        idlerpg[userid]['logged_in'] = true
        robot.brain.set('idlerpg', idlerpg)

    logout = (msg) ->
        idlerpg = robot.brain.get('idlerpg') or {}

        userid = msg.message?.user?.jid or msg

        robot.logger.info("User #{userid} logging out.")

        unless idlerpg[userid]
            robot.logger.info("User #{userid} is not yet registered.")
            return robot.send( { user: userid }, "You have not registered yet." )

        unless idlerpg[userid]['logged_in']
            robot.logger.info("User #{userid} is not logged in.")
            return robot.send( { user: userid }, "You are not logged in." )

        penalize(userid, time_for_penalty("logout", idlerpg[userid]['level']), "User logged out.")
        idlerpg[userid]['logged_in'] = false
        robot.brain.set('idlerpg', idlerpg)

    ####################
    # Robot interactions
    ####################

    robot.hear /HELP/i, (msg) ->
        in_room(msg) and help msg
    robot.hear /IDLERPG HELP/i, (msg) ->
        is_private(msg) and help msg

    robot.hear /LOGIN/i, (msg) ->
        in_room(msg) and login msg
    robot.hear /IDLERPG LOGIN/i, (msg) ->
        is_private(msg) and login msg

    robot.hear /LOGOUT/i, (msg) ->
        in_room(msg) and logout msg
    robot.hear /IDLERPG LOGOUT/i, (msg) ->
        is_private(msg) and logout msg

    robot.hear /REGISTER (.*)/i, (msg) ->
        in_room(msg) and register msg
    robot.hear /IDLERPG REGISTER (.*)/i, (msg) ->
        is_private(msg) and register msg

    robot.hear /(.*)/, (msg) ->
        return unless PLAYING and in_room(msg)
        # Valid commands do not count
        return if msg.message.text.match(/^(HELP|LOGIN|LOGOUT|REGISTER)/i)
        userid = msg.envelope.user.jid
        idlerpg = robot.brain.get('idlerpg') or {}
        # Non-players and logged-out players don't count
        return unless idlerpg[userid]?
        return unless idlerpg[userid]['logged_in']
        # Penalize user
        penalize(userid, time_for_penalty("talk", idlerpg[userid]['level'], msg.message.text), "Talking is not idling!")

    robot.enter (msg) ->
        return unless in_room(msg)
        userid = msg.envelope.user.jid

    robot.leave (msg) ->
        # TODO - this does not work! Function never seems to fire.
        return unless PLAYING and in_room(msg)
        userid = msg.envelope.user.jid
        idlerpg = robot.brain.get('idlerpg') or {}
        return unless idlerpg[userid]?
        return unless idlerpg[userid]['logged_in']
        penalize(userid, time_for_penalty("part", idlerpg[userid]['level']), "User left the room.")
        logout(userid)


    ####################
    # Admin commands
    ####################
    robot.hear /IDLERPG DATA/i, (msg) ->
        return unless is_private(msg) and is_admin(msg)
        idlerpg = robot.brain.get('idlerpg') or {}
        robot.send( { user: msg.message.user.jid }, Util.inspect(idlerpg) )

    robot.hear /IDLERPG START/i, (msg) ->
        return unless is_private(msg) and is_admin(msg)
        robot.logger.info("Admin starting game.")
        start_loop()

    robot.hear /IDLERPG STOP/i, (msg) ->
        return unless is_private(msg) and is_admin(msg)
        robot.logger.info("Admin stopping game.")
        clearTimeout(LOOP_TIMEOUT)
        PLAYING = false

    robot.hear /IDLERPG SET TIME ([^ ]+) (\d+)/i, (msg) ->
        if is_private(msg) and is_admin(msg)
            robot.logger.info("Admin setting remaining time for user #{msg.match[1]} to #{msg.match[2]}.")
            try
                # Find the user
                users = robot.brain.usersForFuzzyName(msg.match[1])
                if users.length == 0
                    throw new Error("No users found for #{msg.match[1]}")
                else if users.length > 1
                    throw new Error("Multiple users matched #{msg.match[1]}, please be more specific")
                set_time(users[0].jid, msg.match[2])
            catch error
                robot.logger.error("Unable to set remaining time: " + error)
                msg.send error

    ####################
    # Robot interactions
    ####################

    start_loop = () ->
        if PLAYING
            robot.logger.debug("Already playing, not starting again.")
            return

        PLAYING = true
        LAST_TIMESTAMP = get_timestamp()

        announce("Starting IdleRPG! Everyone, please register or login. Type 'HELP' for help.")
        robot.logger.info "Starting idleRPG at #{LAST_TIMESTAMP}"

        do_loop()

    do_loop = () ->
        idlerpg = robot.brain.get('idlerpg') or {}

        [ LAST_TIMESTAMP, interval_passed ] = [ get_timestamp(), get_timestamp() - LAST_TIMESTAMP]

        robot.logger.debug("Performing idlerpg loop", [ LAST_TIMESTAMP, interval_passed ] )

        # Subtract interval_passed from every logged in user
        for userid, user of idlerpg
            unless not user.logged_in
                robot.logger.debug "Set #{user.name} #{user.userid} time from #{user.remaining} to", (user.remaining - interval_passed)
                user.remaining -= interval_passed
                if user.remaining <= 0
                    level_up(user.userid)

        #TODO Global events?

        LOOP_TIMEOUT = setTimeout(do_loop, LOOP_INTERVAL * 1000)

