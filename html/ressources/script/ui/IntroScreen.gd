extends Control


func _on_btn_next_pressed():
	var audio_stream_obj = self.get_node("ColorRect/audiostreamplayer_sound_effect")
	audio_stream_obj.play()
	yield(audio_stream_obj,"finished")
	self.get_tree().change_scene("res://ressources/scene/ui/ui_menu.tscn")
