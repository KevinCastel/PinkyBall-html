extends Control

class_name SaveFileDialog

var _title = "Save"

var _current_path

var _last_current_path

onready var _vbox_dirfiles = self.get_node("panel_body/panel_containers_file_directories/VBoxContainer")
onready var _text_edit_current_path = self.get_node("panel_body/textedit_path")

var _old_cursor_column = 0

var _dict_dirfiles = {} #name_file : {is_dir:bool,
						#count_files_and_directories_children:int,
						#absolute_path:string

var _main_stats_game

func init_(main_stats_game = null):
	"""
		Constructor for this object
	"""
	self._main_stats_game = main_stats_game

func _ready():
	var combo_box = self.get_node("panel_body/panel_informations/Vertica_Container/combo_box")
	combo_box.add_item("html")
	combo_box.add_item("pdf")
	combo_box.set_context_menu_selection(0)
	combo_box.set_text(combo_box.get_item_by_index(combo_box._index_selection))

	self.set_current_path(OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS))
	
#	self._combo_box_current_path.get_parent().set_font_size_input(30)
#	self._combo_box_current_path.get_parent().set_font_size_suggestion(17)
#	self._combo_box_current_path.get_parent().set_combobox_size(Vector2(1000, 0), true)
#
#	self._combo_box_current_path.get_parent()._clean_text_on_item_selectionned = true
	var font_obj = DynamicFont.new()
	font_obj.font_data = load("res://ressources/fonts/consola.ttf")
	
	self._text_edit_current_path.add_font_override("font",font_obj)
	
	self.get_all_files_directories(self._current_path)
	self.show_files()


func _process(delta):
	"""
		Main Runtime
	"""	
	var txt
	var new_cursor_column = self._text_edit_current_path.cursor_get_column()
	if self._old_cursor_column != new_cursor_column:
		if new_cursor_column > 0:
			self._old_cursor_column = new_cursor_column

	if Input.is_action_just_pressed("context_valid"): #and self._combo_box_current_path.has_focus() and not self._combo_box_current_path.get_parent()._is_context_menu_open:
		txt = self._text_edit_current_path.text
		txt = self.correct_path(txt)
		if not self.get_is_path_valid(txt):
			if self._last_current_path:
				txt = self._last_current_path
				self.set_current_path(txt)
		else:
			self._last_current_path = txt
		
		
		self.clean_dirfiles_panel()
		self.set_current_path(txt)
		self.get_all_files_directories(txt)
		self.show_files()
		
		self._text_edit_current_path.cursor_set_column(new_cursor_column)


func set_current_path(new_path):
	self._current_path = new_path
	self._text_edit_current_path.text = self._current_path


func _on_texture_button_exit_pressed():
	self.queue_free()


func get_title():
	return self._title


func set_title(new_title):
	self.get_node("panel_title/label_title").text = new_title
	self._title = new_title


func _on_button_save_pressed():
	self.write_file()
	self.queue_free()

func write_file(fname=null):
	var file_name
	var file_object = File.new()
	var combobox = self.get_node("panel_body/panel_informations/Vertica_Container/combo_box")
	
	if fname:
		file_name = fname
	else:
		file_name = "stats_"+str(OS.get_unix_time())+"."+\
					combobox.get_item_by_index(combobox._index_selection)
	file_object.open(self._current_path+"/"+file_name, File.WRITE)
	
	file_object.store_string(self._main_stats_game.get_html_text())
	file_object.close()


func get_all_files_directories(path:String):
	"""
		Return all directories and files from a path
	"""
	var directory_object =  Directory.new()
	var file_name = ""

	if not path.ends_with("/"):
		path += "/"

	if directory_object.open(path) == OK:
		directory_object.list_dir_begin()
		file_name = directory_object.get_next()
		while file_name != "":
			if file_name != "." and file_name != "..":
				if directory_object.current_is_dir():
					self._dict_dirfiles[file_name] = {"is_dir":true,
													"count_dirfiles_children":self.count_dirfiles_children_from_parent(path+file_name),
													"absolute_path":path+file_name}
				else:
					self._dict_dirfiles[file_name] = {"is_dir":false,
													"absolute_path":path+file_name}
				#self._combo_box_current_path.get_parent().add_item(self._dict_dirfiles[file_name]["absolute_path"])

			file_name = directory_object.get_next()


