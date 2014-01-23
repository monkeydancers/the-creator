window.gameobject_class = Object.create({
    _edit_property: function(data){
        var _t = this;
        
        _t.manager.render_property_popin(data);
        var popin = _t.container.find('.popin');

        popin.find('.property-datatype-field').attr('disabled', true);

        // Add button interactions
        popin.find('.save-property-button').on('click.creator', function(e){

            $.ajax({
                url: '/configure/update_property', 
                type: 'post', 
                dataType: 'json',
                data: { 'parrent_class_identifier'  : _t.identifier, 
                        'property_identifier'       : "",
                        'property_name'             : "",
                        'property_default'          : "",
                         'authenticity_token'       : authToken()}, 
                success: function(data){
                    console.log(data);
                    // This should update the GUI aswell.
                    popin.find('.close').trigger('click');
                }
            });               



        });

        popin.find('.delete-property-button').on('click.creator', function(e){
            console.log("delete");
            console.log(data.identifier);
            popin.find('.close').trigger('click');

            $.ajax({
                url: '/configure/delete_property', 
                type: 'post', 
                dataType: 'json',
                data: { 'parrent_class_identifier'  : _t.identifier, 
                        'property_identifier'       : "",
                         'authenticity_token'       : authToken()}, 
                success: function(data){
                    console.log(data);
                    // This should update the GUI aswell.
                    popin.find('.close').trigger('click');
                }
            });  

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
                    _t.container.find('.empty-subclasses-placeholder').css('display', 'none');
                    // This should perhaps be done in a template
                    _t.manager.render_gameobject_subclass_row(data);

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

        _t.container.on('click.creator', '.show-subclass-link',  function(e){
            e.preventDefault();
            var identifier = $(e.currentTarget).parents('tr').data('identifier');
            _t.manager.load_gameobject_class(identifier);
            $('#miller').miller('select_node' , identifier);
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

    load_gameobject_class: function(identifier){
        $.ajax({
            url: '/configure/class_info', 
            type: 'get', 
            dataType: 'json',
            data: {'identifier' : identifier}, 
            success: function(data){
                class_manager.render_gameobject_class(data);
            }
        });     
    },
    render_gameobject_class: function(data){
        var _t              = this;

        _t.container.html(_t.templates['gameobject_class'].render(data));
        _t.open_class = Object.create(window.gameobject_class).init(_t.container, data['identifier'], _t);
    },
    render_gameobject_subclass_row: function(data){
        var _t              = this;

        console.log(data);
        if(_t.open_class){
            return _t.container.find('.subclasses-table tbody').append(_t.templates['gameobject_class_row'].render({'subclass' : data}));
        } else {
            return false
        }
        
    },
    render_new_class_popin: function(data){
        var _t              = this;

        _t.container.append(_t.templates['new_subclass_popin'].render(data));
    },
    render_property_popin: function(data){
        var _t              = this;

        var popin = _t.templates['property_popin'].render(data)
        _t.container.append(popin);
        return popin;
    },

    init: function(container){ 
    	var _t            	= this;
    	_t.container 		= container;
        _t.open_class       = null;
        _t.templates        = [];

        _t.templates['gameobject_class']        = Liquid.parse($('#gameobject_class_template').html());
        _t.templates['gameobject_class_row']    = Liquid.parse($('#gameobject_class_row_template').html()); 
        _t.templates['new_subclass_popin']      = Liquid.parse($('#new_subclass_template').html());
        _t.templates['property_popin']          = Liquid.parse($('#new_property_template').html())

        return _t;
    }	
  });
