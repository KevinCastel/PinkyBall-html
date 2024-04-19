extends KinematicBody2D

var _vel = Vector2.ZERO
var _speed = 0
const _MAX_SPEED = 300
const _ACCEL = 2.3 #1.3

var _can_launch_item = false

var _cam_debug_object

var _progress_bar_value = 0

var _bonus_speed = 0

var _negatif_speed = 0

var _weapon = ""

var _weapon_data = {
	"bullet" : 0,
	"rocket" : 0
}

var _dict_spawn_area = {}

var _chrono_shoot = 0

var _max_chrono_shoot = 500

var _is_rocket_rc_in_inventory = false

var _dict_sound = {}

onready var _parent = self.get_parent()

var _dict_index_weapon = {
	0:null,
	1:null}

onready var _raycast_item = self.get_node("raycast2D_items")

var _chrono_pos = 0
var _max_chrono_pos = 3

var _last_global_position = Vector2.ZERO

var _dict_buttoms_dynamic := {}

func _physics_process(delta):
	"""Main runtime"""
	if self._parent._pause:return
	if not self._parent._is_game_playing: return
	
	self.check_area2D_spawn()
	self.check_position()
	self.play_sound()

	if self._weapon != "":
		if self._chrono_shoot < self._max_chrono_shoot:
			self._chrono_shoot += 1
		elif self._weapon_data[self._weapon] > 0 and self._parent._gameplay_mode == "platform":
			self.shoot()
	
	if not self.global_position.y != 844: self.global_position.y = 844
	
	if self._parent._gameplay_mode == "platform":self.check_input(delta)
	
	self._vel = Vector2(self._speed, 0)
	
	self._vel = move_and_slide(self._vel)
	
	if self._raycast_item.get_collider():
		if self._progress_bar_value < 100:
			self._progress_bar_value += 1
		else:
			self.item_won()
	elif self._progress_bar_value > 0:
		self._progress_bar_value -= 1
	
	self.get_node("texture_progress").value = self._progress_bar_value
	
	self.set_acceleration()
	
	self.check_weapon_mun()
 

func check_position():
	"""
		Count the iteration of this method when this object
		is not moving but having a speed
	"""
	if self._last_global_position != self.global_position:
		self._last_global_position = self.global_position
		self._chrono_pos = 0
	elif self._chrono_pos < self._max_chrono_pos:
		self._chrono_pos += 1
	else:
		self._chrono_pos = 0
		self._speed = 0

func check_area2D_spawn():
	"""
		Check when the player can spawn bullet
	"""
	self._can_launch_item = (len(self._dict_spawn_area) == 0)

func set_acceleration():
	"""refresh value of the negative speed and the bonus speed"""
	self._negatif_speed = lerp(self._negatif_speed, 0.0000, 0.0008)
	self._bonus_speed = lerp(self._bonus_speed, 0.0000, 0.0004)
	if self._bonus_speed > 0.0010 and self._bonus_speed < 0.0012:
		self._bonus_speed = 0
		self._parent.add_message("Terminus")

func get_acceleration():
	"""get the acceleration value"""
	var accel = self._ACCEL + self._bonus_speed
	if self._negatif_speed > 0:
		accel /= self._negatif_speed
	return accel

