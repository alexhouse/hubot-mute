# Hubot Mute

Allows channels to mute Hubot if quiet is required for whatever reasons. Hubot will not respond to any commands in a muted channel (other than `mute` commands).

[![Build Status](https://travis-ci.org/alexhouse/hubot-mute.png)](https://travis-ci.org/alexhouse/hubot-mute) [![NPM version](https://badge.fury.io/js/hubot-mute.png)](http://badge.fury.io/js/hubot-mute)

## Usage

* `hubot mute list` - List all individually muted channels
* `hubot global mute` - Globally mute all channels
* `hubot global unmute` - Globally unmute all channels (but keep individually muted)
* `hubot mute {channel}` - Mute specific channel
* `hubot unmute {channel}` - Unmute specific channel
* `hubot unmute all (the things)` - Unmute all individually muted channels

## Configuration

This script requires the env variable `HUBOT_MUTE_ROOM_PREFIX` to be set. This is used in determining how to respond to the channel.
This should **ALWAYS** be set - even if blank (i.e. hipchat)

For example, if you're on IRC or Slack you'll probably want this setting as `#`. Basecamp should be able to leave it as blank.

## Installation

Add the package `"hubot-mute": "*"` as a dependency in your Hubot package.json file. Then add `"hubot-mute"` to the list in the `external-scripts.json` file.
