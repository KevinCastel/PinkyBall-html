extends Node2D

onready var _cam_obj = self.get_node("cam")

var _cam_debug

var _cam_menu
var _cam_anim
var _cam_anim_slide_speed = 0.00

var _move_cam_menu = false

var _player_name = "user"

var _is_having_touchpad = OS.has_touchscreen_ui_hint()

var _file_dialog_save

onready var _command_lines = preload("res://ressources/script/console.gd").new()
onready var textedit_cmd = self.get_node("CanvasLayer/Control/Panel/textedit")

onready var _cheatc_object = preload("res://ressources/script/cheat_code.gd").new()

var _pause = false

var _force_player_position = false

var _gameplay_mode = "platform"

var _ball_launched = false

var _plane_obj

var _player_life = 3

var _ball_object_can_be_destroyed = true #for every ball objects

 
var score_saved = false

var _dict_player_node = {
	"plane" : null,
	"rocket" : null,
	"character" : null
}

onready var _player_object_platform = self.get_node("player")

var _max_ball = 0

var _list_message = []


var _dict_audiostreamplayer_shoot = {} #name+int : [audiostreamonbject, sound_name, play_pitch, volume_pitch]
var _dict_audiostreamplayer2D = {} #name+int : [audiostreamobject, sound_name, play_pitch, volume_pitch]

var _brick_still = 0

var _is_game_playing = true

var _dict_btns = {}

var _can_spawn_btns = false

onready var stats_object = Stats.new()

var character_futur_superpower = "" setget setCharacterFuturSuperpower

var _maximum_bricks = 0

var _lowest_object_distance = 0.00

var _jscript_object = JavaScript

var _is_player_on_web_app = false

func _ready():
	if not self._is_having_touchpad or OS.get_name().to_lower() in ["windows"]:
		self.destroy_touchbtn()
	
	self.set_highscore_ui_enabled(false)
	
	self.add_child(self._command_lines)
	self.add_child(_cheatc_object)
	
	self.load_map()
	self._cam_obj.add_target(self._player_object_platform)
	
	self.init_cam(self._cam_obj)
	
	self.get_node("tilemap_bricks").visible = false
	
	
#	var js_script = preload("res://ressources/script/http_app/js.gd").new()
#	self.add_child(js_script)
#	self._player_name = js_script.get_username()
	randomize()
	self._player_name = "Guest"+str(randi()%100+1)
	
	self._max_ball = len(self.get_node("bricks").get_children())
	
	self.set_gameplay_mode("platform")
	self.spawn_platform_player()


func spawn_platform_player():
	"""
		Should be used for spawning platform player but this one
		is already added this one is used for now to place platform
		player at the start of the game
	"""
	"""
	var spawn_global_pos = Vector2.ZERO
	var screen_size = OS.window_size
	
	spawn_global_pos.x = screen_size.x / 1.7
	spawn_global_pos.y = 844
	
	self._player_object_platform.global_position = spawn_global_pos
	"""
	self._player_object_platform.global_position.x = 500



func _physics_process(delta):
	"""mainruntime global"""
	self.check_sound()
	if self._is_game_playing:
		self.message_loop()
		var txteditor_obj = self.get_node("CanvasLayer/Control/Panel/textedit")
		var all_lines_cmd = self.get_node("CanvasLayer/Control/Panel/rich_textbox")
		if Input.is_action_just_released("new_line") and self.get_focus():
			if self.get_focus().name == "textedit":
				self._command_lines.manage_command(txteditor_obj, all_lines_cmd, self)
		
		if self._gameplay_mode == "anim_pieces":
			self.play_animation()
		
		if self._player_life <= 0:
			self.finish_game()
		if self._brick_still != self.get_node("bricks").get_child_count():
			self._brick_still = self.get_node("bricks").get_child_count()
			if self._brick_still == 0:
				self.finish_game(self._brick_still == 1)
		
		if self._cam_debug:
			self.move_camera()
		
		if self._force_player_position:
			self.automatic_platform_player()

		
		self.check_map_bottom()
	else:
		var player_global_position = self._player_object_platform.global_position
		var zoom_to_reach = ((self._player_object_platform.get_node("body").get_rect().get_area()/2)/1000)/4 #+ Vector2(0.5,0.5)
		if self._move_cam_menu and not self._can_spawn_btns:
			self._cam_menu.global_position.x = lerp(self._cam_menu.global_position.x,
													player_global_position.x,
													0.04)
			self._cam_menu.global_position.y = lerp(self._cam_menu.position.y,
													player_global_position.y,
													0.04)
			
			self._cam_menu.zoom.x = lerp(self._cam_menu.zoom.x, zoom_to_reach, 0.02)
			self._cam_menu.zoom.y = lerp(self._cam_menu.zoom.y, zoom_to_reach, 0.02)
			
			self._can_spawn_btns = (self._cam_menu.zoom.x < 0.513)
			
		elif len(self._dict_btns) == 0:
			self.get_node("CanvasLayer/ColorRect").queue_free()
			var global_pos = self._player_object_platform.global_position
			global_pos.y -= 32
			global_pos.x -= 64
			for btn_info in [{"text":"Restart"},{"text":"Quit"}]:
				self.create_btn_object(btn_info["text"], global_pos, Vector2(60,12))
				global_pos.x += 60+5
			
			global_pos = self._player_object_platform.global_position
			self.create_btn_object("save", global_pos, Vector2(40,8))
			
			self.create_panel()


