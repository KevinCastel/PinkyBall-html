extends RigidBody2D

var _vel = Vector2.ZERO

var _speed = 130

var _list_collision = []

var _second_unix_spawn

var _can_collide_with_brick = false

func _physics_process(_delta):
	"""main runtime"""
	self.accelerate()
	
	self.apply_impulse(Vector2.ZERO, self._vel)
	
	
	self.check_chrono_destruction()

func spawn(global_pos, rota, impulse_y, impulse_x):
	"""spawn while using the global position"""
	self.set_datetime()
	self.global_position = global_pos
	self.rotation_degrees = rota
	
	var vel_impulse = Vector2(impulse_x, impulse_y)
	self.apply_impulse(Vector2.ZERO, vel_impulse) 
	
	self.set_brick_collision(false)
	
	self.contact_monitor = true
	self.contacts_reported = 5


func check_chrono_destruction():
	var actual_second = OS.get_unix_time()
	if int(actual_second) > int(self._second_unix_spawn)+3:
		self.explose()

func set_datetime():
	self._second_unix_spawn = OS.get_unix_time()

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
				self.find_parent("game").set_futur_character_superpower(
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
	var i = self._list_collision.find(body.name)
	self._list_collision.remove(i)
	if not self._can_collide_with_brick:
		self._can_collide_with_brick = (not self.check_if_list_collision_contains_str(
			self._list_collision,
			"brick"))
	if self._can_collide_with_brick:
		self.set_brick_collision(true)


func check_if_list_collision_contains_str(list_:Array, string_:String):
	"""return if a list(list_) contains a string (string_)"""
	var does_list_contains_string = false
	for e in list_:
		if not does_list_contains_string:
			does_list_contains_string = (string_ in e)
	return does_list_contains_string

func set_brick_collision(collide_with_brick:bool):
	"""
		Set the collision of this object with brick (mask 5)
		
		Take Args As:
			collide_with_brick (bool) set if this object collide
			with brick or not
	"""
	self.set_collision_mask_bit(5, collide_with_brick)


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
	if brick_superpower == null:brick_superpower = ""
	if brick_superpower != "":
		self.find_parent("game").character_futur_superpower = brick_superpower


func explose():
	"""called by a event when is colliding, make it explose"""
	var parent = self.get_parent().get_parent()
	parent.manage_explosion(self.global_position, "", 2)
	self.queue_free()


func on_collision_bottom():
	"""called when this object collide with a bottom"""
	self.explose()
