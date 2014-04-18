var config = {}

config.redis = {};
config.web = {};
config.api 	= {};

// config.redis.host = 'localhost';
// config.redis.port = 6379;
// config.web.port = process.env.WEB_PORT || 4500;
// config.log = {location: '../log/node-proxy.log'}

config.environments = {
	development: {
		base: "0.0.0.0:4000/socket"
	}
}


module.exports = config;