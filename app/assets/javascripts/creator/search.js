window.game_object_search = Object.create({
	_do_search: function(search_string){
		var _t = this;

		// Ajax here
		var res = {'game_objects_list' : [
			{'name': "obj 1",
			'class_name' : "detektiv",
			'identifier' : '32094i'},
			{'name': "obj 2",
			'identifier' : '33094i'},
			{'name': "obj 3",
			'class_name' : "fetto",
			'identifier' : '35094i'}
		]};

		_t._show_search_results(res);
	},
	_show_search_results: function(res){
		var _t = this;

		_t.selected_index   = 0;

		_t.objects_in_result = res['game_objects_list'].length;

		for(var i = 0; i < res['game_objects_list'].length; i++){
			res['game_objects_list'][i]['no_checkbox'] = true;
		}


		var html = $(_t.templates['game_objects_collection_list'].render(res));


		_t.res_container.html(html);
		_t.res_container.find('tr').on('click.creator', function(e){
			_t.callback($(e.currentTarget).data('identifier'));
		});
	},
	_prepare_search: function(search_string){
		var _t = this;
		if(_t.ajax_timer){
			clearTimeout(_t.ajax_timer);
	    }
	    _t.ajax_timer = setTimeout(function() {
	    	_t._do_search(search_string);
	    	_t.ajax_timer = null;
	    }, 400);
	},
	init: function(container, callback){
		var _t 				= this;
		_t.ajax_timer  		= null;
		_t.container 		= container;
		_t.callback 		= callback;
		_t.focus 			= false;
		_t.res_container 	=  _t.container.find('.gol-table');

		_t.templates 		= [];
    	_t.templates['game_objects_collection_list'] 			= Liquid.parse($('#game_objects_collection_list_template').html());

    	_t.selected_index   	= 0;
    	_t.objects_in_result 	= 0;

		// Add search timer
	    _t.container.find('.search-field').on('focus.creator', function(e){ 
	    	_t.focus = true
			var search_string   = e.target.value;
			var elm             = $(e.target);
			var default_string  = elm.prop('placeholder');
			if(search_string == default_string){
				elm.val('');
			}
	    });
	    _t.container.find('.search-field').on('blur.creator', function(e){ 
	      _t.focus = false;
	      var search_string   = e.target.value;
	      var elm             = $(e.target);

	      if(search_string == ''){
	        elm.val(elm.prop('placeholder'));
	        _t._do_search('');
	      }
	    });
	   	_t.container.find('.search-field').on('keydown.creator', function(e){ 
	   		switch(e.keyCode){
	   			case 38: 
	   				if(_t.selected_index > 1){
	   					_t.selected_index--;
	   				} else {
	   					_t.selected_index = _t.objects_in_result ;
	   				}
		   			break;
	   			case 40:
		   			if(_t.selected_index >= _t.objects_in_result){
	   					_t.selected_index = 0;
		   			}
   					_t.selected_index++;
		   			break;
	   			case 13:
	   				_t.callback(_t.res_container.find("tr:nth-child(" + _t.selected_index + ")").data('identifier'));
		   			break;
	   			default: 
					return;
					break;
	   		}

	   		_t.res_container.find("tr").removeClass('selected');
			_t.res_container.find("tr:nth-child("+ _t.selected_index + ")").addClass('selected');
			e.preventDefault();
			e.stopPropagation();
		});	

	   	_t.container.find('.search-field').on('keyup.creator', function(e){ 
	   		if(e.keyCode == 38 || e.keyCode == 40 || e.keyCode == 12){
				e.preventDefault();
				e.stopPropagation()
				return;
	   		}
			_t._prepare_search(e.target.value);
		});

	    
	}	

});



