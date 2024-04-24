extends KinematicBody2D

var _life = 100
var _vel = Vector2.ZERO
var _speed = 0

const GRAVITY = 6

const ACCEL = 1
const ACCEL_JET_PACK = 0.2
const MAX_SPEED = 150
const MAX_SPEED_JET_PACK = 120

var _bonus_speed = 0

var _chrono_shoot_sound = 0

var _state
enum {WALK,FALL,JUMP,IDLE}

var _cam_object


var _colur = ""

onready var _audiostreamplayer2D_jetpack = self.get_node("jet_pack/audiostreamplayer2D_jet_pack")

onready var _sprite_jet_pack = self.get_node("jet_pack/sprite_jet_pack")
onready var _sprite_jet_pack_flame = self.get_node("jet_pack/sprite_flame")
onready var _jet_pack_obj = self.get_node("jet_pack")

onready var bullet_explosive = preload("res://ressources/scene/character/explosive_ball.tscn")
onready var rocket_explosive = preload("res://ressources/scene/character/rocket.tscn")
onready var bullet = preload("res://ressources/scene/character/bullet.tscn")
#var bullet_inst = preload("res://ressources/scene/character/bullet.tscn").instance()
onready var _game = self.get_parent().get_parent()

var _dict_sound_src = {
	"jump" : preload("res://ressources/sound/character/Jump.wav"),
	"fall" : preload("res://ressources/sound/character/Fall.wav"),
	"unbroken_brick" : preload("res://ressources/sound/character/unbroken_brick.wav"),
	"broken_brick" : preload("res://ressources/sound/character/broken_brick.wav"),
	"die" : preload("res://ressources/sound/character/die.wav"),
	"hurt" : preload("res://ressources/sound/character/Hurt.wav")}

var _dict_pieces_src = {"head" : preload("res://ressources/scene/character/pieces/head.tscn"),
	"arms" : preload("res://ressources/scene/character/pieces/arms.tscn"),
	"body" : preload("res://ressources/scene/character/pieces/body.tscn"),
	"legs" : preload("res://ressources/scene/character/pieces/legs.tscn"),
	"foot" : preload("res://ressources/scene/character/pieces/foot.tscn")}


var _jump_force = 0

var _last_global_position = Vector2.ZERO
var _chrono_last_position

var _brick_broken = 0

var _max_brick_can_be_break = 3

var _can_play_jump_sound = false
var _can_play_fall_sound = false

var _is_play_jump_sound = false
var _is_play_fall_sound = false

var _dict_sound = {"micro_rocket":0, "micro_bomb":0}

var _cam_zoom = 0.5

var _falling_damage = 0.00

onready var position2D_muzzle = self.get_node("postiion2D_muzzle")

var _weapon
enum {EXPLOSIVE_BULLET, ROCKET, BULLET}

var _dict_ammo = {"micro_bomb":0, "micro_rocket":0, "bullet":0}


const MAX_SECOND_DESTROYING = 100

var _last_minute = 0
var _unix_spawn_time = OS.get_unix_time()

var _chrono_jet_pack_flame_anim = 0
const MAXIMUM_CHRONOS_JET_PACK = 4

var _last_frame_index_jet_pack_animation = 0
var _does_have_jet_pack = false

var _acceleration_jet_pack = 0
const MAXIMUM_ACCELERATION_JET_PACK = 0.1

var _unix_jet_pack
var MAXIMUM_JET_PACK_SECOND = 2

var MAXIMUM_JET_PACK_Y = 12

var _dict_jet_pack_light_texture = {
	0:preload("res://ressources/img/effects/jet-pack/j0.png"),
	1:preload("res://ressources/img/effects/jet-pack/j1.png"),
	2:preload("res://ressources/img/effects/jet-pack/j2.png"),
	3:preload("res://ressources/img/effects/jet-pack/j3.png")
} #the index is the frame index on the tile sprites used for the jet pack sprite


