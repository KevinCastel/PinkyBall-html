"""
	This file is extended from SilentWolf (Brass Hoorper)
	
	I've created this one while using Leaderboard (Brass Hoorper) for
	a customized leaderboard
"""

extends Control

var max_scores = 10

var list_index = 0

onready var _label_information = self.get_node("panel_leaderboard/label_information")

const ScoreItem = preload("res://ressources/scene/ui/ScoreItem.tscn")
const SWLogger = preload("res://addons/silent_wolf/utils/SWLogger.gd")

var ld_name = " control_leaderboard"

func _ready():
	"""
		Ready from Leaderboard.gd (Brass Hoorper) Silent Wolf
		
		Called for 
	"""
	print("SilentWolf.Scores.leaderboards: " + str(SilentWolf.Scores.leaderboards))
	print("SilentWolf.Scores.ldboard_config: " + str(SilentWolf.Scores.ldboard_config))
	self._label_information.visible = false
	var scores = []
	if ld_name in SilentWolf.Scores.leaderboards:
		scores = SilentWolf.Scores.leaderboards[ld_name]
	var local_scores = SilentWolf.Scores.local_scores
	
	if len(scores) > 0: 
		render_board(scores, local_scores)
	else:
		# use a signal to notify when the high scores have been returned, and show a "loading" animation until it's the case...
		add_loading_scores_message()
		yield(SilentWolf.Scores.get_high_scores(), "sw_scores_received")
		hide_message()
		render_board(SilentWolf.Scores.scores, local_scores)
	
	if Global.get_if_is_a_new_player():
		self.add_item_manualy(Global.new_player_name,
							Global.new_player_score,
							Global.new_player_time)


func render_board(scores, local_scores):
	var all_scores = scores
	if ld_name in SilentWolf.Scores.ldboard_config and is_default_leaderboard(SilentWolf.Scores.ldboard_config[ld_name]):
		all_scores = merge_scores_with_local_scores(scores, local_scores, max_scores)
		if !scores and !local_scores:
			add_no_scores_message()
	else:
		if !scores:
			add_no_scores_message()
	if !all_scores:
		for score in scores:
			add_item(score.player_name, str(int(score.score)), str(int(score.time)))
	else:
		for score in all_scores:
			add_item(score.player_name, str(int(score.score)), str(int(score.metadata["time"])))


func add_loading_scores_message():
	self._label_information.visible = true
	self._label_information.text = "Loading Scores..."


func hide_message():
	self._label_information.visible = false


func is_default_leaderboard(ld_config):
	var default_insert_opt = (ld_config.insert_opt == "keep")
	var not_time_based = !("time_based" in ld_config)
	return  default_insert_opt and not_time_based


func merge_scores_with_local_scores(scores, local_scores, max_scores=10):
	if local_scores:
		for score in local_scores:
			var in_array = score_in_score_array(scores, score)
			if !in_array:
				scores.append(score)
			scores.sort_custom(self, "sort_by_score");
	var return_scores = scores
	if scores.size() > max_scores:
		return_scores = scores.resize(max_scores)
	return return_scores


func add_no_scores_message():
	self._label_information.visible = true
	self._label_information.text = "No Score Yet!"



func add_item(player_name, score, time):
	var item = ScoreItem.instance()
	list_index += 1
	
	item.get_node("panel_score_item/VBoxContainer/label_username").text = str(list_index) + str(". ") + player_name

	item.get_node("panel_score_item/VBoxContainer/label_score").text = "Brick Brocken :"+score+\
															" Time :"+time+"secondes"
	
	
	item.anchor_top = list_index * 100
	item.size_flags_vertical = SIZE_EXPAND_FILL
	
	self.get_node("panel_leaderboard/Node2D/ScrollContainer/ScoreItemContainer").add_child(item)
#	self.get_node("panel_leaderboard/ScoreItemContainer").add_child(item)


func score_in_score_array(scores, new_score):
	var in_score_array =  false
	if new_score and scores:
		for score in scores:
			if score.score_id == new_score.score_id: # score.player_name == new_score.player_name and score.score == new_score.score:
				in_score_array = true
	return in_score_array


func add_item_manualy(player_name:String, score, time):
	"""
		Add score for this new score
	"""
	var item = ScoreItem.instance()
	list_index += 1
	
	item.get_node("panel_score_item/VBoxContainer/label_username").text = str(list_index) + str(". ") + player_name

	item.get_node("panel_score_item/VBoxContainer/label_score").text = "Brick Brocken :"+str(score)+\
															" Time :"+str(time)+"secondes"
	
	
	item.anchor_top = list_index * 100
	item.size_flags_vertical = SIZE_EXPAND_FILL
	
	self.get_node("panel_leaderboard/Node2D/ScrollContainer/ScoreItemContainer").add_child(item)
#	self.get_node("panel_leaderboard/ScoreItemContainer").add_child(item)


func _on_btn_close_pressed():
	self.play_sound("accept")
	yield(self.get_node("audiostreamplayer_effect"), "finished")
	self.get_tree().change_scene("res://ressources/scene/ui/ui_menu.tscn")


func play_sound(context:String):
	var dict_preload_sound = {"accept":preload("res://ressources/sound/menu/accept_sound.mp3"),
							"wrong":preload("res://ressources/sound/menu/wrong_sound.mp3")}
	var audiostreamplayer_effect = self.get_node("audiostreamplayer_effect")
	audiostreamplayer_effect.stream = dict_preload_sound[context]
	audiostreamplayer_effect.play()
