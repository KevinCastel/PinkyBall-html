extends Node

"""used for the console object"""

class_name Console

var _list_lines = []

var _textedit_obj; var _historic_richtxt_obj

var _prompt = "dev>"

var _parent_game_node

var _pattern_vector2D = "([\\d][^a-z])+"

func clear_console_input(txt_obj_to_clear):
	"""clear the console input

	Take arg as:
		textedit (textedit Node)
	"""
	txt_obj_to_clear.text = ""

func remove_line_return():
	"""Remove '\n' from text of txteditor_obj"""
	var txt = self._textedit_obj.text
	if "\n" in txt:
		txt = txt.replace("\n", "")
		self._textedit_obj.text = txt

func add_line(cmd, use_prompt = false):
	"""add line to the console"""
	if use_prompt:
		self._historic_richtxt_obj.text += self._prompt+cmd+"\n"
	else:
		self._historic_richtxt_obj.text += cmd+"\n"

func cmd_software(cmd:String):
	"""
		Called when the parent command 'software' is called

		Take Args As:
			cmd (str) witch is the input
	"""
	var dict_group_value = {}

	var string_prediction = ""; var dict_predictions = {}
	if cmd == "software.version":
		self.add_line("This version of PinkyBall is 1.2 (rewrite)")
	elif cmd == "software.restart":
		self._parent_game_node.get_tree().reload_current_scene()
	elif cmd.begins_with("software --pause"):
		dict_group_value["value"] = self.get_argument(
			"(software --pause:)(?<value>.*)",cmd, "value")

		if dict_group_value["value"] == "true":
			self.add_line("The software is paused")
			self._parent_game_node._pause = true
		elif dict_group_value["value"] == "false":
			self.add_line("The software is unpaused")
			self._parent_game_node._pause = false
		else:
			self.add_line("The value should be a boolean value ('true' or 'false')"+\
						"Not '"+dict_group_value["value"]+"'")
	elif cmd.begins_with("software pause"):
		self.add_line("Remember pause is a set-var, any set-var should be write with the prefix '--'")
	elif cmd == "software":
		self.add_line("This command wait argument see 'help software'")
	else:
		dict_predictions = self.calculate_prediction(cmd,
						["software --pause:true",
						"software --pause:false",
						"software.restart",
						"software.version"])
		string_prediction = self.get_prediction(dict_predictions)

		self.add_line("Maybe this "+string_prediction)

func cmd_help(cmd:String):
	"""called when the user inputed the help command"""
	if cmd == "help":
		self.add_line("Here all commands in a-z orders:"+\
					"\n'camera' <argument manipulate the camera object"+\
					"\n'example <argument>' show value example (see 'help example' for argument)"+\
					"\n'player' manipulate the player object (see 'help player')"+\
					"\n'software' manipulated this software (see 'help software')"+\
					"\n'spawn' spawn object on the map"+\
					"\n'var' show all argument type for command (see 'help var')"+\
					"\n'value' show all values type for argument ('see 'help value')"+\
					"\nUse 'help var' for getting information on type arguments"+\
					"\nUse 'help value' for getting information on values of arguments")
	elif cmd == "help player":
		self.add_line("Here all commands in a-z orders"+\
					"\n'ammo-bullet' :('info-var') show the player's ammo for bullet"+\
					"\n'ammo-bullet' :('set-var', int value) set the player's ammo for bullet"+\
					"\n'ammo-rocket' :('info-var') show the player's ammo for rocket"+\
					"\n'ammo-rocket' :('set-var', int value) set the player's ammo for rocket"+\
					"\n'follow-ball' :('info-var') show if the player's platform follow the ball"+\
					"\n'follow-ball' :('set-var', bool value) set if the player's platform follow the ball"+\
					"\n'life' : ('info-var') show if the player's life"+\
					"\n'life' : ('set-var', int value) show if the player's life"+\
					"\n'mode' : ('info-var') show the actual gameplay mode"+\
					"\n'position' :('info-var') show the player object "+\
					"\n'position' :'<int x,int y>' is the new position"+\
					"\n'weapon' :('info-var') show information about the player's weapon"+\
					"\n'weapon' :'<int value>' set the player's weapon, you can use the following weapon name:"+\
					"\n\t'bullet' :(non-explosive weapon)"+\
					"\n\t'rocket' :(explosive weapon)")
	elif cmd == "help software":
		self.add_line("Help for the command software help"+\
					"\n'pause:<bool value>' (set-var): set if the gameplay is pause or unpaused"+\
					"\n'restart' (action-var)"+\
					"\n'version' (info-var)")
	elif cmd == "help var":
		self.add_line("Help for the use of argument called:"+\
					"\nThere is two type of arguments:"+\
					"\n\tset-var used for changing value and always use"+\
					"prefix like '--'"+\
					"\n\tinfo-var used for getting a value and doesn't use prefix"+\
					"\n\taction-var used for making change")
	elif cmd == "help value":
		self.add_line("Help for the use of argument called:"+\
					"\nSome value wait a specific type of value used in programmation"+\
					"\n\t'bool' have two value 'true' or 'false'"+\
					"\n\t'int' wait a integer number"+\
					"\n\t'string' can be whatever as word or setence"+\
					"\nSee 'help example' for generating example of theses types")
	elif cmd == "help example":
		self.add_line("Help for the example command called:"+\
					"\nThere is three types of value, here:"+\
					"\n\t'bool"+\
					"\n\t'string'"+\
					"\n\t'int'"+\
					"\n\t'float'"+\
					"\nUse example command like 'example <type>'")
	elif cmd == "help spawn":
		self.add_line("Help for the spawn command:"+\
					"At first, it take the argument 'item' (set-var) wait a 'string value'"+\
					"cannot be random value, have to be from this list of items:"+\
					"\n\t'bomb' :spawn a bomb object ('position' allowed)"+\
					"\n\t'bullet' : spawn a bullet object ('position' & 'ammo' allowed)"+\
					"\n\t'heart' : spawn a heart object ('position' allowed)"+\
					"\n\t'plane' : spawn a plane object ('position' allowed)"+\
					"\n\t'rocket' : spawn a rocket object ('position' & 'ammo' & 'rc' allowed)"+\
					"\n\t'slowball' : spawn a slowball object ('position' allowed)"+\
					"\n\n-'position' (set-var) (int value, int value) can be used as Vector var,"+\
					"used to spawn the object at the specified position"+\
					"\n-'ammo' (set-var) (int value) used to specify the ammo"+\
					"\n-'rc' (set-var) (bool value) used to specify if the object is controllable"+\
					" by the player (not by default)")
	elif cmd == "help camera":
		self.add_line("Help for camera command called:"+\
					"'camera' is used for manipulating the player camera, need argument like:"+\
					"\n-'mode' : 'set-var, string value' is for changing camera by value, the value need to be in this list:"+\
					"\n\t'character' : set a camera on the character"+\
					"\n\t'debug' : set a camera on the world's map"+\
					"\n\t'rocket' : set a camera on the player's rocket"+\
					"\n\t'plane' : set a camera on the player's plane"+\
					"Can show a error if the player object isn't as the value specified")