func export_score():
	"""
		Called for saving stats on the local user storage
		
		The user can save as html or pdf file
	"""
	
	self._file_dialog_save = self.get_node("CanvasLayer/SaveFileDialog")
	
	self._file_dialog_save.popup()
	
	self._file_dialog_save.mode = FileDialog.MODE_SAVE_FILE
	self._file_dialog_save.access = FileDialog.ACCESS_FILESYSTEM

	self._file_dialog_save.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	self._file_dialog_save.connect("file_selected", self, "on_closing_save_file_dialog")
	self._file_dialog_save.window_title = "Save Your Score"
	self._file_dialog_save.filters = ["*.html"]
	

func get_score():
	"""
		Return everything about the score for this game about this player
	"""
	var dict_score = {}
	for gameplay_mode_name in ["platform", "character","rocket","plane"]:
		dict_score[gameplay_mode_name+"_time"] = self.stats_object.get_gameplay_mode_time(gameplay_mode_name)
		if self.stats_object.check_if_time_can_be_converted_in_minutes(dict_score[gameplay_mode_name+"_time"]):
			dict_score[gameplay_mode_name+"_time"] = str(self.stats_object.convert_second_to_minutes(dict_score[gameplay_mode_name+"_time"]))+"mins"
		else:
			dict_score[gameplay_mode_name+"_time"] =str(dict_score[gameplay_mode_name+"_time"])+"secs"
	
	for i in self.stats_object._dict_items:
		dict_score[i+"_spawned"] = self.stats_object.get_item_spawned(i)
		dict_score[i+"_used"] = self.stats_object.get_item_used(i)
		
		dict_score[i+"_ratio"] = float(dict_score[i+"_used"])/float(dict_score[i+"_spawned"])*100
	
	for i in ["bullet","rocket","heart","bomb","rc_plane"]:
		if not i+"_spawned" in dict_score:
			dict_score[i+"_spawned"] = 0
			dict_score[i+"_used"] = 0
			dict_score[i+"_ratio"] = float(0.00)
	
	for ammo_name in self.stats_object._dict_ammo:
		for ammo_data in self.stats_object._dict_ammo[ammo_name]:
			dict_score[ammo_name+"_"+ammo_data] = self.stats_object._dict_ammo[ammo_name][ammo_data]
			dict_score[ammo_name+"_precision"] = self.stats_object.get_precision_ammo(ammo_name)
	
	return dict_score


func create_panel():
	"""
		Create panel with RichTextBox for showing stats and score
	"""
	var dict_score = self.get_score()
	
	var player_position = self._player_object_platform.global_position
	var panel_stats_object = Panel.new()
	
	
	panel_stats_object.set_size(Vector2(210,100))
	
	#var global_pos = Vector2(player_position.x-50, player_position.y-140)
	var global_pos = Vector2(player_position.x-(210/2), player_position.y-140)
	panel_stats_object.rect_global_position = global_pos
	
	self.add_child(panel_stats_object)
	
	var text_edit = TextEdit.new()
	
	text_edit.readonly = true
	
	text_edit.set_size(panel_stats_object.get_size())
	
	self.get_node(panel_stats_object.name).add_child(text_edit)
	
	text_edit.text = "Score & Stats:"+\
					"\n--------------"+\
					"\n*Time:"+\
					"\nPlatform :"+dict_score["platform_time"]+\
					"\nCharacter :"+dict_score["character_time"]+\
					"\nPlane :"+dict_score["plane_time"]+\
					"\nRocket :"+dict_score["rocket_time"]+\
					"\n--------------"+\
					"\n*Items:(used*spawn/100)"+\
					"\nBomb :"+str("%.2f"%dict_score["bomb_ratio"])+"/100%"+\
					"\nBullet :"+str("%.2f"%dict_score["bullet_ratio"])+"100%"+\
					"\nHeart :"+str("%.2f"%dict_score["heart_ratio"])+"/100%"+\
					"\nPlane :"+str("%.2f"%dict_score["plane_ratio"])+"/100%"+\
					"\nRocket :"+str("%.2f"%dict_score["rocket_ratio"])+"/100%"+\
					"\n--------------"+\
					"\nAmmo (by precision):"+\
					"\nBullet fired :"+str(dict_score["bullet_fired"])+\
					"\nBullet precision :"+str(dict_score["bullet_precision"])+\
					"\nRocket fired :"+str(dict_score["rocket_fired"])+\
					"\nRocket precision :"+str("%.2f"%dict_score["rocket_precision"])+\
					"\nMicro-Rocket :"+str("%.2f"%dict_score["micro_rocket_precision"])+\
					"\nMicro-Bomb :"+str("%.2f"%dict_score["micro_bomb_precision"])+\
					"\n--------------"+\
					"\nExplosion"
					
	
	textedit_cmd.set_size(Vector2(100,100))


