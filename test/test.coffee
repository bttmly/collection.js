hub = $({})

$.getJSON "data.json", ( data ) ->
	e = $.Event( "jsonComplete" )
	e.jsonData = data
	hub.trigger( e )

hub.on "jsonComplete", ( event ) ->

	console.log "rock and roll..."

	data = event.jsonData

	# attach to window for inspection
	window.vanillaCollection = data
	window.barebonesCollection = new Barebones.Collection( data )

	methods = ['forEach', 'each', 'map', 'collect', 'reduce', 'foldl', 'inject', 'reduceRight', 'foldr', 'find', 'detect', 'filter', 'select', 'reject', 'every', 'all', 'some', 'any', 'include', 'contains', 'invoke', 'max', 'min', 'toArray', 'size', 'first', 'head', 'take', 'initial', 'rest', 'tail', 'drop', 'last', 'without', 'indexOf', 'shuffle', 'lastIndexOf', 'isEmpty', 'chain']

	cloner = ->
		result = []
		result.push $.extend true, {}, vanillaCollection
		result.push new Barebones.Collection( data )
		return result

	checkCollectionEquality = ( col1, col2 ) ->
		result = true
		for model, i in col1
			unless col1[i] is col2[i]
				result = false
				console.log col1[i]
				console.log col2[i]
				break
		return result

	checkArrayEquality = ( arr1, arr2 ) ->
		result = true
		for name, i in arr1
			unless arr1[i] is arr2[i]
				result = false
				console.log arr1[i]
				console.log arr2[i]
				break
		return result


	# forEach
	window.tests =
		forEach : do ->
			[v, b] = cloner()
			test = ( model ) ->
				model.testProp = "just a test"
			_.each v, test
			b.each test
			b = b.arrayify()
			
			return checkCollectionEquality b, v

		map : do ->
			[v, b] = cloner()
			test = ( model ) ->
				return model.name

			vmap = _.map v, test
			bmap = b.map test

			return checkArrayEquality bmap, vmap

		reduce : do ->
			[v, b] = cloner()
			test = ( memo, model ) ->
				return memo + model.scrimYds
			vreduce = _.reduce v, test, 0
			breduce = b.reduce test, 0
			return if vreduce is breduce then true else false

		reduceRight : do ->
			[v, b] = cloner()
			test = ( memo, model ) ->
				return memo + model.passYds
			vreduce = _.reduceRight v, test, 0
			breduce = b.reduceRight test, 0
			return if vreduce is breduce then true else false

	fail = false
	for test, pass of tests
		if not pass
			console.log test
			fail = true

	if fail is false
		console.log tests
