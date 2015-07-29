# Description:
#   Prevent Hubot from outputting anything for a period
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_MUTE_ROOM_PREFIX (# on Slack, IRC, etc, otherwise leave blank, but must be defined)
#
# Commands:
#   hubot mute list - Check which channels have been muted
#   hubot mute|unmute (channel name) - (un)mute a channel (if channel name omitted, mutes current channel)
#   hubot unmute all - Unmute all individually muted channels
#   hubot global mute|unmute - (Un)mute hubot everywhere
#
# Author:
#   Alex House (@alexhouse)
#

mute_channels = []
mute_listener = null
mute_all = false
mute_explain = {}
mute_first = true;

module.exports = (robot) ->
  robot.brain.on 'loaded', ->
    if mute_first
      mute_first = false
      mute_channels = robot.brain.get('mute_channels') or []
      mute_all = robot.brain.get('mute_all') or false

  robot.respond /mute list$/i, (msg) ->
    msg.finish()
    if mute_channels.length is 0 and mute_all is false
      msg.send 'No channels have been muted yet'
      return

    if mute_all is true
      msg.send 'ALL channels are muted'
    else
      for room in mute_channels
        msg.send room + ' is muted'

  robot.respond /global (mute|unmute)$/i, (msg) ->
    msg.finish()
    action = msg.match[1].toLowerCase()
    muteAll action, (what) ->
      msg.send what

  re = new RegExp("(mute|unmute) (all|[\\" + process.env.HUBOT_MUTE_ROOM_PREFIX + "]?[\\S]+)$", "i")
  robot.respond re, (msg) ->
    msg.finish()
    channel = msg.match[2]
    action = msg.match[1].toLowerCase()
    
    if channel == 'all'
      if action == 'mute'
        msg.send 'Deprecated: Mute all channels now with `hubot global mute`'
        return

      count = mute_channels.length
      if count > 0
        mute_channels = []
        msg.send 'Unmuted ' + count + ' channels'
      else
        msg.send 'No channels were muted, so nothing was done'

      return

    success = muteChannel action, channel, (what) ->
      msg.send what

    if success
      robot.messageRoom channel, msg.message.user.name + ' has ' + action + 'd this channel from ' + process.env.HUBOT_MUTE_ROOM_PREFIX + msg.message.room

  robot.respond /(mute|unmute)$/i, (msg) ->
    msg.finish()
    channel = process.env.HUBOT_MUTE_ROOM_PREFIX + msg.message.room

    muteChannel msg.match[1], channel, (what) ->
      msg.send what

  # Catch-all listener to mute responses
  robot.hear /(.*)$/i, (msg) ->
    if mute_all is false and mute_channels.indexOf(process.env.HUBOT_MUTE_ROOM_PREFIX + msg.message.room) == -1
      return
    if msg.match[1].indexOf('mute') != -1
      return

    msg.finish()

    if msg.match[0].toLowerCase().indexOf(robot.name.toLowerCase()) != 0
      return

    reason = if mute_all is true then 'All channels are muted' else "Channel #{process.env.HUBOT_MUTE_ROOM_PREFIX}#{msg.message.room} is muted"
    if !mute_explain[msg.message.room]?
      msg.send 'This channel is currently muted because: ' + reason
      mute_explain[msg.message.room] = true
      delay 300000, ->
        delete mute_explain[msg.message.room]

  mute_listener = robot.listeners.pop()
  robot.listeners.unshift(mute_listener)

muteAll = (action, cb) ->
  mute_all = action == 'mute'

  robot.brain.set 'mute_all', mute_all
  cb 'All channels have been ' + action + 'd'

muteChannel = (action, channel, cb) ->
  action = action.toLowerCase()
  if process.env.HUBOT_MUTE_ROOM_PREFIX?
    if channel.indexOf(process.env.HUBOT_MUTE_ROOM_PREFIX) != 0
      cb "Cannot #{action} '#{channel}'. Did you mean '#{process.env.HUBOT_MUTE_ROOM_PREFIX}#{channel}'?"
      return false

  if action == 'mute'
    if mute_channels.indexOf(channel) > -1
      cb 'Channel ' + channel + ' already muted'
      return false

    mute_channels.push(channel)
  else
    idx = mute_channels.indexOf(channel)
    if idx == -1
      cb 'Cannot unmute ' + channel + ' - it is not muted'
      return false

    mute_channels.splice idx, 1

  robot.brain.set 'mute_channels', mute_channels
  cb 'Channel ' + channel + ' ' + action + 'd'
  return true

delay = (ms, func) -> setTimeout func, ms

