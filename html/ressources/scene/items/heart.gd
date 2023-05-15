extends "res://ressources/script/items/item_object.gd"

var _life = 0

func set_life():
	randomize()
	self._life = randi()%100

func play_animation():
	"""called for playing animation"""
	var anim_node = self.get_node("anim")
	anim_node.play("beat")

func get_life():
	return self._life

func start_sound():
	self.get_node("audio_stream_player2D_beat").play()
