extends StaticBody2D

"""global script used for bricks"""

var _can_be_destroyed = false

var _superpower = ""

var brick_index = {"plane_white":0,
		"plane_blue":1,
		"plane_green":2,
		"plane_yellow":3,
		"plane_pink":4,
		"coffee_white":5,
		"coffee_blue":6,
		"coffee_green":7,
		"coffee_yellow":8,
		"coffee_pink":9,
		"slowerball_white":10,
		"slowerball_blue":11,
		"slowerball_green":12,
		"slowerball_yellow":13,
		"slowerball_pink":14,
		"deathhead_white":15,
		"deathhead_blue" :16,
		"deathhead_green":17,
		"deathhead_yellow":18,
		"deathhead_pink":19,
		"bomb_white":20,
		"bomb_blue":21,
		"bomb_green":22,
		"bomb_yellow":23,
		"bomb_pink":24,
		"alcohol_white":25,
		"alcohol_blue":26,
		"alcohol_green":27,
		"alcohol_yellow":28,
		"alcohol_pink":29,
		"money_white":30,
		"money_blue":31,
		"money_green":32,
		"money_yellow":33,
		"money_pink":34,
		"rocket_blue":35,
		"rocket_white":36,
		"rocket_green":37,
		"rocket_yellow":38,
		"rocket_pink":39,
		"bullet_white":40,
		"bullet_blue":41,
		"bullet_yellow":42,
		"bullet_green":43,
		"bullet_pink":44,
		"heart_white":45,
		"heart_blue":46,
		"heart_green":47,
		"heart_yellow":48,
		"heart_pink":49,
		"white":50,
		"blue":51,
		"pink":52,
		"yellow":53,
		"green":54,
		"black":55,
		"rc_pink":57,
		"rc_yellow":58,
		"rc_blue" : 59,
		"rc_green" : 60}

onready var _parent = self.get_parent().get_parent()

var _colur = ""

var _audiostreamplayer_obj

func _init_(global_pos, cell_name):
	"""constructor of this object
	
	Take argument as:
		global_pos (Vector2) for global position
		
		superpower (str) if doesn't have superpower
	"""
	self.global_position = global_pos
	
	var brick_name = self.set_colur(cell_name)
	
	self._superpower = self.set_superpower(cell_name)
	
	if self._superpower:
		brick_name = self._superpower + "_" + brick_name
	
	self.get_node("sprite").frame = self.get_index_brick(brick_name)
	

func add_audiostreamplayer():
	self._audiostreamplayer_obj = AudioStream.new()
	self._audiostreamplayer_obj.stream = preload("res://ressources/sound/brick_impact.wav")
	self._audiostreamplayer_obj.play()
	
	self._parent.add_sound_audiostreamplayer2D(self._audiostreamplayer_obj)

func get_index_brick(cell_name):
	"""return the index"""
	var index = 0
	if "rc_plane" in cell_name: cell_name = "rc_"+self._colur
	index = self.brick_index[cell_name]
	return index

func set_superpower(cell_name):
	"""return superpower"""
	if "rc" in cell_name:
		return "rc_plane"
	if "plane" in cell_name:
		return "plane"
	elif "bomb" in cell_name:
		return "bomb"
	elif "bullet" in cell_name:
		return "bullet"
	elif "rocket" in cell_name:
		return "rocket"
	elif "coffee" in cell_name:
		return "coffee"
	elif "alcohol" in cell_name:
		return "alcohol"

func set_colur(cell_name): #1:43:20
	"""return the color"""
	if "pink" in cell_name:
		self._colur = "pink"
		return "pink"
	elif "green" in cell_name:
		self._colur = "green"
		return "green"
	elif "yellow" in cell_name:
		self._colur = "yellow"
		return "yellow"
	elif "blue" in cell_name:
		self._colur = "blue"
		return "blue"

func get_colur():
	"""return the colur of this object"""
	return self._colur

#func on_ball_impact():
#	"""called when the ball imapcted this object (brick)"""
#	print_stack()
#	if self._superpower != "":
#		self._parent.manage_spawning_item_by_cheat_or_console(self._superpower,
#															self.global_position)
#
#	self._parent.add_message(str(self._parent.get_bricks_still())+" bricks yet")
#	self.destroy_object()


func on_impact():
	"""Called when a specific type of bject collide with this object"""
	if self._superpower != "":
		self._parent.manage_spawning_item_by_cheat_or_console(self._superpower,
															self.global_position)

	self._parent.add_message(str(self._parent.get_bricks_still())+" bricks yet")
	self.destroy_object()


func on_character_collision():
	"""called when a character's head collides with this object"""
	if self._superpower != "plane" and self._parent._gameplay_mode != "platform":
		if self._superpower != "":
			self._parent.manage_spawning_item_by_cheat_or_console(self._superpower,
																self.global_position)
	self.destroy_object()

func destroy_object():
	"""destroy the object"""
	self._parent.add_sound_audiostreamplayer2D("brick_impact", 1.0, 1.0)
	self.queue_free()

func get_superpower():
	return self._superpower

func on_collision_explosion():
	"""called when collide with explosion object"""
	self.destroy_object()
