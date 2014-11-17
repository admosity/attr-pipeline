require 'mocha'
chai = require 'chai'
{expect, assert} = chai
chai.should()


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

describe "Validator required", ->

  {Validator} = require '../index'

  testValidator = new Validator({
    bleh: required: true  
  })

  it "should throw callback with required error", (done)->
    testValidator.validate({wef:"hai"}, (err, value)->
      try
        err.message.should.equal('`bleh` is required.')
        done()
      catch e
        done(e)
      

    )

  it "should return promise with required error", (done)->
    testValidator.validate({wef:"hai"})
    .then (value)->
      should.not.exist(value)

    .catch (err)->
      should.exist(err)
      err.message.should.equal('`bleh` is required.')
    .done ()->
      done()

  it "should return object on success", (done)->
    testValidator.validate({bleh: "YAY"}, (err, value)->
      try
        expect(err).to.not.be.ok
        # eql means deep equal
        expect(value).to.eql({bleh: "YAY"})
        done()
      catch e
        done(e)
      

    )
      
  it "should return promise with object on success", (done)->
    testValidator.validate({bleh: "YAY"})
    .then (value)->
      expect(value).to.eql({bleh: "YAY"})
    .catch (err)->
      expect(err).to.not.be.ok
    .done ()->
      done()


  it "should pass through other attributes", (done)->
    testValidator.validate({bleh: "YAY", other: "YEAH!"})
    .then (value)->
      expect(value).to.eql({bleh: "YAY", other: "YEAH!"})
    .catch (err)->
      expect(err).to.not.be.ok
    .done ()->
      done()

describe "Pipeline tests", ()->
  {Validator} = require '../index'
  describe "Single attribute and single pipe function", ()->
    
    testValidator = new Validator({
      attr1: {pipe: [(value, cb)->cb(value isnt 1, value)]}  
    })

    it "validate when attribute is not present", (done)->
      testValidator.validate {blah: "OK"}, (err, obj)->
        try
          expect(err).to.not.be.ok
          expect(obj).to.eql({blah: "OK"})
          done()
        catch e
          done(e)
        


    it "validate when attribute is present", (done)->
      testValidator.validate {attr1: 1}, (err, obj)->
        try
          expect(err).to.not.be.ok
          expect(obj).to.eql({attr1: 1})
          done()
        catch e
          done(e)
        



    it "validate when attribute is not present", (done)->
      testValidator.validate {blah: "OK"}
      .then (obj)->
        expect(obj).to.eql({blah: "OK"})
      .catch (err)->
        expect(err).to.not.be.ok
      .done ()->
        done()

    it "validate when attribute is present", (done)->
      testValidator.validate {attr1: 1}
      .then (obj)->
        expect(obj).to.eql({attr1: 1})
        # expect(true).to.be.false
      .catch (err)->
        expect(err).to.not.be.ok
      .done ()->
        done()

    it "should fail validation when attribute value does not validate", (done)->
      testValidator.validate {attr1: 2}, (err, obj)->
        try
          expect(err).to.be.ok
          done()
        catch e
          done(e)
        
  describe "Multiple attributes and multiple many functions in pipeline", ()->
    errorSpot = 0
    testValidator = new Validator({
      attr3: {required: false, pipe: []}
      attr1: {required: true, pipe: [
        (value)->
          errorSpot = 1
          typeof value is 'string'
        (value)->
          errorSpot = 2
          value.length is 5
        (value)->
          errorSpot = 3
          value is "hello"
        ]}
      attr2: {required: true},
    })

    it "should succeed with the correct input", (done)->
      testValidator.validate {attr1: "hello", attr2: "anything"}, (err, obj)->
        try
          expect(err).to.not.be.ok
          expect(obj).to.eql({attr1: "hello", attr2: "anything"})
          done()
        catch e
          done(e)


    it "should fail with incorrect input", (done)->
      testValidator.validate {attr1: "hello1", attr2: "anything"}, (err, obj)->
        try
          expect(err.message).to.equal('Path `attr1` not valid with value: `hello1`')
          done()
        catch e
          done(e)

    errorSpot = 0

    it "should fail with incorrect input at the beginning of the pipeline", (done)->
      testValidator.validate {attr1: 1, attr2: "anything"}, (err, obj)->
        try
          expect(errorSpot).to.equal(1)
          done()
        catch e
          done(e)

    errorSpot = 0

    it "should fail with incorrect input at the middle of the pipeline", (done)->
      testValidator.validate {attr1: "hello1", attr2: "anything"}, (err, obj)->
        try
          expect(errorSpot).to.equal(2)
          done()
        catch e
          done(e)

    errorSpot = 0

    it "should fail with incorrect input at the end of the pipeline", (done)->
      testValidator.validate {attr1: "march", attr2: "anything"}, (err, obj)->
        try
          expect(errorSpot).to.equal(3)
          done()
        catch e
          done(e)
        
    it "should fail and be able to retrieve meta data", (done)->
      testValidator.validate {attr1: "hello1", attr2: "anything"}, (err, obj)->
        try
          expect(err.ap.path).to.equal('attr1')
          expect(err.message).to.equal("Path `attr1` not valid with value: `hello1`")
          expect(err.ap.value).to.equal("hello1")
          # single argument functions return true
          expect(err.ap.originalError).to.be.true()
          done()
        catch e
          done(e)



      
      

      
