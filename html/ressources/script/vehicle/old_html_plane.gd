extends RigidBody2D

"""
script for this object

Here some detail:
	
	direction = 1 (right) or
	direction = -1 (left)
	
	this is used for set the direction of the project
"""

const _MAX_CHRONO_BRICK_SECOND = 2

var _spawn_unix_time = self.get_unix_time()

var _direction = -1

var _speed = 6; var _maximum_speed = 18

var _vel = Vector2.ZERO; var _accel = 30

var _turning_braking = 0;var _fuel = 1000

var _cam_object

var first_explosion_size = 10

var _dict_explosion_size = {"first": 10, "last":20, "running": 15}

var _count_explosion = 0;var _maximum_explosion = 3

var _delay_between_explosion = 150; var _delay_explosion = 0

var _life = 100

onready var _parent = self.get_parent().get_parent()

var _have_explosed_for_the_first_time = false

var _is_character_in_plane = true

var _block_pos = false

var _ammo = 4

var _list_collision = []

var _can_collide_with_brick = false

var _dict_sound = {}

var _weapon_pitch = 1.0

var _can_be_destroyed = false


func set_block_pos(v):
	"""used for freeze the sliding of this object"""
	self._block_pos = v


func spawn(global_pos, ammo=4):
	"""
		Used for spawn this object
		And setting information on this object
		
		Take Args As:
			global_pos (Vector2D) is where this object will spawn (global position)
			ammo (int) is the number of ammo in the plane that the player can shoot
		
	"""
	self.global_position = global_pos
	self.global_position.y -= 10
	
	self._ammo = ammo
	
	self.create_cam()
	
	self.contact_monitor = true
	self.contacts_reported = 4
	
	self.rotation_degrees = 34
	
	self.set_collision_brick(false)
	self.set_collision_ball(false)


func _physics_process(_delta):
	"""mainruntime for this object"""
	self.sleeping = self._parent._pause
	if self._parent._pause:return
	
	self.set_rotation_speed()
	
	self.play_sound()
	self.play_motor_sound()
	
	if not self._can_collide_with_brick:
		if self.get_unix_time() > self._spawn_unix_time+self._MAX_CHRONO_BRICK_SECOND:
			if not self.get_if_is_colliding_with():
				self.set_collision_brick(true)
				self._can_collide_with_brick = true
				self.set_collision_ball(true)
	
	self.check_explosion()
	if self._speed<=0:self._speed = 0
	
	self._weapon_pitch = lerp(self._weapon_pitch, 0.00, 0.10)
	
	if Input.is_action_just_released("get-out_plane") and self._count_explosion < 2\
		and self._is_character_in_plane:
		self._is_character_in_plane = false
		self.spawn_player_character()
		self.remove_cam("character")
	
	if self._count_explosion == 0:
		if self._block_pos:return
		self.get_direction()
		self.get_acceleration()
		if self._is_character_in_plane:
			self.check_flip()
		
		self.apply_impulse(Vector2.ZERO, self._vel)
		
		self.gravity_scale = 1/((12+self._speed)/2)
		
		if Input.is_action_just_released("plane_shoot") and self._ammo > 0 and\
			self._is_character_in_plane:
			self.shoot()
		
		if Input.is_action_just_released("player_change_direction"):
			if self._direction == 1:
				self._direction = -1
				self.flip_object("right")
				self._vel.x = -self._vel.x
				self.apply_impulse(Vector2.ZERO, self._vel)
			else:
				self._direction = 1
				self.flip_object("left")
				self._vel.x = abs(self._vel.x)
				self.apply_impulse(Vector2.ZERO, self._vel)
		
	elif self._delay_explosion < self._delay_between_explosion:
		self._delay_explosion += 1
		self.applied_torque = lerp(self.applied_torque, 0.00, 0.10)
	elif self._count_explosion < self._maximum_explosion:
		self._speed -= 10
		self._delay_explosion = 0
		self._count_explosion += 1
		self.set_explosion_colour(40)
		self._parent.manage_explosion(self.global_position,
			"plane",
			self._dict_explosion_size["running"])
	elif self._is_character_in_plane:
		self.remove_cam("platform")
		self.queue_free()
	elif self._can_be_destroyed:
		self.queue_free()


func set_rotation_speed():
	var additionnal_speed = 0
	if self._direction == 1:
		if self.global_rotation_degrees > 0:
			additionnal_speed = self.global_rotation_degrees/100000
		elif self.global_rotation_degrees < 0:
			additionnal_speed = -abs(self.global_rotation_degrees/100000)
	
	self._speed += additionnal_speed


