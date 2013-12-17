//= require creator/jquery.miller
//= require creator/gameobject

//= require_self

var tree = [
	{ 'id': 1, 'name': 'Anakin', 'info' : {'objects': 31}, 'children' : [  
		{ 'id': 6, 'name': 'Luc', 'info' : {'objects': 32}, 'children': null, },
		{ 'id': 7, 'name': 'Leia', 'info' : {'objects': 33}, 'children': [
			{ 'id': 11, 'name': 'Leia Junior', 'info' : {'objects': 34}, 'children': null  },
			{ 'id': 12, 'name': 'Chewleia', 'info' : {'objects': 35}, 'children': null  },
			{ 'id': 13, 'name': 'Han Polo', 'info' : {'objects': 36}, 'children': null  },
			] },
		],
	},
	{ 'id': 2, 'info' : {'objects': 320}, 'name': 'Robots', 'children' : [
		{ 'id': 3, 'name': 'C3PO', 'info' : {'objects': 37}, 'children': null   },
		{ 'id': 4, 'name': 'R2D2', 'info' : {'objects': 38}, 'children': null   },
		{ 'id': 5, 'name': 'C3PO 2', 'info' : {'objects': 39}, 'children': null   },
		{ 'id': 66, 'name': 'R2D2 2', 'info' : {'objects': 40}, 'children': null   },

		{ 'id': 77, 'name': 'C3PO 3', 'info' : {'objects': 41}, 'children': null   },
		{ 'id': 8, 'name': 'R2D2 3', 'info' : {'objects': 42}, 'children': null   },
		{ 'id': 9, 'name': 'C3PO 4', 'info' : {'objects': 43}, 'children': null   },
		{ 'id': 10, 'name': 'R2D2 4', 'info' : {'objects': 44}, 'children': null   },
		]
	 },
];

var workspace_manager;

$(document).ready(function() {
		$('#miller').miller({
				'useAjax' : false,
				'tree': tree,
				'toolbar': {
					'preRender' : function(current_node, path){
						if(current_node){
							var objects = $('<span class="gol-draghandle num-of-object-in-selected-class gameobject-list-counter ">' + current_node['info']['objects'] + ' Objects</span>');
							path.append(objects);
							objects.draggable({ revert: true, helper: "clone", appendTo: "body", zIndex: 1000 });


						}
 					},
					'options': {
						'Select': function(id) { alert('Select node or leaf ' + id); },
						'Show all ': function(id) { alert('Quickview on node or leaf ' + id); }
					}
				},
				'pane': {
					'options': {
						'Add': function(id) { alert('Add to leaf ' + id); },
						'Update': function(id) { alert('Update leaf ' + id); },
						'Delete': function(id) { alert('Delete leaf ' + id); }
					}
				}
			}
		);


		// Initialize game objects

		$( ".go-droparea" ).droppable({ accept: ".go-draghandle", hoverClass: "go-droparea-active", drop: function(){ console.log("Dropped")}  });


		// Close button on all popin
		$("body").on('click.creator', '.popin .close',  function(){ console.log("close");$(this).parent('.popin').css({'display': 'none'})});
		
		// Close a workspace object 
		$(".work-spaces").on('click.creator', '.tools .icon.x',  function(){ console.log($(this).parent('.workspace'));$(this).parents('.workspace').html(' ').removeClass('occupied')});


		// Editable HACK
		$(".work-spaces").on('click.creator', '.editable',  function(){ console.log("EDIT");});



		workspace_manager = Object.create(window.workspaces).init();

		// This is just functionallity test
		// workspace_manager._open_game_object(1, {'class_path': 'Robots / C3PO', 'name' : 'Name of game object that is really long', 'identifier' : '7777777', 'properties': [{'name': 'ninjor', 'current_value' : '0', 'default_value': '2', 'type' : 'integer'}, {'name': 'minions', 'current_value' : '10', 'default_value': '0', 'type' : 'integer'}, {'name': 'tomtar', 'current_value' : '125 objects', 'default_value': 'empty', 'type' : 'objects', 'id' : '123'} ], 'description' : 'Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Maecenas faucibus mollis interdum. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Nullam id dolor id nibh ultricies vehicula ut id elit. Etiam porta sem malesuada magna mollis euismod.', 'image_url': ''})
		// workspace_manager._open_game_object(3, { 'class_path': 'Robots / R2D2', 'name' : 'Min get', 'identifier' : '6666', 'properties': [{'name': 'styrkan', 'current_value' : 'etsy', 'default_value': 'nope', 'type' : 'string'}, {'name': 'glädje', 'current_value' : '1', 'default_value': '0', 'type' : 'integer'} ], 'description' : 'loremipsum', 'image_url': ''})
		// workspace_manager._open_game_objects_collection(2, {'identifier' : '23gf33', 'num_game_objects' : 120, 'objects_per_page' : 5, 'game_objects_list': [{'name' : 'objekt 1', 'identifier' : '123'}, {'name' : 'objekt 2', 'identifier' : '1234'}] });
	}
);
