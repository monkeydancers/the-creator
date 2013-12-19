//= require creator/jquery.miller
//= require creator/gameobject

//= require_self


var workspace_manager;

// TODO:This should be integrated into the workspace manager /SR
function setupMiller(data){
	$('#miller').miller({
		'openLine' : function(line){ console.log("Hepp")},
		'tree': data,
		'toolbar': {
			'preRender' : function(current_node, path){
				if(current_node){
					var objects = $('<span class="gol-draghandle num-of-object-in-selected-class gameobject-list-counter ">' + current_node['info']['objects'] + ' Objects</span>');
					var new_button = $('<a href="#" class="new_object_button" data-identifier="' + current_node['info']['identifier'] + '"> - New Object</a>');
					path.append(objects);
					path.append(new_button);
					objects.draggable({
						revert: true, 
						helper: "clone", 
						appendTo: "body", 
						zIndex: 1000 
					});
					objects.data('identifier', current_node.info.identifier);
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
}

$(document).ready(function() {

		$.ajax({
			url: '/create/structure', 
			type: 'get', 
			dataType: 'json', 
			success: function(data){
				setupMiller(data);
			}
		})

		// Close button on all popin
		$("body").on('click.creator', '.popin .close',  function(){ 
			console.log("close");
			$(this).parent('.popin').css({'display': 'none'});
		});
		
		// Add new object
		$('body').on('click.creator', '.new_object_button', function(e){
			console.log(e.currentTarget);
			e.preventDefault();
		})

		// Close a workspace object 
		$(".work-spaces").on('click.creator', '.tools .icon.x',  function(){ console.log($(this).parent('.workspace'));$(this).parents('.workspace').html(' ').removeClass('occupied')});

		workspace_manager = Object.create(window.workspaces).init();

/*
		 This is just functionallity test
		
		 workspace_manager._open_game_object(1, 
		 {
		 	'class_path': 'Robots / C3PO', 
		 	'name' : 'Name of game object that is really long', 
		 	'identifier' : '7777777', 
		 	'properties': [
		 		{'name': 'ninjor', 'current_value' : '0', 'default_value': '2', 'type' : 'integer'}, 
		 		{'name': 'minions', 'current_value' : '10', 'default_value': '0', 'type' : 'integer'}, 
		 		{
		 			'name': 'tomtar', 
		 			'current_value' : '125 objects', 
		 			'default_value': 'empty', 
		 			'type' : 'objects', 
		 			'id' : '123'} 
		 		], 
		 		'description' : 'Praesent commodo cursus magna, vel scelerisque 
		 		nisl consectetur et. Maecenas faucibus mollis interdum. Aenean 
		 		eu leo quam. Pellentesque ornare sem lacinia quam venenatis 
		 		vestibulum. Nullam id dolor id nibh ultricies vehicula ut id 
		 		elit. Etiam porta sem malesuada magna mollis euismod.', 
		 		'image_url': ''
		 })
		 workspace_manager._open_game_object(3, { 'class_path': 'Robots / R2D2', 'name' : 'Min get', 'identifier' : '6666', 'properties': [{'name': 'styrkan', 'current_value' : 'etsy', 'default_value': 'nope', 'type' : 'string'}, {'name': 'glädje', 'current_value' : '1', 'default_value': '0', 'type' : 'integer'} ], 'description' : 'loremipsum', 'image_url': ''})
		 workspace_manager._open_game_objects_collection(2, 
		 {
		 	'identifier' : '23gf33', 
		 	'num_game_objects' : 120, 
		 	'objects_per_page' : 5, 
		 	'game_objects_list': [
		 		{'name' : 'objekt 1', 'identifier' : '123'}, 
		 		{'name' : 'objekt 2', 'identifier' : '1234'}
		 	] 
		 });

*/

	}
	);
