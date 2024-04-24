extends KinematicBody2D

var _vel = Vector2.ZERO

var _brick_brocken = 0

const _MAX_BRICK_TO_BREAK = 10

onready var _game = self.find_parent("game")

onready var _explosive_ball = preload("res://ressources/scene/character/explosive_ball.tscn")

func spawn(global_pos : Vector2, direction : int):
	"""
		Called for spawning this object
		
		Take Args as:
			global_pos (Vector2) is the new global position for this object
			direction (int) is the character shooter direction for assign an
				x absciss (speed value)
	"""
	self.global_position = global_pos
	self._vel = Vector2(4*direction, 0)


func _physics_process(_delta):
	var coll = self.move_and_collide(self._vel)
	
	if self._brick_brocken == self._MAX_BRICK_TO_BREAK:self.destroy()
	
	if coll:
		self.collide(coll.get_collider())


func collide(coll_object):
	"""
		Called when this object is colliding with something
		
		Take Args As:
			coll_object witch is the node colliding
	"""
	var coll_name = coll_object.name
	self._brick_brocken -= int("brick" in coll_name) #convert bool to int
	if "wall" in coll_name:
		self.queue_free()
	
	if "brick" in coll_name:
		var superpower = coll_object._superpower
		self._game.add_sound_to_audiostreamplayer("brick_impact")
		if superpower != "":
			if superpower == "bomb":
				coll_object.on_impact()
			elif superpower == "rocket":
				coll_object.on_impact()
			
		coll_object.queue_free()
		self.queue_free()

func on_collision_explosion():
	"""
		Event called from collision explosion
	"""
	var bullet_explosive_inst = self._explosive_ball.instance()
	var ammu_node = self._game.get_node("ammu")
	
	ammu_node.call_deferred("add_child", bullet_explosive_inst)
	bullet_explosive_inst.spawn(self.global_position, 1, Vector2.ZERO)
	
	self.destroy()


func destroy():
	"""Destroy this object"""
	self.queue_free()
