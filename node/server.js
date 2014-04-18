var redis 					= require('redis'); 
var _								= require('underscore'); 
var WebSocket 			= require('ws'); 
var config 					= require('./config'); 
var sys 						= require('util');
var url 						= require('url'); 
config 							= config.environments[(process.env.NODE_ENVIRONMENT || 'development')]

// Setup a WebSocket-server
var wss = new WebSocket.Server({port: 4000});

wss.on('connection', function(ws){
	// Clients connect using the format ws://HOST/PATH?game=GAME_API_KEY
	// Parse out the game-api-key and use it as the pipeline-separator in
	// order to allow multiplexing messages over the redis-channel
	var reqURL 		= ws.upgradeReq.url;
	var data 			= url.parse(reqURL, true); 

	// Create a redis-client. Use multiple clients since Redis doesn't allow
	// a client to send any other messages once it's subscribed. In future, 
	// change this to one client, using multiple channels instead. .daniel
	var client 		= redis.createClient(); 
	client.on('message', function(channel, message){
		// Just pass the message along to the GUI, and let it update the proper stuff!
		ws.send(message);
	})

	// Set up a basic message-catcher for obvious error-managing, since the server doesn't
	// allow incoming messages.
	ws.on('message', function(message){
		ws.send({error: true, message: "This server does not accept messages."});			
	});

	// Subscribe the Redis-client to the proper message-pipeline
	client.subscribe('rule-pipeline-'+data.query.game); 

	// Acknowledge the connection
	ws.send({error: false});
});

