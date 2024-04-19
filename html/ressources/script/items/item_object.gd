extends RigidBody2D

var _type = ""

var _dict_sound = {}

func spawn(type, global_pos):
	self._type = type
	
	self.global_position = global_pos
	
	self.get_geometry()
	
	if "bullet" in self.name:self.set_colur([216,36,124])
	
	self.sleeping = false
	self.can_sleep = false
	
	self.contact_monitor = true
	self.contacts_reported = 5
	
	if self.has_method("play_animation"):
		self.call_deferred("play_animation")
	if self.has_method("start_sound"):
		self.call_deferred("start_sound")

func _process(_delta):
	"""runtime of this object, sometime overwrite in instance"""
	self.delete_audio_player()

func set_colur(new_colur):
	"""set colur"""
	var colur
	var colur_list
	if typeof(new_colur) == TYPE_ARRAY:
		colur = Color8(new_colur[0], new_colur[1], new_colur[2])
	elif typeof(new_colur) == TYPE_STRING:
		colur_list = Color(new_colur)
		colur = Color8(colur_list[0]*255, colur_list[1]*255, colur_list[2]*255)
	self.get_node("sprite").modulate = colur

func get_geometry():
	"""return the geomertry"""
	var rect = int(self.get_node("sprite").get_rect().get_area())
	
	self.weight = (rect/200)-0.32*0.32

func destroy():
	"""destroy this object"""
	self.queue_free()

func create_audio_stream_playerD(audio_name:String, play_pitch = 1.0, play_volume_db=1.0):
	"""
		Called on event collision for example and add a AudioStreamPlayer2D
		for playing a collision sound

		Take Args As:
			audio_name (String, used for the node name the key name in _dict_sound)
			play_pitch (float, pitch_scale for the AudioStreamPlayer2D)
			play_volume_db (float, volume_db for the AudioStreamPlayer2D)
	"""
	randomize()
	var n = audio_name+str(randi())
	var dict_sound = {
		"collision_rocket" : preload("res://ressources/sound/vehicle/plane_impact.wav"),
		"collision_coffee" : preload("res://ressources/sound/coffee_impact.wav"),
		"collision_bomb" : preload("res://ressources/sound/bomb_impac.wav"),
		"collision_bullet" : preload("res://ressources/sound/bullet_collision.wav")
	}
	var audio_stream_player_2D_object = AudioStreamPlayer2D.new()
	audio_stream_player_2D_object.pitch_scale = play_pitch
	audio_stream_player_2D_object.volume_db = play_volume_db
	audio_stream_player_2D_object.stream = dict_sound[audio_name]
	audio_stream_player_2D_object.name = n
	
	self.get_node("sound").add_child(audio_stream_player_2D_object)
	self._dict_sound[n] = audio_stream_player_2D_object

	audio_stream_player_2D_object.play()

func delete_audio_player():
	"""
		Delete the AudioStreamPlayer
	"""
	var first_key
	if len(self._dict_sound):
		first_key = self._dict_sound.keys()[0]
		if not self._dict_sound[first_key].is_playing():
			if self.get_node_or_null("sound/"+first_key):
				self.get_node("sound/"+first_key).queue_free()
			
			self._dict_sound.erase(first_key)

func get_sound_volume(object_type):
	match object_type:
		"bomb":
			return 0+((self.linear_velocity.y + self.linear_velocity.x)*3)
		"rocket":
			return (10+(self.linear_velocity.x+self.linear_velocity.y)*5)
		"bullet":
			return -40+((self.linear_velocity.y + self.linear_velocity.x)/1.80)
		"coffee":
			return -10+((self.linear_velocity.y + self.linear_velocity.x)/1.00)

func get_audio_pitch(object_type):
	"""Return pitch_scale for a AudioStreamPlayer2D when colliding"""
	match object_type:
		"bomb":
			return (1.0+((self.linear_velocity.x+self.linear_velocity.y)/10)*2)
		"rocket":
			return (1.0+(self.linear_velocity.y+self.linear_velocity.x)/1)
		"alcohol":
			return (1.0+(self.linear_velocity.y+self.linear_velocity.x)/self.linear_velocity.length())
		"bullet":
			return (1.0)


func _on_alcohol_body_entered(body):
	if "alcohol" in body.name:
		self.create_audio_stream_playerD("alcohol")

func _on_alcohol_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if "alcohol" in body.name:
		self.create_audio_stream_playerD("alcohol", self.get_audio_pitch("alcohol"), self.get_sound_volume("alcohol"))
