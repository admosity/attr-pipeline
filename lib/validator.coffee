async = require 'async'

###
# Helpers
###

typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'

injectAttr = (value, callback)->
  callback(null, value)

pipeCleaner = (attr, pipeline, obj, callback)->
  pipeline.unshift((cb)->cb(null, obj[attr]))
  async.waterfall(pipeline, (err, result)->
    if err
      callback(err)
    else
      if result is not null
        obj[attr] = result
        callback(err, result)
  )



###
Validator class
###
class Validator

  constructor: () ->
    # ...
    if arguments.length < 1
      throw new Error("Must have at least one argument.")

    if typeof arguments[0] isnt 'object'
      throw new Error("First argument must be an object.")

    @schemaRules = {}
    @pipeFunctions = []
    for attr, schemaDef of arguments[0]
      do (attr, schemaDef)=>
        # console.log schemaDef.pipe
        if not schemaDef.pipe and not schemaDef.required? 

          throw new Error("pipe or required needs to be defined for `#{attr}`")
        if not typeIsArray(schemaDef.pipe) and not schemaDef.required
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
          
        # async.waterfall.bind(null, [injectAttrasync.waterfall.bind])
        pipeFunc = pipeCleaner.bind(null, attr, preppedPipe)
        pipeFunc.attr = attr
        @pipeFunctions.push pipeFunc


    opts = {}
    if arguments.length >= 2
      opts = arguments[1]

  _validateHelper: (index, length, obj, callback)->
    if index is length
      return callback()

    @pipeFunctions[index](obj, (err)->
      if err
        callback(err)
      else
        @_validateHelper(index+1, length, obj, callback)
    )

  validate: (obj, callback)->
    curr = 0
    len = @pipeFunctions.length
    @_validateHelper(curr, len, obj, callback)

        

exports.Validator = Validator
    



    