(function(w){

	var search_prototype = {
		initialize: function(){			
			this.el 		= $("#search-box"); 
			this.res 		= Liquid.parse("<li><h3>{{name}}</h3><h5>{{type}}</h5></li>")
			this.el.on('webkitAnimationEnd mozAnimationEnd MSAnimationEnd oanimationend animationend', this._cleanup.bind(this)); 
			this.current_index = 0; 
			this.el.find('input').on('keydown', function(e){
				if(e.which == 38 || e.which == 40){
					e.preventDefault(); 
					return false;
				}
			});
			return this; 
		}, 
		search: function(options){
			this.open(); 
			this.opts = $.extend({
				onSelect: $empty, 
				onAbort: $empty
			}, options);
			this.el.find('input').bind('keyup', this._perform.bind(this)).focus();
			this.deferred = $.Deferred();
			return this.deferred.promise();
		}, 
		open: function(skipAnimation){
			if(skipAnimation){
				this.el.css('display', 'block'); 
			}else{
				this.el.css({display: 'block', 'opacity': 0}).addClass('fadeInDown'); 
			}
			key('esc', this.hide.bind(this)); 
		},
		hide: function(skipAnimation){
			// Here, unregister keys and stuff...
			key.unbind('esc');
			this.deferred = null;
			this.current_index = 0; 
			if(skipAnimation){
				this.el.css('display', 'none'); 
			}else{
				this.el.addClass('fadeOutUp');
			}
		}, 
		_nav: function(kc){
			if(kc === 38){
				this.el.find('.selected').removeClass('selected'); 
				var idx = (this.current_index-1) < 0 ? this.el.find('li').length-1 : this.current_index -1; 
				this.current_index = idx; 
				this.el.find('li').eq(idx).addClass('selected'); 
			}else if(kc === 40){
				this.el.find('.selected').removeClass('selected'); 
				var idx = (this.current_index+1) > this.el.find('li').length-1 ? 0 : this.current_index + 1; 
				this.current_index = idx; 
				this.el.find('li').eq(idx).addClass('selected'); 
			}else if(kc === 13){
				this.opts.onSelect(this.el.find('.selected').data('res')); 
				if(this.deferred){
					this.deferred.resolve(this.el.find('.selected').data('res')); 
				}
				this.hide(); 
			}else if(kc === 27){
				this.ops.onAbort();
				if(this.deferred){
					this.deferred.reject(); 
				}
				this.hide();
			}else{
				console.log("unknown keycode - abort nav"); 
			}
		},
		_cleanup: function(){
			if(this.el.hasClass('fadeInDown')){
				this.el.css({opacity:1, display:'block'}); 
				this.el.removeClass('fadeInDown'); 
			}else{
				this.el.css({opacity:0, display: 'none'}); 
				this.el.removeClass('fadeOutUp'); 
			}
		}, 
		_perform: function(e){
			if([38,40,27,13].indexOf(e.which) > -1){
				e.preventDefault(); 
				this._nav(e.which); 
			}

			if(this.request){
				this.request.abort(); 
			}
			this.request = $.ajax({url: '/search', dataType: 'json', type: 'post', data: {
				authenticity_token: authToken(), 
				scope: this.opts.scope, 			
				query: {
					strict: this.opts.strict, 
					query: this.el.find('input').val()
				}
			}}); 
			this.request.done(this._resultsReceived.bind(this)); 
			this.request.fail(this._resultsError.bind(this)); 
		}, 
		_resultsReceived: function(data){
			key.setScope('results');
			var l = this.el.find('ul'); 
			l.empty(); 
			var _t = this; 
			$.each(data.results, function(idx, el){
				var k = $(_t.res.render(el)); 
				k.data('res', el);
				l.append(k); 
			});
			l.find('li').eq(this.current_index).addClass('selected');
		},
		_resultsError: function(){
			// Hook error into this here!
			console.log(arguments); 
		}
	}

	window.search = Object.create(search_prototype).initialize(); 

})(window); 