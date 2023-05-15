extends RigidBody2D

var _last_global_position = Vector2.ZERO

var _count_destroy = 0

const MAX_COUNTER_DESTROY = 3

onready var _game_node = self.find_parent("game")
onready var _audio_stream_player_2D_falling = self.get_node("audiostreamplayer2D")

func spawn(global_pos, flip_h, impulse_value = Vector2(100, 3)):
	if flip_h:self.rotation_degrees -= 180
	self.contact_monitor = true
	self.contacts_reported = 5
	self.global_position = global_pos
	self.apply_central_impulse(impulse_value.rotated(self.rotation))
	

func _physics_process(_delta):
	"""
		Main runtime for thiso object
	"""
	self.play_audio_stream_player_2D()
	if self._last_global_position != self.global_position:
		self._count_destroy = 0
		self._last_global_position = self.global_position
	else:
		self._count_destroy += 1
		if self._count_destroy > self.MAX_COUNTER_DESTROY:
			self.explose()


func explose():
	"""
		Called for destroying this object and creating a explosion
	"""
	self._audio_stream_player_2D_falling.stop()
	self._game_node.manage_explosion(self.global_position,
								"micro_bomb")
	self.queue_free()


func can_explose_on_collision():
	return (self.linear_velocity.x > 60 or self.linear_velocity.x < -60 or\
			self.linear_velocity.y > 60 or self.linear_velocity.y <-60)


func _on_explosive_ball_body_entered(_body):
	self.explose()


func play_audio_stream_player_2D():
	var new_value = int(abs(self.linear_velocity.y - 0.00))
	if new_value > 0.0001:
		self._audio_stream_player_2D_falling.pitch_scale = 1.00+(new_value/85)
		self._audio_stream_player_2D_falling.volume_db = -20+(new_value/14)