func cmd_example(cmd:String):
	"""Called when the user called the example command"""
	var list_string = ["Hello", "Hello Friends", "3+2=4"]

	randomize()
	var i = -1; var e

	if cmd == "example string":

		i = int(rand_range(0, len(list_string)-1))
		e = list_string[i]

		self.add_line("Here a string example:'"+e+"'")
	elif cmd == "example int":
		i = int(rand_range(0, 100))

		self.add_line("Here a int example:"+str(i))
	elif cmd == "example bool":
		self.add_line("The bool can be assigned with 'true' or 'false'")
	elif cmd == "example float":
		i = rand_range(0.00, 99.00)

		e = "%.2f"%i

		self.add_line("Here a float32 example :"+str(e))
	elif cmd == "example":
		self.add_line("'example' wait argument use 'help example' for help")


func cmd_ball(cmd:String):
	"""Called when the user called the 'player' command"""
	var _error_level = 0
	var dict_match = {}
	
	dict_match["parent"] = self.get_argument("(?<parent>[\\w]*)(\\s*)",
						cmd,
						"parent")

	dict_match["first_argument_prefix"] = self.get_argument(dict_match["parent"]+\
						"(\\s*)(?<prefix_argument>[^\\w\\d]*)",
						cmd,
						"prefix_argument")

	dict_match["first_argument_name"] = self.get_argument(dict_match["parent"]+"(\\s*)"+\
						dict_match["first_argument_prefix"]+"(?<argument_name>[\\w][^\\d:]*)(\\s*)",
						cmd,
						"argument_name")

	dict_match["first_argument_equal_sign"] = self.get_argument("(.*)"+dict_match["first_argument_prefix"]+\
										dict_match["first_argument_name"]+"(\\s*)(?<equal_sign>[^\\w\\d]*)(\\s*)",
										cmd,
										"equal_sign")

#	print_stack()
#	print("dict_match:", dict_match)

func cmd_player(cmd:String):
	"""
		Called when the user called the 'player' command
	"""
	var error_level = 0

	var dict_match = {}

	dict_match["parent"] = self.get_argument("(?<parent_command>[\\w]*)",
											cmd,
											"parent_command")

	dict_match["first_argument_prefix"] = self.get_argument(
		dict_match["parent"]+"(\\s*)(?<prefix>[^\\w]*)",
		cmd,
		"prefix")

	if dict_match["first_argument_prefix"] != "":
		dict_match["first_argument_name"] = self.get_argument(
			dict_match["parent"]+"(\\s*)"+dict_match["first_argument_prefix"]+"(?<argument_name>[\\w-]*)",
			cmd,
			"argument_name")
	else:
		dict_match["first_argument_name"] = self.get_argument(
			dict_match["parent"]+"(\\s*)(?<argument_name>[\\w-]*)",
			cmd,
			"argument_name"
		)

	dict_match["first_argument_equal_sign"] = self.get_argument(
			"(.*)"+dict_match["first_argument_prefix"]+dict_match["first_argument_name"]+\
			"(\\s*)(?<equal_sign>[^\\d\\w\\s]*)(\\s*)",
			cmd,
			"equal_sign")

	dict_match["first_argument_value"] = self.get_argument(
			"(.*)"+dict_match["first_argument_name"]+"(\\s*)"+dict_match["first_argument_equal_sign"]+\
			"(\\s*)(?<argument_value>[\\w\\d,][^\\s]*)(\\s*)",
			cmd,
			"argument_value")

	if dict_match["first_argument_value"]:
		if dict_match["first_argument_name"] == "position":
			dict_match = self.check_argument(dict_match,
												{0:"position",1:"",2:""},
												"first")
		elif dict_match["first_argument_name"] in ["ammo-bullet", "ammo-rocket"]:
			dict_match = self.check_argument_value(dict_match,
													"first",
													{0:"ammo-bullet"},
													{0:"([\\d]+)"})

	if not "is_first_argument_valid" in dict_match:
		dict_match["is_first_argument_valid"] = true

