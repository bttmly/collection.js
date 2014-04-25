# collection.coffee 0.1.0
# Requires Lo-Dash (or Underscore)
# MIT License

( ( root, factory ) ->
  if typeof define is "function" and define.amd
    define [
      "lodash"
      "exports"
    ], ( _, exports ) ->
      root.Collection = factory( root, exports, _ )
      return

  else if typeof exports isnt "undefined"
    _ = require( "lodash" )
    factory( root, exports, _ )

  else
    root.Collection = factory( root, {}, root._ )

)( this, ( root, Collection, _ ) ->
  
  previousCollection = root.Collection
  
  slice = [].slice.call.bind( [].slice )
  
  addArg = ( arg, args ) ->
    args = slice args
    args.unshift arg
    return args

  class Collection extends Array
    constructor : ( models, options ) ->
      options or= {}
      if models
        for model in models
          if options.init
            model = do ( m = model ) ->
              return options.init( m )
          this.push( model )

    slice : ->
      return new Collection super( arguments )

    splice : ->
      return new Collection super( arguments )

    groupBy : ->
      groups = _.groupBy addArg( this, arguments )
      for key, col of groups
        groups[key] = new Collection col
      return groups

  returnsCollectionMethods = [ 'forEach', 'each', 'eachRight', 'forEachRight', 'map', 'collect', 'filter', 'select',
    'where', 'pluck', 'reject', 'invoke', 'initial', 'rest', 'tail', 'drop',
    'compact', 'flatten', 'without', 'shuffle', 'remove', 'transform',
    'unique', 'uniq', 'union', 'intersection', 'difference']

  notReturnsCollectionMethods = [ 'reduce', 'foldl', 'inject', 'reduceRight', 'foldr',
    'find', 'detect', 'findWhere', 'every', 'all', 'some', 'any', 'contains', 'max',
    'min', 'include', 'size', 'first', 'last', 'indexOf', 'lastIndexOf',
    'isEmpty', 'toArray', 'at', 'findLast', 'indexBy', 'sortBy', 'countBy' ]

  for method in returnsCollectionMethods
    do ( method ) ->
      if _[method]
        Collection::[method] = ->
          return new Collection _[method].apply _, addArg( this, arguments )

  for method in notReturnsCollectionMethods
    do ( method ) ->
      if _[method]
        Collection::[method] = ->
          return _[method].apply _,addArg( this, arguments )

  Collection.noConflict = ->
    root.Collection = previousCollection
    return this

  return Collection
  
)

  