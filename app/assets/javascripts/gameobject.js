window.editable = Object.create({
	_edit_clicked: function(index, event){
		var _t 			= this;
		var edit_entry 	= $(event);

		// Temporary var - Identifier here is the same as the property
		var objects 			  = {'identifier' 		: '23g363', 
									 'num_game_objects' : 44,
									 'objects_per_page'	: 5, 
									 'game_objects_list': [{'name' : 'objekt 1', 'identifier' : '123'}, {'name' : 'objekt 2', 'identifier' : '1234'}]};

		var popin = _t.template.render({
			'header' 			: 'Editing ' + edit_entry.data('key'),
			'value' 			: edit_entry.text(),
			'identifier' 		: edit_entry.data('identifier'),
			'type'				: edit_entry.data('type'),
			'game_objects_list'	: objects.game_objects_list,
			'num_game_objects' 	: objects.num_game_objects,
			'object_per_page'	: objects.objects_per_page
		});
		_t.workspace.prepend(popin);

		if(edit_entry.data('type') == 'objects'){
			_t.ws_manager.render_game_objects_collection(_t.workspace.find('.popin'), objects);
		}
	},
	init: function(workspace, ws_manager){
		var _t 			= this;
		_t.workspace 	= workspace;
		_t.ws_manager	= ws_manager;


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
	// Class Methods
	build_pagination: function(current_page, num_game_objects, objects_per_page, paginations_pages){
		var total_pages 	= Math.ceil(num_game_objects / objects_per_page);
		var show_num_pages 	= paginations_pages;
		var pages = [];
		var start_page = current_page - Math.ceil(show_num_pages / 2);

		

		if((start_page + show_num_pages) > total_pages){
			start_page = total_pages - show_num_pages; 
		}

		if(start_page < 0){
			start_page = 0;
		}

		if(total_pages < paginations_pages){
			show_num_pages = total_pages;
		}

		for( var i = 0; i < show_num_pages; i++){
			pages.push(i  + 1 +  start_page);
		}
		return pages;
	},

	// Object methods
	_select_all_objects : function(){

	},
	_checkbox_clicked: function(checkbox, row){
		var _t = this;
		if(checkbox.is(':checked')){
			_t.selected_objects.push(row.data('identifier'));
		} else {
			_t.selected_objects.splice(_t.selected_objects.indexOf(row.data('identifier')), 1);;
		}
		_t.object_counter_elm.html(_t.selected_objects.length);

		console.log(_t.selected_objects.length);
	},
	_pagination_clicked: function(number_elm){
		var _t = this;

		_t.pagination_elm.find('a').removeClass('selected');
		number_elm.addClass('selected');

		_t.current_page = number_elm.text() * 1;

		// Change content over ajax
		_t._render_new_page(_t.game_objects);

	},
	_render_new_page: function(gameobjects){
		var _t = this;
		_t.ws_manager.render_gameobjects_collection_page(_t.container.find('tbody'), gameobjects);
		_t.ws_manager.render_pagination_to_objects_collection(_t.pagination_elm,  _t.game_objects, _t.current_page  );
				_t._attach_event_handeler_to_list_page();
	},
	_attach_event_handeler_to_list_page: function(){
		var _t = this;
		_t.container.find( ".go-draghandle").draggable({ revert: true, helper: "clone", appendTo: "body", zIndex: 1000 });

		// Pagination Event Handlers
		_t.container.find('.gol-table .col-pagination a').on('click.creator', function(e){
			var number = $(e.currentTarget);
			e.preventDefault();

			_t._pagination_clicked.apply(_t, [number]);
		});

		// Checkbox Event Handlers
		_t.container.find('input[type=checkbox]').on('click.creator', function(e){ 
			var checkbox = $(e.currentTarget);
			 _t._checkbox_clicked.apply(_t, [checkbox, checkbox.parent('.checkbox-col').parent('.game_object_row')]) 
		});


	},

	init: function(game_objects, container, ws_manager){ 
    	var _t            		= this;
    	_t.selected_objects		= [];
    	_t.container 	  		= container;
    	_t.ws_manager			= ws_manager;

    	_t.game_objects 		= game_objects;

    	_t.identifier 			= game_objects.identifier;
    	_t.num_objects 			= game_objects.num_game_objects;

    	_t.current_page 		= 1;

    	_t.object_counter_elm 	= _t.container.find(".objects-selected-in-list");
    	_t.pagination_elm		= _t.container.find(".col-pagination");

    	// Add drag drop
		_t.container.find( ".gol-draghandle" ).draggable({ revert: true, helper: "clone", appendTo: "body", zIndex: 1000 });
		_t.container.find( ".go-droparea" ).droppable({ 
			accept: ".go-draghandle", 
			hoverClass: "go-droparea-active", 
			drop: function(){ console.log("Dropped")}  
		});

		_t._attach_event_handeler_to_list_page();

		return _t;
	}
});

window.game_object = Object.create({

	init: function(game_object, workspace, ws_manager){ 
    	var _t            	= this;
    	_t.container 	  	= workspace;
    	_t.ws_manager 		= ws_manager;
		_t.container.find( ".go-draghandle").draggable({ revert: true, helper: "clone", appendTo: "body", zIndex: 1000 });
		_t.container.find( ".gol-draghandle" ).draggable({ revert: true, helper: "clone", appendTo: "body", zIndex: 1000 });
		_t.container.find( ".go-droparea" ).droppable({ 
			accept: ".go-draghandle", 
			hoverClass: "go-droparea-active", 
			drop: function(){ console.log("Dropped")}  
		});

		_t.tabs 	= Object.create(window.game_objects_tabs).init(_t.container.find('.gameobject-tabs'));
		_t.editable = Object.create(window.editable).init(_t.container, ws_manager);

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
		
		// Perhaps some effect should be used to indicate interaction?
		ws.html(_t.templates['game_object'].render(game_object));

		ws.addClass('occupied');
		Object.create(window.game_object).init(game_object, ws, this);
	},
	_add_pagination_to_gameobjects: function(gameobjects, selected_page) {
		var _t = this;
		gameobjects['selected_page'] = selected_page;
		gameobjects['pages'] 		  =  window.game_objects_collection.build_pagination(gameobjects['selected_page'], gameobjects.num_game_objects, _t.objects_per_page, _t.show_pagination_pages);
		return gameobjects;
	},

	_open_game_objects_collection: function(workspace, game_objects){ 
		var _t  = this;
		var ws  = _t._find_workspace(workspace);

		ws.addClass('occupied');
		_t.render_game_objects_collection(ws, game_objects);
	},
	render_gameobjects_collection_page: function(container,gameobjects){
		var _t = this;

		container.html(_t.templates['game_objects_collection_list'].render(gameobjects));
	},
	render_pagination_to_objects_collection: function(container, gameobjects, selected_page){
		var _t = this;

		game_objects = _t._add_pagination_to_gameobjects(gameobjects, selected_page);

		container.html(_t.templates['game_objects_collection_pagination'].render(gameobjects));
	},
	render_game_objects_collection: function(container, game_objects){
		var _t = this;
		game_objects = _t._add_pagination_to_gameobjects(game_objects, 21);
		// Perhaps some effect should be used to indicate interaction?
		container.html(_t.templates['game_objects_collection'].render(game_objects));
		Object.create(window.game_objects_collection).init(game_objects, container, this);
	},

	init: function(){ 
    	var _t           			= this;
    	_t.workspaces	 			= [];
    	_t.objects_per_page 		= 5;
    	_t.show_pagination_pages 	= 5;


    	// Add templates for future references
    	_t.templates 	= {};
    	_t.templates['game_object'] 						= Liquid.parse($('#game_object_template').html());
    	_t.templates['game_objects_collection'] 			= Liquid.parse($('#game_objects_collection_in_ws_template').html());
    	_t.templates['game_objects_collection_pagination'] 	= Liquid.parse($('#game_objects_collection_pagination_template').html());
    	_t.templates['game_objects_collection_list'] 		= Liquid.parse($('#game_objects_collection_list_template').html());

    	return _t;
	}
});