#	print_stack()
#	print("dict_match:", dict_match)

	var player_node
	var detail = ""; var follow_ball : bool
	var list_command = ["ammo-bullet","ammo-rocket", "position",
						"weapon","message","mode"]


	if not dict_match["first_argument_value"]: dict_match["first_argument_value"] = ""

	if not dict_match["first_argument_name"] in list_command:
		error_level = 1
		self.add_line("'"+dict_match["first_argument_name"]+"' isn't recognise"+\
									"\nSee 'help player'")
	elif dict_match["first_argument_prefix"] != "" and dict_match["first_argument_prefix"] != "--":
		error_level = 1
		self.add_line("'"+dict_match["first_argument_value"]+"' can't be used as 'set-var' but the prefix isn't "+\
		"'"+dict_match["first_argument_prefix"]+"' but '--'")
	elif dict_match["first_argument_name"] == "position" and not dict_match["is_first_argument_value_valid"]:
		error_level = 1
		self.add_line("'"+dict_match["first_argument_value"]+"' isn't valid should be use like 'int x,int y'")
	elif dict_match["first_argument_name"] in list_command and dict_match["first_argument_prefix"] == "--"\
				and dict_match["first_argument_value"] == "":
		error_level = 1
		self.add_line("'"+dict_match["first_argument_name"]+"' is a 'set-var', you used the prefix '--' so a value was waited")
	elif dict_match["first_argument_name"] in ["ammo-bullet", "ammo-rocket"] and not dict_match["is_first_argument_valid"]:
		error_level = 1
		self.add_line("'"+dict_match["first_agument_name"]+"' waited a 'int value' see 'example var'")
	
	if error_level == 0:
		if dict_match["first_argument_name"] == "life" and dict_match["first_argument_prefix"] == "":
			self.add_line("\tPlayer life :"+str(self._parent_game_node._player_life))
		elif dict_match["first_argument_name"] == "message":
			self._parent_game_node.show_message(dict_match["first_argument_value"])
		elif dict_match["first_argument_name"] == "life" and dict_match["first_argument_prefix"] != "":
			detail = str(self._parent_game_node._player_life)
			self._parent_game_node._player_life = int(dict_match["first_argument_value"])
			self.add_line("\tPlayer life changed: "+detail+" by "+dict_match["first_argument_value"])
		elif dict_match["first_argument_name"] == "mode" and dict_match["first_argument_prefix"] == "":
			self.add_line("Player's gameplay mode:'"+ self._parent_game_node.get_gameplay_mode()+"'")#show the mode
		elif dict_match["first_argument_name"] == "position" and dict_match["first_argument_prefix"] == "":
			if self._parent_game_node._gameplay_mode == "platform":
				detail = "patform"
				player_node = self._parent_game_node.get_node("player")
			elif self._parent_game_node._gameplay_mode == "plane":
				detail = "plane"
				player_node = self._parent_game_node._dict_player_node["plane"]
			elif self._parent_game_node._gameplay_mode == "rocket":
				detail = "rocket"
				player_node = self._parent_game_node._dict_player_node["rocket"]
			elif self._parent_game_node._gamepay_mode == "character":
				detail = "character"
				player_node = self._parent_game_node._dict_player_node["character"]
				
			
			self.add_line("Player's position ("+detail+") :"+\
			str(player_node.global_position.x)+","+str(player_node.global_position.y))
		elif dict_match["first_argument_name"] == "position" and dict_match["first_argument_prefix"] != "":
			if self._parent_game_node._gameplay_mode == "platform":
				detail = "patform"
				player_node = self._parent_game_node.get_node("player")
			elif self._parent_game_node._gameplay_mode == "plane":
				detail = "plane"
				player_node = self._parent_game_node._dict_player_node["plane"]
			elif self._parent_game_node._gameplay_mode == "rocket":
				detail = "rocket"
				player_node = self._parent_game_node._dict_player_node["rocket"]
			elif self._parent_game_node._gamepay_mode == "character":
				detail = "character"
				player_node = self._parent_game_node._dict_player_node["character"]
				
			self.add_line("Player's "+detail+" moved from :"+\
				str(player_node.global_position.x)+","+str(player_node.global_position.y)+\
				" to "+str(dict_match["first_argument_value"]))
			
			player_node.global_position = self.string_to_vector2D(dict_match["first_argument_value"])
		elif dict_match["first_argument_name"] == "follow-ball" and dict_match["first_argument_prefix"] != "":
			follow_ball = (dict_match["first_argument_value"] == "true")
			if follow_ball != self._parent_game_node._force_player_position:
				if follow_ball:
					self._parent_game_node._force_player_position = false
					detail = "Player's platform unfollow the ball"
				else:
					self._parent_game_node._force_player_position = true
					detail = "Player's platform follow the ball"
			else:
				detail = "You attempted to assign the same value that is already assigned"

			self.add_line(detail)
		elif dict_match["first_argument_name"] == "follow-ball" and dict_match["first_argument_prefix"] == "":
			if self._parent_game_node._force_player_position:
				detail = "Player's platform have to follow ball"
			else:
				detail = "Player's platform havn't to follow ball"
				
			self.add_line(detail)
		elif dict_match["first_argument_name"] == "name" and dict_match["first_argument_prefix"] == "":
			if not self._parent_game_node._player_name:
				self._parent_game_node._player_name = "guest"
			
			self.add_line("Player's name :'"+self._parent_game_node._player_name+"'")
		elif dict_match["first_argument_name"] == "name" and dict_match["first_argument_prefix"] != "":
			detail = "Player's name '"+self._parent_game_node._player_name+\
				"' changed by '"+self._parent_game_node._player_name+"'"
			self._parent_game_node._player_name = dict_match["first_argument_value"]
		elif dict_match["first_argument_name"] == "mode":
			self.add_line("Player's mode is '"+self._parent_game_node._gameplay_mode+"'")
		elif dict_match["first_argument_name"] == "ammo-rocket" and dict_match["first_argument_prefix"] != "":
			player_node = self._parent_game_node.get_node("player")
			detail = str(player_node._weapon_data["rocket"])
			self.add_line("Player's ammo for rocket changed :'"+dict_match["first_argument_value"]+"'"+\
						" by '"+detail+"'")
		elif dict_match["first_argument_name"] == "ammo-bullet" and dict_match["first_argument_prefix"] == "":
			player_node = self._parent_game_node.get_node("player")
			if player_node._weapon_data["bullet"] > 0:
				self.add_line("Player's ammo for bullet :", player_node._weapon_data["bullet"])
			else:
				self.add_line("Player doesn't have ammo for bullet")
		elif dict_match["first_argument_name"] == "ammo-rocket" and dict_match["first_argument_prefix"] == "":
			player_node = self._parent_game_node.get_node("player")
			if player_node._weapon_data["rocket"] > 0:
				self.add_line("Player's ammo for rocket :", player_node._weapon_data["rocket"])
			else:
				self.add_line("The player havn't bullet for rocket")
		elif dict_match["first_argument_name"] == "ammo-bullet" and dict_match["first_argument_prefix"] != "":
			player_node = self._parent_game_node.get_node("player")
			detail = str(player_node._weapon_data["bullet"])
			self.add_line("Player's ammo for bullet changed :'"+detail+"'"+\
							" by '"+dict_match["first_argument_value"]+"'")
		elif dict_match["first_argument_name"] == "ammo-rocket" and dict_match["first_argument_prefix"] == "":
			player_node = self._parent_game_node.get_node("player")
			detail = str(player_node._weapon_data["rocket"])
			self.add_line("Player's ammo for rocket changed :'"+detail+"'"+\
							" by '"+dict_match["first_argument_value"]+"'")
		elif dict_match["first_argument_name"] == "weapon" and dict_match["first_argument_prefix"] == "":
			player_node = self._parent_game_node.get_node("player")
			if player_node._weapon != "":
				detail = "Player's weapon :'"+str(player_node._weapon)+"'"
			else:
				detail = "The player doesn't have this weapon"
			
			self.add_line(detail)
		elif dict_match["first_argument_name"] == "weapon" and dict_match["first_argument_prefix"] != "":
			player_node = self._parent_game_node.get_node("player")
			detail = player_node._weapon
			if detail != dict_match["first_argument_value"]:
				if player_node._weapon_data[dict_match["first_argument_value"]] > 0:
					detail = "Player's weapon changed from :'"+detail+"' to '"+dict_match["first_argument_value"]+"'"
				else:
					detail = "You try to give a weapon that the player doesn't have ammo for it"
			else:
				detail = "You attempted to set the player's weapon to what it is already"
			self.add_line(detail)
	else:
		self.add_line("A error was raised...")

