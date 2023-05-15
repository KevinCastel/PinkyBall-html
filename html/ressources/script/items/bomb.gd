extends "res://ressources/script/items/item_object.gd"

var _chrono_explosion = 0
var _maximum_chrono_explosion = 100

onready var _progress_object = self.get_node("texture_progress")

onready var _parent_game_node = self.get_parent().get_parent()

func _process(_delta):
	"""main runtime"""
	self.sleeping = self._parent_game_node._pause
	
	if self._parent_game_node._pause: return
	
	self._progress_object.value = self._chrono_explosion
	if int(self._chrono_explosion) < self._maximum_chrono_explosion-30:
		self._chrono_explosion += 0.10
	else:
		self.explosion()
		self.destroy()

func explosion():
	"""used when this object explode"""
	self._parent_game_node.manage_explosion(self.global_position, "bomb")

func on_bullet_collision():
	"""called when this object is colliding with bullet object"""
	self.explosion()
	self._chrono_explosion = self._maximum_chrono_explosion-30

func on_explosion_collision():
	"""called when this object is collding with object explosion"""
	self.explosion()

func set_explosion_chrono_on_collision():
	"""Refresh the chrono value when this object collide"""
	self._chrono_explosion += int(self.linear_velocity.x + self.linear_velocity.y)*10.00
	

func _on_bomb_body_entered(_body):
	self.create_audio_stream_playerD("collision_bomb", 0.7, self.get_sound_volume("bomb"))
	self.set_explosion_chrono_on_collision()

func _on_bomb_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	#self.add_sound("bomb_impact", 0.7, self.get_sound_volume())
	self.create_audio_stream_playerD("collision_bomb", 0.7, self.get_sound_volume("bomb"))
	self.set_explosion_chrono_on_collision()

#func delete_sound():
#	var first_key
#	if len(self._dict_sound) > 0:
#		first_key = self._parent_game_node.get_first_key_from_dict(self._dict_sound)
#
#		if not self._dict_sound[first_key].is_playing():
#			if self.get_node_or_null("sound/"+first_key):
#				self.get_node("sound/"+first_key).queue_free()
#				self._dict_sound.erase(first_key)

#func create_audio_stream_playerD(sound_name, play_pitch=1.0, play_volume_db=1.0):
#	"""
#		Add sound (AudioStreamPlayer2D) to this object
#	"""
#	var dict_sound = {
#		"bomb_impact" : preload("res://ressources/sound/bomb_impac.wav")
#	}
#	randomize()
#	var n = sound_name+str(randi())
#
#	var audio_stream_player_2D_object = AudioStreamPlayer2D.new()
#	audio_stream_player_2D_object.name = n
#
#	self._dict_sound[n] = audio_stream_player_2D_object
#	audio_stream_player_2D_object.stream = dict_sound[sound_name]
#
#	audio_stream_player_2D_object.volume_db = play_volume_db
#	audio_stream_player_2D_object.pitch_scale = play_pitch
#
#	self.get_node("sound").add_child(audio_stream_player_2D_object)
#
#	audio_stream_player_2D_object.play()
