extends Control

#var _can_bind_keyboard = false

onready var _half_screen_size = OS.window_size.y/2

var last_key_scancode = 0 setget setLastKeyScancode

var last_key_action = "" setget setLastKeyAction

var new_key_scancode = 0 setget setNewKeyScancode




#func set_if_can_bind(pos_y):
#	self._can_bind_keyboard = (pos_y <= self._half_screen_size)


func set_label_key_text(txt):
	self.get_node("ColorRect/label_key_text").text = txt + " Press key (mouse should be upper than this text)"


func set_label_title(last_key_text:String=""):
	var label_title = self.get_node("ColorRect/label_title")
	if last_key_text == "":
		label_title.text = "Change Your Keys:"
	else:
		label_title.text = "Change ("+last_key_text+") Your Keys:"


func _input(event):
	"""
		Capture input for binding input when it can
	"""
	if event is InputEventKey:
		self.set_label_key_text(event.as_text())
		new_key_scancode = event.scancode
		self.play_sound("accept")
	
#	if self._can_bind_keyboard:
#		if event is InputEventKey:
#			self.set_label_key_text(event.as_text())
#			new_key_scancode = event.scancode
#			self.play_sound("accept")
#	elif event is InputEventKey:
#		self.play_sound("wrong")
		
#	if event is InputEventMouse:
#		self.set_if_can_bind(event.position.y)


func setLastKeyScancode(new_value):
	last_key_scancode = new_value


func setLastKeyAction(new_value):
	last_key_action = new_value


func _on_btn_apply_pressed():
	"""
		Event called when the applied button is pressed,
		This one used to replace old key by the new key defined
		by the user
	"""
	self.get_node("ColorRect/btn_apply").visible = false
	self.find_parent("ui").new_key_valided()
	

func setNewKeyScancode(new_value):
	new_key_scancode = new_value


func play_sound(context:String):
	var dict_preload_sound = {"accept":preload("res://ressources/sound/menu/accept_sound.mp3"),
							"wrong":preload("res://ressources/sound/menu/wrong_sound.mp3")}
	var audiostreamplayer_effect = self.get_node("audiostreamplayer_effect")
	if not audiostreamplayer_effect.is_playing():
		audiostreamplayer_effect.stream = dict_preload_sound[context]
		audiostreamplayer_effect.play()