func spawn_player_character():
	"""called for making spawn the player character"""
	var player_character_inst = preload(
		"res://ressources/scene/character/character.tscn").instance()
	
	self._parent.get_node("character").add_child(player_character_inst)
	
	player_character_inst.spawn(self.global_position,
		"pink")
	self._parent.set_gameplay_mode("character")


func set_collision_brick(can_collide_with_brick:bool):
	"""
		Set the collision between this object and the brick objects
		
		Take Arg As:
			can_collide_with_brick (bool)
	"""
	self.set_collision_mask_bit(5, can_collide_with_brick)


func set_collision_ball(can_collide_with_ball:bool):
	self.set_collision_mask_bit(3, can_collide_with_ball)



func is_sliding(both=true):
	"""
	Take Args as both (bool) that mean if this object have to be
	stop or can slide by his x or his y else return if this
	object is stop
	return if this object is sliding based on the linear velocity"""
	var is_y_sliding = (self.linear_velocity.x > 0.10 or\
		self.linear_velocity.x < -0.10)
	var is_x_sliding = (self.linear_velocity.y > 0.10 or\
		self.linear_velocity.y < -0.10)
	if both:
		return (is_x_sliding or is_y_sliding)
	else:
		return (is_x_sliding and is_y_sliding)


func make_last_explosion():
	if not is_sliding():
		self._parent.manage_explosion(self.global_position,
			"plane",
			self._dict_explosion_size["last"])


func check_explosion():
	"""check when this object is have less than 0 life for making explosion"""
	if self._life <= 0 and self._count_explosion == 0:
		self._count_explosion = 1


func set_direction(map_rect_horizontal):
	"""
		set the direction of this object,
		if this object is to the right of the
		screen, the direction is set to the left
		if this object is to the lef of the screen
		the direction is set to the right
	"""
	if self.global_position.x > map_rect_horizontal/2:
		self._direction = -1
		self.flip_object("right")
	else:
		self._direction = 1
		self.flip_object("left")
	
	if self._direction == 1:
		self.rotation_degrees *= -1


func flip_object(new_direction):
	"""used for set the direction"""
	var sprite = self.get_node("sprite")
	var coll_right = self.get_node("collision_right")
	var coll_left = self.get_node("collision_left")
	
	var coll_area2D_right = self.get_node("area2D/collision_right")
	var coll_area2D_left = self.get_node("area2D/collision_left")
	
	var muzzle_node = self.get_node("position2D_muzzle")
	match new_direction:
		"right":
			sprite.flip_h = true
			coll_left.disabled = true
			coll_right.disabled = false
			muzzle_node.position.x = -24
			coll_area2D_left.disabled = true
			coll_area2D_right.disabled = false
		"left":
			sprite.flip_h = false
			coll_left.disabled = false
			coll_right.disabled = true
			muzzle_node.position.x = 24
			
			coll_area2D_left.disabled = false
			coll_area2D_right.disabled = true


func get_acceleration():
	"""
		Called for getting the acceleration (input included)
	"""
	if Input.is_action_pressed("player_launch_ball") and self._is_character_in_plane:
		self._maximum_speed = min(self._maximum_speed+0.10, 18)
	elif Input.is_action_pressed("player_down") and self._is_character_in_plane:
		self._maximum_speed = max(self._maximum_speed-0.10, 10)
	
	if self._speed > self._maximum_speed:
		self._speed = self._maximum_speed
	
	self._speed = lerp(self._speed, 0.00, 0.00002)
	self._vel = self.transform.x * (self._speed*self._direction)


func get_direction():
	"""
		Called for getting the direction (input included)
		
		Also reduce the speed when the user turn
	"""
	var turn = 0
	if Input.is_action_pressed("player_left") and self._is_character_in_plane:
		turn = 300
		self._turning_braking = min(self._turning_braking+0.05,0.2)
	elif Input.is_action_pressed("player_right") and self._is_character_in_plane:
		turn = -300
		self._turning_braking = min(self._turning_braking+0.05, 0.2)
	
	self._turning_braking = lerp(self._turning_braking,0.00, 0.05)
	self._speed -= self._turning_braking
	
	self.applied_torque = turn
	self.applied_torque = lerp(self.applied_torque, 0.00, 0.10)


