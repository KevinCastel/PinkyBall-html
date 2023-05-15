extends "res://ressources/script/items/item_object.gd"

var _vel = Vector2.ZERO
var _speed = 0
var _is_rc = false

var _engine = false

var _chrono_engine = 0
var _maximum_chrono_engine = 100

var _cam_obj

var _acceleration_value = 0.10

var _explode_key_pressed = 0

onready var _raycast_explose_object = self.get_node("raycast2D_explosion")

func spawn(is_rc = false, global_pos = Vector2.ZERO):
	var parent = self.get_parent().get_parent()
	self._raycast_explose_object.enabled = false
	
	if parent._gameplay_mode != "platform" and is_rc:
		is_rc = false
	
	self._type = "rocket"
	self._is_rc = is_rc
	self.global_position = global_pos
	
	self.contact_monitor = 10
	
	if is_rc:
		self._acceleration_value = 0.015
		self._cam_obj = Camera2D.new()
		self.add_child(self._cam_obj)

		parent.manage_camera("rocket", self._cam_obj)

func _physics_process(_delta):
	"""main runtime"""
	if self._engine:
		self.check_sound_format()
		
		self._vel = self.transform.x * self._speed
		
		self._speed = lerp(self._speed, 1.3, self._acceleration_value*((0.1+self._speed)/4))
		
		self.add_force(Vector2.ZERO, self._vel)
		
		if self._is_rc:self.check_input()
		
	else:
		self.chrono_starting_off()
	self.play_sound()
	
	if self.get_node("raycast2D_explosion").is_colliding():
		self.explode()

func check_sound_format():
	"""
		Check format when it need-it
	"""
	var parent = self.find_parent("game")
	var audio_stream_player_object = self.get_node("audiostreamplayer2D_motor")
	var audio_stream_sampler_object = audio_stream_player_object.stream
	if not self.get_if_sound_is_pixelated(audio_stream_sampler_object) and\
		parent._gameplay_mode == "character":
			audio_stream_player_object = self.set_sound_format(true)
	elif self.get_if_sound_is_pixelated(audio_stream_sampler_object) and\
		parent._gameplay_mode != "character":
			audio_stream_player_object = self.set_sound_format(false)

func set_sound_format(set_8bit_format):
	"""
		Set format sound
	"""
	if set_8bit_format:
		return AudioStreamSample.FORMAT_8_BITS
	else:
		return AudioStreamSample.FORMAT_16_BITS

func get_if_sound_is_pixelated(stream_object):
	"""
		Get if sound is in 8 bits format
	"""
	return (stream_object.format == AudioStreamSample.FORMAT_8_BITS)

func check_input():
	"""manage input from the user"""
	var rotate = 0
	if Input.is_action_just_pressed("player_right"):
		rotate = 100
	elif Input.is_action_just_pressed("player_left"):
		rotate = -100
	
	self.applied_torque = rotate
	self.applied_torque = lerp(self.applied_torque, 0.00, 0.10)
	
	if Input.is_action_pressed("player_launch_ball"):
		self._acceleration_value = min(self._acceleration_value+0.13, 1.50)
	elif Input.is_action_pressed("player_down"):
		self._acceleration_value = max(self._acceleration_value-0.05, 0.30)
		
	if Input.is_action_just_released("action"):
		if self._explode_key_pressed < 3:
			self._explode_key_pressed += 1
		else:
			self.explode()

func chrono_starting_off():
	"""refresh the chrono"""
	self.get_node("texture_progress").value = self._chrono_engine
	if int(self._chrono_engine) < self._maximum_chrono_engine:
		self._chrono_engine += 0.30
	else:
		self._engine = true
		self._raycast_explose_object.enabled = true

func explode():
	"""called for the explosion"""
	var parent = self.get_parent().get_parent()
	if self._is_rc:
		self._cam_obj.current = false
		self._cam_obj.queue_free()
		if parent._gameplay_mode == "platform":
			parent.manage_explosion(self.global_position,"rocket")
			parent.manage_camera("gameplay")
	
	parent.manage_explosion(self.global_position, "rocket")
	
	self.queue_free()

func set_layer_collision_():
	"""disabled the layer"""
	self.set_collision_layer_bit(10,true)
	self.set_collision_layer_bit(2 ,false)

func play_sound():
	"""
		Called from the runtime
		
		Used to play idle and/or run motor, can change the pitch and volume_db
		 by the speed
	"""
	var audiostreamplayer2D_motor_obj = self.get_node("audiostreamplayer2D_motor")
	var audiostreamplayer2D_loading_obj = self.get_node("audiostreamplayer2D_load")
	if not self._engine:
		audiostreamplayer2D_loading_obj.pitch_scale = 0.7+self._chrono_engine/20
		audiostreamplayer2D_loading_obj.volume_db = 0.4+self._chrono_engine/10
		
		if not audiostreamplayer2D_loading_obj.is_playing():
			audiostreamplayer2D_loading_obj.play()
	
	audiostreamplayer2D_motor_obj.pitch_scale = 0.7+(1+self._speed)
	audiostreamplayer2D_motor_obj.volume_db = -23+((self._chrono_engine/10)+(self._speed/10))
	if not audiostreamplayer2D_motor_obj.is_playing():
		audiostreamplayer2D_motor_obj.play()
	else:
		audiostreamplayer2D_loading_obj.volume_db = max(
					audiostreamplayer2D_loading_obj.volume_db-0.10,
					-23)


func _on_rocket_body_entered(_body):
	self.create_audio_stream_playerD("rocket_collision", self.get_audio_pitch("rocket"), self.get_sound_volume("rocket"))

func _on_rocket_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	self.create_audio_stream_playerD("rocket_collision", self.get_audio_pitch("rocket"), self.get_sound_volume("rocket"))
