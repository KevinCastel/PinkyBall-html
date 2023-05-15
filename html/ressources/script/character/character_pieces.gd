extends RigidBody2D


onready var _game_parent = self.find_node("game")

var _time_relapse

const MAXIMUM_TIME_RELAPSE = 16

var _can_flicker = false

var _spawn_second_unix_time = OS.get_unix_time()

const MAXIMUM_SECONDS_BEFORE_DESTROYING = 10



func spawn(global_pos, linear_vel):
	"""
		Spawn this object at a specified global position
		
		Take Args As:
			global_pos (Vector2) used to spawn this object on this world
			linear_vel : (Vector2) defined the linear speed for this object
	"""
	self.sleeping = false
	self.can_sleep = false
	self.set_collision_mask_bit(16,true)
	self.global_position = global_pos
	
	self.linear_velocity = linear_vel


func _process(delta):
	"""
		Main runtime for this object
		(used for visual effect)
	"""
	var game_node = self.find_parent("game")
	
	if OS.get_unix_time() >= self._spawn_second_unix_time+self.MAXIMUM_SECONDS_BEFORE_DESTROYING:
		if game_node._gameplay_mode == "character":
			game_node.manage_camera("gameplay",
				game_node.get_current_camera_object())
			self._can_flicker = true
			
			
	elif self._can_flicker:
		self.modulate.a = lerp(self.modulate.a, 0.00, 0.005)
		if self.modulate.a < 0.0001:self.destroy()


func on_collision_bottom():
	"""
		Event (called when this object is colliding with the bottom)
	"""
	self.destroy()


func destroy():
	"""Destroy this object"""
	self.queue_free()