func create_btn_object(btn_text:String, global_pos=Vector2.ZERO, object_size=Vector2.ZERO):
	"""
		Create button 2D object
		
		Take Args As:
			btn_text (String) is the text of the button that is it indicate to the user
			global_pos (Vector2) is for placing this object on the screen using the global_position
			object_size (Vector2) is the size of this object on the screen
	"""
	var btn = Button.new()
	btn.text = btn_text
	btn.rect_global_position = global_pos
	
	btn.set_size(object_size)
	
	randomize()
	self._dict_btns["button"+str(randi())] = btn
	btn.connect("pressed", self, "_button_pressed", [btn.text])
	
	self.add_child(btn)

func finish_game(is_player_winning=false):
	"""
		Called when the game is finished,
		
		The script know if the player win or not
			by the argument 'is_player_winning : bool'
	"""
	var last_camera_object = self.get_current_camera_object()

	self._move_cam_menu = true
	self._is_game_playing = false
	self.set_gameplay_mode("menu")
	
	if is_player_winning:
		self.add_message("You win!")
	else:
		self.add_message("You lose-it!")
	
	var ball = self.get_node_or_null("ball")
	if ball:
		ball._speed = 0
	
	self.manage_camera("menu", last_camera_object)
	self.set_highscore_ui_enabled(true)
	if not self.score_saved:
		self.score_saved = true


func move_camera():
	"""Used for camera movements"""
	if Input.is_action_pressed("player_launch_ball"):
		self._cam_debug.global_position.y -= 1
	if Input.is_action_pressed("player_down"):
		self._cam_debug.global_position.y += 1
	if Input.is_action_pressed("player_right"):
		self._cam_debug.global_position.x += 1
	if Input.is_action_pressed("player_left"):
		self._cam_debug.global_position.x -= 1

func get_focus():
	"""return the node that have the focus"""
	var node_f
	
	for ui_node in self.get_node("CanvasLayer/Control/Panel").get_children():
		if not node_f and ui_node.has_focus():
			node_f = ui_node
	
	return node_f

func init_cam(camera_obj):
	"""Set camera limit"""
	var tile_wall = self.get_node("tilemap_walls")
	
	var zone = tile_wall.get_used_rect()
	
	var cell_size = tile_wall.cell_size
	
	camera_obj.limit_left = zone.position.x * cell_size.x
	camera_obj.limit_right = (zone.size.x + zone.position.x) * cell_size.x
	
	camera_obj.limit_top = zone.position.y * cell_size.y
	camera_obj.limit_bottom = (zone.size.y + zone.position.y) * cell_size.y

func get_map():
	"""iterate the tile map for save to dictionnary"""
	var tile_bricks = self.get_node("tilemap_bricks")
	var dict_maps = {}
	var cell_tile_id; var cell_i = 0
	for cell in tile_bricks.get_used_cells():
		cell_tile_id = tile_bricks.get_cellv(cell)
		dict_maps[cell_i] = tile_bricks.tile_set.tile_get_name(cell_tile_id)
		cell_i += 1
	
	return dict_maps

func launch_ball(global_pos):
	"""launch the ball"""
	var ball_obj
	if not self._ball_launched:
		ball_obj = preload("res://ressources/scene/gameplay/ball.tscn").instance()
		self.add_child(ball_obj)
		ball_obj.spawn(global_pos)
		ball_obj.set_if_can_be_destroyed_at_bottom(self._ball_object_can_be_destroyed)
		self._cam_obj.add_target(ball_obj)
		self._ball_launched = true

func load_map():
	"""used for load the map"""
	var tile_bricks = self.get_node("tilemap_bricks")
	var pos
	var cell_id; var cell_name
	for cell in tile_bricks.get_used_cells():
		cell_id = tile_bricks.get_cellv(cell)
		cell_name = tile_bricks.tile_set.tile_get_name(cell_id)
		if not "black" in cell_name:
			pos = tile_bricks.map_to_world(cell) + Vector2(25,12)
			self.create_brick(pos, cell_name)
			self._maximum_bricks += 1