func item_won():
	"""when a item is won"""
	var colliding_object
	
	if self._raycast_item.is_colliding():
		colliding_object = self._raycast_item.get_collider()
		if "coffee" in colliding_object.name:
			self._parent.stats_object.add_item_used("coffee")
			self._bonus_speed = 150
			self._parent.add_message("Slow Down! Slow Down!")
		elif "alcohol" in colliding_object.name:
			self._parent.stats_object.add_item_used("alcohol")
			self._negatif_speed = 20
			self._parent.add_message("Yu know you're drunk!")
		elif "bullet" in colliding_object.name:
			self._parent.stats_object.add_item_used("bullet")
			self._parent.set_if_ball_object_can_be_destroyed(false)
			self._weapon_data["bullet"] += 10
			self.set_weapon("bullet")
			self.launch_ball()
			self._parent.add_message("What a rampage!")
		elif "rocket" in colliding_object.name:
			self._parent.stats_object.add_item_used("rocket")
			self._parent.set_if_ball_object_can_be_destroyed(false)
			self.launch_ball()
			colliding_object.set_layer_collision_()
			self._weapon_data["rocket"] += 1
			if not self._is_rocket_rc_in_inventory:
				self._is_rocket_rc_in_inventory = colliding_object._is_rc
			self.set_weapon("rocket")
			self._parent.add_message("So the rampage have to explose!") #Que le carnage explose
		elif "heart" in colliding_object.name:
			self._parent.stats_object.add_item_used("heart")
			self._parent._player_life = colliding_object.get_life()
			self._parent.add_message("Alive when it should be dead!")
		elif "rc" in colliding_object.name:
			self._parent.stats_object.add_item_used("rc_plane")
			self._is_rocket_rc_in_inventory = true
			self._parent.add_message("Missile are RC now!")
		if self.check_if_can_destroy_the_item(colliding_object.name):
			colliding_object.destroy()
			self._parent.add_message("Ahah! Nothing to win")

func check_weapon_mun():
	"""
		Check the ammo value for each weapon
		
		Change automaticly the weapon if a weapon is in the wait list
		as secondary index and that the first weapon/actual weapon havn't 
		anymore ammo
	"""
	if self._weapon == "rocket":
		if self._weapon_data["rocket"] == 0 and self._weapon_data["bullet"] > 0:
			self._weapon = "bullet"
		elif self._weapon_data["rocket"] == 0 and self._weapon_data["bullet"] == 0:
			self._parent.set_if_ball_object_can_be_destroyed(true)
			self._weapon = ""
	elif self._weapon == "bullet":
		if self._weapon_data["bullet"] == 0 and self._weapon_data["rocket"] > 0:
			self._weapon = "rocket"
		elif self._weapon_data["bullet"] == 0 and self._weapon_data["rocket"] == 0:
			self._parent.set_if_ball_object_can_be_destroyed(true)
			self._weapon = ""
			#self.set_if_ball_can_be_destroyed(true)

func set_weapon(weapon):
	"""set weapon"""
	match weapon:
		"bullet":
			self._parent.set_if_ball_object_can_be_destroyed(false)
			if self._weapon != "":
				self._dict_index_weapon[1] = weapon
				self._weapon_data[weapon] += 5
			else:
				self._weapon = weapon
				self._dict_index_weapon[0] = weapon
		"rocket":
			self._parent.set_if_ball_object_can_be_destroyed(false)
			if self._weapon != "":
				self._dict_index_weapon[1] = weapon
				self._weapon_data[weapon] += 5
			else:
				self._weapon = weapon
				self._dict_index_weapon[0] = weapon

func check_if_can_destroy_the_item(item_name):
	"""return if the item can be destroy"""
	return (not "bomb" in item_name and not "rocket" in item_name)

func force_position(pos_x):
	"""force the global position for the platformer"""
	self.global_position.x = pos_x

func check_input(_delta):
	"""manage input"""
	var accel = self.get_acceleration()
	if Input.is_action_pressed("player_right"):
		self._speed = min(self._speed+accel, self._MAX_SPEED)
	elif Input.is_action_pressed("player_left"):
		self._speed = max(self._speed-accel, -self._MAX_SPEED)
	else:
		if self._bonus_speed == 0:
			self._speed = lerp(self._speed, 0.00, 0.02)
		else:
			self._speed = lerp(self._speed, 0.00, 0.10*(self._bonus_speed/100))
	
	if Input.is_action_just_pressed("player_launch_ball") and\
		 self._parent._gameplay_mode == "platform":
		if not self._parent._ball_launched:
			self.launch_ball()
		elif self._weapon != "" and self._parent._gameplay_mode == "platform" and\
			self._can_launch_item:
			if self._weapon_data[self._weapon] > 0:
				self._weapon_data[self._weapon] -=1
				self.shoot()

