window.editable = Object.create({
	_edit_clicked: function(index, event){
		var _t = this;
		var edit_entry = $(event);

		console.log(edit_entry.html());
		console.log(edit_entry.data('key'));

		_t.workspace.prepend(_t.template.render({
			'header' 		: 'Editing ' + edit_entry.data('key'),
			'value' 		: edit_entry.text(),
			'identifier' 	: edit_entry.data('identifier') 
		}));

	},
	init: function(workspace){
		var _t 				= this;
		_t.workspace 	= workspace;
    	_t.template		= Liquid.parse($('#workspace_popin_template').html());

		// Attach events
    	_t.workspace.find('.editable').each(function( index){ 
    		$(this).on('click.creator.editable', function() { _t._edit_clicked.apply(_t, [index, this]) } );
    	});
		return _t;
	}
});


window.game_objects_tabs = Object.create({
	_tab_clicked: function(index){
		
		// Switch content
		this.tabs_content.find('.tab-content').removeClass('selected');
    	this.tabs_content.find('.tab-content:eq(' +  index +')').addClass('selected');

    	// Select the approparite tab 
    	this.tabs.find('li').removeClass('selected');
    	this.tabs.find('li:eq(' +  index +')').addClass('selected');
	},
	init: function(container){ 
    	var _t            	= this;
    	_t.container 		= container;

    	_t.tabs 	 		= _t.container.children('.tabs');
    	_t.tabs_content 	= _t.container.children('.tabs-content');


    	// Attach events
    	_t.tabs.find('li').each(function( index){ 
    		$(this).on('click.creator.tabs', function() { _t._tab_clicked.apply(_t, [index]) } );
    	});
    	
    	return _t;

    }	
});


window.game_objects_collection = Object.create({

	init: function(game_objects, workspace){ 
    	var _t            = this;

    	_t.container 	  = workspace;
		_t.container.find( ".go-draghandle").draggable({ revert: true, helper: "clone", appendTo: "body" });
		_t.container.find( ".go-draghandles" ).draggable({ revert: true, helper: "clone", appendTo: "body" });
		_t.container.find( ".go-droparea" ).droppable({ accept: ".go-draghandle", hoverClass: "go-droparea-active", drop: function(){ console.log("Dropped")}  });

    	return _t;
	}
});

window.game_object = Object.create({

	init: function(game_object, workspace){ 
    	var _t            = this;
    	_t.container 	  = workspace;
		_t.container.find( ".go-draghandle").draggable({ revert: true, helper: "clone", appendTo: "body" });
		_t.container.find( ".go-draghandles" ).draggable({ revert: true, helper: "clone", appendTo: "body" });
		_t.container.find( ".go-droparea" ).droppable({ accept: ".go-draghandle", hoverClass: "go-droparea-active", drop: function(){ console.log("Dropped")}  });

		_t.tabs 	= Object.create(window.game_objects_tabs).init(_t.container.find('.gameobject-tabs'));
		_t.editable = Object.create(window.editable).init(_t.container);


    	return _t;
	}
});


window.workspaces = Object.create({
	_find_workspace: function(workspace){
		return $($('.workspace')[workspace - 1]);
	},
	open_game_object: function(identifier, workspace){
		// Find by ajax and send back

		this._open_game_object(workspace, game_object);

	},
	_open_game_object: function(workspace, game_object){ 
		var _t = this;
		var ws  = _t._find_workspace(workspace);
		
		console.log(_t.templates);
		// Perhaps some effect should be used to indicate interaction?
		ws.html(_t.templates['game_object'].render(game_object));

		ws.addClass('occupied');
		Object.create(window.game_object).init(game_object, ws);
	},

	_open_game_objects_collection: function(workspace, game_objects){ 
		var _t  = this;
		var ws  = _t._find_workspace(workspace);

			// Perhaps some effect should be used to indicate interaction?
		ws.html(_t.templates['game_objects_collection'].render(game_objects));

		ws.addClass('occupied');
		Object.create(window.game_objects_collection).init(game_objects, ws);
	},
	init: function(){ 
    	var _t            = this;
    	console.log("Initialize workspaces");

    	_t.workspaces 	= [];

    	// Add templates for future references
    	_t.templates 	= {};
    	_t.templates['game_object'] 			= Liquid.parse($('#game_object_template').html());
    	_t.templates['game_objects_collection'] = Liquid.parse($('#game_objects_collection_template').html());
    	_t.templates['workspace_popin'] 		= Liquid.parse($('#workspace_popin_template').html());

    	return this;
	}
});