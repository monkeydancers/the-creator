$(function(){
	$.ajax({
		url: '/api/v1/game_objects', 
		type: 'GET', 
		data: {
			key: "d0d9a2141512a21d25dc29cca094915745dd4aa9", 
			scope: "0f0ecce"
		}, 
		dataType: 'json', 
		success: function(data){
			
		}
	})
});