extends Area2D


var _type = ""

var _actual_size = 1
var _max_size = 1

var _chrono_by_frame = 0
var _max_chrono_by_frame = 1

onready var _parent = self.get_parent()

var _bricks_destroyed = 0


var _dict_sound = {
	"plane" : preload("res://ressources/sound/plane_explosion.mp3"),
	"bomb" : preload("res://ressources/sound/bomb_explosion.mp3"),
	"rocket" : preload("res://ressources/sound/plane_explosion.mp3"),
	"8bit" : preload("res://ressources/sound/character/explosion.wav")
	}

var _sound_obj

onready var _light_explosion = self.get_node("Light2D")

func _physics_process(_delta):
	"""main runtime"""
	if self._parent._pause: return
	
	
	if self._chrono_by_frame < self._max_chrono_by_frame:
		self._chrono_by_frame += 1
	else:
		self._chrono_by_frame = 0
		
		if self._actual_size < self._max_size:
			self._actual_size += 1
			
			self.scale = Vector2(self._actual_size, self._actual_size)
		else:
			if self._bricks_destroyed > 0:
				self._parent.add_message(str(self._bricks_destroyed)+" explosed!")
				#self._parent.show_message(str(self._bricks_destroyed)+" explosed!")
			
			if not self._sound_obj.playing:
				self.queue_free()
			elif self.visible:
				self.visible = false


func spawn(global_pos = Vector2.ZERO, type = "", max_size=0):
	"""
		Called for spawning the object take arg as
		
		global_pos (Vector2) is the global position
		
		max_size (is to reach as maximum) max size is is not always
		specified, you can use the argument wich will get automacly the
		size
	"""
	self._type = type
	if type != "":
		if max_size == 0:
			self._max_size = self.get_max_size_by_explosion_type(type)
		else:
			self._max_size = max_size
	else:
		self._max_size = max_size
	
	self.global_position = global_pos
	
#	if type:
#		self._light_explosion = self.get_node("Light2D")
#		self._light_explosion.texture_scale = self.get_light2D_scale(type)
#		self._light_explosion.energy = self.get_light2D_energy()


func get_light2D_scale(weapon_name):
	match weapon_name:
		"bomb":
			return 2.50
		"rocket":
			return 3
		"micro_bomb":
			return 1.15
		"micro_rocket":
			return 1.70


func get_light2D_energy():
	return 0.30+self.get_node("Light2D").scale


func set_sound(game_obj, play_pitch=1.0, _play_volume=1.0):
	"""
		Set AudioStream2D with setting up some variables for the sound object
		
		Take Args As:
			play_pitch (by default 1) is the default pitch for the AudioStreamPlay2D
			play_volume (by default 1) is the default speeed for the AudioStreamPlay2D
	"""
	self._sound_obj = AudioStreamPlayer2D.new()
	self.add_child(self._sound_obj)
	
	self._sound_obj.pitch_scale = play_pitch
	
	if self._type in self._dict_sound:
		self._sound_obj.stream = self._dict_sound[self._type]
	else:
		self._sound_obj.stream = self._dict_sound["bomb"]
		self._sound_obj.pitch_scale = 1.7
	
	if game_obj:
		if game_obj._gameplay_mode == "character":
			self._sound_obj.stream = self._dict_sound["8bit"]
	
	self._sound_obj.play()


func get_max_size_by_explosion_type(type):
	"""Return value by default the explosion's max size"""
	match type:
		"bomb":
			return 20
		"rocket":
			return 40
		"micro_bomb":
			return 2
		"micro_rocket":
			return 6


func _on_explosion_area_entered(area):
	self.explosion(area)


func _on_explosion_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	self.explosion(area)


func _on_explosion_body_entered(body):
	self.explosion(body)
	self._bricks_destroyed += int("brick" in body.name)


func _on_explosion_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	self.explosion(body)
	self._bricks_destroyed += int("brick" in body.name)


func explosion(body):
	if body.has_method("on_collision_explosion"):
		if "brick" in body.name and "micro" in self._type:
			self.add_stats()
		body.on_collision_explosion()
	elif body.has_method("on_explosion_collision"):
		body.on_explosion_collision()


func add_stats():
	self._parent.stats_object.add_ammo_brick_broken(self._type)
