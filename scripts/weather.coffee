# Description:
#   Weather. Uses World Weather Online, you have to sign up for an API key and set it as an environment variable HUBOT_WORLDWEATHERONLINE_API_KEY.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot weather - Shows the current weather

weatherApiKey = process.env.HUBOT_WORLDWEATHERONLINE_API_KEY

module.exports = (robot) ->
  robot.respond /weather$/i, (msg) ->
    unless weatherApiKey?
      msg.send 'Missing HUBOT_WORLDWEATHERONLINE_API_KEY environment variable. It might be raining. Or not. Nobody knows.'
      return

    msg.http("http://api.worldweatheronline.com/free/v1/weather.ashx?q=10003&format=json&key=#{weatherApiKey}")
      .get() (error, response, body) ->
        response = JSON.parse(body)
        if response.data
          current = response.data.current_condition[0]
          msg.send current.weatherIconUrl[0].value
          msg.send "It's " + current.temp_F + '° and ' + current.weatherDesc[0].value
        else
          msg.send "Weather API is broken. The world must have ended."