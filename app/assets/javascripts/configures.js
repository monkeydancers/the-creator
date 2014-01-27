//= require creator/jquery.miller
//= require creator/gameobject_class

//= require_self


var class_manager = null; 

// TODO:This should be integrated into the workspace manager /SR
function setupMiller(data){
	$('#miller').miller({
		'openLine' : function(node){ 
			class_manager.load_gameobject_class(node['info']['identifier']);
		},
		'tree': data,
		'toolbar': {
			'preRender' : function(current_node, path){
				
			}
		},

	});
}

$(document).ready(function() {
	class_manager = Object.create(window.gameobject_class_manager).init($('.configure-container'), $('#miller')  );
	$.ajax({
		url: '/create/structure', 
		type: 'get', 
		dataType: 'json', 
		success: function(data){
			setupMiller(data);
		}
	})	
	$("body").on('click.creator', '.popin .close',  function(){ $(this).parent('.popin').css({'display': 'none'})});
});
