//= require creator/jquery.miller
//= require creator/gameobject_class

//= require_self


$(document).ready(function() {
	class_manager = Object.create(window.gameobject_class_manager).init($('.configure-container'), $('#miller')  );

	$("body").on('click.creator', '.popin .close',  function(){ $(this).parent('.popin').css({'display': 'none'})});
});
