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
	_open_more_actions_popover: function(){
		var _t = this;
		_t.container.prepend(_t.more_template.render());
	},
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

		console.log(_t.selected_objects);
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

		_t.ws_manager.render_gameobjects_collection_page(_t.container.find('tbody'), _t.pagination_elm, _t.current_page,  gameobjects);
		_t._attach_event_handeler_to_list_page();
		_t._check_selected_objects();
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
	_check_selected_objects: function(){
		var _t = this;

		if(_t.all_selected){
			_t.container.find('.checkbox-col input').attr('checked', true);
		} else {
			_t.container.find('.game_object_row').each(function(i, elm) {
				elm = $(elm);
				if(_t.selected_objects.indexOf(elm.data('identifier')) > -1){
					elm.find('.checkbox-col input').attr('checked', true);
				}
			});
		}
	},
	_toggle_all_selected: function(elm){
		var _t = this;

		if(_t.all_selected){
			_t.all_selected 		= false
			_t.selected_objects	 	= [];
			_t.container .find('.checkbox-col input').prop('checked', false);
			_t.object_counter_elm.html("0");
			elm.html("select all");
		} else {
			_t.all_selected = true;
			_t.container.find('.checkbox-col input').prop('checked', true);
			_t.object_counter_elm.html(_t.num_objects);
			elm.html("deselect all");
		}
	},
	init: function(game_objects, container, ws_manager, options){ 
    	var _t            		= this;
    	_t.selected_objects		= []; // Identifiers of selected game objects
    	_t.all_selected 		= false;
    	_t.opts  				= options

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

		_t.more_template	= Liquid.parse($('#workspace_more_popin_template').html());

    	_t.container.find('.tools .icon.plus').on('click.creator',  function(){
    		_t._open_more_actions_popover.apply(_t, [])
    	});

    	_t.container.find('.select_all').on('click.creator',  function(e){
    		_t._toggle_all_selected.apply(_t, [$(e.currentTarget)])
    		e.preventDefault()
    	});

		_t._attach_event_handeler_to_list_page();
		_t._check_selected_objects();

		return _t;
	}
});

window.game_object = Object.create({
	_open_more_actions_popover: function(){
		var _t = this;
		_t.container.prepend(_t.more_template.render());
	},
	init: function(game_object, workspace, ws_manager){ 
    	var _t            	= this;
    	_t.container 	  	= workspace;
    	_t.ws_manager 		= ws_manager;

    	_t.more_template	= Liquid.parse($('#workspace_more_popin_template').html());

    	_t.container.find('.tools .icon.plus').on('click.creator',  function(){
    		_t._open_more_actions_popover.apply(_t, [])
    	});


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

	_open_game_objects_collection: function(workspace, gameobjects){ 
		var _t  = this;
		var ws  = _t._find_workspace(workspace);

		ws.addClass('occupied');

		_t.render_game_objects_collection(ws, gameobjects);
	},

	prepare_gameobjects: function(gameobjects, page){
		var _t = this;
		gameobjects['selected_page'] = page;
		gameobjects['pages'] 		 = window.game_objects_collection.build_pagination(gameobjects['selected_page'], gameobjects['num_game_objects'], _t.opts['gameobjects_collection']['objects_per_page'] , _t.opts['gameobjects_collection']['show_pagination_pages']);

		return gameobjects;
	},
	render_gameobjects_collection_page: function(container,pagination_container, page, gameobjects){
		var _t = this;

		gameobjects = _t.prepare_gameobjects(gameobjects, page);

		container.html(_t.templates['game_objects_collection_list'].render(gameobjects));
		pagination_container.html(_t.templates['game_objects_collection_pagination'].render(gameobjects));
	},
	render_game_objects_collection: function(container, gameobjects){
		var _t = this;

		gameobjects = _t.prepare_gameobjects(gameobjects, 1);


		// Perhaps some effect should be used to indicate interaction?
		var tmpl = $(_t.templates['game_objects_collection_in_ws'].render(gameobjects));
		Object.create(window.game_objects_collection).init(gameobjects, tmpl, this, _t.opts['gameobjects_collection']);

		container.html(tmpl);
	},

	init: function(options){ 
    	var _t           					= this;
    	_t.workspaces	 					= [];
    	_t.opts 							= {};
    	_t.opts['gameobjects_collection'] 	= {};

    	// Default options
    	_t.opts['gameobjects_collection']['objects_per_page'] 			= 5;
    	_t.opts['gameobjects_collection']['show_pagination_pages'] 		= 5;

    	// Add templates for future references
    	_t.templates 	= {};
    	_t.templates['game_object'] 						= Liquid.parse($('#game_object_template').html());
    	_t.templates['game_objects_collection_in_ws'] 		= Liquid.parse($('#game_objects_collection_in_ws_template').html());
    	_t.templates['game_objects_collection_pagination'] 	= Liquid.parse($('#game_objects_collection_pagination_template').html());
    	_t.templates['game_objects_collection_list'] 		= Liquid.parse($('#game_objects_collection_list_template').html());
    	_t.templates['game_objects_collection'] 			= Liquid.parse($('#game_objects_collection_template').html());


    	return _t;
	}
});