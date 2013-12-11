//= require jquery-ui
//= require jquery.miller
//= require liquid.min
//= require gameobject
//= require_self




var tree = [
	{ "id": 1, "name": "Anakin", "children" : [  
		{ "id": 6, "name": "Luc", "children": null, "parent": false  },
		{ "id": 7, "name": "Leia", "children": [
			{ "id": 11, "name": "Leia Junior", "children": null, "parent": false  },
			{ "id": 12, "name": "Chewleia", "children": null, "parent": false  },
			{ "id": 13, "name": "Han Polo", "children": null, "parent": false  },
			], "parent": true  },
		], "parent": true 
	},
	{ "id": 2, "name": "Robots", "children" : [
		{ "id": 3, "name": "C3PO", "children": null, "parent": false   },
		{ "id": 4, "name": "R2D2", "children": null, "parent": false   },
		], "parent": true
	 },
];

var workspace_manager;

$(document).ready(function() {
		$('#miller').miller({
				'useAjax' : false,
				'tree': tree,
				'toolbar': {
					'options': {
						'Select': function(id) { alert('Select node or leaf ' + id); },
						'Quickview': function(id) { alert('Quickview on node or leaf ' + id); }
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
		$( ".go-draghandle" ).draggable({ revert: true, helper: "clone", appendTo: "body" });
		$( ".go-draghandles" ).draggable({ revert: true, helper: "clone", appendTo: "body" });
		$( ".go-droparea" ).droppable({ accept: ".go-draghandle", hoverClass: "go-droparea-active", drop: function(){ console.log("Dropped")}  });


		// Close button on all popin
		$("body").on('click.creator', '.popin .close',  function(){ console.log("close");$(this).parent('.popin').css({'display': 'none'})});
		
		// Close a workspace object 
		$(".work-spaces").on('click.creator', '.tools .icon.x',  function(){ console.log($(this).parent('.workspace'));$(this).parents('.workspace').html(' ').removeClass('occupied')});


		// Editable HACK
		$(".work-spaces").on('click.creator', '.editable',  function(){ console.log("EDIT");});



		workspace_manager = Object.create(window.workspaces).init();

		// This is just functionallity test
		workspace_manager._open_game_object(1, {'name' : 'Name of game object that is really long', 'identifier' : '7777777', 'properties': [{'name': 'ninjor', 'current_value' : '0', 'default_value': '2'}, {'name': 'tomtar', 'current_value' : '10', 'default_value': '0'} ], 'description' : 'Praesent commodo cursus magna, vel scelerisque nisl consectetur et. Maecenas faucibus mollis interdum. Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum. Nullam id dolor id nibh ultricies vehicula ut id elit. Etiam porta sem malesuada magna mollis euismod.', 'image_url': ''})
		workspace_manager._open_game_object(3, {'name' : 'Min get', 'identifier' : '6666', 'properties': [{'name': 'styrkan', 'current_value' : 'etsy', 'default_value': 'nope'}, {'name': 'glädje', 'current_value' : '1', 'default_value': '0'} ], 'description' : 'loremipsum', 'image_url': ''})
		workspace_manager._open_game_objects_collection(2, {'num_game_objects' : 13, 'game_objects_list': [{'name' : 'objekt 1', 'identifier' : '123'}, {'name' : 'objekt 2', 'identifier' : '1234'}] });
	}
);
