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
  
  slice = Function::call.bind( Array::slice )
  
  addArg = ( arg, args ) ->
    args = slice args
    args.unshift arg
    args

  class Collection extends Array
    constructor : ( models, options ) ->
      options or= {}
      if models
        for model in models
          if options.init
            model = do ( m = model ) ->
              options.init( m )
          @push( model )

    # TODO: figure out best way to handle 'grouping' methods
    # groupBy : ->
    #   groups = _.groupBy addArg( this, arguments )
    #   for key, col of groups
    #     groups[key] = new Collection col
    #   return groups

  arrayMethods = [ "slice", "splice", "concat" ]

  for method in arrayMethods
    do ( method ) ->
      Collection::method = ->
        new Collection method.apply( @, arguments )

  returnsCollectionMethods = [ 'forEach', 'each', 'eachRight', 'forEachRight', 'map', 'collect', 'filter', 'select',
    'where', 'pluck', 'reject', 'invoke', 'initial', 'rest', 'tail', 'drop',
    'compact', 'flatten', 'without', 'shuffle', 'remove', 'transform',
    'unique', 'uniq', 'union', 'intersection', 'difference']

  notReturnsCollectionMethods = [ 'reduce', 'foldl', 'inject', 'reduceRight', 'foldr',
    'find', 'detect', 'findWhere', 'every', 'all', 'some', 'any', 'contains', 'max',
    'min', 'include', 'size', 'first', 'last', 'indexOf', 'lastIndexOf',
    'isEmpty', 'toArray', 'at', 'findLast', 'indexBy', 'sortBy', 'countBy' ]

  lodashMethods = returnsCollectionMethods.concat notReturnsCollectionMethods

  for method in lodashMethods
    do ( method ) ->
      if _[method]
        retCol = method in returnsCollectionMethods
        Collection::[method] = ->
          result = _[method].apply _, addArg( @, arguments )
          if retCol then new Collection( result ) else result 

  Collection.noConflict = ->
    root.Collection = previousCollection
    @

  Collection
  
)

  