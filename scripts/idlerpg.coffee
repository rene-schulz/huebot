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
#   - only listen for idle-violations in #IdleRPG
#
#   - when launching, log everyone out
#
#   - leveling! 600*(1.16^YOUR_LEVEL)
#   - penalties!
#       - Part       200*(1.14^(YOUR_LEVEL))
#       - Quit       20*(1.14^(YOUR_LEVEL))
#       - LOGOUT     20*(1.14^(YOUR_LEVEL))
#       - Talk/emote [message_length]*(1.14^(YOUR_LEVEL))
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

    time_for_next_level = (level) ->
        return 600 * Math.pow(1.16, level)

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
        # TODO announce to room
        robot.logger.info "User ${idlerpg[userid]['username']} is now level #{idlerpg[userid]['level']}"

        search_for_item(userid)

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
        idlerpg = robot.brain.get('idlerpg') or {}

        userid = msg.message.user.jid

        robot.logger.info("User #{userid} logging in.")

        unless idlerpg[userid]
            robot.logger.info("User #{userid} is not yet registered.")
            return robot.send( { user: userid }, "You have not registered yet." )

        idlerpg[userid]['logged_in'] = true
        robot.brain.set('idlerpg', idlerpg)

    logout = (msg) ->
        idlerpg = robot.brain.get('idlerpg') or {}

        userid = msg.message.user.jid

        robot.logger.info("User #{userid} logging out.")

        unless idlerpg[userid]
            robot.logger.info("User #{userid} is not yet registered.")
            return robot.send( { user: userid }, "You have not registered yet." )

        unless idlerpg[userid]['logged_in']
            robot.logger.info("User #{userid} is not logged in.")
            return robot.send( { user: userid }, "You are not logged in." )

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
        return unless in_room(msg)

    robot.enter (msg) ->
        return unless in_room(msg)
        userid = msg.envelope.user.jid
        username = msg.envelope.user.name

    robot.leave (msg) ->
        return unless in_room(msg)
        userid = msg.envelope.user.jid
        username = msg.envelope.user.name
        # TODO - penalize user, and log them out

    # Admin commands
    robot.hear /IDLERPG DATA/i, (msg) ->
        if is_private(msg) and is_admin(msg)
            idlerpg = robot.brain.get('idlerpg') or {}
            robot.send( { user: msg.message.user.jid }, Util.inspect(idlerpg) )

    robot.hear /IDLERPG START/i, (msg) ->
        if is_private(msg) and is_admin(msg)
            robot.logger.info("Admin starting game.")
            start_loop()

    robot.hear /IDLERPG STOP/i, (msg) ->
        if is_private(msg) and is_admin(msg)
            robot.logger.info("Admin stopping game.")
            clearTimeout(LOOP_TIMEOUT)



    ####################
    # Robot interactions
    ####################

    start_loop = () ->
        LAST_TIMESTAMP = get_timestamp()
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
                if user.remaining < 0
                    level_up(user.userid)

        #TODO Global events?

        LOOP_TIMEOUT = setTimeout(do_loop, LOOP_INTERVAL * 1000)

