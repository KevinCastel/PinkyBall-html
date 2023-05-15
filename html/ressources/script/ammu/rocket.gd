extends RigidBody2D

var _is_rc = false

var _vel = Vector2.ZERO
var _acceleration = 0

var _fuel = 100

onready var texture_progress_fuel = self.get_node("texture_progress")

var _is_explosed = false

var _cam_object

var _last_position = Vector2.ZERO
var _chrono_force_explosion = 0

func spawn(global_pos, is_rc = false):
	"""create this object"""
	self.global_position = global_pos
	
	self._is_rc = is_rc
	
	if self._is_rc:self.set_cam_for_rc()
	
	self.weight = 1.3

	self.contact_monitor = true
	
	self.contacts_reported = 4

func set_cam_for_rc():
	"""create camera object"""
	var parent = self.get_parent().get_parent()
	
	self._cam_object = Camera2D.new()
	
	self._cam_object.current = true
	
	self._cam_object.rotating = true
	
	self.add_child(self._cam_object)
	
	parent.set_gameplay_mode("rocket")
	parent.manage_camera("rocket", self._cam_object)

func _physics_process(delta):
	"""mainruntime of this object"""
	self.set_acceleration(delta)
	if self._is_rc:
		self.set_direction()
		self.set_camera_rotation()
		self.set_cam_zoom()
		self.check_position()
	
	self._vel = self.transform.y * -self._acceleration
	self.apply_impulse(Vector2.ZERO, self._vel)
	
	
	self._fuel = lerp(self._fuel, 0.00, 0.002+(self._acceleration/100000))

	self.texture_progress_fuel.value = int(self._fuel)+30
	
	self.play_sound()

func set_camera_rotation(rota_value=null):
	"""set the camera rotation
	
		Take Arg as:
			rotat_value
	"""
	if rota_value:
		self._cam_object.rotation += rota_value
	
	self._cam_object.rotation = lerp(self._cam_object.rotation, 0.00, 0.10)

func check_position():
	"""when this object is blocked to the same positon since long time"""
	var is_x_same = (self.global_position.x == self._last_position.x)
	var is_y_same = (self.global_position.y == self._last_position.y)
	
	if is_y_same and is_x_same:
		if self._chrono_force_explosion < 10:
			self._chrono_force_explosion += 1
		else:
			self.explosion()

	if not is_y_same:
		self._last_position.y = self.global_position.y
		self._chrono_force_explosion = 0

	if not is_x_same:
		self._last_position.x = self.global_position.x
		self._chrono_force_explosion = 0

func set_cam_zoom(zoom_value = null):
	"""set the camera zoom"""
	var cam_zoom_value = self._cam_object.zoom.x
	if zoom_value:
		cam_zoom_value -= zoom_value
	
	cam_zoom_value = lerp(cam_zoom_value, 1, 0.010)
	if cam_zoom_value != self._cam_object.zoom.x:
		self._cam_object.zoom = Vector2(cam_zoom_value, cam_zoom_value)
	
func set_direction():
	"""set the direction"""
	var turn = 0
	
	if Input.is_action_pressed("player_right"):
		turn = -30
	elif Input.is_action_pressed("player_left"):
		turn = 30

	self.set_camera_rotation(turn/100)
	
	self.applied_torque = turn
	
	self.applied_torque = lerp(self.applied_torque, 0.00, 0.10)

func set_acceleration(_delta):
	"""
		Set the acceleration
		
		Set the acceleration thanks to the fuel still
	"""
	
	if not self._is_rc:
		self._acceleration = min(self._acceleration+0.002, 1.2)
	else:
		if Input.is_action_pressed("player_launch_ball"):
			self._acceleration = min(self._acceleration+0.05, 1.3)
			self.set_cam_zoom(0.005)
		if int(self._acceleration*100) > int(self._fuel*10):
			self._acceleration = self._fuel/10
		
		self._acceleration = lerp(self._acceleration, 0.00, 0.10)

func is_colliding():
	"""called when this object is colliding"""
	var is_x_enough_to_explode = (self.linear_velocity.x > 2 or self.linear_velocity.x < -2)
	var is_y_enough_to_explode = (self.linear_velocity.y > 2 or self.linear_velocity.y < -2)
	if is_x_enough_to_explode or is_y_enough_to_explode and not self._is_explosed:
		self._is_explosed = true
		self.explosion()

func explosion():
	var parent = self.get_parent().get_parent()
	parent.manage_explosion(self.global_position, "rocket")
	parent.set_gameplay_mode("platform")
	parent.manage_camera("gameplay")
	
	self.queue_free()

func _on_rocket_body_entered(_body):
	self.is_colliding()

func _on_rocket_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	self.is_colliding()

func on_collision_expllosion():
	"""called when this object is hit by an explosion"""
	self.explosion()

func play_sound():
	"""Play sound for this object"""
	var audiostreamplayer2D_motor = self.get_node("audiostreamplayer2D_motor")
	
	audiostreamplayer2D_motor.pitch_scale = 1.0+self._acceleration
	
	if not audiostreamplayer2D_motor.is_playing():
		audiostreamplayer2D_motor.play()


#func on_explosion_collision():
#	"""
#		Called when this object collide with an explosion object
#	"""
#	self.explosion()
