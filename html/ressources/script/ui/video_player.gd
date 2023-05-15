extends Control

onready var _video_player = self.get_node("CanvasLayer/VideoPlayer")

func _ready():
	self.manage_window_at_starting()
	self._video_player.play()
	yield(self._video_player, "finished")
	self.get_tree().change_scene("res://ressources/scene/ui/IntroScreen.tscn")

func manage_window_at_starting():
	"""center window"""
	OS.window_size = Vector2(800,500)
	
	var half_screen_size = OS.get_screen_size(0)/6
	
	OS.window_position = half_screen_size


