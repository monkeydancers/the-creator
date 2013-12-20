//= require creator/editable
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
		if(_t.selection == "all"){
			_t.selection = [];
		}
		if(checkbox.is(':checked')){
			_t.selection.push(row.data('identifier'));
		} else {
			_t.selection.splice(_t.selection.indexOf(row.data('identifier')), 1);;
		}
		_t.object_counter_elm.html(_t.selection.length);

		console.log(_t.selection);
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
		_t._attach_event_handler_to_list_page();
		_t._check_selected_objects();
	},
	_attach_event_handler_to_list_page: function(){
		var _t = this;
		_t.container.find( ".go-draghandle").each(function(idx, el){
			var _e = $(el);
			_e.data('identifier', {identifier: _e.find('.identifier').text().replace(/#/, ""), scope: null}); 

		}).draggable({ revert: true, helper: "clone", appendTo: "body", zIndex: 1000 });

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
		if(_t.selection == "all"){
			_t.container.find('.checkbox-col input').attr('checked', true);
		} else {
			_t.container.find('.game_object_row').each(function(i, elm) {
				elm = $(elm);
				if(_t.selection.indexOf(elm.data('identifier')) > -1){
					elm.find('.checkbox-col input').attr('checked', true);
				}
			});
		}
	},
	_toggle_all_selected: function(elm){
		var _t = this;
		if(_t.selection == "all"){
			_t.selection	 	= [];
			_t.container .find('.checkbox-col input').prop('checked', false);
			_t.object_counter_elm.html("0");
			elm.html("select all");
		} else {
			_t.selection = "all";
			_t.container.find('.checkbox-col input').prop('checked', true);
			_t.object_counter_elm.html(_t.num_objects);
			elm.html("deselect all");
		}
	},
	_delete_selected_items: function(){
		var _t = this;
		console.log(_t);
		console.log('Delete:');		
		if(_t.selection == "all"){
			console.log('All objects');		
		} else {
			console.log(_t.selection);
		}
	},
	init: function(game_objects, container, ws_manager, options){ 
		var _t            				= this;
    	_t.selection						= [];
    	_t.opts  								= options

    	_t.container 	  				= container;
    	_t.ws_manager						= ws_manager;

    	_t.game_objects 				= game_objects;

    	_t.identifier 					= game_objects.identifier;
    	_t.num_objects 					= game_objects.num_game_objects;

    	_t.current_page 				= 1;

    	_t.object_counter_elm 	= _t.container.find(".objects-selected-in-list");
    	_t.pagination_elm				= _t.container.find(".col-pagination");


    	// Add drag drop
    	_t.container.find(".gol-draghandle" ).draggable({ 
    		revert: true, 
    		helper: "clone", 
    		appendTo: "body", 
    		zIndex: 1000,
    		start: function(e, ui){
    			$(ui.helper).data('identifier', _t.selection);
    		}
    	});

    	_t.more_template	= Liquid.parse($('#workspace_more_popin_template').html());


		_t.container.find('.delete-selected-button').on('click.creator',  function(){
    		_t._delete_selected_items.apply(_t, [])
    	});



    	_t.container.find('.tools .icon.plus').on('click.creator',  function(){
    		_t._open_more_actions_popover.apply(_t, [])
    	});

    	_t.container.find('.select_all').on('click.creator',  function(e){
    		_t._toggle_all_selected.apply(_t, [$(e.currentTarget)])
    		e.preventDefault()
    	});

    	_t._attach_event_handler_to_list_page();
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

	open: function(identifier, opts){
		var _t = this; 
		$.when(this._choose_workspace(), this._load_identifier(identifier)).then(function(workspace, data){
			_t.open_in(workspace, data, opts);
		}, function(error){
			console.log(error);
		});
	},

	open_in: function(workspace, identifier, opts){
		var _t = this;
		$.when(this._load_identifier(identifier)).then(function(data){
			if(data.list){
				_t._render_list(workspace, data);				
			}else{
				_t._render_object(workspace, data);
			}
		});
	},

	_choose_workspace: function(){		
		var _t 						= this; 
		// Create a deferred object
		var deferred 			= $.Deferred(); 

		// Generalize clean-up and resolvement of the deferred object
		var selected = function(workspace){
			// Cleanup events
			$(document).off('.workspace_selector'); 
			_t.workspace_selector.find('li').off('.workspace_selector');
			// Hide the selector
			_t.workspace_selector.css('display', 'none'); 
			// Resolve the deferred and pass along the selected workspace
			deferred.resolve(workspace); 
		}

		// Add events for supporting clicking, using element-index as indicator in order
		// to support new workspaces
		this.workspace_selector.find('li').on('click.workspace_selector', function(e){
			var _target = $(e.currentTarget); 
			selected(_target.index()+1);
		});

		// Allow selection using keyboard and 1,2,3
		$(document).on('keyup.workspace_selector', function(e){
			var _i = [49,50,51].indexOf(e.which); 
			if(_i >= 0){
				selected(_i + 1); 
			}
		});

		// Show the selector and return a "promise"
		this.workspace_selector.css('display', 'block'); 
		return deferred.promise(); 
	},

	_load_identifier: function(identifier){
		var deferred = $.Deferred(); 
		$.ajax({
			url: '/create/identifier', 
			data: {
				identifier: identifier
			}, 
			dataType: 'json', 
			success: function(data){
				deferred.resolve(data);
			}, 
			error: function(){
				deferred.reject({
					message: "We couldn't load that game object"
				});
			}
		})
		return deferred.promise();
	},

	_render_object: function(workspace, game_object){ 
		var _t = this;
		if(typeof(workspace) == "object"){
			var ws = workspace;
		}else{
			var ws  = _t._find_workspace(workspace);			
		}		
		// Perhaps some effect should be used to indicate interaction?
		ws.html(_t.templates['game_object'].render(game_object));

		_t.occupy(ws);

		Object.create(window.game_object).init(game_object, ws, this);
	},

	_render_list: function(workspace, gameobjects){ 
		var _t  = this;
		if(typeof(workspace) == "object"){
			var ws = workspace;
		}else{
			var ws  = _t._find_workspace(workspace);			
		}

		_t.occupy(ws);

		_t.render_game_objects_collection(ws, gameobjects);
	},

	prepare_gameobjects: function(gameobjects, page){
		var _t = this;
		gameobjects['selected_page'] 	= page;
		gameobjects['pages'] 		 			= window.game_objects_collection.build_pagination(gameobjects['selected_page'], gameobjects['num_game_objects'], _t.opts['gameobjects_collection']['objects_per_page'] , _t.opts['gameobjects_collection']['show_pagination_pages']);

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

	occupy: function(ws){
		var ws = $(ws); 
		ws.addClass('occupied');
		ws.droppable('disable');
	},

	empty_workspace: function(e){
		var target = $(e.currentTarget); 
		var workspace = target.parents('.workspace'); 
		workspace.html('').removeClass('occupied').droppable('enable');
	},

	init: function(options){ 
		var _t           					= this;
		_t.workspaces	 						= [];
		_t.opts 									= {};

		_t.workspace_selector 		= $(".open-in");


		// Initialize game objects
		$(".workspace.go-droparea" ).droppable({ 
			accept: ".go-draghandle, .gol-draghandle", 
			hoverClass: "go-droparea-active", 
			drop: function(e, ui){				
				var data = ui.draggable.data('identifier');
				if(!data){
					var data = ui.helper.data('identifier');
				}
				_t.open_in($(e.target), data.identifier, {}); 
			}
		});

		$(".work-spaces").on('click.creator', '.tools .icon.x',  this.empty_workspace.bind(this));

		_t.opts['gameobjects_collection'] 	= {};

    	// Default options
    	_t.opts['gameobjects_collection']['objects_per_page'] 			= 5;
    	_t.opts['gameobjects_collection']['show_pagination_pages'] 		= 5;

    	// Add templates for future references
    	_t.templates 	= {};
    	_t.templates['game_object'] 													= Liquid.parse($('#game_object_template').html());
    	_t.templates['game_objects_collection_in_ws'] 				= Liquid.parse($('#game_objects_collection_in_ws_template').html());
    	_t.templates['game_objects_collection_pagination'] 		= Liquid.parse($('#game_objects_collection_pagination_template').html());
    	_t.templates['game_objects_collection_list'] 					= Liquid.parse($('#game_objects_collection_list_template').html());
    	_t.templates['game_objects_collection'] 							= Liquid.parse($('#game_objects_collection_template').html());

    	return _t;
    }
  });
