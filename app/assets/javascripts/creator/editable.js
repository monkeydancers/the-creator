window.editable = Object.create({
	_edit_clicked: function(index, event){
		var _t 			= this;
		var edit_entry 	= $(event);

		// Temporary var - Identifier here is the same as the property
		var objects 			  = {'identifier' 		: '23g363', 'num_game_objects' : 125,
									 'game_objects_list': [{'name' : 'objekt 1', 'identifier' : '123'}, {'name' : 'objekt 2', 'identifier' : '1234'}]};

		var data = {
			'header' 			: 'Editing ' + edit_entry.data('key'),
			'value' 			: edit_entry.text(),
			'identifier' 		: edit_entry.data('identifier'),
			'type'				: edit_entry.data('type')	
		}
		if(edit_entry.data('type') == 'objects'){
			objects = _t.ws_manager.prepare_gameobjects(objects, 1);
			$.extend(data, objects);
		}

		var popin = $(_t.template.render(data));

		if(edit_entry.data('type') == 'objects'){
			Object.create(window.game_objects_collection).init(objects, popin, _t.ws_manager, _t.ws_manager.opts['gameobjects_collection']);
		}
		
		_t.workspace.prepend(popin);
	},


		
	init: function(workspace, ws_manager){
		var _t 			= this;
		_t.workspace 	= workspace;
		_t.ws_manager	= ws_manager;


    	_t.template		= Liquid.parse($('#workspace_editable_popin_template').html());

		// Attach events
    	_t.workspace.find('.editable').each(function( index){ 
    		$(this).on('click.creator.editable', function() { _t._edit_clicked.apply(_t, [index, this]) } );
    	});
		return _t;
	}
});
