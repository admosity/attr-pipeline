Q = require 'q'

# Q.longStackSupport = true

###
# Helpers
###

typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

injectAttr = (value, callback)->
  callback(null, value)

pipeCleaner = (attr, pipeline, obj)->

  if pipeline.required or obj[attr]?
    pipeline.reduce(Q.when, Q(obj[attr]))
    .then (result)->
      obj[attr] = result
      return obj
    .catch (err)->
      originalError = err
      newErr = new Error(err.message or "")

      newErr.ap = {}
      newErr.ap.path = attr
      newErr.ap.value = obj[attr]

      newErr.ap.originalError = err
      if err.message isnt "`#{attr}` is required."

        newErr.message = "Path `#{attr}` not valid with value: `#{obj[attr]}`"
        throw newErr
      else 
        throw newErr
  else
    obj
    
###
Validator class
###
class Validator

  constructor: () ->
    if arguments.length < 1
      throw new Error("Must have at least one argument.")

    if typeof arguments[0] isnt 'object'
      throw new Error("First argument must be an object.")

    @_pipeFunctions = []
    for attr, schemaDef of arguments[0]
      do (attr, schemaDef)=>
        if not schemaDef.pipe and not schemaDef.required? 

          throw new Error("pipe or required needs to be defined for `#{attr}`")
        if schemaDef.pipe? and not typeIsArray(schemaDef.pipe)
          throw new Error("pipe must be an array")
          
        preppedPipe = schemaDef.pipe?.slice(0).map (fun)->
          if fun.length is 1
            return (value, callback)->callback(!fun(value), value)
          return fun


        preppedPipe ?= []



        if schemaDef.required
          preppedPipe.unshift (value, callback)->
            if !value?
              callback(new Error("`#{attr}` is required."))
            else
              callback(null, value)

        preppedPipe = preppedPipe.map (fun)->Q.denodeify(fun)

        preppedPipe.attr = attr
        preppedPipe.required = schemaDef.required ? false
          
        pipeFunc = pipeCleaner.bind(null, attr, preppedPipe)
        pipeFunc.attr = attr
        pipeFunc.required = schemaDef.required ? false
        pipeFunc.hasPipe = (preppedPipe.length > 0 and !schemaDef.required) or (schemaDef.required and preppedPipe.length > 1)
        @_pipeFunctions.push pipeFunc

    @_pipeFunctions.sort((a, b)->
      if not a.required and not a.hasPipe
        return 1
      else if not a.required and a.hasPipe
        if not b.required and b.hasPipe
          return 0
        else if b.required and not b.hasPipe
          return 1
        else if b.required and b.hasPipe
          return 1
      else if a.required and not a.hasPipe
        if not b.required and b.hasPipe
          return -1
        else if b.required and not b.hasPipe
          return 0
        else if b.required and b.hasPipe
          return -1
      else if a.required and a.hasPipe
        if not b.required and b.hasPipe
          return -1
        else if b.required and not b.hasPipe
          return 1
        else if b.required and b.hasPipe
          return 0

      return 0
    )

    opts = {}
    if arguments.length >= 2
      opts = arguments[1]


  validate: (obj, callback)->
    rtn = @_pipeFunctions.reduce(Q.when, Q(obj))

    if !callback? then rtn else 
      theErr = null
      theObj = null
      rtn.then (obj)->
        theObj = obj
      .catch (err)->
        theErr = err
      .fin ()->
        callback(theErr, theObj)
      
exports.Validator = Validator
    



    