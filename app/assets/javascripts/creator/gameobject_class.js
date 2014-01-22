window.gameobject_class = Object.create({
    _edit_property: function(data){
        var _t = this;
        console.log(data);


        _t.manager.render_property_popin(data);

        _t.container.find('.save-property-button').on('click.creator', function(e){
            console.log("save");
            console.log(data.identifier);
            _t.container.find('.popin .close').trigger('click');

        });

        _t.container.find('.delete-property-button').on('click.creator', function(e){
            console.log("delete");
            console.log(data.identifier);
            _t.container.find('.popin .close').trigger('click');
        }); 

    },
    _new_property: function(){
        var _t = this;

        _t.manager.render_property_popin({'name' : '',
                                          'dataype': '',
                                          'default' : '' });

    },
    _new_subclass: function(){
        var _t = this;

        _t.manager.render_new_class_popin({});

        _t.container.find('.create-subclass-button').on('click.creator', function(e){
            e.preventDefault();
            var form           = $(e.currentTarget).parents('form');
            var class_name     = form.find('.subclass-name').val();

            $.ajax({
                url: '/configure/new_class', 
                type: 'post', 
                dataType: 'json',
                data: { 'parrent_class_identifier'  : _t.identifier, 
                        'class_name'                : class_name,
                         'authenticity_token'       : authToken()}, 
                success: function(data){
                    console.log(data);
                    // This should perhaps be done in a template
                    _t.container.find('.subclasses-table tbody').append('<tr><td>' + data['name'] + '</td><td></td></tr>')

                    // Closes the popin
                    $('.popin .close').trigger('click');
                    // Update miller column datablock and trigger a reload of the current node

                }
            });                 
        });

    },


    _rename_class: function(){

    },
   init: function(container, identifier, manager){ 
        var _t = this;

        _t.identifier       = identifier;
        _t.container        = container;
        _t.manager          = manager;

        $('.add-subclass-button').on('click.creator', function(){
            _t._new_subclass();
        });

        $('.add-property-button').on('click.creator', function(){
            _t._new_property();
        });

        $('.edit_propery_link').on('click.creator', function(e){
            
            var elm = $(e.currentTarget).parent('.action').parent('tr');

            _t._edit_property({ 'identifier' : elm.data('identifier'),
                                'name' : elm.find('td:first-child').text(),
                               'default' : elm.find('.default-value').text(),
                               'datatype' : elm.find('.data-type').text(), });
            e.preventDefault();
        });



        return _t;
    }
});

window.gameobject_class_manager = Object.create({
    render_gameobject_class: function(data){
        var _t              = this;

        _t.container.html(_t.templates['gameobject_class'].render(data));
        _t.open_class = Object.create(window.gameobject_class).init(_t.container, data['identifier'], _t);
    },
    render_new_class_popin: function(data){
        var _t              = this;

        _t.container.append(_t.templates['new_subclass_popin'].render(data));
    },
    render_property_popin: function(data){
        var _t              = this;

        _t.container.append(_t.templates['property_popin'].render(data));
    },

    init: function(container){ 
    	var _t            	= this;
    	_t.container 		= container;
        _t.open_class       = null;
        _t.templates        = [];

        _t.templates['gameobject_class']    = Liquid.parse($('#gameobject_class_template').html());
        _t.templates['new_subclass_popin']  = Liquid.parse($('#new_subclass_template').html());
        _t.templates['property_popin']      = Liquid.parse($('#new_property_template').html())

        return _t;
    }	
  });
