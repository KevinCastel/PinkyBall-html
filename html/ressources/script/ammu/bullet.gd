extends RigidBody2D

var _vel = Vector2.ZERO

var _acceleration = 0

var _can_execute_runtime = false

var _brick_destroyed = 0

onready var raycast2D_destroy = self.get_node("raycast2D_destroy")

onready var texture_progress = self.get_node("texture_progress")
var _chrono_destroy = 30.00

func spawn(global_pos):
	"""used for spawning when the player shoot"""
	self.set_collision_layer_bit(2, false)
	self.set_collision_layer_bit(9,true)
	self.global_position = global_pos
	self.set_colur("#C5D824") #yellow
	
	self.weight = 2.95
	self._can_execute_runtime = true

func set_colur(new_colur):
	var colur_ob; var colur_list
	if typeof(new_colur) == TYPE_ARRAY:
		colur_ob = Color8(new_colur[0],new_colur[1], new_colur[2])
	elif typeof(new_colur) == TYPE_STRING:
		colur_list = Color(new_colur)
		colur_ob = Color8(colur_list[0]*255, colur_list[1]*255, colur_list[2]*255)
	self.get_node("sprite").modulate = colur_ob

func _physics_process(_delta):
	"""mainruntime of the application"""
	self.sleeping = self.get_parent().get_parent()._pause
	if self.get_parent().get_parent()._pause:
		return
	
	if self._can_execute_runtime:
		self._vel = self.transform.y * -self._acceleration
		
		self.set_acceleration()
		self.apply_impulse(Vector2(0,1), self._vel)
		
		if self.raycast2D_destroy.is_colliding():
			self.destroy()
		
		self._chrono_destroy += 0.05
		self.texture_progress.value = int(self._chrono_destroy) 
		
		if int(self._chrono_destroy) >= 80:self.destroy()

func set_acceleration():
	"""set the acceleration"""
	self._acceleration = min((self._acceleration+0.2)*(1+self._acceleration/20), 0.70)

func destroy():
	"""called when the object have to explose"""
	var coll_object
	var game_node = self.find_parent("game") #get_parent()x2
	var weapon_name_player = game_node.find_node("player")._weapon
	if self.raycast2D_destroy.is_colliding():
		coll_object = self.raycast2D_destroy.get_collider()
		if "brick" in coll_object.name:
#			game_node.stats_object.add_ammo_brick_broken(weapon_name_player)
			game_node.stats_object.add_ammo_brick_broken("bullet")
			coll_object.on_impact()
			coll_object.destroy_object()
			self._brick_destroyed += 1
			self._chrono_destroy += 8.00
		elif "bomb" in coll_object.name:
			coll_object.on_bullet_collision()
			self.queue_free()
	
		if not self.check_if_the_ball_can_destroyed(["ball", "brick", "wall"],
												coll_object.name):
			if self._brick_destroyed > 1:
				game_node.show_message("One Bullet, "+self._brick_destroyed+" Bricks Destroyed")
			else:
				game_node.show_message("One Bullet, A Brick Destroyed")
			self.queue_free()
	else:
		if self._brick_destroyed > 1:
			game_node.add_message("One Bullet, "+str(self._brick_destroyed)+" Bricks Destroyed")
			#parent.show_message("One Bullet, "+str(self._brick_destroyed)+" Bricks Destroyed")
		else:
			game_node.add_message("One Bullet, A Brick Destroyed")
		self.queue_free()

func get_collider_name(list_strings_model:Array, string_to_find:String):
	"""
		Return the item name after finding it in string extracted from list
		witche contains all strings model

		For example the string to find is '@bomb123' and the list that contains
		all string model here ['bomb', 'plane', 'example']
		
		The list will be iterate for testing each strings model is in the string
		given as argument
		
		Take Args As:
			list_strings_model:Array
			string_to_find:String
	"""
	var string_to_return = ""
	for string_model in list_strings_model:
		if string_model in string_to_find:
			string_to_return = string_model
	
	return string_to_return

func check_if_the_ball_can_destroyed(list_items:Array, coll_name:String):
	"""return if the item name allows the ball to destroy"""
	var can_be_destroyed = false
	for s in list_items:
		if not can_be_destroyed:
			can_be_destroyed = (s in list_items)
	
	return can_be_destroyed