func spawn(global_pos:Vector2, colur:String):
	"""
		Spawn this object
		
		Take Args As:
			global_pos(unit Vector2D for global position)
			pseudo (str) is the player/bot name
			colur (str) is the color of this object
	"""
	if self._game.character_futur_superpower != "":
		self.set_ammo(self._game.character_futur_superpower)
	

	self._game.set_btn_mobile_visibility("shoot", false)
	self._game.set_btn_mobile_visibility("up", true)
	
	self.set_jet_pack_visibility(false)
	self._unix_spawn_time = OS.get_unix_time()
	self.global_position = global_pos
	self.change_state(IDLE)
	
	self._colur = colur
	
	self.create_camera()


#func set_texture(colur):
#	var dict_texture = {
#		"pink" : preload("res://ressources/img/character/tileset_pink_character.png"),
#		"blue" : preload("res://ressources/img/character/tileset_blue_character.png"),
#		"green" : preload("res://ressources/img/character/tileset_green_character.png"),
#		"yellow" : preload("res://ressources/img/character/tileset_yellow_character.png")}
#	if colur in dict_texture:
#		t = dict_texture[colur]
#		self._sprite_obj.texture = t
#		self._sprite_obj.hframes = 5
#		self._sprite_obj.vframes = 6


func _physics_process(_delta):
	"""main runtime for this object"""
	if not  self._does_have_jet_pack:
		self._vel.y += self.GRAVITY
	else:
		self._vel.y += 2
	
	if self._does_have_jet_pack:
		self.check_jet_pack_time()
		self.play_animation_jet_pack()
		self.play_jet_pack_light_animation()
		self.play_jet_pack_sound()
	
	self._chrono_shoot_sound = lerp(self._chrono_shoot_sound, 0.00, 0.02)
	
	self.check_input()
	
	self.state_loop()
	self.camera_effect_loop()
	
	self.move_and_slide(self._vel, Vector2.UP)
	
	self.check_time()
	
	if self.is_on_floor():
		self._can_play_jump_sound = false
		self._can_play_fall_sound = false
		if self._falling_damage > 0.00:
			print("falling_damage: ",self._falling_damage)
			self.add_sound("hurt")
			self._life -= self._falling_damage
			self._falling_damage = 0.00
			
			if self._life < 0:
				self.die()
	else:
		self._falling_damage += abs(self._vel.y/2000)
		
		if not self._is_play_jump_sound:
			self.add_sound("jump")
			self._is_play_jump_sound = true
		if not self._is_play_fall_sound:
			self.add_sound("fall")
			self._is_play_fall_sound = true
	
	if self.is_on_floor() and self._vel.y > 0:
		self._vel.y = 0
	
	self.check_velocity()
	self.check_raycast_2D()


func check_velocity():
	"""check if the velocity is the same as it was last second"""
	if self.global_position != self._last_global_position:
		self._last_global_position = self.global_position
		self._chrono_last_position = 0
	elif self._chrono_last_position < 3:
		self._chrono_last_position += 1
		
	elif self._chrono_last_position > 9:
		if self._vel.x > 0.10 or self._vel.x < -0.10:
			self._speed = 0
			self._vel.x = 0.00
		if self._vel.y < 1:
			self._vel.y = 0.00
		self._chrono_last_position = 0


func state_loop():
	"""check the sliding of this object for setting the animation"""
	var is_sliding_x = (self._vel.x > 0.30 or self._vel.x < -0.30)
	var is_jumping = (self._vel.y < -0.10)
	var is_falling = (self._vel.y > 3)
	
	if is_on_floor():
		if is_falling:
			is_falling = false
	else:
		if is_falling and not _can_play_fall_sound:
			self._is_play_fall_sound = false
			self._can_play_fall_sound = true
	
	if self._state == WALK and not is_sliding_x:
		self.change_state(IDLE)
	if self._state == IDLE and is_sliding_x:
		self.change_state(WALK)
	if self._state in [WALK, IDLE, JUMP] and is_falling:
		self.change_state(FALL)
	if self._state in [WALK, IDLE] and is_jumping:
		self.change_state(JUMP)
	if self._state == FALL and self.is_on_floor():
		self.change_state(IDLE)
	if self._state in [JUMP,FALL] and self._does_have_jet_pack and not self.is_on_floor():
		self.change_state(IDLE)


func change_state(new_state):
	self._state = new_state
	match self._state:
		IDLE:
			self.change_animation("idle")
		WALK:
			self.change_animation("walk")
		JUMP:
			self.change_animation("jump")
		FALL:
			self.change_animation("fall")