func count_dirfiles_children_from_parent(path_parent:String):
	var directory_object = Directory.new()
	var file_name = ""
	var count_children = 0
	if directory_object.open(path_parent) == OK:
		directory_object.list_dir_begin()
		file_name = directory_object.get_next()
		while file_name != "":
			if file_name != ".." and file_name != ".":
				count_children += 1

			file_name = directory_object.get_next()
	
		return count_children
	else:
		return null

func create_btn_object(txt:String):
	"""
		Create a btn object
		
		Take Args As:
			txt (String) is the text of the button object
	"""
	var btn_object = Button.new()
	btn_object.text = txt
	btn_object.connect("pressed", self, "_on_btn_dirfiles_pressed", [btn_object.text])
	btn_object.set_size(Vector2(100, 20))
	btn_object.rect_position = Vector2(0,4)
	
	#btn_object.size_flags_horizontal = SIZE_FILL
	
	var font_object = DynamicFont.new()
	font_object.font_data = load("res://ressources/fonts/consola.ttf")
	
	btn_object.name = "btn_"+txt
	btn_object.add_font_override("font", font_object)
	
	var flat_box_style_object = StyleBoxFlat.new()
	flat_box_style_object.bg_color = Color8(0,0,0,0)
	btn_object.add_stylebox_override("normal",flat_box_style_object)

	flat_box_style_object = StyleBoxFlat.new()
	flat_box_style_object.bg_color = Color8(0,50,0,30)
	
	btn_object.add_stylebox_override("hover", flat_box_style_object)
	
	return btn_object


func create_file_label(txt:String):
	"""
		Create label that contains the number of children (sub files, directories...)
		
		Take Args As:
			txt (String) is the text of the button
			local_position_x (float) is the local position for this objecti in x
		
		Return a label object
	"""
	var label_object = Label.new()
	label_object.text = txt
	
	var font_object = self.get_dynamic_font_for_dirfiles(16)
	label_object.add_font_override("font", font_object)
	
	label_object.align = Label.ALIGN_CENTER
	label_object.valign = Label.VALIGN_CENTER
	
	return label_object


func get_dynamic_font_for_dirfiles(font_size=17, font_color = Color8(155,155,155,255)):
	"""
		Create a dynamic font for dirfiles panel and children
		
		Take Args As:
			font_size (int) is the font_size
			font_color (Color8) is the font_color
		
		Return a font dynamic specific for dirfiles panel and childrens
	"""
	var font_object = DynamicFont.new()
	font_object.font_data = load("res://ressources/fonts/ebrima.ttf")
	
	font_object.size = font_size
	
	return font_object


func create_file_panel(file_name:String, vbox:VBoxContainer, is_color_panel_blue=false, childrens=null):
	"""
		Create the panel that is created for each files and directories,
		this panel contains information about the last one

		Take Args As:
			file_name (String) name of the file
			
			vbox (VBoxContainer) is the VBoxContainer used for placing each panel dirfiles
			
			is_color_panel_blue (bool) is for setting the color of the panel 1 on 2
			
			children (int) if the current is dir, it is the numbers of childrens (sub-dirs, sub-files)
			 (by default null for when the current is a file)
			
	"""
	var panel_object = PanelContainer.new()
	
	var flat_box_style_object = StyleBoxFlat.new()
	
	if is_color_panel_blue:
		flat_box_style_object.bg_color = Color8(51, 59, 79)
	else:
		flat_box_style_object.bg_color = Color8(50,50,50)
	
	var hbox_object = HBoxContainer.new()
	
	vbox.add_child(panel_object)
	panel_object.add_child(hbox_object)
	hbox_object.add_child(self.create_btn_object(file_name))
	if childrens:
		hbox_object.add_child(self.create_file_label(str(childrens)))
	