func create_cam():
	"""used for creating camera object"""
	self._cam_object = Camera2D.new()
	
	self.add_child(self._cam_object)
	
	self._cam_object.current = true
	
	self._parent.init_cam(self._cam_object)
	
	self._parent.manage_camera("plane", self._cam_object)
	self._parent.set_gameplay_mode("plane", self)


func remove_cam(new_type:String):
	"""
		Use to remove remove Camera an change the gameplay mode
		
		Bug here
		
		Take Args As:
			new_type:str
	"""
	if new_type == "platform":
		self._parent.manage_camera("gameplay")
	else:
		if self._cam_object:
			self._cam_object.current = false
			self._cam_object.queue_free()
			self._cam_object = null
	self._parent.set_gameplay_mode(new_type)


func destroy():
	"""rewrite for debuging"""
	if not self._have_explosed_for_the_first_time:
		self._have_explosed_for_the_first_time = true
		self._life = 0
		self.set_explosion_colour(20)
		self._parent.manage_explosion(self.global_position,
			"plane",
			self._dict_explosion_size["first"])


func take_damage():
	"""make damage"""
	var damage = self.linear_velocity.x + self.linear_velocity.y
	damage /= 1200
	self._life = damage
	self._speed -= 2*damage
	
	self.add_sound("plane_impact", 1.0+(self._speed/10), -10+(damage*2))
	
	if self._life <= 0:
		self._parent.manage_explosion(self.global_position,
			"plane",
			self._dict_explosion_size["first"],
			1.0+self._count_explosion/10,
			1.0+self._count_explosion/10)


func set_explosion_colour(value_to_substract:float):
	"""change the colour of this object
	for making this object more dark
	use value_to_substract to substract value
	"""
	var colur = self.modulate
	colur.a8 -= value_to_substract
	colur.g8 -= value_to_substract
	colur.r8 -= value_to_substract
	self.modulate = colur


func _on_plane_body_entered(_body):
	self.take_damage()


func _on_plane_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	self.take_damage()


func shoot():
	"""called when the player shoot"""
	var bullet = preload("res://ressources/scene/ammu/plane_ammu.tscn").instance()
	var rota = self.global_rotation_degrees
	if self._direction != 1:
		rota -= 180
	
	bullet.spawn(self.get_node("position2D_muzzle").global_position,
		rota,
		self.linear_velocity.x,
		self.linear_velocity.y)
	self._ammo -= 1
	self._parent.get_node("ammu").add_child(bullet)
	
	self._parent.stats_object.add_ammo_fired("plane_m4")
	
	self.add_sound("plane_shoot", 1.0+self._weapon_pitch)
	self._weapon_pitch += 0.25


func check_flip():
	"""
		Check when the rotation and the flip arn't coordinate for this object
		
		bug here:
			rotation_degrees (float)
	"""
	if self.rotation_degrees < -90 and self._direction == 1:
		self.rotation_degrees = -90
	elif self.rotation_degrees > 90 and self._direction == 1:
		self.rotation_degrees = 90
	elif self.rotation_degrees < -90 and self._direction == -1:
		self.rotation_degrees = -90
	elif self.rotation_degrees > 90 and self._direction == -1:
		self.rotation_degrees = 90



func _on_area2D_body_entered(body):
	"""event used for """
	if "brick" in body.name or "ball" in body.name:
		self._list_collision.append(body.name)
		#self._can_set_brick_collision = false


func check_if_list_collision_contains_str(list_to_check:Array, s:String):
	"""check if a list contains s (str) argument"""
	var is_containing_string = false
	for e in list_to_check:
		if not is_containing_string:
			is_containing_string = (s in e)
	return is_containing_string


func _on_area2D_body_exited(body):
	"""event used when colliding for removing collision
	in the list_colliison"""
	var i = -1
	if "brick" in body.name or "ball" in body.name:
		if body.name in self._list_collision:
			i = self._list_collision.bsearch(body.name)
			self._list_collision.pop_at(i-1)


func on_collision_explosion():
	"""destroy this object when colliding with explosion"""
	self._count_explosion = 1


func play_sound():
	var first_key
	
	if len(self._dict_sound) > 0:
		first_key = self._dict_sound.keys()[0]
		
		if not self._dict_sound[first_key].is_playing():
			self.get_node("sound/"+first_key).queue_free()
			self._dict_sound.erase(first_key)