func get_brick_information(cell_name):
	"""used regex element for substract information from the cell name"""
	var dict_informations = {
		"colur" : "",
		"superpower" : ""} #26:16
	
	if "pink" in cell_name:
		dict_informations["colour"] = "pink"
	elif "green" in cell_name:
		dict_informations["colur"] = "green"
	elif "yellow" in cell_name:
		dict_informations["colur"] = "yellow"
	elif "blue" in cell_name:
		dict_informations["colur"] = "blue"
	
	if "plane" in cell_name:
		dict_informations["superpower"] = "plane"
	elif "heart" in cell_name:
		dict_informations["superpower"] = "heart"
	elif "bomb" in cell_name:
		dict_informations["superpower"] = "bomb"
	elif "rocket" in cell_name:
		dict_informations["superpower"] = "bomb"
	elif "bullet" in cell_name:
		dict_informations["superpower"] = "bullet"
	
	return dict_informations

func create_brick(global_pos, cell_name):
	"""create the object
	
	Take Args as:
		global_pos : Vector2 for the global position
		superpower : str (can be empty if the brick havn't no superpower')
		cell_name : str
	"""
	var brick_object = preload("res://ressources/scene/gameplay/brick.tscn").instance()
	brick_object._init_(global_pos, cell_name)
	
	self.get_node("bricks").add_child(brick_object)

func _input(event):
	var e_txt = event.as_text()
	if not "inputeventmousemotion" in e_txt.to_lower():
		self._cheatc_object.manage_cheat_code(event.as_text())

func manage_camera(mode, cam_object = null):
	var cam_gameplay = self.get_node("cam")
	
	match mode:
		"gameplay":
			if self._cam_debug:
				self._cam_debug.current = false
			
			cam_gameplay.current = true
			
			if self.has_node("cam_debug"):
				self._cam_debug.queue_free()
				self._cam_debug = null
			
		"debug":
			cam_gameplay.current = false
			
			self._cam_debug = Camera2D.new()
			self._cam_debug.current = true
			
			self.add_child(self._cam_debug)
			self._cam_debug.name = "cam_debug"
			
			self._cam_debug.global_position = cam_gameplay.global_position
			self._cam_debug.zoom = cam_gameplay.zoom
			
			self.init_cam(self._cam_debug)
		"rocket":
			if self._gameplay_mode in ["plane", "platform"] and self._gameplay_mode == "platform":
				cam_gameplay.current = false
				cam_object.current = true
				
				self.init_cam(cam_object)
		"character":
			print_debug("new_mode:", mode)
			print("cam_obj:",cam_object)
			
			cam_object.current = true
			
			self.init_cam(cam_object)
		"menu":
			if not cam_object:
				cam_object = self._cam_obj
			
			self._cam_menu = Camera2D.new()
			
			self._cam_menu.zoom = cam_object.zoom
			self._cam_menu.global_position = cam_object.global_position
			cam_object.current = false
			
			self._cam_menu.current = true
			
			self.add_child(self._cam_menu)
		
		"anim_pieces": #used to switch betwin character and platform camera
			self._cam_anim = Camera2D.new()
			self.add_child(self._cam_anim)
			
			if cam_object:
				self._cam_anim.zoom = cam_object.zoom
				self._cam_anim.global_position = cam_object.global_position
				cam_object.current = false
			
			self._cam_anim.current = true
			


func get_current_camera_object():
	match self._gameplay_mode:
		"platform":
			return self._cam_obj
		"plane":
			if self._dict_player_node["plane"]:
				return self._dict_player_node["plane"]._cam_object
			else:
				if self._is_player_on_web_app:
					self._jscript_object.eval("alert('Error Camera Not Foundt, you should reload this game')")
				else:
					push_error("Error Camera Not Foundt")
		"rocket":
			if self._dict_player_node["rocket"]:
				return self._dict_player_node["rocket"]._cam_object
			else:
				if self._is_player_on_web_app:
					self._jscript_object.eval("alert('Error Camera Not Foundt, you should reload this game')")
				else:
					push_error("Error Camera Not Foundt")
		"character":
			if self._dict_player_node["character"]:
				return self._dict_player_node["character"]._cam_object
			else:
				if self._is_player_on_web_app:
					self._jscript_object.eval("alert('Error Camera Not Foundt, you should reload this game')")
				else:
					print_stack()
					push_error("Error Camera Not Foundt")
					print_debug("dict_characters:", self._dict_player_node)
			
		"anim_pieces":
			return self._cam_anim

