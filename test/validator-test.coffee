require 'mocha'
chai = require 'chai'
{expect, assert} = chai


describe "Validator constructor", ->
  {Validator} = require '../index'
  it "should expect at least one argument", ()->
    test = ->
      new Validator

    assert.throw test, Error, 'Must have at least one argument.'

  it "should expect an object as the first argument", ()->
    test = ->
      new Validator("NOT AN object")

    assert.throw test, Error, "First argument must be an object."

  it "should expect all keys in object to have object values", ()->
    test = ->
      new Validator({
        bleh: {}
      })

    assert.throw test, Error, "pipe or required needs to be defined for `bleh`"

  it "should expect pipe schema attribute to be an array", ()->
    test = ->
      new Validator({
        bleh: {pipe: "FAIL"}  
      })

    assert.throw test, Error, "pipe must be an array"

  it "should expect to construct if required is present", ()->
    test = ->
      new Validator({
        bleh: {required: true}  
      })

    assert.doesNotThrow(test)

describe "Validator use cases", ->

  {Validator} = require '../index'

  testValidator = new Validator({
    bleh: required: true  
  })

  it "should throw callback with error", (done)->
    testValidator.validate({wef:"hai"}, (err, callback)->
      console.log err
      done()
      )
