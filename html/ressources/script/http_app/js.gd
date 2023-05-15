extends Node


var _my_js_callback = JavaScript.create_callback(self, "myCallback") # This reference must be kept
var console = JavaScript.get_interface("console")

func get_username():
	return JavaScript.eval("prompt('Type your username here:');")