func manage_spawning_item_by_cheat_or_console(item_name,
												global_pos=null,
												is_rocket_rc = false,
												ammo = null):
	"""spawn items when the user used cheat code or console cmd"""
	if item_name:self.stats_object.add_item_spawned(item_name)
	
	var dict_items = {
		"coffee" : preload("res://ressources/scene/items/cofee.tscn"),
		"alcohol" : preload("res://ressources/scene/items/alcohol.tscn"),
		"rocket" : preload("res://ressources/scene/items/rocket.tscn"),
		"bullet" : preload("res://ressources/scene/items/bullet.tscn"),
		"bomb" : preload("res://ressources/scene/items/bomb.tscn"),
		"heart" : preload("res://ressources/scene/items/heart.tscn"),
		"plane" : preload("res://ressources/scene/vehicles/plane.tscn"),
		"rc_plane" : preload("res://ressources/scene/items/rc_item.tscn")
	}
	var item_parent_object = self.get_node("items")
	
	var object
	if not global_pos:global_pos = self.get_node("player/position2D_ball").global_position
	
	if item_name in dict_items:
		object = dict_items[item_name].instance()
		
		
		if "rocket" in item_name:
			if self._gameplay_mode != "platform": is_rocket_rc = false

			item_parent_object.add_child(object)
			object.spawn(is_rocket_rc, global_pos)
			
			if ammo:
				self.get_node("player")._weapon_data["rocket"] = ammo
	
		elif "plane" in item_name and not "rc" in item_name:
			if self._gameplay_mode == "platform":
				if not ammo:
					ammo = 4
				
				item_parent_object.add_child(object)
				object.spawn(global_pos, ammo)
				object.set_direction(self.get_map_size())
		else:
			item_parent_object.add_child(object)
			object.spawn(item_name, global_pos)

func get_map_size():
	"""
		Take Arguments As:
			mode (str) is used to specify if the value
			to return is horizontal or vertical
		return the size of the map
	"""
	return (1290+308)/2

func manage_explosion(global_pos, type = "", size_explosion = 0, play_pitch=1.0, play_volume=1.0):
	"""used for managing explosion
		
		Take argrs as:
			global_pos (Vector2)
			type (str)
			size_explosion (int) used when the type isn't specified
	"""
	var explosion_instance = preload("res://ressources/scene/effect/explosion.tscn").instance()
	
	self.call_deferred("add_child", explosion_instance)
	explosion_instance.spawn(global_pos, type, size_explosion)
	
	explosion_instance.set_sound(self, play_pitch, play_volume)

func set_gameplay_mode(new_gameplay_mode:String, player_node = null):
	"""
		Set the gameplay mode, used as help for knowing how the player
		is playing.
		
		Take Args As:
			new_gameplay_mode (string) is the new gameplay mode
			player_node (node object) can be the player's:
				plane object
				rocket object
				character object
			
			For the player's platform, doesn't need to be store in this 
				dictionnary
		
	"""
	if stats_object.get_if_gameplay_mode_is_already_added(self._gameplay_mode):
		self.stats_object.set_time_for_gameplay_mode(self._gameplay_mode, "end")
		if new_gameplay_mode != "anim_pieces":
			self.stats_object.set_time_for_gameplay_mode(new_gameplay_mode,"start")
	elif self._gameplay_mode != "anim_pieces":
		self.stats_object.set_time_for_gameplay_mode(self._gameplay_mode,"start")
	
	self._force_player_position = (new_gameplay_mode in ["plane"])
	var last_gameplay_mode = self._gameplay_mode
	
	if new_gameplay_mode in ["platform", "plane", "character", "rocket", "menu",
							"anim_pieces"]:
		self._gameplay_mode = new_gameplay_mode
		
		if new_gameplay_mode != "platform":
			self._dict_player_node[new_gameplay_mode] = player_node
		if last_gameplay_mode != "platform" and self._dict_player_node[last_gameplay_mode]:
			self._dict_player_node[last_gameplay_mode] = null


func set_if_ball_object_can_be_destroyed(b):
	self._ball_object_can_be_destroyed = b
	
	var ball_obj = self.get_node_or_null("ball")
	
	if ball_obj:
		ball_obj.set_if_can_be_destroyed_at_bottom(b)

func check_map_bottom():
	"""check when if the ball is under the limiet and make if true
		Make the player losing a life
		
		It's a bit the same for the items but items are destroyed
	"""
	var y_limit = 850
	var ball_node = self.get_node_or_null("ball")
	var list_children_obj = self.get_node("items").get_children()
	if ball_node:
		if ball_node.global_position.y > y_limit and ball_node._can_be_destroyed:
			self._ball_launched = false
			self._cam_obj.remove_target(ball_node)
			self._player_life -= 1
			ball_node.queue_free()
			
			self.get_node("player").set_ball(false)
			self.add_message("Survive "+str(self._player_life)+" time!")
			
	list_children_obj += self.get_node("character").get_children()
	list_children_obj += self.get_node("ammu").get_children()
	
	if len(list_children_obj) > 0:
		for c in list_children_obj:
			if not self.get_if_this_item_can_be_destroyed(["bomb", "rocket"], c.name):
				if c.global_position.y > y_limit:
					if c.has_method("destroy"):
						c.destroy()
					elif c.has_method("on_collision_bottom"):
						c.on_collision_bottom()
					elif c.has_method("on_collision_ball"):
						c.on_collision_ball()
					elif c.has_method("on_collision_explosion"):
						c.on_collision_explosion()
					else:
						c.queue_free()

