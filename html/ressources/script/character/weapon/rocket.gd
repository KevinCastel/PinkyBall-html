extends RigidBody2D

var _last_global_position = Vector2.ZERO

var _count_destroyer = 0

const MAXIMUM_CHRONO_DESTROY = 3

func spawn(global_pos, is_flip_h):
	"""
		Called for spawning this object
	"""
	if is_flip_h:
		self.rotation_degrees -= 180
	var vel = Vector2(100,10).rotated(self.rotation)
	self.global_position = global_pos
	self.apply_central_impulse(vel)


func _physics_process(_delta):
	"""
		Main runtime
	"""
	if self._last_global_position != self.global_position:
		self._last_global_position = self.global_position
	else:
		self._count_destroyer += 1
		if self._count_destroyer > self.MAXIMUM_CHRONO_DESTROY:
			self.explose()


func _on_rocket_body_entered(_body):
	"""
		GDScript event for RigidBody2D when colliding with
		object
	"""
	self.find_parent("game").add_audiostream2D_sound("rocket_collision_character")
	if self.can_explose_on_impact():
		self.explose()

func explose():
	"""
		Called when this object is explosing
	"""
	self.find_parent("game").manage_explosion(self.global_position,
											"micro_rocket")
	self.queue_free()

func can_explose_on_impact():
	"""
		Return if this object can explose
	"""
	var speed_for_explosing = 5
	return (self.linear_velocity.x > speed_for_explosing or self.linear_velocity.x < -speed_for_explosing or\
			self.linear_velocity.y > speed_for_explosing or self.linear_velocity.y < -speed_for_explosing)


func spawn_pieces():
	"""
		Used for spawning members of this character object
		when this destroying
	"""
	var dict_pieces = {
		"head": preload("res://ressources/scene/character/pieces/head.tscn"),
		"body" : preload("res://ressources/scene/character/pieces/body.tscn"),
		"arm" : preload("res://ressources/scene/character/pieces/arms.tscn"),
		"legs" : preload("res://ressources/scene/character/pieces/legs.tscn")
	}
	
	var inst_scene
	
	var global_pos = self.global_position
	global_pos.y += 6
	
	var list_positions_sub = [] #used to decremente the global_position.y for spawning element
	
	var character_pieces_node = self.find_parent("game").get_node("characters_pieces")
	
	for piece in dict_pieces:
		inst_scene = piece.instance()
		
