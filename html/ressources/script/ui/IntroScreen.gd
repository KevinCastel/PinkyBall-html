extends Control

onready var _label_rules = self.get_node("ColorRect/VBoxContainer/HboxContainer/label_rules")
onready var _MAXIMUM_LINES = len(self._label_rules.text.split("\n"))
onready var _scrollbar = self.get_node("ColorRect/VBoxContainer/HboxContainer/VScrollBar")

func _ready():
	self._scrollbar.max_value = self._MAXIMUM_LINES-self._label_rules.max_lines_visible


func _on_btn_next_pressed():
	self.get_node("ColorRect/btn_next").visible = false
	var audio_stream_obj = self.get_node("ColorRect/audiostreamplayer_sound_effect")
	audio_stream_obj.play()
	yield(audio_stream_obj,"finished")
# warning-ignore:return_value_discarded
	self.get_tree().change_scene("res://ressources/scene/ui/ui_menu.tscn")


func _on_VScrollBar_scrolling():
	self._label_rules.lines_skipped = (self._scrollbar.value-1)+int(self._scrollbar.value == 0)