func get_if_this_item_can_be_destroyed(list_name:Array, str_name:String):
	"""return if this object can be destroyed"""
	var can_be_destroyed = false
	for s in list_name:
		if not can_be_destroyed:
			can_be_destroyed = (s in str_name)
	
	return can_be_destroyed

func add_message(message:String):
	"""add message for showing it"""
	self._list_message.append(message)

func message_loop():
	"""
		Called from runtime for see message
	"""
	var player_node
	
	if self._dict_player_node["plane"]:
		player_node = self._dict_player_node["plane"]
	elif self._dict_player_node["rocket"]:
		player_node = self._dict_player_node["rocket"]
	elif self._dict_player_node["character"]:
		player_node = self._dict_player_node["character"]
	else:
		player_node = self._player_object_platform
		
	var message_object
	
	message_object = player_node.get_node_or_null("message_object")

	if len(_list_message) > 0:
		if message_object:
			if not message_object._show:
				message_object.reset()
				message_object.set_text(self._list_message[0])
				_list_message.pop_at(0)
		else:
			message_object = preload("res://ressources/scene/uth/message_user.tscn").instance()
			message_object.set_text(self._list_message[0])
			
			player_node.add_child(message_object)
			message_object.spawn(player_node.global_position)
			
			message_object.name = "message_object"
			
			_list_message.pop_at(0)

#func show_message(message):
#	"""
#		Called when the software want to show a message to the user
#		for the gameplay
#
#		message (string) is the message that will be show
#	"""
#	print_stack()
#	var player_node; var message_inst
#	var message_global_pos
#
#
#	if player_node.has_node("message_object"):
#		message_inst = player_node.get_node("message_object")
#		message_inst.reset()
#	else:
#		message_global_pos = player_node.global_position
#
#		message_inst = preload("res://ressources/scene/uth/message_user.tscn").instance()
#
#		player_node.add_child(message_inst)
#		message_inst.spawn(message_global_pos)
#		message_inst.name = "message_object"
#
#	message_inst.set_text(message)

func get_bricks_still():
	"""
		Return how much brick it stay
	"""
	return self.get_node("bricks").get_child_count()

func get_gameplay_mode():
	return self._gameplay_mode

func get_first_key_from_dict(dict_):
	"""
		Return the first key of the dictionnary passed as argumetn
	"""
	return dict_.keys()[0]

func add_sound_to_audiostreamplayer(audio_name:String, play_pitch=1.0, play_volume=1.0):
	"""
		Add sound (AudioStreamPlayer)
		
		Take Args As:
			audio_name (string) the stream name for a AudioStreamPlayerObject
			play_pitch (float) is the pitch for the AudioStreamPlayerObject
			play_volume (float) is the volume for the AudioStreamPlayerObject
	"""
	
	randomize()
	var key_name = audio_name+str(randi())
	
	var audiostreamplayer_obj = AudioStreamPlayer.new()
	audiostreamplayer_obj.stream = self.get_sound(audio_name)
	
	audiostreamplayer_obj.pitch_scale = play_pitch
	audiostreamplayer_obj.volume_db = play_volume
	
	audiostreamplayer_obj.play()
	
	self.get_node("sound").add_child(audiostreamplayer_obj)
	
	self._dict_audiostreamplayer_shoot[key_name] = [audiostreamplayer_obj, audio_name, play_pitch, play_volume]

func add_sound_audiostreamplayer2D(audio_name:String, play_pitch=1.0, play_volume=1.0):
#	if global_pos == Vector2.ZERO:
#		print_stack()
	
	randomize()
	var key_name = audio_name+str(randi())

	var audiostreamplayer2D_obj = AudioStreamPlayer2D.new()
	audiostreamplayer2D_obj.stream = self.get_sound(audio_name)
	audiostreamplayer2D_obj.pitch_scale = play_pitch
	audiostreamplayer2D_obj.volume_db = play_volume
	
	self._dict_audiostreamplayer_shoot[key_name] = [audiostreamplayer2D_obj,
													audio_name,
													play_pitch,
													play_volume]
	
	self.get_node("sound_audiostreamplayer2D").add_child(audiostreamplayer2D_obj)
	
	audiostreamplayer2D_obj.play()

