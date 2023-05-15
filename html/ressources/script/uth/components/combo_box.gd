extends Control

var _list_items = []

var _index_selection = -1


onready var _panel_context = self.get_node("panel_context")

onready var _text_edit = self.get_node("text_edit")

var _is_context_menu_open = false


var _last_time_key_pressed = self.get_unix_time()

var _can_add_item = false

var _last_cursor_column

export var _does_user_can_add_item = false
export var _clean_text_on_item_selectionned = false

signal _on_text_changed
signal _on_item_selectionned

var _font_size_input
var _font_size_suggestion

func _ready():
	"""
		Called when this object is added in the scene
	"""
	self.hide_context_menu()
	
	var font_obj = DynamicFont.new()
	font_obj.font_data = load("res://ressources/fonts/consola.ttf")
	self._text_edit.add_font_override("font",font_obj)
	
	font_obj.size = self._font_size_input
	
	var style_box_flat_object = StyleBoxFlat.new()
	style_box_flat_object.bg_color = Color8(200,200,200)
	
	self._text_edit.add_stylebox_override("normal", style_box_flat_object)
	
	self._text_edit.rect_size.y = font_obj.get_height() + 8
	
	self._text_edit.add_color_override("font_color", Color8(0,0,0,255))
	
	self.focus_mode = Control.FOCUS_NONE

func _init(font_size_input=20, font_size_suggs = 14):
	"""
		Constructor of this object
	"""
	self._font_size_input = font_size_input
	self._font_size_suggestion = font_size_suggs

func _process(_delta):
	"""
		Main runtime for this object
	"""
	if not self._text_edit.has_focus() and self._is_context_menu_open:
		self.clean_items()
		
		self.hide_context_menu()
	
	self.clean_line_return(self._text_edit)
	
	self.set_cursor_column()
	var txt
	
	if self._is_context_menu_open:self.check_input()
	if self._last_time_key_pressed+1 < self.get_unix_time():
		self._can_add_item = (not self._is_context_menu_open)
	
	if Input.is_action_just_pressed("context_valid") and self._text_edit.has_focus():
		if self._is_context_menu_open:
			if self._clean_text_on_item_selectionned:
				self._text_edit.text = self.get_item_by_index(self._index_selection)
			else:
				self._text_edit.insert_text_at_cursor(self.get_item_by_index(self._index_selection))
			self.hide_context_menu()
			emit_signal("_on_item_selectionned", self.get_item_by_index(self._index_selection))
		elif self._does_user_can_add_item:
			txt = self._text_edit.text
			if not self._is_context_menu_open:
				self._last_time_key_pressed = self.get_unix_time()
				
				if "\n" in txt:
					txt = txt.replace("\n","")
					self._text_edit.text = txt
				
				if len(txt) > 0:
					self.add_item(txt)
				
				self._text_edit.cursor_set_column(self._last_cursor_column)


func set_cursor_column():
	""""""
	if self._text_edit.cursor_get_line() == 0:
		if self._text_edit.cursor_get_column() > 0:
			self._last_cursor_column = self._text_edit.cursor_get_column()


func check_input():
	"""
		Check input
	"""
	if len(self._list_items) > 0:
		if Input.is_action_just_pressed("context_up") and self._index_selection > 0:
			self.set_context_menu_selection(self._index_selection-1)
			self.set_labels_theme()
		elif Input.is_action_just_pressed("context_down") and self._index_selection < len(self._list_items)-1:
			self.set_context_menu_selection(self._index_selection+1)
			self.set_labels_theme()


func hide_context_menu():
	"""
		Hide the context menu
	"""
	self._is_context_menu_open = false
	self._panel_context.visible = false
	self.clean_items()


func open_context_menu():
	"""
		Show the context menu
	"""
	var vbox_context = self.get_node("panel_context/vbox_containers")
	self._is_context_menu_open = true
	self._panel_context.visible = true
	
	var label_obj
	
	var fonct_height = 17
	
	for though in self._list_items:
		label_obj = self.create_label(though)
		vbox_context.add_child(label_obj)
	
	self.set_context_menu_selection(0)
	self.set_labels_theme()

#	self._panel_context.rect_global_position.y = 4+(fonct_height*len(self._list_items))
	
	
	#self._panel_context.rect_global_position.y = self._text_edit.rect_size.y
	
	self._panel_context.show_on_top = true
	
	self._panel_context.rect_global_position.y = (self.rect_global_position.y+self._text_edit.get_size().y)
	
	self._panel_context.rect_size.x = self._text_edit.rect_size.x
	self._panel_context.rect_size.y += len(self._list_items) * (label_obj.get_size().y)
	
	
	vbox_context.rect_global_position = self._panel_context.rect_global_position
	
	vbox_context.rect_size = self._panel_context.rect_size