func play_motor_sound():
	var audiostream2D_run_object = self.get_node("audiostreamplayer2D_run")
	var audiostream2D_idle_object = self.get_node("audiostreamplayer2D_idle")
	
	#var idle_pitch = (self._speed - 0)
	
	audiostream2D_idle_object.volume_db = 0 - self._speed
	
	var audio_stream_sampler_object = audiostream2D_run_object.stream
	
	if not self.get_if_stream_audio_is_pixelated(audio_stream_sampler_object) and\
		self._parent._gameplay_mode == "character":
		audiostream2D_run_object.stream = self.set_stream_format(
			audiostream2D_run_object.stream,
			true)
	elif self.get_if_stream_audio_is_pixelated(audio_stream_sampler_object) and\
		self._parent._gameplay_mode != "character":
		audiostream2D_run_object.stream = self.set_stream_format(
			audiostream2D_run_object.stream,
			false)
	
	if self._parent._gameplay_mode == "character":
		if self._count_explosion == 0:
			audiostream2D_run_object.volume_db = -30
		else:
			audiostream2D_run_object.stop()
			audiostream2D_idle_object.stop()
	else:
		if self._count_explosion == 0:
			audiostream2D_run_object.volume_db = -23+self._speed
		elif audiostream2D_idle_object.volume_db == 0 and audiostream2D_run_object.volume_db < -42:
#			audiostream2D_idle_object.stop()
#			audiostream2D_run_object.stop()
			self._can_be_destroyed = true
		else:
			audiostream2D_idle_object.volume_db =  lerp(audiostream2D_idle_object.volume_db, -23, 0.5)
			audiostream2D_run_object.volume_db = lerp(audiostream2D_run_object.volume_db, -43, 0.2)
			audiostream2D_run_object.pitch_scale = lerp(audiostream2D_run_object.pitch_scale, 0.7, 0.04)
		
		if self._speed > 0:
			audiostream2D_run_object.pitch_scale = 1.0*(1+self._speed/5)
		
		if not audiostream2D_idle_object.is_playing():
			audiostream2D_idle_object.play()
		if not audiostream2D_run_object.is_playing():
			audiostream2D_run_object.play()


func get_if_stream_audio_is_pixelated(stream_object):
	"""
		Take Args As:
			stream_object : AudioStreamSampler
		
		Return if the format's stream (AudioStreamSample)
	"""
	return (stream_object.format == AudioStreamSample.FORMAT_8_BITS)


func set_stream_format(stream_object, set_to_8_bits):
	"""
		Set stream object format
		
		Take the stream_object from a AudioStreamPlayerObject
		
		if set to FORMAT_8_BIT is true set the format's audio stream object
		If not set to FORMAT_16_BIT work with AudioStreamSample
		
		return the 'stream_object'
	"""
	if set_to_8_bits:
		stream_object.format = AudioStreamSample.FORMAT_8_BITS
	else:
		stream_object.format = AudioStreamSample.FORMAT_16_BITS
	
	return stream_object


func add_sound(sound_name:String, play_pitch=1.0, play_volume=1.0):
	randomize()
	var n = sound_name+str(randi())
	
	var dict_sound = {
		"plane_shoot" : preload("res://ressources/sound/vehicle/mp5_plane_weapon.wav"),
		"plane_impact" : preload("res://ressources/sound/vehicle/plane_impact.wav")
	}
	
	var audiostream2D_object = AudioStreamPlayer2D.new()
	
	var audio_stream_sampler
	
	audiostream2D_object.name = n
	audiostream2D_object.stream = dict_sound[sound_name]
	audiostream2D_object.pitch_scale = play_pitch
	audiostream2D_object.volume_db = play_volume
	
	self.get_node("sound").add_child(audiostream2D_object)
	
	audiostream2D_object.play()
	
	if sound_name == "plane_impact":
		audio_stream_sampler = audiostream2D_object.stream
		
		audio_stream_sampler = self.set_stream_format(
			audio_stream_sampler,
			self._parent._gameplay_mode == "character")
		
		audiostream2D_object.stream = audio_stream_sampler
	
	self._dict_sound[n] = audiostream2D_object


func get_unix_time():
	return OS.get_unix_time()


func get_if_is_colliding_with():
	"""
		Return if area2D is colliding with a object of the name of object_name
		
		Check from the global_list of collision
		
		Take Args As:
			object_name (String) is the body
	"""
	var is_colliding_with_brick = false
	for body_name in self._list_collision:
		if not is_colliding_with_brick:
			is_colliding_with_brick = "brick" in body_name
	
	return is_colliding_with_brick