#	panel_object.add_child(self.create_btn_object(file_name))
#	panel_object.add_child(self.create_file_label(str(childrens), 120))
	
	panel_object.add_stylebox_override("panel", flat_box_style_object)
	
	panel_object.set_size(Vector2(vbox.get_size().x,120))


func show_files():
	var is_color_blue = 0
	var children
	for file in self._dict_dirfiles:
		children = null
		if self._dict_dirfiles[file]["is_dir"]:
			children = self._dict_dirfiles[file]["count_dirfiles_children"]
		
		self.create_file_panel(file, self._vbox_dirfiles, bool(is_color_blue), children)
		
		is_color_blue += 1
		if is_color_blue > 1:
			is_color_blue = 0


func correct_path(path:String):
	if "\\" in path:
		path = path.replace("\\","/")

	var list_index_to_remove_character = []

	var is_text = false
	var count_slash = 0
	var index_character = 0
	for c in path:
		if c == "/":
			count_slash += 1
			if count_slash > 1:
				list_index_to_remove_character.append(index_character)
		else:
			count_slash = 0

		index_character += 1

	for index in list_index_to_remove_character:
		path.erase(index, index)

	if path.begins_with("\\") or path.begins_with("/"):
		path.erase(0,0)
	
	if not path.ends_with("/"):path += "/"
	
	return path


func _on_textedit_path_text_changed():
	var txt = self._text_edit_current_path.text
	var old_txt = txt
	txt = self.correct_path(txt)


	if "\n" in txt:txt = txt.replace("\n","")
	if "\t" in txt:txt = txt.replace("\t", "")

	if txt != old_txt:
		self._text_edit_current_path.text = txt
		self._text_edit_current_path.cursor_set_column(self._old_cursor_column+1)
	
	if self.get_is_path_valid(txt):
		self._last_current_path = txt


func clean_dirfiles_panel():
	"""
		Remove all panel for directories or files
	"""
	self._dict_dirfiles.clear()
	for child in self._vbox_dirfiles.get_children():
		child.queue_free()


func _on_btn_dirfiles_pressed(dirfile_name:String):
	var extension_file; var file_name
	var combobox = self.get_node("panel_body/panel_informations/Vertica_Container/combo_box")
	if self._dict_dirfiles[dirfile_name]["is_dir"]:
		var absolute_path = self._dict_dirfiles[dirfile_name]["absolute_path"]
		self.set_current_path(absolute_path)
		self.clean_dirfiles_panel()
		self.get_all_files_directories(absolute_path)
		self.show_files()
	else:
		#do stuffs for a file (ask for replacing or not
		extension_file = self.get_extension_file(dirfile_name)
		if extension_file == combobox._index_selection:
			self.write_file(self.get_name_file(dirfile_name))


func get_name_file(file_name):
	var regex_object = RegEx.new()
	
	regex_object.compile("(?<file_name>[\\w\\d]*)\\.(?<extension>[a-z0-9]*)")
	
	var match_obj = regex_object.search(file_name)
	return match_obj.strings[1]

func get_extension_file(file_name:String):
	var regex_object = RegEx.new()
	
	regex_object.compile("(?<file_name>[\\w\\d]*)\\.(?<extension>[a-z0-9]*)")
	
	var match_obj = regex_object.search(file_name)
	return match_obj.strings[2]

func get_is_path_valid(path:String):
	var directory_object = Directory.new()
	if directory_object.open(path) == OK:
		return true
	
	return false


func _on_combo_box__on_text_changed():
	pass



#func _on_combo_box_path__on_item_selectionned(new_item:String):
#	new_item = self.correct_path(new_item)
#	self._combo_box_current_path.get_parent().clear_items()
#	self.clean_dirfiles_panel()
#	self.set_current_path(new_item)
#	self.get_all_files_directories(new_item)
#	self.show_files()
#
#	self._combo_box_current_path.text = new_item
#
