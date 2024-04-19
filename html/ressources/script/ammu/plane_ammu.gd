extends RigidBody2D

var _vel = Vector2.ZERO

var _speed = 130

var _list_collision = []

var _second_unix_spawn

var _can_collide_with_brick = false

onready var _gameplay = self.find_parent("game")

func _physics_process(_delta):
	"""main runtime"""
	self.accelerate()
	
	self.apply_impulse(Vector2.ZERO, self._vel)
	
	self.check_chrono_destruction()

func spawn(global_pos, rota, impulse_y, impulse_x):
	"""spawn while using the global position"""
	self._second_unix_spawn = OS.get_unix_time()
	self.global_position = global_pos
	self.rotation_degrees = rota
	
	var vel_impulse = Vector2(impulse_x, impulse_y)
	self.apply_impulse(Vector2.ZERO, vel_impulse) 
	
	self.set_collision_mask_bit(5, false)
	
	self.contact_monitor = true
	self.contacts_reported = 5


func check_chrono_destruction():
	var actual_unix_time = OS.get_unix_time()
	var LIFE_DELAY_SECOND = 3
	if int(actual_unix_time) > int(self._second_unix_spawn)+LIFE_DELAY_SECOND:
		self.explose()


func accelerate():
	"""set the acceleration"""
	self._vel = self.transform.x * self._speed
	self._speed = lerp(self._speed, 0.00, 0.10)


func check_raycast_collision():
	"""check raycast collision"""
	var raycast_node = self.get_node("RayCast2D")
	var coll_object
	if raycast_node.is_colliding():
		coll_object = raycast_node.get_collider()
		if "brick" in coll_object.name:
			if coll_object._superpower != "":
				self._gameplay.set_futur_character_superpower(
											coll_object._superpower)
		
		if coll_object.has_method("destroy"):
			coll_object.destroy()
		elif coll_object.has_method("on_ball_impact"):
			coll_object.on_ball_impact()


func _on_area2D_body_entered(body):
	"""event used for adding collision (body's name) in _list_collision"""
	self._list_collision.append(body.name)


func _on_area2D_body_exited(body):
	"""
		event that used for removing collision (body's name) in _list_collision
	"""
	var collider_remove = self._list_collision.find(body.name)
	self._list_collision.remove(collider_remove)
	if not self._can_collide_with_brick:
		self._can_collide_with_brick = (not self.get_list_collision_contains_string_object())
	if self._can_collide_with_brick:
		self.set_collision_mask_bit(5, true)


func get_list_collision_contains_string_object():
	"""return if an string type is contains in the list_collisions"""
	var does_list_contains_string = false
	for collider in self._list_collision:
		if not does_list_contains_string:
			does_list_contains_string = ("brick" in collider)
	return does_list_contains_string


func _on_plane_ammu_body_entered(body):
	var is_sliding_x = (self.linear_velocity.x > 1 or\
					 self.linear_velocity.x < -1)
	
	var is_sliding_y = (self.linear_velocity.y > 1 or\
						self.linear_velocity.y < -1)
	
	if is_sliding_x or is_sliding_y:
		if "brick" in body.name:
			self.collide_with_brick(body._superpower)
		self.explose()


func collide_with_brick(brick_superpower):
	"""
		Called when this object collide with brick object,
		Check if this brick got a superpower
		If true, save this superpower for setting-up when
		the player's character will spawn (give a superpower)
		
		Take Args As:
			brick_superpower (String)
	"""
	if brick_superpower != "" && brick_superpower != null:
		self._gameplay.character_futur_superpower = brick_superpower


func explose():
	"""called by a event when is colliding, make it explose"""
	self._gameplay.manage_explosion(self.global_position, "", 2)
	self.queue_free()


func on_collision_bottom():
	"""called when this object collide with a bottom"""
	self.explose()