func cmd_camera(cmd:String):
	"""Called when the user called the camera command"""
	var dict_match = {}

	var error_level = 0

	dict_match["parent"] = self.get_argument(
				"(?<parent>[\\w]*)(\\s*)",
				cmd,
				"parent")

	dict_match["first_argument_prefix"] = self.get_argument(
			dict_match["parent"]+"(\\s*)(?<argument_prefix>[^\\w\\d]*)",
			cmd,
			"argument_prefix")

	dict_match["first_argument_name"] = self.get_argument(
			dict_match["parent"]+"(\\s*)"+dict_match["first_argument_prefix"]+\
			"(?<argument_name>[\\w]*)",
			cmd,
			"argument_name")

	dict_match["first_argument_equal_sign"] = self.get_argument(
			"(.*)"+dict_match["first_argument_prefix"]+dict_match["first_argument_name"]+\
			"(\\s*)"+"(?<argument_value>[^\\w\\d\\s]*)(\\s*)",
			cmd,
			"argument_value")

	dict_match["first_argument_value"] = self.get_argument(
			"(.*)"+dict_match["first_argument_name"]+"(\\s*)"+dict_match["first_argument_equal_sign"]+\
			"(\\s*)(?<argument_value>[\\w]*)",
			cmd,
			"argument_value")

#	print_stack()
#	print("dict_match:", dict_match)

	if dict_match["first_argument_name"] != "mode":
		error_level = 1
		self.add_line("'"+dict_match["first_argument_name"]+"' isn't recognise")
	elif dict_match["first_argument_name"] == "mode" and dict_match["first_argument_prefix"] != "--":
		error_level = 1
		self.add_line("'"+dict_match["first_argument_value"]+"' is a 'set-var', use this argument with the prefix '--'")
	elif not dict_match["first_argument_value"] in ["debug", "platform", "plane", "rocket", "character"]:
		error_level = 1
		self.add_line("'"+dict_match["first_argument_value"]+"' isn't recognise, see 'help camera'")
	elif dict_match["first_argument_value"] in ["plane", "rocket", "character"]:
		error_level = int(not self._parent_game_node._dict_player_node[dict_match["first_argument_value"]])
		self.add_line("'"+dict_match["first_argument_value"]+"' isn't used actual")
	
	if error_level == 0:
		if dict_match["first_argument_name"] == "mode":
			self._parent_game_node.manage_camera(dict_match["first_argument_value"])

