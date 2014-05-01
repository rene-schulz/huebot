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
#   - leveling! 600*(1.16^YOUR_LEVEL)
#   - penalties!
#       - Part       200*(1.14^(YOUR_LEVEL))
#       - Quit       20*(1.14^(YOUR_LEVEL))
#       - LOGOUT     20*(1.14^(YOUR_LEVEL))
#       - Talk/emote [message_length]*(1.14^(YOUR_LEVEL))
#
#   - items!
#       - random(0, 1.5*LEVEL
#       - legendary items!
#           - Norton's +( random(LEVEL, 2*LEVEL) ) TABLEFLIP
#           - Alain's +( random(LEVEL, 2*LEVEL) ) BAR TAB
#       - idlerpg formula:
#         for each 'number' from 1 to YOUR_LEVEL*1.5
#           you have a 1 / ((1.4)^number) chance to find an item at this level
#         end for
#
#   - dueling!
#
#   - alignments
#    - punish for switching too often?

GAME_ROOM = "67748_idlerpg@conf.hipchat.com"

HELP_TEXT = """
Welcome to IdleRPG - like http://idlerpg.net/ except not as good yet!

The following commands should be typed in the IdleRPG room,
or privately messaged to this bot with the prefix "IDLERPG"

HELP
 Prints this help text.

REGISTER <character name> <character class>
 This registers you as an idlerpg player, with that character name and class.
 If you want spaces in your character name or class, put them in quotes.
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
  robot.hear /HELP/, (msg) ->
    if msg.envelope.room == GAME_ROOM or msg.envelope.user.reply_to == GAME_ROOM
        robot.send user: msg.message.user.jid, HELP_TEXT

  # robot.enter (msg) ->
  #   msg.send "Someone just joined " + msg.envelope.room
  #   robot.logger.debug msg
  # 
  # robot.leave (msg) ->
  #   msg.send "Someone just left " + msg.envelope.room