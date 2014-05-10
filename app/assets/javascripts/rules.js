//= require libraries/src-min/ace


// Add rule interactions here...

$(document).ready(function(){
	window.rule_editor = makeEditor();
	window.rule_editor.makeList();

	$(window.rule_editor).on('loading', function(){

	});

	$(window.rule_editor).on('complete', function(){

	})

})

function makeEditor(){
	var _rule_editor = {
		new: function(el, editor_el){
			var _t = this; 
			this.editor_el = editor_el;
			this.container = el; 
			$(document).on('click', '.rule_row', function(e){
				var _r = $(e.currentTarget); 
				_t.loadRule.apply(_t, [_r.attr('data-rule-base-url')]); 
			});
			// this.container.find('.rule_row').on('click', function(e){
			// 	var _r = $(e.currentTarget); 
			// 	_t.loadRule.apply(_t, [_r.attr('data-rule-base-url')]); 
			// });
			
			this.container.find('.tools .plus').on('click', function(e){
				var _p = $(_t.add_popin_template.render());
				_t.container.append(_p); 
				_p.find('.close').on('click', function(){
					_t.closePopin.apply(_t);
				});
				_p.find('form').on('submit', function(e){
					e.preventDefault();
					_t.addRule({
						name: _p.find('.name-field').val()
					}); 
				}); 
				_p.find('input').focus();
			});


			this.editorOpen 	= false; 
			this.rule_row_template 		= Liquid.parse($('#rule-row-template').html());
			this.add_popin_template		= Liquid.parse($('#rule-popin').html()); 
			this.editor_template 			= Liquid.parse($('#editor-template').html());
			return this; 
		}, 
		makeList: function(){
			var _t = this; 
			$.ajax({
				url:'/rules', 
				type: 'get', 
				dataType: 'json', 
				success: function(data){
					$.each(data.rules, function(idx, rule){
						_t.container.find('.gol-table tbody').append(_t.rule_row_template.render(rule));
					});
				}, 
				error: function(){
					console.log(arguments);
				}
			})
		},
		addRule: function(data){
			var _t = this; 
			$.ajax({
				url: '/rules',
				type: 'POST', 
				data: {rule: data, authenticity_token: authToken()}, 
				dataType: 'json', 
				success: function(data){
					_t.closePopin();
					_t.container.find('.gol-table tbody').append(_t.rule_row_template.render(data.rule)); 
				}, 
				error: function(){
					console.log(arguments); 
				}
			});
		},
		closePopin: function(){
			this.container.find('.popin').remove();
		},
		loadRule: function(rule_url){
			var _t = this;
			$(this).trigger('loading'); 
			$.ajax({
				url: rule_url, 
				dataType: 'json', 
				type: 'GET', 
				success: function(data){
					$(_t).trigger('complete'); 
					_t.current_rule = rule_url;
					_t._renderEditor.apply(_t, [data.rule]);
				}, 
				error: function(data){
					$(_t).trigger('complete');
					// Post errors here...
				}
			});
		}, 
		close: function(){
			this.stopAutosave();
			this.editor.destroy();
			this.editor_el.find('#editor-injection-point').empty(); 
			this.editor_el.find('.empty-editor-notice').show();
			this.editorOpen = false;
		},
		startAutosave: function(){
			// Here - add hooks to disable autosaving when the entire browser window
			// is blurred.
			var _t  = this; 
			this.savingInterval = setInterval(function(){
//				_t._save();
			}, 10000); 
		},
		stopAutosave: function(){
			clearInterval(this.savingInterval);
		},
		searchForFilter: function(e){
			var _t = this;
			var el = $(e.currentTarget); 
			var query = window.search.search({scope: 'GameObjectClass'}); 
			var payload = {}
			query.done(function(object){
				payload[el.attr('data-attr')] = object.identifier;
				$.ajax({
					url: _t.current_rule, 
					data: {rule: payload, authenticity_token:authToken(), _method: 'PUT'}, 
					type: 'post',
					dataType: 'json', 
					success: function(data){
						console.log(data);
						if(!data.error){
							el.html(data.rule[el.attr('data-attr')]);
						}else{
							console.log("error");
						}
					}, 
					error: function(){
						console.log("error..."); 
					}
				})
			});
			query.fail(function(){
				// Perhaps do nothing here? 
			});
		},
		_renderEditor: function(rule_def){
			var _t = this; 
			var _o = $(this.editor_template.render(rule_def)); 
			if(_t.editorOpen){
				_t.close();
			}
			this.editor_el.find('.empty-editor-notice').hide(); 			
			this.editor_el.find('#editor-injection-point').append(_o); 
			_o.find('.icon').on('click', function(){_t.close.apply(_t)});
			this.help_text 	= this.editor_el.find('.rule-editor-help'); 
			this.editor = ace.edit("rule-editor");
			this.editor.setTheme("ace/theme/monokai");
			this.editor.renderer.setScrollMargin(15, 15, 0, 0);
			this.editor.getSession().setMode("ace/mode/javascript");
			this.editor.focus();
			this.editor.on('blur', function(){
				_t._save.apply(_t);
			});
			this.editor_el.find('.filter-trigger').on('click', this.searchForFilter.bind(this)); 
			this.editorOpen = true;
			this.startAutosave(); 
		}, 
		_save: function(){
			var _t = this; 
			this.help_text.html('Saving...'); 
			$.ajax({
				url: this.current_rule, 
				data: {authenticity_token: authToken(), rule: {rule_code: this.editor.getValue()}, _method: 'PUT'} , 
				type: 'POST',
				dataType: 'json', 
				success: function(){
					_t.help_text.html('Saved!'); 
					setTimeout(function(){
						_t.help_text.html("");
					}, 4000); 
				}, 
				error: function(){
					// Here - stagger save and post an error!
				}
			})
		}
	}; 

	return Object.create(_rule_editor).new($(".rule-list-section"), $(".rule-editor-section")); 
}