func cmd_spawn(cmd:String):
	"""
		Called when the user called the 'spawn' command

		At first analyze the input and extract information by RegEx (Godot):
			Check if the command have arguments so if it's true,
			the script extract the argument's name with argument's value

		To Finish it can send a message in the console for showing the error
			if there is or there are, the message contains a help redirecting
			sometime some advices, it get a prediction help too!

		For redirecting after finding error the algorythm used a error_level
			to redirect the conditions

		Take Args As:
			cmd (string) witch is the user's input
	"""
	var error_level = 0

	var prediction = ""; var dict_predictions = {}

	var list_items = ["bullet", "rocket", "heart", "bomb", "plane"]

	var list_prediction_model = ["spawn --item:bullet",
								"spawn --item:bullet --position:x,x",
								"spawn --item:bullet --ammo:x",
								"spawn --item:bullet --ammo:x --position:x,x",
								"spawn --item:bullet --position:x,x --ammo:x",
								"spawn --item:rocket",
								"spawn --item:rocket --rc:false",
								"spawn --item:rocket --rc:false --ammo:x",
								"spawn --item:rocket --rc:false --ammo:x --position:x,x",
								"spawn --item:rocket --ammo:x --rc:false --position:x,x",
								"spawn --item:rocket --position:x,x --rc:false --ammo:x",
								"spawn --item:rocket --rc:true",
								"spawn --item:rocket --rc:true --ammo:x --position:x,x",
								"spawn --item:rocket --rc:true --position:x,x --ammo:x",
								"spawn --item:plane",
								"spawn --item:plane --position:x,x"
								]

	var dict_match = {}

	var character_to_captured = "ù|\\*|\\^|¨|$|¤|£|€|^!|^?|,|;|^\\s|"

	dict_match["parent_command"] = self.get_argument(
									"(?<parent_command>[\\w]*)",
									cmd,
									"parent_command")

	dict_match["first_argument_prefix"] = self.get_argument(
									dict_match["parent_command"]+"(\\s*)(?<first_argument_prefix>[^\\w|^\\d]*)([^\\w]*)",
									cmd,
									"first_argument_prefix")


	if dict_match["first_argument_prefix"] != "":
		dict_match["first_argument_name"] = self.get_argument(
			dict_match["parent_command"]+"(\\s+)"+dict_match["first_argument_prefix"]+"(?<argument_name>[a-z|"+character_to_captured+"]*)(\\s*)(:)",
			cmd.to_lower(),
			"argument_name")
	else:
		dict_match["first_argument_name"] = self.get_argument(
			"(spawn )(?<argument_name>[\\w]*)(.*)",
			cmd,
			"argument_name")

	if dict_match["first_argument_name"]:
		dict_match["first_argument_equal_sign"] = self.get_argument(
											"(.*)"+dict_match["first_argument_name"]+"(\\s*)(?<equal_sign>[^\\w]*)(\\s*)(\\w)",
											cmd,
											"equal_sign")

		if not dict_match["first_argument_equal_sign"]:
			dict_match["first_argument_equal_sign"] = ""

		dict_match["first_argument_value"] = self.get_argument(
			"(.*)"+dict_match["first_argument_name"]+"(\\s*)"+dict_match["first_argument_equal_sign"]+"(\\s*)(?<argument_value>[\\w]*)(\\s*)",
			cmd,
			"argument_value")

		var second_argument = self.get_argument(
								dict_match["first_argument_value"]+"(\\s*)(?<others>.*)",
								cmd,
								"others")
		var third_argument = ""

		if second_argument != "":
			dict_match["second_argument_prefix"] = self.get_argument(
				"(?<prefix>[^\\w]*)",
				second_argument,
				"prefix")

			dict_match["second_argument_name"] = self.get_argument(
				dict_match["second_argument_prefix"]+"(?<second_argument_name>[\\w]*)",
				second_argument,
				"second_argument_name")

			dict_match["second_argument_equal_sign"] = self.get_argument(
				dict_match["second_argument_name"]+"(\\s*)(?<second_argument_equal_sign>([^\\w]*))",
				second_argument,
				"second_argument_equal_sign")

			dict_match["second_argument_value"] = self.get_argument(
				dict_match["second_argument_name"]+"(\\s*)"+dict_match["second_argument_equal_sign"]+\
				"(\\s*)"+"(?<argument_value>[\\w|,]*)",
				second_argument,
				"argument_value")

			dict_match = self.check_argument(dict_match,
													{0:"ammo",1:"position",2:"rc"},
													"second")

			third_argument = self.get_argument(
							dict_match["second_argument_value"]+"(\\s*)(?<third_argument>(.*))",
							second_argument,
							"third_argument")

			print("third_argument:", third_argument)

			if third_argument != "":
				dict_match["third_argument_prefix"] = self.get_argument(
									"(\\s*)(?<prefix>[^\\w]*)",
									third_argument,
									"prefix")

				dict_match["third_argument_name"] = self.get_argument(
						dict_match["third_argument_prefix"]+"(?<argument_name>[\\w]*)",
						third_argument,
						"argument_name")

				dict_match["third_argument_equal_sign"] = self.get_argument(
						dict_match["third_argument_name"]+"(\\s*)(?<argument_value>[^\\w]*)",
						third_argument,
						"argument_value")

				dict_match["third_argument_value"] = self.get_argument(
						dict_match["third_argument_equal_sign"]+"(\\s*)"+"(?<argument_value>[\\w|,]*)",
						third_argument,
						"argument_value")

				dict_match = self.check_argument(dict_match,
														{0:"ammo", 1:"position",2:"rc"},
														"third")