func get_sound(item_name:String):
	"""used to get the sound object"""
	var dict_sound = {
		"bullet" : preload("res://ressources/sound/bullet_shoot.mp3"),
		"brick_impact" : preload("res://ressources/sound/brick_impact.wav"),
		"wall_impact" : preload("res://ressources/sound/wall_impact.wav"),
		"brick_impact_8bit" : preload("res://ressources/sound/character/broken_brick.wav"),
		"character_die_8bits" : preload("res://ressources/sound/character/die.wav"),
		"rocket_character" : preload("res://ressources/sound/character/shoot_rocket.wav"),
		"unbrocken_brick_character" : preload("res://ressources/sound/character/unbroken_brick.wav"),
		"rocket_collision_character":preload("res://ressources/sound/character/rocket_collision_character.wav"),
		"starting_on_jet_pack":preload("res://ressources/sound/character/jp/start.mp3"),
		"end_jet_pack":preload("res://ressources/sound/character/jp/end.mp3")}
	
	if self._gameplay_mode == "character":
		if item_name == "brick_impact":
			item_name += "_8bit"
	
	return dict_sound[item_name]

func check_sound():
	"""
		Foreach sound in the list_audiostreamplayer play the 
			sound and delete the sound
	
		Take Args As:
			play_pitch (1.0) : is the pitch for the audio stream player
			play_volume (1.0) : is the volume for the audio stream player
		
	"""
	var first_key; var list_value
	
	if len(self._dict_audiostreamplayer_shoot) > 0:
		first_key = self.get_first_key_from_dict(self._dict_audiostreamplayer_shoot)
		list_value = self._dict_audiostreamplayer_shoot[first_key]
		
		if not list_value[0].is_playing():
			self._dict_audiostreamplayer_shoot.erase(first_key)
	
	if len(self._dict_audiostreamplayer2D) > 0:
		first_key = self.get_first_key_from_dict(self._dict_audiostreamplayer2D)
		list_value = self._dict_audiostreamplayer2D[first_key]
		
		if not list_value[1].is_playing():
			self._dict_audiostreamplayer2D.erase(first_key)


func _button_pressed(txt:String):
	if txt == "Restart":
		self.get_tree().reload_current_scene()
	if txt == "save":
		self.export_score()
	if txt == "submit":
		#submit score
		pass
	if txt == "quit":
		pass


func set_console_visible(is_visible):
	"""
		Set if the game console is visible or not
	"""
	self.get_node("CanvasLayer").visible = is_visible
	self.get_node("CanvasLayer/Control").visible = is_visible
	self.get_node("CanvasLayer/Control/Panel").visible = is_visible


func destroy_touchbtn():
	for n in self.get_node("CanvasLayer").get_children():
		if n.name.begins_with("touchscreenbutton"):
			n.queue_free()


func _on_SaveFileDialog_file_selected(path):
	var f = File.new()
	f.open(path, File.WRITE_READ)
	var txt = self.stats_object.get_html_text()
	f.store_string(txt)
	f.close()


func setCharacterFuturSuperpower(new_superpower:String):
	character_futur_superpower = new_superpower

func play_animation():
	"""
		Called for playing camerra animation directly for theses lines of code
	"""
	var current_camera = self.get_current_camera_object()
	var current_cam_global_pos = current_camera.global_position
	var gameplay_cam_global_pos = self.get_node("cam").global_position
	var is_global_pos_x_the_same = (current_cam_global_pos.x > gameplay_cam_global_pos.x-0.10 and\
									 current_cam_global_pos.x < gameplay_cam_global_pos.x+0.10)
	var is_global_pos_y_the_same = (current_cam_global_pos.y > gameplay_cam_global_pos.y-0.10 and\
									 current_cam_global_pos.y < gameplay_cam_global_pos.y+0.10)
	
	var gameplay_cam_zoom = self.get_node("cam").zoom
	
	if current_cam_global_pos.x < gameplay_cam_global_pos.x-50 or\
	  current_cam_global_pos.y < gameplay_cam_global_pos.y-50:
		self._cam_anim_slide_speed = min(self._cam_anim_slide_speed+0.06, 30)
	elif current_cam_global_pos.x > gameplay_cam_global_pos.x+50 or\
	  current_cam_global_pos.y > gameplay_cam_global_pos.y+50:
		self._cam_anim_slide_speed = max(self._cam_anim_slide_speed-0.06, -30)
	
	if current_cam_global_pos.y < gameplay_cam_global_pos.y+10 or\
	  current_cam_global_pos.y > gameplay_cam_global_pos.y-10:
		if current_camera.zoom.x != gameplay_cam_zoom.x:
			current_camera.zoom.x = lerp(current_camera.zoom.x, gameplay_cam_zoom.x, 0.02)
			current_camera.zoom.y = lerp(current_camera.zoom.y, gameplay_cam_zoom.y, 0.02)
	
	if current_camera.global_position.x < gameplay_cam_global_pos.x:
		current_camera.global_position.x = min(current_camera.global_position.x+self._cam_anim_slide_speed,
												gameplay_cam_global_pos.x)
		
	elif current_camera.global_position.x > gameplay_cam_global_pos.x:
		current_camera.global_position.x = max(current_camera.global_position.x-self._cam_anim_slide_speed,
											gameplay_cam_global_pos.x)
	
	if current_camera.global_position.y > gameplay_cam_global_pos.y+0.01:
		current_camera.global_position.y = max(current_camera.global_position.x+self._cam_anim_slide_speed,
												gameplay_cam_global_pos.y)
	elif current_camera.global_position.y < gameplay_cam_global_pos.y+0.01:
		current_camera.global_position.y = min(current_camera.global_position.y+self._cam_anim_slide_speed,
											gameplay_cam_global_pos.y)
	
	if is_global_pos_x_the_same:
		self._cam_anim_slide_speed = lerp(self._cam_anim_slide_speed, 0.00, 0.10)
		self.set_gameplay_mode("platform")
		self.manage_camera("gameplay", current_camera)


