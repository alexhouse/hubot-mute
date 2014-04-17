chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'mute', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()
      hear: sinon.spy()

    require('../src/hubot-mute')(@robot)

  it 'registers a respond listener for "mute list"', ->
  	expect(@robot.respond).to.have.been.calledWith(/mute list/)

  it 'registers a respond listener for "mute"', ->
    expect(@robot.respond).to.have.been.calledWith(/mute/)
  it 'registers a respond listener for "unmute channel"', ->
    expect(@robot.respond).to.have.been.calledWith(/unmute channel/)

  it 'registers a respond listener for "mute all"', ->
    expect(@robot.respond).to.have.been.calledWith(/mute all/)
