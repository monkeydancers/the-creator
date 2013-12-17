//= require creator/jquery.miller
//= require creator/gameobject_class

//= require_self


var tree = [
	{ 'id': 1, 'name': 'Anakin', 'info' : {'objects': 31}, 'children' : [  
		{ 'id': 6, 'name': 'Luc', 'info' : {'objects': 32}, 'children': null, 'parent': false  },
		{ 'id': 7, 'name': 'Leia', 'info' : {'objects': 33}, 'children': [
			{ 'id': 11, 'name': 'Leia Junior', 'info' : {'objects': 34}, 'children': null, 'parent': false  },
			{ 'id': 12, 'name': 'Chewleia', 'info' : {'objects': 35}, 'children': null, 'parent': false  },
			{ 'id': 13, 'name': 'Han Polo', 'info' : {'objects': 36}, 'children': null, 'parent': false  },
			], 'parent': true  },
		], 'parent': true 
	},
	{ 'id': 2, 'info' : {'objects': 320}, 'name': 'Robots', 'children' : [
		{ 'id': 3, 'name': 'C3PO', 'info' : {'objects': 37}, 'children': null, 'parent': false   },
		{ 'id': 4, 'name': 'R2D2', 'info' : {'objects': 38}, 'children': null, 'parent': false   },
		{ 'id': 5, 'name': 'C3PO 2', 'info' : {'objects': 39}, 'children': null, 'parent': false   },
		{ 'id': 66, 'name': 'R2D2 2', 'info' : {'objects': 40}, 'children': null, 'parent': false   },

		{ 'id': 77, 'name': 'C3PO 3', 'info' : {'objects': 41}, 'children': null, 'parent': false   },
		{ 'id': 8, 'name': 'R2D2 3', 'info' : {'objects': 42}, 'children': null, 'parent': false   },
		{ 'id': 9, 'name': 'C3PO 4', 'info' : {'objects': 43}, 'children': null, 'parent': false   },
		{ 'id': 10, 'name': 'R2D2 4', 'info' : {'objects': 44}, 'children': null, 'parent': false   },
		], 'parent': true
	 },
];

var class_manager = null; 


$(document).ready(function() {
		console.log(window.gameobject_class_manager);
		class_manager = Object.create(window.gameobject_class_manager).init($('.configure-container') );



		$('#miller').miller({
				'tree': tree,
				'openLine' : function(node){
					// Call ajax with node['info']['identifier']
					var class_definition = {'name' : node.name}
					class_manager.render_gameobject_class(class_definition);
				},
			}
		);

		$("body").on('click.creator', '.popin .close',  function(){ $(this).parent('.popin').css({'display': 'none'})});


	}
);
