# Barebones.coffee 0.0.0
# Requires Lodash or Underscore 
# by Nick Bottomley, 2014
# MIT License

"use strict"

# Setup Barebones for environment.
do ( root = this, factory = ( root, Barebones, _ ) ->

  # _.noop is defined in Lodash but undefined in Underscore
  lib = if _.noop then "lodash" else "underscore"


  class Collection extends Array
    constructor : ( models ) ->
      if models 
        for model in models
          this.push( model )

  # These methods are in Underscore and Lodash
  # Add them to the collection prototype as done in Backbone
  collectionMethods = ['forEach', 'each', 'map', 'collect', 'reduce', 'foldl',
      'inject', 'reduceRight', 'foldr', 'find', 'detect', 'filter', 'select',
      'reject', 'every', 'all', 'some', 'any', 'include', 'contains', 'invoke',
      'max', 'min', 'toArray', 'size', 'first', 'head', 'take', 'initial', 'rest',
      'tail', 'drop', 'last', 'without', 'indexOf', 'shuffle', 'lastIndexOf',
      'isEmpty', 'chain']

  # These Underscore methods are added differently in Backbone. Need to double check that they work here as expected.
  collectionMethods = collectionMethods.concat( 'pluck', 'where', 'findWhere' )

  # These methods are only in Lodash
  if lib is "lodash"
    collectionMethods = collectionMethods.concat( 'at', 'eachRight', 'forEachRight', 'findLast' )

  _.each collectionMethods, ( method ) ->
    Collection::[method] = ->
      args = [].slice.call( arguments )
      args.unshift( this )
      return _[method].apply( _, args )
    return

  # Underscore / Lodash methods that use an attribute name as an argument.
  attributeMethods = ['groupBy', 'countBy', 'sortBy', 'indexBy']

  _.each attributeMethods, ( method ) ->
    Collection::[method] = ( value, context ) ->
      iterator = if _.isFunction( value ) then value else ( model ) ->
        model[value]
      return _[method]( this, iterator, context )
    return


  # Native array methods on a collection are applied to collection.models
  nativeMethods = ['slice', 'splice', 'shift', 'pop', 'join', 'reverse', 'sort']

  _.each nativeMethods, ( method ) ->
    Collection::[method] = ->
      args = [].slice.call( arguments )
      args.unshift( this )
      return [][method].apply( this, arguments )
    return

  # creates methods named 'colFilter', 'colWhere', etc.
  # they behave like analagous underscore/lodash methods
  # EXCEPT it returns an instance of Collection
  returnsCollectionMethods = ['filter', 'select', 'where', 'reject']

  _.each returnsCollectionMethods, ( method ) ->
    methodName = "col" + method.charAt(0).toUpperCase() + method.slice(1)
    Collection::[methodName] = ->
      constructor = Object.getPrototypeOf( this ).constructor
      args = [].slice.call( arguments )
      args.unshift( this )
      collection = _[method].apply( _, args )
      return new constructor( collection )
    return

  return Collection

) ->

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