#		print_stack()
#		print("dict_match:", dict_match)

		dict_predictions = self.calculate_prediction(cmd, list_prediction_model)
		prediction = self.get_prediction(dict_predictions)
		if dict_match["first_argument_prefix"] != "--" and dict_match["first_argument_name"] == "item":
			error_level = 1
			self.add_line("'item' is a 'set-var', this command use the prefix '--'"+\
						"\n maybe "+prediction) #indicate to the user that 'item' is a set-var
		elif dict_match["first_argument_name"] != "item":
			error_level = 1
			self.add_line("'"+dict_match["first_argument_name"]+"' isn't recognised try with 'item'"+\
						"\nMaybe "+prediction) #indicate to the user that the first argument have to be 'item'
		elif dict_match["first_argument_equal_sign"] != ":" and dict_match["first_argument_equal_sign"] != "=":
			error_level = 1
			self.add_line("'"+dict_match["first_argument_equal_sign"]+"' have to be ':'"+\
							"Maybe "+prediction)
		elif not dict_match["first_argument_value"] in list_items:
			error_level = 1
			self.add_line("'"+dict_match["first_argument_value"]+"' isn't know as item (see help with 'help spawn')")
		elif second_argument != "":
			if dict_match["second_argument_prefix"] != "--" and dict_match["second_argument_name"] in ["position", "ammo","rc"]:
				error_level = 1
				self.add_line("'"+dict_match["second_argument_name"]+"' is a 'set-var', any 'set-var' use the prefix '--'")
			elif not dict_match["second_argument_name"] in ["position", "ammo", "rc"]:
				error_level = 1
				self.add_line("'"+dict_match["second_argument_name"]+"' isn't recognise (see 'help spawn')")
			elif dict_match["second_argument_name"] == "ammo" and not dict_match["is_second_argument_value_valid"]:
				error_level = 1
				self.add_line("'"+dict_match["second_argument_value"]+"' isn't an appropriate value for '"+dict_match["second_argument_name"]+"'"+\
							",\nHave to be a int value (see 'help example')")
			elif dict_match["second_argument_name"] == "position" and not dict_match["is_second_argument_value_valid"]:
				error_level = 1
				self.add_line("'"+dict_match["second_argument_value"]+"' isn't an appropriate value for '"+dict_match["second_argument_name"]+"'")
			elif dict_match["first_argument_name"] == "rocket" and dict_match["second_argument_name"] == "rc" and not dict_match["second_argument_value"] in ["true", "false"]:
				error_level = 1
				self.add_line("'"+dict_match["second_argument_name"]+"' is a bool value so true or false")
			elif dict_match["first_argument_value"] in ["heart", "bomb", "plane"] and dict_match["second_argument_name"] == "rc":
				error_level = 1
				self.add_line("'"+dict_match["first_argument_value"]+"' doesn't take the argument '"+dict_match["second_argument_name"]+"'")
			elif third_argument != "":
				if dict_match["second_argument_name"] == dict_match["third_argument_name"]:
					error_level = 1
					self.add_line("'"+dict_match["second_argument_name"]+"' have to be used one time")
	else:
		self.add_line("An error was catched...")

	var dict_arguments = {}
	var optionnal = ""

	if error_level == 0:
		if cmd.begins_with("spawn --item:slowball"):
			dict_arguments["posiiton"] = null
			if "second_argument_name" in dict_match:
				if dict_match["second_argument_name"] == "position":
					dict_arguments["position"] = dict_match["second_argument_name"]

			if dict_arguments["position"]:
				optionnal += "spawn at "+dict_arguments["position"]
				dict_arguments["position"] = self.string_to_vector2D(dict_arguments["position"])
			else:
				optionnal += "spawn at the player"

			self.add_line("Spawn slowball "+optionnal)
		elif cmd.begins_with("spawn --item:plane"):
			dict_arguments["position"] = null
			if "second_argument_name" in dict_match:
				if dict_match["second_argument_name"] == "position":
					dict_arguments["position"] = dict_match["second_argument_value"]
			if "third_argument_name" in dict_match:
				if dict_match["third_argument_value"] == "position":
					dict_arguments["position"] = dict_match["third_argument_value"]

			if dict_arguments["position"]:
				optionnal += "spawn at"+dict_arguments["position"]
				dict_arguments["position"] = self.string_to_vector2D(dict_arguments["position"])
			else:
				optionnal += "spawn at player"


			dict_arguments["ammo"] = null
			if "second_argument_name" in dict_match:
				if dict_match["second_argument_name"] == "ammo":
					dict_arguments["ammo"] = int(dict_match["second_argument_value"])
			if "third_argument_name" in dict_match:
				if dict_match["third_argument_name"] == "ammo":
					dict_arguments["ammo"] = int(dict_match["third_argument_value"])

			if dict_arguments["ammo"]:
				optionnal += "ammo :"+str(dict_arguments["ammo"])
			else:
				optionnal += " ammo :4"

			self._parent_game_node.manage_spawning_item_by_cheat_or_console(
				"plane",
				dict_arguments["position"],
				false,
				dict_arguments["ammo"]
			)
			self.add_line("Spawn plane "+optionnal)
		elif cmd.begins_with("spawn --item:bullet"):
			dict_arguments["position"] = null
			if "second_argument_name" in dict_match:
				if dict_match["second_argument_name"] == "position":
					dict_arguments["position"] = dict_match["second_argument_name"]
			if "third_argument_name" in dict_match:
				if dict_match["third_argument_name"] == "posiiton":
					dict_arguments["position"] = dict_match["third_argument_value"]

			if dict_arguments["position"]:
				optionnal += "spawn at "+dict_arguments["position"]
				dict_arguments["position"] = self.string_to_vector2D(dict_arguments["position"])
			else:
				optionnal += "spawn at player"

			dict_arguments["ammo"] = null
			if "second_argument_name" in dict_match:
				if dict_match["second_argument_name"] == "ammo":
					dict_arguments["ammo"] = dict_match["second_argument_value"]
			if "third_argument_name" in dict_match:
				if dict_match["third_argument_name"] == "ammo":
					dict_arguments["ammo"] = dict_match["third_argument_value"]

			if dict_arguments["ammo"]:
				dict_arguments["ammo"] = int(dict_arguments["ammo"])
				optionnal += " ammo:"+str(dict_arguments["ammo"])
			else:
				dict_arguments["ammo"] = 0
				optionnal += " ammo:0"

			self._parent_game_node.manage_spawning_item_by_cheat_or_console(
													"bullet",
													dict_arguments["position"],
													null,
													dict_arguments["ammo"])

			self.add_line("Spawn bullet "+optionnal)
		elif cmd.begins_with("spawn --item:heart"):
			dict_arguments["position"] = null
			if "second_argument_name" in dict_match:
				if dict_match["second_argument_name"] == "position":
					dict_arguments["position"] = dict_match["second_argument_value"]

			if dict_arguments["position"]:
				optionnal += "spawn at"+dict_arguments["position"]
				dict_arguments["position"] = self.string_to_vector2D(dict_arguments["position"])
			else:
				optionnal += "spawn at player"

			self.add_line("Spawn heart "+optionnal)

			self._parent_game_node.manage_spawning_item_by_cheat_or_console(
													"heart",
													dict_arguments["position"])
		elif cmd.begins_with("spawn --item:bomb"):
			dict_arguments["position"] = null
			if dict_match["first_argument_name"] == "position":
				dict_arguments["position"] = dict_match["first_argument_value"]
			if "second_argument_name" in dict_match:
				if dict_match["second_argument_name"] == "position":
					dict_arguments["position"] = dict_match["second_argument_value"]


			if dict_arguments["position"]:
				optionnal += "at "+dict_arguments["position"]
				dict_arguments["position"] = self.string_to_vector2D(dict_arguments["position"])
			else:
				optionnal += "at player"

			self.add_line("Spawn bomb "+optionnal)

			self._parent_game_node.manage_spawning_item_by_cheat_or_console(
														"bomb",
														dict_arguments["position"])

		elif cmd.begins_with("spawn --item:rocket"):
			dict_arguments["position"] = null
			if dict_match["first_argument_name"] == "position":
				dict_arguments["position"] = dict_match["first_argument_value"]
			if "second_argument_name" in dict_match:
				if dict_match["second_argument_name"] == "position":
					dict_arguments["position"] = dict_match["second_argument_value"]
			if "third_argument_name" in dict_match:
				if dict_match["third_argument_name"] == "position":
					dict_arguments["position"] = dict_match["third_argument_value"]

			if dict_arguments["position"]:
				optionnal += "at "+dict_arguments["position"]
				dict_arguments["position"] = self.string_to_vector2D(dict_arguments["position"])
			else:
				optionnal += "at player"

			dict_arguments["rc"] = "false"
			if dict_match["first_argument_name"] == "rc":
				dict_arguments["rc"] = dict_match["first_argument_value"]

			if "second_argument_name" in dict_match:
				if dict_match["second_argument_name"] == "rc":
					dict_arguments["rc"] = dict_match["second_argument_value"]
			if "third_argument_name" in dict_match:
				if dict_match["third_argument_name"] == "rc":
					dict_arguments["rc"] = dict_match["third_argument_value"]
			dict_arguments["rc"] = (dict_arguments["rc"] == "true")

			if dict_arguments["rc"]:
				optionnal += " rc"

			dict_arguments["ammo"] = null
			if dict_match["first_argument_name"] == "ammo":
				dict_arguments["ammo"] = int(dict_arguments["first_argument_value"])
			if "second_argument_name" in dict_match:
				if dict_match["second_argument_name"] == "ammo":
					dict_arguments["ammo"] = int(dict_arguments["second_argument_value"])
			if "third_argument_name" in dict_match:
				if dict_match["third_argument_name"] == "ammo":
					dict_arguments["ammo"] = int(dict_arguments["third_argument_value"])

			if dict_arguments["ammo"]:
				optionnal += " ammo:"+str(dict_arguments["ammo"])
			else:
				dict_arguments["ammo"] = 0
				optionnal += " ammo:0"

			self._parent_game_node.manage_spawning_item_by_cheat_or_console(
													"rocket",
													dict_arguments["position"],
													dict_arguments["rc"],
													dict_arguments["ammo"])

			self.add_line("Spawn rocket "+optionnal)