func set_jet_pack_visibility(visible):
	self._jet_pack_obj.get_node("sprite_flame").visible = visible
	self._jet_pack_obj.get_node("sprite_jet_pack").visible = visible
	self._jet_pack_obj.get_node("light2D").visible = visible


func play_animation_jet_pack():
	var i_frame
	if self._chrono_jet_pack_flame_anim == self.MAXIMUM_CHRONOS_JET_PACK:
		randomize()
		i_frame = randi()%3+1
		
		if i_frame == self._last_frame_index_jet_pack_animation:
			if self._last_frame_index_jet_pack_animation == 0:
				i_frame = 1
			elif self._last_frame_index_jet_pack_animation == 3:
				i_frame = 3
			else:
				i_frame += int(rand_range(-1,1))
				if i_frame == 0:
					i_frame = 1
		
		self._sprite_jet_pack_flame.frame = i_frame
		
		self._chrono_jet_pack_flame_anim = 0
	else:
		self._chrono_jet_pack_flame_anim += 1
	
	self._last_frame_index_jet_pack_animation = i_frame


func play_jet_pack_light_animation():
	"""
		Called when the player got the jet-pack,
		This is used for setting up light animation
	"""
	var i = self._sprite_jet_pack.frame
	var jet_pack_light = self.get_node("jet_pack/light2D")
	
	jet_pack_light.texture = self._dict_jet_pack_light_texture[i]
	
	jet_pack_light.energy = 1.99+((int(self._vel.y < 0.00)*2))
	jet_pack_light.texture_scale = (1.00+rand_range(0.00, 1.00))+(int(self._vel.y > 0.00))


func change_animation(new_anim):
	"""change the animation"""
	var anim_player_body = self.get_node("anim_player")
	var anim_player_front_arm = self.get_node("anim_front_arm")
	var anim_player_back_arm = self.get_node("anim_back_arm")
	
	var sprite_back_arm = self.get_node("back_arm")
	
	var can_play_anim = true
	
	if new_anim != anim_player_body.current_animation:
		if self._does_have_jet_pack and new_anim in ["jump", "fall"]:
			can_play_anim = false
		
		if self._does_have_jet_pack:
			if new_anim == "jump":
				can_play_anim = false
			elif new_anim == "fall":
				new_anim = "idle"
		
		if can_play_anim:
			anim_player_body.play(new_anim)
			if new_anim in anim_player_back_arm.get_animation_list() and not self._does_have_jet_pack:
				if not sprite_back_arm.visible:
					sprite_back_arm.visible = true
				anim_player_back_arm.play(new_anim)
			else:
				if sprite_back_arm.visible:
					anim_player_back_arm.stop()
					sprite_back_arm.visible = false
			
			if new_anim in anim_player_front_arm.get_animation_list() and not self._does_have_jet_pack:
				anim_player_front_arm.play(new_anim)
				
			elif self._does_have_jet_pack:
				anim_player_front_arm.play("jet_pack")


func get_weapon_name_to_string(weap):
	match weap:
		ROCKET:
			return "micro_rocket"
		EXPLOSIVE_BULLET:
			return "micro_bomb"
		BULLET:
			return "bullet"


func shoot(weapon):
	"""
		Used as event when the player shoot
	"""
	self._game.stats_object.add_ammo_fired(self.get_weapon_name_to_string(self._weapon))
	
	var bullet_explosive_inst = self.bullet_explosive.instance()
	var rocket_explosive_inst = self.rocket_explosive.instance()
	var bullet_inst = self.bullet.instance()
	
	var ammu_parent_node = self._game.get_node("ammu")
	var sprite_flip_h = self.get_node("skin").flip_h
	
	match weapon:
		EXPLOSIVE_BULLET:
			ammu_parent_node.add_child(bullet_explosive_inst)
			bullet_explosive_inst.spawn(self.position2D_muzzle.global_position,
				sprite_flip_h)
		
		ROCKET:
			self._chrono_shoot_sound += 0.002
			self._game.add_sound_to_audiostreamplayer("rocket_character")
			ammu_parent_node.add_child(rocket_explosive_inst)
			rocket_explosive_inst.spawn(self.position2D_muzzle.global_position,
				sprite_flip_h)
		
		BULLET:
			self._chrono_shoot_sound += 0.006
			ammu_parent_node.add_child(bullet_inst)
			bullet_inst.spawn(self.position2D_muzzle.global_position,
				0+int(not sprite_flip_h)-int(int(sprite_flip_h) == 1)
				)
			self._game.add_sound_to_audiostreamplayer("bullet",
				1.3+self._chrono_shoot_sound,
				1.3+self._chrono_shoot_sound)

