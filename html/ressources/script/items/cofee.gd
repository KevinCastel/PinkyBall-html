extends "res://ressources/script/items/item_object.gd"


func _on_coffee_body_entered(_body):
	self.create_audio_stream_playerD("collision_coffee", 1.0, self.get_sound_volume("coffee"))


func _on_coffee_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	self.create_audio_stream_playerD("collision_coffee", 1.0, self.get_sound_volume("coffee"))