func string_to_vector2D(string_:String):
	"""
		Convert string_ to Vector2D
	"""
	var list_values = string_.split(",")
	return Vector2(float(list_values[0]), float(list_values[1]))

func check_argument_value(dict_matched:Dictionary, cardinal_number:String,
							dict_condition:Dictionary, dict_pattern:Dictionary):
	"""
		Called for checking if this argument's value contains error or not.

		Called for add bool value to the 'dict_matched', this bool value
		is if the argument's value contains error or not

		'dict_matched' can have multiple arguments so a cardinal nummber
			need to be specified for the new key in the dictionnary,
			the key add :'is_<cardinal_number>_argument_value_valid'

		'dict_pattern' contains index as key (for condition, have to be in the
			keys of 'dict_condition'), the key
			value contains the string pattern for the regex

		For checking if value is valid or not it use the regex object,
			Every patterns are passed as arguments in 'dict_pattern'

		'dict_condition' contains index (int) as key, the key's value is
			what the string ('argument_value') have to be equal.

		There is a link between 'dict_condition' and 'dict_pattern',
			when the condition 'dict_condition' value is equal to
			the 'argument_name' (string)

		*can automatise for 10 conditions

		return 'dict_match' with the new key & value
	"""
	var argument_value = dict_matched[cardinal_number+"_argument_value"]
	var argument_name = dict_matched[cardinal_number+"_argument_name"]

	var is_argument_value_valid = false

	var dict_backup = dict_condition

	for i in range(0,10):
		if not i in dict_backup:
			dict_condition[i] = ""

	if argument_name == dict_condition[0]:
		is_argument_value_valid = self.check_if_matched(dict_pattern[0],
														argument_value)
	elif argument_name == dict_condition[1]:
		is_argument_value_valid = self.check_if_matched(dict_pattern[1],
														argument_value)
	elif argument_name == dict_condition[2]:
		is_argument_value_valid = self.check_if_matched(dict_pattern[2],
														argument_value)
	elif argument_name == dict_condition[3]:
		is_argument_value_valid = self.check_if_matched(dict_pattern[3],
														argument_value)
	elif argument_name == dict_condition[4]:
		is_argument_value_valid = self.check_if_matched(dict_pattern[4],
														argument_value)
	elif argument_name == dict_condition[5]:
		is_argument_value_valid = self.check_if_matched(dict_pattern[5],
														argument_value)
	elif argument_name == dict_condition[6]:
		is_argument_value_valid = self.check_if_matched(dict_pattern[6],
														argument_value)
	elif argument_name == dict_condition[7]:
		is_argument_value_valid = self.check_if_matched(dict_pattern[7],
														argument_value)
	elif argument_name == dict_condition[8]:
		is_argument_value_valid = self.check_if_matched(dict_pattern[8],
														argument_value)
	elif argument_name == dict_condition[9]:
		is_argument_value_valid = self.check_if_matched(dict_matched[9],
														argument_value)

	dict_matched["is_"+cardinal_number+"_argument_value_valid"] = is_argument_value_valid

	return dict_matched

