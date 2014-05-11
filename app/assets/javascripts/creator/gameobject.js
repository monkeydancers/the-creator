//= require creator/editable
//= require creator/event_center

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
	cleanup: function(callback){
		$.each(this._event_binds, function(idx, el){
			window.event_center.off(el); 
		});
		callback(); 
	},

	// Object methods
	_open_more_actions_popover: function(){
		var _t = this;
		var pop = _t.more_template.render(); 
		_t.container.prepend(pop);
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
			_t.container.find('.checkbox-col input').prop('checked', false);
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
		$.ajax({
			url: '/create/remove', 
			type: 'post',
			dataType: 'json', 
			data: {identifier: _t.game_objects.identifier, scope: _t.selection, authenticity_token: authToken()}, 
			success: function(data){
				$(document).trigger('delete.'+data.object_type, [{
					identifier: _t.game_objects.identifier, 
					data: {
						value: data.description, 
						selection: _t.selection
					}
				}]);				
			}, 
			error: function(){
				console.log(arguments);
			}
		});
	},
	init: function(game_objects, container, ws_manager, options){ 
		var _t            				= this;
		_t.selection						= [];
		_t.opts  								= options

		_t._event_binds 					= []; 

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
    			$(ui.helper).data('identifier', {identifier: _t.game_objects.identifier, scope:_t.selection});
    		}
    	});

			_t._event_binds.push(window.event_center.on('delete', 'object', function(identifier, data, selector){
				_t.game_objects.game_objects_list = _.reject(_t.game_objects.game_objects_list, function(el, idx){
					return data.selection.indexOf(el.identifier) > -1
				});
				_t.game_objects.num_game_objects = _t.game_objects.game_objects_list.length;
				_t._render_new_page(_t.game_objects); 
			}));

			_t._event_binds.push(window.event_center.on('update', 'object', function(identifier, data, selector){
				_t.container.find(selector + " ."+data.key).html(data.value);
			}));

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
		var pop = $(_t.more_template.render()); 
		pop.find('.close').on('click', function(){
			pop.remove();
		});
		_t.container.prepend(pop);
	},
	init: function(game_object, workspace, ws_manager){ 
		var _t            = this;
		_t.container 	  	= workspace;
		_t._event_binds 		= []; 
		_t.ws_manager 		= ws_manager;

		_t.more_template	= Liquid.parse($('#workspace_more_popin_template').html());

		_t.container.find('.tools .icon.plus').on('click.creator',  function(){
			_t._open_more_actions_popover.apply(_t, [])
		});

		// Register this for de-registration once we close it
		_t._event_binds.push(window.event_center.on('update', 'object', function(identifier, data, selector){
			_t.container.find(selector).find("."+data.key).html(data.value);
		}));

		_t._event_binds.push(window.event_center.on('update', 'property', function(identifier, data, selector){
			console.log(arguments);
			_t.container.find(selector).html(data.value);
		}));

		_t._event_binds.push(window.event_center.on('delete', 'property', function(identifier, data, selector){
			_t.container.find('.content').find(selector).html(data.value); 
		}));

		_t.container.find(".editable[data-attribute='true']").data('identifier', {identifier: game_object.identifier, scope: null}); 

		_t.container.find( ".go-draghandle").each(function(idx, el){
			var _e = $(el);
			_e.data('identifier', {identifier: _e.attr('data-identifier'), scope: null}); 
		}).draggable({ 
			revert: true, 
			helper: "clone", 
			appendTo: "body", 
			zIndex: 1000, 
			start: function(){

			}});

		_t.container.find( ".gol-draghandle" ).draggable({ revert: true, helper: "clone", appendTo: "body", zIndex: 1000 });

		_t.container.find( ".go-droparea" ).droppable({ 
			accept: ".go-draghandle", 
			hoverClass: "go-droparea-active", 
			drop: function(){ console.log("Dropped")}  
		});

		_t.tabs 	= Object.create(window.game_objects_tabs).init(_t.container.find('.gameobject-tabs'));
		_t.editable = Object.create(window.editable).init(_t.container, ws_manager);

		return _t;
	}, 
	cleanup: function(callback){
		$.each(this._event_binds, function(idx, el){
			window.event_center.off(el); 
		});
		callback(); 
	}
});


