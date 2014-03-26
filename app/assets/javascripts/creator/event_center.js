window.event_center = Object.create({
	init: function(){
		this.callbacks = {};
		this.lookups = {};
		return this;
	},
	on: function(e_name, namespace, callback){
		if(namespace){
			var event_name = e_name+"."+namespace; 			
		}else{
			var event_name = e_name;
		}
		var time_key = (new Date()).getTime();		
		if(!this.callbacks[event_name]){
			$(document).on(event_name, this._fire.bind(this)); 
			this.callbacks[event_name] = [];
		}
		this.lookups[time_key] = {
			event: event_name, 
			callback: callback
		}; 
		this.callbacks[event_name].push(callback);
		return time_key
	}, 
	off: function(timekey){
		var callback = this.lookups[timekey]; 
		console.log(callback); 
		if(callback){
			console.log(this.callbacks[callback.event]);
			this.callbacks[callback.event] = _.reject(this.callbacks[callback.event], function(el, idx){
				return el.callback == callback
			});
			console.log(this.callbacks[callback.event]);
			if(this.callbacks[callback.event].length <= 0){
				$(document).off(callback.event_name);
			}
		}else{
			return true;
		}
	}, 
	_fire: function(e, payload){
		var e_name = e.type+"."+e.namespace;
		_.each(this.callbacks[e_name], function(func, idx){
			if(typeof(payload.identifier) == "string"){
				var selector = "[data-identifier='"+payload.identifier+"']"; 				
			}else{
				// This is a scoped identifer.
				var selector = "[data-identifier='"+payload.identifier.identifier+"']"; 
			}
			func(payload.identifier, payload.data, selector); 
		});
	}
}).init(); 