func check_argument(dict_matched:Dictionary, dict_condition_argument:Dictionary,
							str_index_argument:String):
	"""
		Called for checking if this argument's value contains error or not

		The algorythm's (condition) detail:
			-First condition is for Vector2 value like 'x,y'
			
			-Second condition is for Vector2 value like 'x,y'
			
			-Third condition is for bool value ('true' or 'false')
		
		Take Args As:
			dict_matched : Dictionnary (string: string and bool) contains all matched arguments
				(RegEx group) from the user input
			
			dict_condition_argument : Dictionnary (int:string) contains condition string in order
				by index
			
			str_index_argument : String indicate if it's 'third' argument or the 'second' argument
		
		Return the dict_matched
	"""
	if dict_matched[str_index_argument+"_argument_name"] == dict_condition_argument[0]:
		dict_matched["is_"+str_index_argument+"_argument_value_valid"] = self.check_if_matched(
					_pattern_vector2D,
					dict_matched[str_index_argument+"_argument_value"])
	elif dict_matched[str_index_argument+"_argument_name"] == dict_condition_argument[1]:
		dict_matched["is_"+str_index_argument+"_argument_value_valid"] = self.check_if_matched(
					"(([\\d])(,)([\\d]))+",
					dict_matched[str_index_argument+"_argument_value"])
	elif dict_matched[str_index_argument+"_argument_name"] == dict_condition_argument[2]:
		dict_matched["is_"+str_index_argument+"_argument_value"] = self.check_if_matched(
					"(true|false)",
					dict_matched[str_index_argument+"_argument_value"])
	else:
		dict_matched["is_"+str_index_argument+"_argument_valid"] = false

	return dict_matched

func check_if_matched(pattern:String, string_:String):
	"""
		Check if string_ match with pattern (RegEx)

		Return if it match or not
	"""
	var does_have_matched = false
	var regex_match = RegEx.new()
	regex_match.compile(pattern)
	var match_obj = regex_match.search(string_)
	if match_obj:
		does_have_matched = (match_obj.strings[0] != "")

	return does_have_matched

func execute_command(cmd):
	"""execute the command if know, if unknow return error"""
	if cmd == "clear" or cmd == "cls":
		self.clear_console_input(self._historic_richtxt_obj)
	elif cmd == "close":
		self._parent_game_node.set_console_visible(false)
	elif str(cmd).begins_with("software"):
		self.cmd_software(cmd)
	elif str(cmd).begins_with("help"):
		self.cmd_help(cmd)
	elif str(cmd).begins_with("example"):
		self.cmd_example(cmd)
	elif str(cmd).begins_with("spawn"):
		self.cmd_spawn(cmd)
	elif str(cmd).begins_with("player"):
		self.cmd_player(cmd)
	elif str(cmd).begins_with("camera"):
		self.cmd_camera(cmd)
	elif str(cmd).begins_with("ball"):
		self.cmd_ball(cmd)
	else:
		self.add_line("Nothing foundt for '"+cmd+"' see 'help'")

func get_argument(pattern:String, cmd:String, index_return=null, search_all=true):
	"""
		Analyze a string (cmd:String) with the pattern (string) by RegEx

		If cmd match with the pattern, the method can return the string group
		element wanted (index_return) by default his value is equal to null
		so when the value is equal to -1 nothing is returned

		return the argument
	"""
	var list_groups = []; var index_string = 0; var string_matched
	var regex_object = RegEx.new()
	regex_object.compile(pattern)

	var match_obj

	if search_all:
		match_obj = regex_object.search_all(cmd)
	else:
		match_obj = regex_object.search(cmd)

	if match_obj:
		if typeof(index_return) == TYPE_STRING:
			index_string = self.get_index_of_match_group(match_obj[0], index_return)
			string_matched = self.get_string_by_index_from_match_group(match_obj[0], index_string)

			return string_matched
		elif typeof(index_return) == TYPE_ARRAY:
			for string_match in match_obj[0].strings:
				if index_string in index_return:
					list_groups.append(string_match)
				index_string += 1
			return list_groups
		else:
			return "error"
	else:
		return null

func get_string_by_index_from_match_group(match_obj, index_string):
	"""return the string by the index"""
	var string = ""; var i = 0
	for s in match_obj.strings:
		if i == index_string:
			string = s
		i += 1
	return string

func get_index_of_match_group(match_obj, group_name):
	"""Return the group index of the name"""
	var index_group = -1
	for g in match_obj.names:
		if g == group_name:
			index_group = match_obj.names[group_name]

	return index_group

func export_map():
	"""manage the exporting map"""
	var dict_maps = self._parent_game_node.get_map()
	if dict_maps:
		self.add_line("Exported with success")
	else:
		self.add_line("No exportation")

func manage_command(textedit_obj, historic_richtxt_obj, parent_node):
	"""manage command"""
	self._parent_game_node = parent_node
	self._textedit_obj = textedit_obj
	self._historic_richtxt_obj = historic_richtxt_obj
	self.remove_line_return()
	self.add_line(self._textedit_obj.text, true)

	var cmd = self._textedit_obj.text
	self.clear_console_input(self._textedit_obj)

	if len(cmd) > 0:self.execute_command(cmd)

func calculate_prediction(cmd:String, list_prediction_model:Array):
	"""
		Calculate the prediction of the command typed

		At first check if each character foundt are the same position
			in the cmd and the model that is iterate from
			list_prediction_model

		Take Args As:
			cmd (str) witch is the command
			list_prediction_model (Array:str)
	"""
	var predict = 0
	var dict_prediction = {}
	for c in list_prediction_model:
		dict_prediction[c] = 0.00

	var index_character_from_cmd = 0; var index_character = 0
	for character_from_cmd in cmd:
		for string_model in list_prediction_model:
			predict = 0
			index_character = 0
			for c in string_model:
				if c == character_from_cmd and index_character == index_character_from_cmd:
					predict += 30
				elif c in cmd:
					predict += 10
				index_character += 1
			dict_prediction[string_model] = predict
		index_character_from_cmd += 1

	return dict_prediction

func get_prediction(dict_model:Dictionary):
	"""
		Iterate the dictionnary passed as argument
		Get the string that have the highest probabillity value

		Take Args As:
			dict_model : Dictionnary(String:Float)
		Return string_
	"""
	var predict = 0
	var string_ = ""
	for k in dict_model:
		if predict < dict_model[k]:
			predict = dict_model[k]
			string_ = k
	return string_
