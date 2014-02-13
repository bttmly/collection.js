hub = $ {}

$.getJSON "data.json", ( data ) ->
	window.data = data
	e = $.Event( "jsonComplete" )
	e.jsonData = data
	hub.trigger( e )

hub.on "jsonComplete", ( event ) ->
	console.log "READY..."
	
	data = event.jsonData
	window.collection = new Barebones.Collection( data )
