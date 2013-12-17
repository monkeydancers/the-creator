//= require creator/jquery.miller
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

$(document).ready(function() {
		$('#miller').miller({
				'useAjax' : false,
				'tree': tree,
				'toolbar': {
					'preRender' : function(current_node, path){

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
);
