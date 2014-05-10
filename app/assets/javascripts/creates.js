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
					new_button.on('click', function(e){
						e.preventDefault();
						workspace_manager.addObject(current_node);
					});
					path.append(objects);
					path.append(new_button);
					objects.draggable({
						revert: true, 
						helper: "clone", 
						appendTo: "body", 
						zIndex: 1000 
					});
					objects.data('identifier', {identifier: current_node.info.identifier, scope: null});
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
		
		// // Add new object
		// $('body').on('click.creator', '.new_object_button', function(e){
		// 	e.preventDefault();
		// 	var tmpl = Liquid.parse($("#new_object_template").html()); 
		// 	console.log(tmpl.render());
		// })

		var ws = new WebSocket("ws://"+$("meta[name=host]").attr("content")+":4000?game="+gameKey()); 
		ws.onmessage = function(e){
			console.log(e);
			if(e.data.length > 0){
				$(document).trigger('update.property', [JSON.parse(e.data)]);				
			}
		}

		workspace_manager = Object.create(window.workspaces).init();
});
