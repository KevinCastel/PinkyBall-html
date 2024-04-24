extends KinematicBody2D

var _vel = Vector2.ZERO

var _can_be_destroyed = true

var _is_paused = false

var _dict_sound = {}

var _speed = 1.0

var _accel = 0.00001#0.0000001

const MAXIMUM_SPEED = 1.80 #1

onready var _game_node = self.find_parent("game")


func spawn(global_pos):
	self.global_position = global_pos
	self._vel = Vector2(-0.3,-0.3)
	self._speed = 1.0


func _physics_process(_delta):
	if self._game_node._pause:return
	if self._is_paused:return
	
	self.play_sound()
	
	var coll = move_and_collide(self._vel)
	var collider_object
	if coll:
		collider_object = coll.get_collider()
		self._vel = self._vel.bounce(coll.normal)
		self.sub_speed(coll.get_collider().name)
		
		if "brick" in collider_object.name:
			collider_object.on_impact()
			self._accel += 0.000000015
		elif "wall" in collider_object.name:
			self._game_node.add_sound_audiostreamplayer2D("wall_impact",
																	1.0,
																	1.0)
		elif "character" in collider_object.name:
			collider_object.add_sound("hurt")
			collider_object.take_damage(30)
			collider_object.on_ball_collision()
		elif "player" in collider_object.name:
			collider_object.add_sound()
		
	self._speed = lerp(self._speed, self.MAXIMUM_SPEED, self._accel)
	
	self._vel *= self._speed

	var is_game_playing = self._game_node._is_game_playing
	
	if not is_game_playing:
		self._vel.x = lerp(self._vel.x, 0.00, 0.02)
		self._vel.y += 2


func set_if_can_be_destroyed_at_bottom(can_be_destroyed):
	"""
		Set if this object can destroyed at the bottom of this map
		
		Take Args As:
			can_be_destroyed (bool)
	"""
	self._can_be_destroyed = can_be_destroyed


func play_sound():
	if self._game_node._gameplay_mode != "platform": return
	var first_key; var value
	if len(self._dict_sound) > 0:
		first_key = _game_node.get_first_key_from_dict(self._dict_sound)
		value = self._dict_sound[first_key]
		
		if not value.is_playing():
			self.get_node("sound").get_node(first_key).queue_free()
			self._dict_sound.erase(first_key)


func add_sound(play_pitch=1.6, play_volume=10.0):
	"""
		Called on collision for adding sound
	"""
	
	var audiostreamplayer2D_object = AudioStreamPlayer2D.new()
	audiostreamplayer2D_object.stream = preload("res://ressources/sound/platform_impact.wav")
	audiostreamplayer2D_object.pitch_scale = play_pitch
	audiostreamplayer2D_object.volume_db = play_volume
	
	audiostreamplayer2D_object.play()
	
	randomize()
	var n = "ball_impact"+str(randi())
	audiostreamplayer2D_object.name = n
	self._dict_sound[n] = audiostreamplayer2D_object
	
	self.get_node("sound").add_child(audiostreamplayer2D_object)


func reset_speed():
	self._speed = 0
	self._vel = Vector2.ZERO


func get_decimal_number_for_speed(multiplication_value):
	var speed_int = int(self._speed * multiplication_value)
	var unit = int(speed_int - multiplication_value)
	
	return unit
 
func get_breaking_value():
	"""Called for getting the new value of breakin"""
	var first_decimal = self.get_decimal_number_for_speed(1000)
	#Implement for the rest of theses value incrementing an 0*10 until 1000
	var second_decimal = int(self._speed*100)
	var third_decimal = self._speed/1000
	var fourth_decimal = fmod(self._speed,100)
	
	print("speed :", self._speed)
	print("first_decimal:", first_decimal)
	print("second_decimal:", second_decimal)
	print("third_decimal:", third_decimal)
	print("fourth_decimal:", fourth_decimal)


func sub_speed(coll_name:String="others"):
	"""
		Called when this object had collided with something and
		the collision slow down the speed of this object
	"""
	if "brick" in coll_name:
		self.get_breaking_value()
		self._speed = max(0.09000010, self._speed-0.0070) #should use third value after comma for division
		
	
	elif "wall" in coll_name:
		if self._speed > 1.50:
			self._speed -= 0.50
		
		if self._vel.x > 0.70:
			self._vel.x -= 0.30
		elif self._vel.x < -0.70:
			self._vel.x += 0.30
		
		if self._vel.y > 0.70:
			self._vel.y -= 0.30
		elif self._vel.y < -0.70:
			self._vel.y += 0.30
	elif "player" in coll_name:
		if self._speed > 1.30:
			self._speed -= 0.15
		
		if self._vel.x > 0.30:
			self._vel.x -= 0.0015
		elif self._vel.x < -0.30:
			self._vel.x += 0.0015
		
		if self._vel.y > 0.30:
			self._vel.y -= 0.0015
		elif self._vel.y < -0.30:
			self._vel.y += 0.0015
	
#	self._speed = max(self._speed, 0.9989)