func launch_ball():
	self.set_ball(true)
	self._parent.launch_ball(self.get_node("position2D_ball").global_position)

func shoot():
	"""shoot"""
	var dict_weapon_object = {
		"bullet" : preload("res://ressources/scene/ammu/bullet.tscn"),
		"rocket" : preload("res://ressources/scene/ammu/rocket.tscn")
	}
	self._chrono_shoot = 0
	var weap_object = dict_weapon_object[self._weapon].instance()
	var spawn_pos = self.get_node("position2D_ball").global_position
	
	self._parent.get_node("ammu").add_child(weap_object)
	if self._weapon == "bullet":
		weap_object.spawn(spawn_pos)
		self._parent.add_message("Still "+str(self._weapon_data["bullet"])+" ammos")
		self._parent.stats_object.add_ammo_fired(self._weapon)
	else:
		weap_object.spawn(spawn_pos, self._is_rocket_rc_in_inventory)
		self._parent.add_message("Still" + str(self._weapon_data["rocket"])+" rocket")
		self._parent.stats_object.add_ammo_fired(self._weapon)
	
	self._parent.add_sound_to_audiostreamplayer("bullet", 1.0+self._chrono_shoot, 1.0+self._chrono_shoot)
	self.launch_ball()

func set_ammo_for_weapon(weapon_name, ammo, is_rocket_rc = false, force_inventory=false):
	"""
	Used when the cmd is used for giving ammo to the user
	
	Take Args as:
		weapon_name (str) is the weapon that will have more ammo
		ammo (int) is the ammo to addition
		is_rocket_rc (bool) is if the rocket is radio controllable
		force_inventory (bool) for to set the weapon as actual or in inventory
			if the user have weapon and force_inventory is true so this new
			weapon will replace the actual weapon
	"""
	if weapon_name in self._weapon_data:
		self._weapon_data[weapon_name] += int(ammo)
		
		if self._weapon != "":
			if force_inventory or self._weapon == weapon_name:
				self._weapon = weapon_name
			else:
				self._dict_index_weapon[1] = weapon_name
		else:
			self._weapon = weapon_name
		
		if "rocket" in weapon_name:
			if is_rocket_rc:
				self._is_rocket_rc_in_inventory = true


func set_ball(launched:bool):
	"""set when the ball is launched or not"""
	self.get_node("position2D_ball/sprite").visible = (not launched)


func _on_area2D_ball_body_entered(body):
	self._dict_spawn_area[body.name] = body


func _on_area2D_ball_body_exited(body):
	if body.name in self._dict_spawn_area:
		self._dict_spawn_area.erase(body.name)


func add_sound(play_volume=10.0):
	randomize()
	var n = "impact"+str(randi())
	
	var audiostream2D_object = AudioStreamPlayer2D.new()
	audiostream2D_object.stream = preload("res://ressources/sound/platform_impact.wav")
	audiostream2D_object.name = n
	audiostream2D_object.volume_db = play_volume
	
	self.add_child(audiostream2D_object)
	audiostream2D_object.global_position = self.global_position
	
	audiostream2D_object.play()
	self._dict_sound[n] = audiostream2D_object


func play_sound():
	var first_key
	if len(self._dict_sound) > 0:
		first_key = self._dict_sound.keys()[0]
		
		if not self._dict_sound[first_key].is_playing():
			if self.get_node_or_null("sound/"+first_key):
				self.get_node("sound/"+first_key).queue_free()
				self._dict_sound.erase(first_key)


func on_collision_bottom():
	"""Called when this object is colliding with the bottom of the map"""
	self._parent.add_sound_to_audiostreamplayer("character_die_8bits")
	self.queue_free()
