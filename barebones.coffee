# Barebones.coffee 0.0.0
# Based on Backbone.js
# Requires Lodash or Underscore 
# by Nick Bottomley, 2014
# MIT License

# Setup Barebones for environment.
# Cribbed from Backbone
# Variable hoisting should cause factory to be defined before this IIFE runs.
do ( root = this, factory = factory ) ->

	if typeof define is "function" and define.amd
	  define [
	    "underscore"
	    "exports"
	  ], ( _, exports ) ->
	    root.Backbone = factory( root, exports, _ )
	    return

	else if typeof exports isnt "undefined"
	  _ = require("underscore")
	  factory( root, exports, _ )

	else
	  root.Barebones = factory( root, {}, root._ )

	return




factory = ( root, Barebones, _ )

	# _.noop is defined in Lodash but undefined in Underscore.js
	lib = if _.noop then "lodash" else "underscore"

	array = []
	push = array.push
	slice = array.slice
	splice = array.splice
	unshift = array.unshift

	# Barebones.Model
	class Model extends Object
		constructor : ( model ) ->
			for prop, val of model
				this.prop = val

	# Barebones.Collection
	class Collection extends Object
		constructor : ( models, options ) ->
			options or options = {}
			this.model = options.model if options.model
			for model in models
				this.models.push model

			this.initialize()

		model: Model

		models : []

		length : ->
			return this.models.length

		push : ( model ) =>
			model = this._prepareModel( model )
			this.models.push model

		unshift : ( model ) =>
			model = this._prepareModel( model )
			this.models.unshift model

		_prepareModel : ( model ) =>
			unless model instanceof this.model
				model = new this.model( model )
			return model

		initialize : ->



	# These methods are in Underscore and Lodash
	collectionMethods = ['forEach', 'each', 'map', 'collect', 'reduce', 'foldl',
	    'inject', 'reduceRight', 'foldr', 'find', 'detect', 'filter', 'select',
	    'reject', 'every', 'all', 'some', 'any', 'include', 'contains', 'invoke',
	    'max', 'min', 'toArray', 'size', 'first', 'head', 'take', 'initial', 'rest',
	    'tail', 'drop', 'last', 'without', 'indexOf', 'shuffle', 'lastIndexOf',
	    'isEmpty', 'chain']

	# These Underscore methods aren't added the same way in Backbone. Need to double check that they work as expected.
	collectionMethods.concat ['pluck', 'where', 'findWhere']

	# These methods are only in Lodash
	if lib is "lodash"
		collectionMethods.concat ['at', 'eachRight', 'forEachRight', 'findLast']

	for method in collectionMethods
		Collection::[method] = ->
			args = slice.call( arguments )
			args.unshift this.models
			return _[method].apply( _, args )



	attributeMethods = ['groupBy', 'countBy', 'sortBy', 'indexBy']

	for method in attributeMethods
		Collection::[method] = ( value, context ) ->
			iterator = if _.isFunction( value ) then value else ( model ) -> return model[value]
			return _[method]( this.models, iterator, context )



	nativeMethods = ['slice', 'splice', 'shift', 'pop', 'join', 'reverse', 'sort']

	for method in nativeMethods
		Collection::[method] = ->
			args = slice.call( arguments )
			args.unshift this.models
			return Array.prototype[method].apply( null, arguments )



	returnsCollectionMethods = ['filter', 'where', 'reject']

	for method in returnsCollectionMethods
		methodName = "col" + method.charAt(0).toUpperCase() + method.slice(1)
		Collection::[methodName] = ->
			args = slice.call( arguments )
			args.unshift this.models
			return new this.constructor _[method].apply( _, args )

	return {
		Model: Model
		Collection: Collection
	}


