//= require libraries/src-min/ace


// Add rule interactions here...

$(document).ready(function(){
	window.rule_editor = makeEditor();

	$(window.rule_editor).on('loading', function(){
		console.log("monkey");
	});

	$(window.rule_editor).on('complete', function(){
		console.log("donkey");
	})

})

function makeEditor(){
	var _rule_editor = {
		new: function(el, editor_el){
			var _t = this; 
			this.editor_el = editor_el;
			this.container = el; 
			this.container.find('.rule_row').on('click', function(e){
				var _r = $(e.currentTarget); 
				_t.loadRule.apply(_t, [_r.attr('data-rule-base-url')]); 
			});
			this.editor_template = Liquid.parse($('#editor-template').html());
			return this; 
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
		},
		startAutosave: function(){
			var _t  = this; 
			this.savingInterval = setInterval(function(){
				_t._save();
			}, 10000); 
		},
		stopAutosave: function(){
			clearInterval(this.savingInterval);
		},
		_renderEditor: function(rule_def){
			var _t = this; 
			var _o = $(this.editor_template.render(rule_def)); 
			this.editor_el.find('.empty-editor-notice').hide(); 			
			this.editor_el.find('#editor-injection-point').append(_o); 
			_o.find('.icon').on('click', function(){_t.close.apply(_t)});
			this.help_text 	= this.editor_el.find('.rule-editor-help'); 
			this.editor = ace.edit("rule-editor");
			this.editor.setTheme("ace/theme/monokai");
			this.editor.getSession().setMode("ace/mode/javascript");
			this.editor.focus();
			this.editor.on('blur', function(){
				_t._save.apply(_t);
			});
			this.startAutosave(); 
		}, 
		_save: function(){
			console.log("running save...");
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
