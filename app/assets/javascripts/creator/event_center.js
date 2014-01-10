
// Register callbacks, trigger callbacks on document, support removal by key and component, rather than 
// something else (that is - don't keep callbacks around). 
// Do this based on identifier, to minimize stray jquery searches
window.event_center = Object.create({
	init: function(){

		return this;
	}

}).init(); 