window.workspaces = Object.create({
	_find_workspace: function(workspace){
		return $($('.workspace')[workspace - 1]);
	},

	addObject: function(data){
		var _t = this; 
		if(_t.opts.gameobject.creating){
			return;
		}else{
			_t.opts.gameobject.creating = true;
		}
		this._createObject(data).done(function(data){
			_t.opts.gameobject.creating = false;
			if(data.created){
				_t._choose_workspace().done(function(workspace){
					if(data.list){
						_t._render_list(workspace, data);				
					}else{
						_t._render_object(workspace, data);
					}
				});
			}
			// Do nothing if the user just closes the popin again!
		});
	},
	// Refactor this to something more clean after the demo!
	_createObject: function(data){
		var _t = this; 
		var deferred = $.Deferred(); 
		var tmpl = Liquid.parse($("#new_object_template").html()); 
		var dat = $(tmpl.render({class_name: data.name}));
		$("body").append(dat);
		var saveFunc = function(){
			var _name = dat.find('.game-object-name').val(); 
			if(_name.length == 0){
				alert("Name can't be empty!"); 
				return;
			}
			$.ajax({
				url: '/create',
				type: 'POST', 
				dataType: 'json', 
				data: {identifier: data.id, game_object: {name: _name}, authenticity_token: authToken()},
				success: function(response){
					deferred.resolve($.extend(response, {created: true})); 
					closeFunc();
				}, 
				error: function(){
					console.log(arguments);
				}
			})
		}
		var closeFunc = function(){
			$(window).off('.object_creation'); 
			dat.remove();
			_t.opts.gameobject.creating = false;
			deferred.resolve({created: false});
		}
		dat.find('.close').on('click', closeFunc);
		dat.find('.create-object-button').on('click', function(){
			saveFunc();
		});
		dat.find('.game-object-name').on('keydown', function(e){
			if(e.which == 13){
				e.preventDefault();
				saveFunc();
			}
		})
		$(window).on('keyup.object_creation', function(e){
			if(e.which == 27){
				closeFunc();
			}
		});

		return deferred.promise();
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

		_t._hookup_close_button(ws, Object.create(window.game_object).init(game_object, ws, this));
	},

	_render_list: function(workspace, gameobjects){ 
		var _t  = this;
		if(typeof(workspace) == "object"){
			var ws = workspace;
		}else{
			var ws  = _t._find_workspace(workspace);			
		}

		_t.occupy(ws);

		_t._hookup_close_button(ws, _t.render_game_objects_collection(ws, gameobjects));
	},

	_hookup_close_button: function(ws, object){
//				$(".work-spaces").on('click.creator', '.tools .icon.x',  this.empty_workspace.bind(this));
		var _t = this; 
		ws.find('.tools .icon.x').on('click', function(e){
			var _event = e; 
			var cleanup = function(){
				_t.empty_workspace.apply(_t, [_event]); 
			}
			object.cleanup(cleanup);
		});
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
		var obj = Object.create(window.game_objects_collection).init(gameobjects, tmpl, this, _t.opts['gameobjects_collection']);

		container.html(tmpl);
		return obj; 
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

	_setup_search: function(callback){
		var _t        = this;
		var container = $(_t.templates['game_objects_search'].render());

		$('body').append(container);

//		_t.search 	= Object.create(window.game_object_search).init(container, callback);
},
init: function(options){ 
	var _t           			= this;
	_t.workspaces	 			= [];
	_t.opts 					= {};
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

		_t.opts["gameobject"] = {
			creating: false
		}

		_t.opts['gameobjects_collection'] 	= {};

    	// Default options
    	_t.opts['gameobjects_collection']['objects_per_page'] 			= 5;
    	_t.opts['gameobjects_collection']['show_pagination_pages'] 		= 5;

    	// Add templates for future references
    	_t.templates 	= {};
    	_t.templates['game_object'] 							= Liquid.parse($('#game_object_template').html());
    	_t.templates['game_objects_collection_in_ws'] 			= Liquid.parse($('#game_objects_collection_in_ws_template').html());
    	_t.templates['game_objects_collection_pagination'] 		= Liquid.parse($('#game_objects_collection_pagination_template').html());
    	_t.templates['game_objects_collection_list'] 			= Liquid.parse($('#game_objects_collection_list_template').html());
    	_t.templates['game_objects_collection'] 				= Liquid.parse($('#game_objects_collection_template').html());
    	_t.templates['game_objects_search'] 					= Liquid.parse($('#game_objects_search_template').html());


    	_t._setup_search(function(identifier){ alert("It is me mario" + identifier)});

    	return _t;
    }
  });
