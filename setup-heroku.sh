echo "This is actually more of a doc than a script"
exit

echo "Creating heroku app..."
heroku create || goof "Could not create heroku app"

read -p "Enter new heroku app name:" HEROKU_APP_NAME
if [[ -z $HEROKU_APP_NAME ]]; then goof "Enter a valid heroku app name." fi

heroku rename $HEROKU_APP_NAME || goof "Could not rename heroku app to $HEROKU_APP_NAME"

echo "Configuring HEROKU_URL"
heroku config:add HEROKU_URL=http://$HEROKU_APP_NAME.herokuapp.com/ || goof "Could not set HEROKU_URL to $HEROKU_APP_NAME"

echo "Adding redistogo to heroku..."
heroku addons:add redistogo:nano || goof "Could not add redistogo to $HEROKU_APP_NAME"

read -p "Enter hubot hipchat ID:" HUBOT_HIPCHAT_JID
if [[ -z $HUBOT_HIPCHAT_JID ]]; then goof "Enter a valid hubot hipchat ID." fi
heroku config:add HUBOT_HIPCHAT_JID=$HUBOT_HIPCHAT_JID

read -p "Enter hubot hipchat password:" HUBOT_HIPCHAT_PASSWORD
if [[ -z $HUBOT_HIPCHAT_PASSWORD ]]; then goof "Enter a valid hubot hipchat password." fi
heroku config:add HUBOT_HIPCHAT_PASSWORD=$HUBOT_HIPCHAT_PASSWORD

read -p "Enter hubot hipchat rooms:" HUBOT_HIPCHAT_ROOMS
if [[ -z $HUBOT_HIPCHAT_ROOMS ]]; then goof "Enter valid hubot hipchat rooms." fi
heroku config:add HUBOT_HIPCHAT_ROOMS=$HUBOT_HIPCHAT_ROOMS

# IdleRPG
# 67748_idlerpg@conf.hipchat.com

# NYC OffTopic (ignore the name, I know)
# 67748_all_nyc@conf.hipchat.com

### Actually running on heroku

# This just needs to be done once
heroku create --stack cedar
heroku rename bv-pavel-huebot
heroku config:add HEROKU_URL=http://bv-pavel-huebot.herokuapp.com/
heroku addons:add redistogo:nano

heroku config:add HUBOT_HIPCHAT_JID=67748_490479@chat.hipchat.com
heroku config:add HUBOT_HIPCHAT_PASSWORD=
heroku config:add HUBOT_HIPCHAT_ROOMS=67748_all_nyc@conf.hipchat.com

# Do this to launch on Heroku
git push heroku master
heroku ps:scale web=1



### For local stuff

# Read config stuff out
heroku config --shell | ag '^HUBOT'

# Set options for local testing
export HUBOT_HIPCHAT_JID=67748_490479@chat.hipchat.com
export HUBOT_HIPCHAT_PASSWORD=
export HUBOT_HIPCHAT_ROOMS=67748_idlerpg@conf.hipchat.com

export HUBOT_HIPCHAT_ROOMS=67748_bottest@conf.hipchat.com

# Test locally
export HUBOT_LOG_LEVEL=debug
bin/hubot -a hipchat