func check_input():
	var weap_name
	if Input.is_action_just_released("plane_shoot"):
		if self._weapon in [ROCKET, EXPLOSIVE_BULLET, BULLET]:
			weap_name = self.get_weapon_name_to_string(self._weapon)
			var ammo_still =  self._dict_ammo[weap_name]
			if ammo_still > 0:
				self._dict_ammo[weap_name] -= 1
				self.shoot(self._weapon)
			if ammo_still == 0:
				self._game.set_btn_mobile_visibility("shoot", false)
			
		elif self._does_have_jet_pack:
			self._does_have_jet_pack = false
			self.set_jet_pack_visibility(false)
			self._audiostreamplayer2D_jetpack.autoplay = false
			self._audiostreamplayer2D_jetpack.stop()
			self._game.add_sound_to_audiostreamplayer("end_jet_pack")
	
	if self._does_have_jet_pack:
		self._jump_force = 0
		if Input.is_action_pressed("player_down"):
			if self._vel.y < 0.00:
				self._vel.y = lerp(self._vel.y, 0.00, 0.020)
	
	
	if Input.is_action_just_released("player_launch_ball") or self._jump_force > 4 and\
		not self._does_have_jet_pack:
		if self.is_on_floor():
			self._vel.y -= self._jump_force*80
			
			self._can_play_jump_sound = false
			self._is_play_jump_sound = false
		
		self._jump_force = 0
		
	elif Input.is_action_pressed("player_launch_ball"):
		if self._does_have_jet_pack:
			if self.global_position.y+self._vel.y > 2:
				self._acceleration_jet_pack = max(self._acceleration_jet_pack+0.02, self.MAXIMUM_ACCELERATION_JET_PACK)
				self._vel.y -= self._acceleration_jet_pack
		else:
			if self._jump_force < 5:
				self._jump_force += 0.10
			 
	else:
		self._jump_force = 0
	
	if Input.is_action_pressed("player_right"):
		if self.is_on_floor():
			self._speed = min((self._speed+self.ACCEL), self.MAX_SPEED+self._bonus_speed)
			self.flip_sprites(false)
			self.position2D_muzzle.position.x = 7
		elif self._does_have_jet_pack:
			self._speed = min(self._speed+self.ACCEL_JET_PACK, self.MAX_SPEED_JET_PACK)
			self.flip_sprites(false)
			self.position2D_muzzle.position.x = 7
			self.get_node("jet_pack/light2D").position.x = -4
	elif Input.is_action_pressed("player_left"):
		if self.is_on_floor():
			self._speed = max(self._speed-self.ACCEL, -(self.MAX_SPEED+self._bonus_speed))
			self.flip_sprites(true)
			self.position2D_muzzle.position.x = -7
		elif self._does_have_jet_pack:
			self._speed = max(self._speed-self.ACCEL_JET_PACK, -self.MAX_SPEED_JET_PACK)
			self.flip_sprites(true)
			self.position2D_muzzle.position.x = -7
			self.get_node("jet_pack/light2D").position.x = 4
	elif not self.is_on_floor():
		self._speed = lerp(self._speed, 0.00, 0.010)
	else:
		self._speed = lerp(self._speed, 0.00, 0.15)
	
	self._vel.x = self._speed


func flip_sprites(f):
	self.get_node("back_arm").flip_h = f
	self.get_node("front_arm").flip_h = f
	self.get_node("skin").flip_h = f
	
	self._sprite_jet_pack_flame.flip_h = f
	self._sprite_jet_pack.flip_h = f
	
	var dir = 0+int(self._sprite_jet_pack.flip_h)-int(not self._sprite_jet_pack.flip_h)
	
	self._sprite_jet_pack_flame.position.x = 4*dir