func set_highscore_ui_enabled(enabled):
	var btn_object = self.get_node("CanvasLayer/HBoxContainerHighScore/buttonSubmitScore")
	if not OS.has_feature("mobile"):
		btn_object.disabled = (not enabled)
		btn_object.visible = enabled
	
	var textedit_object = self.get_node("CanvasLayer/HBoxContainerHighScore/textedit_user_name")
	textedit_object.visible = enabled
	textedit_object.readonly = (not enabled)


func _on_buttonSubmitScore_pressed():
	"""Called when the user wanted """
	var player_name = self.get_node("CanvasLayer/HBoxContainerHighScore/textedit_user_name").text
	if OS.has_touchscreen_ui_hint() or OS.has_feature("mobile"):
		player_name = JavaScript.eval("alert(\"Your username:\")")
	
	
	var t = self.stats_object.global_time_game()
#	var score =  {"time":self.stats_object.global_time_game(),
#				"brick_brocken":self._maximum_bricks-self._brick_still}
	
	var score = self._maximum_bricks-self._brick_still
	
	SilentWolf.Scores.persist_score(player_name, score, "main", {"time":t})
	SilentWolf.Scores.get_high_scores()
	
#	get_tree().change_scene("res://addons/silent_wolf/Scores/Leaderboard.tscn")
	Global.new_player_name = player_name
	Global.new_player_score = score
	Global.new_player_time = t
	get_tree().change_scene("res://ressources/scene/ui/control_leaderboard.tscn")

func automatic_platform_player():
	"""
		Used to manage the platform when this code control-it
	"""
	var ball_obj
	
	var list_items = self.get_all_items()
	var dict_ob_dist; var dict_items_dist
	if len(list_items) > 0:
		dict_items_dist = self.get_distance_items_platform(list_items)
		dict_ob_dist = self.get_lowest_distance_from_dict(dict_items_dist)
		if self.check_if_item_is_falling(dict_ob_dist):
			if dict_ob_dist["object"].name != "plane":
				self._lowest_object_distance = dict_ob_dist["distance"]
	
	if self.has_node("ball"):
		ball_obj = self.get_node("ball")
	
	if ball_obj:
		self._player_object_platform.global_position.x = ball_obj.global_position.x


func get_all_items(all=false):
	var l = []
	if all:
		return self.get_node("items").get_children()
	else:
		for c in self.get_node("items").get_children():
			if "plane" in c.name:continue
			l.append(c)
		
		return l


func get_distance_items_platform(list_all_obj):
	"""
		Get all distances items from platform
	"""
	var dict_obj_dist = {}
	var platform_gpos_x = self._player_object_platform.global_position.x
	var result = 0.00
	for o in list_all_obj:
		if o.name == "plane":
			continue
		else:
			result = abs(o.global_position.x) - abs(self._player_object_platform.global_position.x)
			dict_obj_dist[o] = result
	
	return dict_obj_dist


func get_lowest_distance_from_dict(dict_dist:Dictionary):
	"""
		Return the item that have have the lowest distance betwin
		it self and the player's platform
	"""
	var lowest_distance = 0.00; var lowest_object = null
	var distance = 0.00
	var dict_item_dist = {}
	for object in dict_dist:
		if dict_dist[object] < lowest_distance:
			lowest_distance = dict_dist[object]
			lowest_object = object
	
	return {"object":lowest_object,"distance":lowest_distance}


func check_if_item_is_falling(object):
	if typeof(object) == 2:
		return (object.global_position.y > 606)
	elif object['object'] != null:
		return (object["object"].global_position.y > 606)


func get_if_application_is_html5():
	"""
		Check if the player is on mobile or laptop
	"""
	self._is_player_on_web_app = (OS.get_naem() == "HTML5")
