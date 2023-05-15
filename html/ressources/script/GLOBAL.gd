extends Node

var new_player_name = "" setget set_player_name

var new_player_time = 0.00 setget set_player_time

var new_player_score = null setget set_player_score

func set_player_name(v):
	new_player_name = v

func set_player_time(v):
	new_player_time = v

func set_player_score(v):
	new_player_score = v


func get_if_is_a_new_player():
	return (new_player_score != null and new_player_name != "" and new_player_time != 0.00)