func check_raycast_2D():
	"""check the raycast 2D collision"""
	var raycast2D_obj = self.get_node("raycast_2D")
	if raycast2D_obj.is_colliding():
		var collider = raycast2D_obj.get_collider()
		if "brick" in collider.name:
			self.breack_brick(collider)
		else:
			self._game.add_sound_to_audiostreamplayer("unbrocken_brick_character")
			self._vel.y = 0
			self._jump_force = 0


func refresh_bonus_speed():
	self._bonus_speed = lerp(self._bonus_speed, 0.00, 0.10)


func breack_brick(collider):
	"""Called when this object's raycast is colliding with a brick object"""
	
	var brick_colour = collider.get_colur()
	var brick_superpower = collider.get_superpower()
	
	randomize()
	if brick_superpower in ["bomb", "rocket", "bullet"]:
		self.set_ammo(brick_superpower)
		collider.queue_free()
	elif brick_superpower == "plane":
		self._unix_jet_pack = OS.get_unix_time()
		self._does_have_jet_pack = true
		self.set_jet_pack_visibility(true)
		self._game.add_sound_to_audiostreamplayer("starting_on_jet_pack", 1.0, -15)
		self._game.set_btn_mobile_visibility("down", true)
		collider.queue_free()
	elif brick_superpower == "coffee":
		self._bonus_speed = 100
		collider.queue_free()
	elif brick_colour == self._colur:
		self._max_brick_can_be_break += randi()%4+2
		collider.queue_free()
	elif brick_superpower == "" or not brick_superpower:
		if self._brick_broken < self._max_brick_can_be_break:
			self._brick_broken += 1
			collider.queue_free()
	
	self._vel = Vector2.ZERO
	self._jump_force = 0


func set_ammo(weapon_name:String):
	"""
		Used to set the player's character ammo and weapon
	"""
	randomize()
	self._game.set_btn_mobile_visibility("shoot",true)
	match weapon_name:
		"bullet":
			self._dict_ammo["bullet"] += (randi()%6)+1
			self._dict_ammo["micro_rocket"] = 0
			self._dict_ammo["micro_bomb"] = 0
			self._weapon = BULLET
		"rocket":
			self._weapon = ROCKET
			self._dict_ammo["micro_rocket"] += (randi()%10)+1
			self._dict_ammo["micro_bomb"] = 0
			self._dict_ammo["bullet"] = 0
		"bomb":
			self._dict_ammo["micro_rocket"] = 0
			self._dict_ammo["bullet"] = 0
			self._dict_ammo["micro_bomb"] += (randi()%5)+1
			self._weapon = EXPLOSIVE_BULLET


func create_camera():
	"""create a camera object for this object"""
	self._cam_object = Camera2D.new()
	self.add_child(self._cam_object)
	self._game.set_gameplay_mode("character")
	self._game.manage_camera("character", self._cam_object)
	
	self._cam_object.zoom = Vector2(0.5,0.5)


func remove_camera():
	"""
		Removing the camera and setting the camera as gameplay/platformer mode
		
		Bug here
	"""
	print_stack()
	self._game.set_gameplay_mode("platform", self)
	self._game.manage_camera("gameplay", self._cam_object)
	
	if self._cam_object:
		self._cam_object.queue_free()
		self._cam_object = null


func on_collision_bottom():
	"""destroy this object when this hits the bottom"""
	self._game.add_sound_to_audiostreamplayer("character_die_8bits", 1.0, -15)
	self._game.manage_camera("gameplay", self._cam_object)
	self.remove_camera()
	self.queue_free()


func on_collision_explosion():
	"""destroy on explosion collision"""
	self._game.add_sound_to_audiostreamplayer("character_die_8bits")
	self.remove_camera()
	self.queue_free()



func add_sound(sound_name:String):
	randomize()
	var n = sound_name+str(randi())
	
	var audiostream2D_object = AudioStreamPlayer2D.new()
	
	audiostream2D_object.stream = self._dict_sound_src[sound_name]
	audiostream2D_object.name = n
	
	audiostream2D_object.play()
	
	self.get_node("sound").add_child(audiostream2D_object)


