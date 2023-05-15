extends Control

var _dict_action_keys = {}

var _list_actions_game = ["player_launch_ball",
						"player_left",
						"player_right",
						"player_down",
						"plane_shoot",
						"get-out_plane",
						"player_change_direction"]


var _ui_key_binding


onready var _checkbox_playing_mouse = self.get_node("checkbox_play_with_mouse")

func _ready():
	self.load_input()
	self.set_labels_action()

	self.set_buttons_event()
	self.set_mouse_play(self.get_if_can_play_with_mouse())


func get_if_can_play_with_mouse():
	var can_play_with_mouse = false
	for e in InputMap.get_action_list("player_launch_ball"):
		can_play_with_mouse = (e is InputEventMouseButton and not can_play_with_mouse)
	
	return can_play_with_mouse


func set_mouse_play(value):
	self._checkbox_playing_mouse.pressed = value




func load_input():
	"""
		Assign dictionnary Action Map for the game
	"""
	var list_keys
	for action_name in InputMap.get_actions():
		if action_name in self._list_actions_game:
			list_keys = InputMap.get_action_list(action_name)
			
#			if action_name == "player_launch_ball":
#				for e in list_keys:
#					if "inputeventmousebutton" in str(e).to_lower():
#						print_debug(list_keys)
			
			self._dict_action_keys[action_name] = list_keys


func get_text_by_scancode(key_id:int):
	"""return a text from a key by her scancode"""
	var input_event_object = InputEventKey.new()
	input_event_object.scancode = key_id
	return input_event_object.as_text()


func set_labels_action():
	"""
		Assign action text to the ui interface
	"""
	var list_actions_childrens = self.get_node("ColorRect/VBoxContainer/control_keys_keysboard/vboxcontainers").get_children()
	var index_ui = 0
	var label_name = ""
	for action_name in self._dict_action_keys:
		for e in self._dict_action_keys[action_name]:
			if index_ui < len(list_actions_childrens):
				label_name = self.get_action_text_to_information_text(action_name, "_", " ")
				label_name = self.get_action_text_to_information_text(label_name, "player", "")
				label_name = self.set_upper_characters(label_name)
				if not self.is_string_beginning_with_space_character(label_name):
					label_name = self.set_first_character_to_upper(label_name)
				
				list_actions_childrens[index_ui].get_node("HBoxContainer/label_keys_name").text = label_name
				if e is InputEventKey:
					list_actions_childrens[index_ui].get_node("HBoxContainer/button_change_keys").text = self.get_text_by_scancode(e.scancode)
		index_ui += 1


func get_action_text_to_information_text(string:String, pattern:String, new_pattern:String):
	"""Return a the string passed as argument by replacing a pattern passed as argument too"""
	return string.replace(pattern, new_pattern)


func set_upper_characters(string:String):
	var new_string = ""
	var last_character = ""
	for c in string:
		if last_character == " ":
			new_string += str(c).to_upper()
		else:
			new_string += str(c).to_lower()
		
		last_character = c
	
	return new_string


#func set_first_character_to_upper(string:String):
#	var new_string=""; var i = 0
#	var does_character_was_foundt = false
#	for c in string:
#		if i == 0:
#			new_string += str(c).to_upper()
#		elif not does_character_was_foundt and not self.is_character_numeric(c):
#			does_character_was_foundt = true
#			new_string += str(c).to_upper()
#		else:
#			new_string += str(c).to_lower()
#
#		i += 1
#	return new_string


func set_first_character_to_upper(string:String):
	var new_string = ""; var index_character = 0
	for c in string:
		if index_character == 0:
			new_string = str(c).to_upper()
		else:
			new_string += c
		
		index_character += 1
	
	return new_string

func is_character_space(character:String):
	return character == " "

func is_character_numeric(character:String):
	return character in ["0","1","2","3","4","5","6","7","8","9"]

func is_string_beginning_with_space_character(string:String):
	return string.split("")[0] == " "


func set_buttons_event():
	"""
		Iterate all action buttons and connect them to the event (pressed)
	"""
	var btn_object
	for panel_object in self.get_node("ColorRect/VBoxContainer/control_keys_keysboard/vboxcontainers").get_children():
		btn_object = panel_object.get_node("HBoxContainer/button_change_keys")
		btn_object.connect("pressed", self, "_btn_pressed", [btn_object.text])


func get_action_name(key_text:String):
	"""Return a action name by searching the keys"""
	for action_name in InputMap.get_actions():
		if action_name in self._list_actions_game:
			for k in InputMap.get_action_list(action_name):
				if k.as_text() == key_text:
					return action_name
	
	return null


func get_scancode_by_text(btn_text:String):
	return OS.find_scancode_from_string(btn_text)


func _btn_pressed(btn_text:String):
	self._ui_key_binding = preload("res://ressources/scene/ui/customize_keyboard.tscn").instance()
	var action_name = self.get_action_name(btn_text)
	self.play_sound("accept")
	if action_name != "":
		self.add_child(self._ui_key_binding)
		self._ui_key_binding.last_key_scancode = self.get_scancode_by_text(btn_text)
		self._ui_key_binding.last_key_action = action_name
		self._ui_key_binding.set_label_title(btn_text)


func new_key_valided():
	"""
		Called for updating the new key
	"""
	var input_event_key_object = InputEventKey.new()
	var action_name = self._ui_key_binding.last_key_action
	var last_key_scancode = self._ui_key_binding.last_key_scancode
	var new_key_text = self.get_text_by_scancode(self._ui_key_binding.new_key_scancode)
	input_event_key_object.scancode = last_key_scancode
	InputMap.action_erase_event(action_name,
								input_event_key_object)
	input_event_key_object.scancode = self._ui_key_binding.new_key_scancode
	InputMap.action_add_event(action_name, input_event_key_object)
	self.set_button_key_text(self.get_btn_object_by_his_text(
									self.get_text_by_scancode(last_key_scancode)),
							new_key_text)
	
	
	self.get_node("customize_keyboard").queue_free()
	self._ui_key_binding = null
	self.play_sound("accept")
	self.get_tree().change_scene("res://ressources/scene/ui/ui_menu.tscn")


func get_btn_object_by_his_text(btn_txt:String):
	var btn_object; var btn_child
	for panel_object in self.get_node("ColorRect/VBoxContainer/control_keys_keysboard/vboxcontainers").get_children():
		btn_child = panel_object.get_node("HBoxContainer/button_change_keys")
		if btn_child.text == btn_txt:
			return btn_child
	
	return null


func set_button_key_text(btn_obj, new_text:String):
	btn_obj.text = new_text


func _on_btn_play_pressed():
	self.play_sound("accept")
	yield(self.get_node("audiostreamplayer_effect"), "finished")
	self.get_tree().change_scene("res://ressources/scene/gameplay/game.tscn")


func play_sound(context:String):
	var dict_preload_sound = {"accept":preload("res://ressources/sound/menu/accept_sound.mp3"),
							"wrong":preload("res://ressources/sound/menu/wrong_sound.mp3")}
	var audiostreamplayer_effect = self.get_node("audiostreamplayer_effect")
	audiostreamplayer_effect.stream = dict_preload_sound[context]
	audiostreamplayer_effect.play()


func _on_checkbox_play_with_mouse_pressed():
	var can_play_with_mouse = self.get_node("checkbox_play_with_mouse").pressed
	if can_play_with_mouse:
		self.play_sound("accept")
	else:
		self.play_sound("wrong")
	
	self.set_mouse_play(can_play_with_mouse)