func create_label(txt:String):
	var label = Label.new()
	
	var dynamic_font = DynamicFont.new()
	dynamic_font.font_data = load("res://ressources/fonts/ebrima.ttf")
	
	dynamic_font.size = self._font_size_suggestion
	
	label.text = txt
		
	label.add_font_override("font", dynamic_font)
	label.add_color_override("font_color", Color8(0,0,0))
	
	return label

func set_context_menu_selection(i):
	self._index_selection = i

func set_labels_theme():
	var i = 0
	var dict_colours = {"selection": Color8(153,217,234),
						"unselected":Color8(255,255,255,100)}
	
	var style_normal
	
	for label in self._panel_context.get_node("vbox_containers").get_children():
		style_normal = StyleBoxFlat.new()
		if i == self._index_selection:
			style_normal.bg_color = dict_colours["selection"]
			label.add_stylebox_override("normal",style_normal)
		else:
			style_normal.bg_color = dict_colours["unselected"]
			label.add_stylebox_override("normal", style_normal)
		
		i+=1


func clean_items():
	for child in self._panel_context.get_node("vbox_containers").get_children():
		child.queue_free()


func add_item(item):
	"""
		Add item for the context menu
	"""
	if not item in self._list_items:
		self._list_items.append(item)

func remove_items(item):
	"""
		Remove item for the context menu
	"""
	var index = -1
	if item in self._list_items:
		index = self._list_items.find(item)
	
	if index != -1:
		self._list_items.pop_at(index)


func get_item_by_index(index:int):
	return self._list_items[index]


func get_unix_time():
	return OS.get_unix_time()


func _input(event):
	var char_c = event.as_text()
	
	if char_c == "Control+Space" and not self._is_context_menu_open and self._text_edit.has_focus():
		self.open_context_menu()
	elif char_c == "Escape" and self._is_context_menu_open and self._text_edit.has_focus():
		self.hide_context_menu()


func get_index_of_item(item:String):
	return self._list_items.find(item)


func _on_text_edit_text_changed():
	var txt = self._text_edit.text
	var model = self.get_stats_on_input(txt)
	if model != "":
		if self._is_context_menu_open:
			self.set_context_menu_selection(self.get_index_of_item(model))
			self.set_labels_theme()
			
			#emit_signal("_on_self_text_changed")
	

func get_stats_on_input(txt:String):
	"""
		Return the model witch is the most identic to txt (String)
		
		Search in items for getting the model
	"""
	var model_word = ""
	var dict_model_stats = {}
	for model in self._list_items:
		dict_model_stats[model] = 0.00
	
	var index_character_model = 0
	var stats = 0.00
	for character_from_txt in txt:
		for model in dict_model_stats:
			stats = 0.00
			index_character_model = 0
			for character_from_model in model:
				if character_from_txt == character_from_model:
					stats += 20.00
				elif index_character_model < len(model)-2:
					if character_from_txt == model[index_character_model+1]:
						stats += 3.00
				elif index_character_model > 0:
					if character_from_txt == model[index_character_model-1]:
						stats += 3.00
				
				if len(model) == len(txt):
					stats += 15.00
				else:
					stats -= 5.00
			
				index_character_model += 1
		
			dict_model_stats[model] = stats
	
	var highest_stats = 0.00
	
	for s in dict_model_stats:
		if highest_stats < dict_model_stats[s]:
			highest_stats = dict_model_stats[s]
			model_word = s
	
	if highest_stats < 0.00:
		model_word = ""
	
	return model_word

func clean_line_return(object):
	"""
		Clean all line return in the text of the object
	"""
	var txt = object.text
	if "\n" in txt:
		txt = txt.replace("\n","")
		object.text = txt
		
		object.cursor_set_column(len(txt))


func set_text(txt:String):
	self._text_edit.text = txt


func set_font_size_input(font_size:float):
	self._font_size_input = font_size


func set_combobox_size(size:Vector2, set_y_to_font_height=false):
	"""
		Change the texedit size with size (Vector2) also used
		set_y_to_font_height (bool), if it's true so the size.y
		will be equal to font_size.y + 16 (for borders)
		
	"""
	var font_height
	if set_y_to_font_height:
		font_height = self._text_edit.get_font("font").get_size()
		self._text_edit.set_size(Vector2(size.x, font_height+16))
	else:
		self._text_edit.set_size(size)


func set_font_size_suggestion(font_size:float):
	self._font_size_suggestion = font_size
	self.hide_context_menu()
	self.clean_items()
	self.show()
	for though in self._list_items:
		self.create_label(though)


func clear_items():
	self._list_items.clear()
