window.editable = Object.create({
	_edit_clicked: function(index, trigger_element){
		var _t 							= this;
		_t._event_binds		= []; 
		var edit_entry 			= $(trigger_element);

		var data = {
			'header' 			: 	'Editing ' + edit_entry.data('key'),
			'value' 			: 	edit_entry.text(),
			'identifier' 	: 	edit_entry.data('identifier'),
			'type'				: 	edit_entry.data('type'), 
			'attribute'		: 	edit_entry.data('attribute'), 
			'key'					: 	edit_entry.data('key')
		}

		console.log(data);

		// If we need to load the value from the server, render the popin
		// with loading == true, and start loading the data, replace the popin
		// once loading has completed.
		if(['object', 'objects'].indexOf(data.type) >= 0){
			$.ajax({
				url: '/create/property', 
				type: 'get', 
				dataType: 'json', 
				data: {identifier: data.identifier, authenticity_token: authToken()}, 
				success: function(objects){
					objects = _t.ws_manager.prepare_gameobjects(objects, 1);
					_t.hide_edit();
					$.extend(data, objects);
					data.loading = false
					_t.create_edit(data, function(popin){
						Object.create(window.game_objects_collection).init(objects, popin, _t.ws_manager, _t.ws_manager.opts['gameobjects_collection']);
						_t.present_edit();
					});
				}, 
				error: function(){

				}
			});		
			data.loading = true;
		}

		_t.create_edit(data, function(popin){
			_t.present_edit();
		}); 
	},

	present_edit: function(){
		this.workspace.prepend(this.popin);	
	},

	create_edit: function(data, callback){
		var _t = this;
		var popin = $(_t.template.render(data));
		this.popin = popin; 

		this.popin.find( ".go-droparea" ).droppable({ 
			accept: ".go-draghandle", 
			hoverClass: "go-droparea-active", 
			drop: function(e, ui){ 
				var identifier_data = ui.draggable.data('identifier');
				_t.save({identifier: data.identifier}, identifier_data.identifier)
			}  
		});

		this.popin.find('.save-btn').one('click', _t.save.bind(_t, data, _t.popin.find('.property-edit-field').val()));
		this.popin.find('.property-edit-field').on('keypress', function(e){
			if(e.which == 13){
				e.preventDefault();
				_t.save.apply(_t, [data, _t.popin.find('.property-edit-field').val()]);
			}
		});

		this.popin.find('.close').on('click', function(){
			_t.hide_edit.apply(_t); 
		});



		// Register this to the de-registed once we close the popin!
		if(data.attribute){
			this._event_binds.push(window.event_center.on('update', 'object', function(identifier, data, selector){
				_t.popin.find(selector).find('.' + data.key).html(data.value);
			}));
		}else{
			this._event_binds.push(window.event_center.on('update', 'property', function(identifier, data, selector){
				_t.popin.find(selector).html(data.value);
			}));

			this._event_binds.push(window.event_center.on('delete', 'property', function(identifier, data, selector){
				_root = _t.popin.find(selector); 
				_.each(data.selection, function(el, ind){
					_root.find('[data-identifier="'+el+'"]').remove(); 
				});
			}));
		}		



		callback(popin);
		return popin; 
	},

	hide_edit: function(){
		if(this.popin){
			this.popin.find('.property-edit-field').off('keypress'); 
			this.popin.find('.save-btn').off('click');
			// Add animations to edit here...
			this.popin.remove();
		//	this.popin = null;
			$.each(this._event_binds, function(idx, el){
				window.event_center.off(el); 
			});
		}
	},

	save: function(data, value){
		var _t = this;
		var payload = {
			identifier: data.identifier, 
			value: value,
			key: data.key,
			authenticity_token: authToken()
		};

		$.ajax({
			url: (data.attribute ? '/create' : '/create/property'), 
			type: (data.attribute ? 'put' : 'post'), 
			dataType: 'json',
			data: payload,
			success: function(server_data){
				var event_data = {
					identifier: payload.identifier, 
					scope: null, 
					data: {
						value: server_data.value, 
						key: server_data.key						
					}
				}
				if(data.attribute){
					$(document).trigger('update.object', [event_data]);				
				}else{
					$(document).trigger('update.property', [event_data]);				
				}
				_t.hide_edit();
			},
			error: function(){
				alert("Something went wrong!");
			}
		})
	},

	init: function(workspace, ws_manager){
		var _t 			= this;
		_t.workspace 	= workspace;
		_t.ws_manager	= ws_manager;

		_t.template		= Liquid.parse($('#workspace_editable_popin_template').html());

		// Attach events
		_t.workspace.find('.editable').each(function(index){ 
			$(this).on('click.creator.editable', function() { 
				_t._edit_clicked.apply(_t, [index, this]) 
			});
		});
		return _t;
	}
});