func camera_effect_loop():
	"""runtime for camera effect called from process"""
	var is_sliding_x = (self._vel.x < -0.10 or self._vel.x > 0.10)
	var is_falling = (self._vel.y > 0.10 and not is_on_floor())
	
	var speed_zoom = abs(self._vel.x / (self._vel.x - 1000))
	
	var acceleration_zoom = abs(self._speed/(self._vel.x-1000))
	
	if is_sliding_x:
		self._cam_zoom = lerp(self._cam_zoom, 0.40+speed_zoom, 0.004+speed_zoom)
	
	elif self._vel.y < -0.10:#jump
		self._cam_zoom = lerp(self._cam_zoom, 0.17, 0.12)
	elif is_falling:
		self._cam_zoom = lerp(self._cam_zoom, 0.20, 0.12)
	else:
		self._cam_zoom = lerp(self._cam_zoom, 0.30+speed_zoom, 0.05+(speed_zoom+acceleration_zoom))
	
	if self._cam_object:
		self._cam_object.zoom = Vector2(self._cam_zoom, self._cam_zoom)



func take_damage(d):
	"""
		Making damage to this object
		
		Take Args As:
			d (int damage)
	"""
	self._life -= d


func check_time():
	"""
		Check time if it have to destroy this object
	"""
	if OS.get_unix_time()>self._unix_spawn_time+self.MAX_SECOND_DESTROYING:
		self.die()
	else:
		var remaining_minute = (OS.get_unix_time() - self._unix_spawn_time)/60
		if remaining_minute != self._last_minute:
			self._last_minute = abs((self.MAX_SECOND_DESTROYING/60)-remaining_minute)


func check_jet_pack_time():
	"""
		Check if the jet pack should be destroyed
	"""
	self._unix_jet_pack += 1
	if OS.get_unix_time() >= self._unix_jet_pack+self.MAXIMUM_JET_PACK_SECOND:
		self._does_have_jet_pack = false
		self.set_jet_pack_visibility(false)
		
		self._audiostreamplayer2D_jetpack.stream.loop = false
		self._audiostreamplayer2D_jetpack.stop()


func die():
	"""
		Called for destroying this object
	"""
	self.spawn_pieces()
	self._game.set_btn_mobile_visibility("shoot", false)
	self._game.set_btn_mobile_visibility("down", false)
	self._game.set_gameplay_mode("anim_pieces")
	self._game.manage_camera("anim_pieces", self._cam_object)
	self.queue_free()


func spawn_pieces():
	"""
		Spawn pieces from this object like (arms, body, head, ...etc)
		When this object is destroying
	"""
	var list_local_position_y_sub = [8,0,4,6,8]
	
	var obj
	var i = 0
	var global_pos = self.global_position
	global_pos.y += 8
	
	for p in self._dict_pieces_src:
		obj = self._dict_pieces_src[p].instance()
		self._game.get_node("characters_pieces").add_child(obj)
		obj.spawn(global_pos, self._vel)
		
		global_pos.y -= list_local_position_y_sub[i]
		i += 1


func play_jet_pack_sound():
	if not self._audiostreamplayer2D_jetpack.playing and self._does_have_jet_pack:
		self._audiostreamplayer2D_jetpack.autoplay = true
		self._audiostreamplayer2D_jetpack.play()
#	elif not self._does_have_jet_pack:pass
#		self._audiostreamplayer2D_jetpack.
#		self._audiostreamplayer2D_jetpack.stop()
	
	if self._vel.y < 0:
		self._audiostreamplayer2D_jetpack.pitch_scale = 1.0+((abs(self._vel.y)+0.0015)/1200)
		self._audiostreamplayer2D_jetpack.volume_db = -20+abs(self._vel.y/10)
	else:
		self._audiostreamplayer2D_jetpack.volume_db = lerp(self._audiostreamplayer2D_jetpack.volume_db,
														-20,
														0.010)
		
		self._audiostreamplayer2D_jetpack.pitch_scale = lerp(self._audiostreamplayer2D_jetpack.pitch_scale,
														1.00+(self._vel.y/200),
														0.010)

func on_ball_collision():
	"""Called when a ball object collide with this object"""
	self.die()
