# Barebones.coffee 0.0.0
# Based on Backbone.js
# Requires Lodash or Underscore 
# by Nick Bottomley, 2014
# MIT License

"use strict"

factory = ( root, Barebones, _ ) ->

  # _.noop is defined in Lodash but undefined in Underscore.js
  lib = if _.noop then "lodash" else "underscore"

  array = []
  push = array.push
  slice = array.slice
  splice = array.splice
  unshift = array.unshift

  # Barebones.Model
  class Model
    constructor : ( model ) ->
      for prop, val of model
        this[prop] = val

  # Barebones.Collection
  class Collection extends Array
    constructor : ( models, options ) ->
      options or options = {}
      this.model = options.model or this.model

      this.initialize.apply( this, arguments )

    model : Model

    initialize : ( models, options ) ->
      if models 
        for model in models
          this.push model

    push : ( model ) ->
      super this._prepareModel( model )

    unshift : ( model ) ->
      super this._prepareModel( model )

    concat : ->
      models = [].concat [].slice.call( arguments )
      model = this._prepareModel( model ) for model in models
      super models

    arrayify : ->
      results = []
      for model in this
        obj = new Object
        for prop, val of model
          obj[prop] = val
        results.push obj
      return results

    _prepareModel : ( model ) ->
      unless model instanceof this.model
        model = new this.model( model )
      return model

  # These methods are in Underscore and Lodash
  # Add them to the collection prototype as done in Backbone
  collectionMethods = ['forEach', 'each', 'map', 'collect', 'reduce', 'foldl',
      'inject', 'reduceRight', 'foldr', 'find', 'detect', 'filter', 'select',
      'reject', 'every', 'all', 'some', 'any', 'include', 'contains', 'invoke',
      'max', 'min', 'toArray', 'size', 'first', 'head', 'take', 'initial', 'rest',
      'tail', 'drop', 'last', 'without', 'indexOf', 'shuffle', 'lastIndexOf',
      'isEmpty', 'chain']

  # These Underscore methods are added differently in Backbone. Need to double check that they work here as expected.
  collectionMethods = collectionMethods.concat 'pluck', 'where', 'findWhere'

  # These methods are only in Lodash
  if lib is "lodash"
    collectionMethods = collectionMethods.concat 'at', 'eachRight', 'forEachRight', 'findLast'

  _.each collectionMethods, ( method ) ->
    Collection::[method] = ->
      args = [].slice.call( arguments )
      args.unshift this
      return _[method].apply _, args
    return

  # Underscore / Lodash methods that use an attribute name as an argument.
  attributeMethods = ['groupBy', 'countBy', 'sortBy', 'indexBy']

  _.each attributeMethods, ( method ) ->
    Collection::[method] = ( value, context ) ->
      iterator = if _.isFunction( value ) then value else ( model ) ->
        model[value]
      return _[method] this, iterator, context
    return


  # Native array methods on a collection are applied to collection.models
  nativeMethods = ['slice', 'splice', 'shift', 'pop', 'join', 'reverse', 'sort']

  _.each nativeMethods, ( method ) ->
    Collection::[method] = ->
      args = [].slice.call arguments
      args.unshift this
      return [][method].apply this, arguments
    return

  # creates methods named 'colFilter', 'colWhere', etc.
  # they behave like analagous underscore/lodash methods
  # EXCEPT they return a new instance of this collection's class with the results as models.
  returnsCollectionMethods = ['filter', 'where', 'reject']

  _.each returnsCollectionMethods, ( method ) ->
    methodName = "col" + method.charAt(0).toUpperCase() + method.slice(1)
    Collection::[methodName] = ->
      constructor = Object.getPrototypeOf( this ).constructor
      args = [].slice.call( arguments )
      args.unshift this
      collection = _[method].apply _, args
      return new constructor collection
    return

  return {
    Model: Model
    Collection: Collection
  }

# Setup Barebones for environment.
# Cribbed from Backbone
do ( root = this, factory = factory ) ->

  if typeof define is "function" and define.amd
    define [
      "underscore"
      "exports"
    ], ( _, exports ) ->
      root.Barebones = factory( root, exports, _ )
      return

  else if typeof exports isnt "undefined"
    _ = require( "lodash" ) or require( "underscore" )
    factory( root, exports, _ )
    # shouldn't this be 
    # exports = factory( root, exports, _ )

  else
    root.Barebones = factory( root, {}, root._ )

  return