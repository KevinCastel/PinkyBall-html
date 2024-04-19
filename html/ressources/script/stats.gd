extends Node

var _dict_time_gameplay_mode = {}


var _dict_items = {} #item_name:{spawned:0,used:0}

var _dict_ammo = {"bullet":{"brick_broken":0.00, "fired":0, "missed_brick":0},
				"rocket":{"brick_broken":0.00, "fired":0, "missed_brick":0},
				"plane_m4":{"brick_broken":0.00, "fired":0, "missed_brick":0},
				"micro_bomb" : {"brick_broken":0.00, "fired":0},
				"micro_rocket" : {"brick_broken": 0.00, "fired":0}}

class_name Stats

func set_time_for_gameplay_mode(gameplay_mode_name:String, key_to_add:String):
	"""
		Set started time or ended time for a specific gameplay mode

		Take Args As:
			gameplay_mode_name (String) have to be equal to:
				-'platformer'
				-'character'
				-'plane'
				-'rocket-rc'

			key_to_add (String) have to be equal to:
				-'start'
				-'end'
	"""
	var list = []; var  dict = {}; var index_list
	if gameplay_mode_name in self._dict_time_gameplay_mode:
		#self._dict_time_gameplay_mode[gameplay_mode_name][key_to_add] = self.get_unixtime()
		match key_to_add:
			"start":
				self._dict_time_gameplay_mode[gameplay_mode_name].append({key_to_add:self.get_unixtime()})
			"end":
				list = self._dict_time_gameplay_mode[gameplay_mode_name]
				index_list = len(list)-1
				dict = list[index_list]
				dict[key_to_add] = self.get_unixtime()

				list[index_list] = dict
				self._dict_time_gameplay_mode[gameplay_mode_name] = list
	else:
		self._dict_time_gameplay_mode[gameplay_mode_name] = [{key_to_add:self.get_unixtime()}]


func get_if_gameplay_mode_is_already_added(gameplay_mode_name:String):
	return (gameplay_mode_name in self._dict_time_gameplay_mode)


func get_gameplay_mode_time(gameplay_mode_name:String):
	"""
		Return the time for a gameplay mode time

		Take Args As:
			gameplay_mode_name (String)
	"""
	var all_time
	var t = 0
	if gameplay_mode_name in self._dict_time_gameplay_mode:
		all_time = self._dict_time_gameplay_mode[gameplay_mode_name]
		for d in all_time:
			if "end" in d:
				t += d["end"] - d["start"]

	return t


func global_time_game(convert_result_to_string=false):
	var global_time = 0
	for t in ["plane","platform","character"]:
		global_time += self.get_gameplay_mode_time(t)
	
	if convert_result_to_string:
		if self.check_if_time_can_be_converted_in_minutes(global_time):
			return str(global_time)+"secondes"
		else:
			return str(global_time)+"minutes"
	
	return global_time

func convert_second_to_minutes(second:int):
	return int(second/60)

func check_if_time_can_be_converted_in_minutes(second:int):
	"""
		Return if the value in second passed as argument is higher than 60
	"""
	return (second > 60)

func get_unixtime():
	"""
		Return the unixtime of the system
	"""
	return OS.get_unix_time()


func add_item_used(item_name:String):
	self._dict_items[item_name]["used"] += 1


func add_item_spawned(item_name:String):
	if item_name in self._dict_items:
		self._dict_items[item_name]["spawned"] += 1
	else:
		self._dict_items[item_name] = {"spawned":1, "used":0}


func get_item_spawned(item_name:String):
	return self._dict_items[item_name]["spawned"]


func get_item_used(item_name:String):
	return self._dict_items[item_name]["used"]


func add_ammo_fired(ammo_name:String):
	self._dict_ammo[ammo_name]["fired"] += 1


func add_ammo_brick_broken(ammo_name:String):
	self._dict_ammo[ammo_name]["brick_broken"] += 1


func get_ammo_fired(weapon_name:String):
	return self._dict_ammo[weapon_name]["fired"]


func get_ammo_brick_broken(weapon_name:String):
	return self._dict_ammo[weapon_name]["brick_broken"]


func get_precision_ammo(weapon_name:String):
	return float(self._dict_ammo[weapon_name]["brick_broken"]*self._dict_ammo[weapon_name]["fired"]/100)


func add_brick_missed(weapon_name:String):
	self._dict_ammo[weapon_name]["missed_brick"] += 1


func get_brick_missed(weapon_name:String):
	return self._dict_ammo[weapon_name]["missed_brick"]


func correct_items_missed_during_game():
	"""
		Add items spawn/used to the dict, theses items wasn't added during the
		gameplay
	"""
	for item_name in ["life","rocket", "bomb", "coffee","plane"]:
		if not item_name in self._dict_items:
			self._dict_items[item_name] = {"spawned":0, "used":0}


func get_all_gameplay_time():
	"""
		Return all time passed for each gameplay mode:
			-platformer
			-character
			-plane
			-rocket-rc
		
		
	"""
	var time = 0
	var dict_time = {}
	for t in ["plane","character","platform"]:
		time = self.get_gameplay_mode_time(t)
		if self.check_if_time_can_be_converted_in_minutes(time):
			dict_time[t] = str(self.convert_second_to_minutes(time))+"minute"
		else:
			dict_time[t] = str(time)+"seconds"
	return dict_time


func get_html_text():
	var dict_times = self.get_all_gameplay_time()
	self.correct_items_missed_during_game()
	return "<!-- See All Value for replacing it by a correct value-->"+\
	"\n<title>PinkyBall Stats</title>"+\
	"\n<body bgcolor=\"#000000\">"+\
	'\n<table width="560" align="center" border="0" cellpadding="5" cellspacing="0">'+\
	'\n\t<tr align="center" valign="top">'+\
	'\n\t\t<td height="59" colspan="2" bgcolor="#000000">'+\
	'\n\t\t\t<div align="center">'+\
	'\n\t\t\t\t<font color="#D8247C" size="5" face="Arial, Helvetica, sans-serif">-------------------------------------------------------------------</font>'+\
	'\n\t\t\t\t<font size="5" face="Rage Italic, Arial, sans-serif">'+\
	"\n\t\t\t\t<br>"+\
	'\n\t\t\t\t<strong>'+\
	'\n\t\t\t\t\t<font color="#D8247C" face="Rage italic, Arial, sans-serif">PinkyBall Stats</font>'+\
	'\n\t\t\t\t</strong>'+\
	'\n\t\t\t\t\t<br>'+\
	'\n\t\t\t\t\t\t<font color="#D8247C">-------------------------------------------------------------------</font>'+\
	'n\t\t\t\t</font>'+\
	'n\t\t\t</div>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="22" colspan="2">&nbsp;</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="40" colspan="2">'+\
	'\n\t\t\t<p>'+\
	'\n\t\t\t\t<font color="#26B3FE" size="6"  face="Consola, Arial, Tahoma">'+\
	'\n\t\t\t\t\t<strong>'+str(self.get_date())+'</strong>'+\
	'\n\t\t\t\t</font>'+\
	'\n\t\t\t</p>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="5" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#00EFD8" size="3" face="Tahoma, impact, Helvetica">'+\
	'\n\t\t\t\t<strong>Time Score:</strong>'+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="3" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t\t\t<strong>Time passed as platformer mode:</strong> '+dict_times["platform"]+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	"\n\t</tr>"+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t<td height="5" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t\t\t<strong>Time Passed as plane mode:</strong> '+dict_times["plane"]+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	"\n\t</tr>"+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="5" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\n<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t\t\t<strong>Time passed as Rocket RC</strong> rocket_rc_time_value'+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="5" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t\t\t<strong>Time passed as character:</strong> '+dict_times["character"]+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="25" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#00EFD8" size="3" face="Tahoma, impact, Helvetica">'+\
	'\n\t\t\t\t<strong>Item:</strong>'+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'<\n\t/tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="10" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t\t<strong>Bomb Used:</strong> '+str(self._dict_items["bomb"]["used"])+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="center">'+\
	'\n\t\t<td height="20" colspan="5">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t<strong>Bomb Spawned:</strong> '+str(self._dict_items["bomb"]["spawned"])+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="14" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t\t\t<strong>Bullet Used:</strong> '+str(self._dict_items["bullet"]["used"])+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="20" colspan="5">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t\t\t<strong>Bullet Spawned:</strong> '+str(self._dict_items["bullet"]["spawned"])+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="center">'+\
	'\n\t\t<td height="5" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="14" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t\t\t<strong>Rocket Used:</strong>'+str(self._dict_items["rocket"]["used"])+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial,  Helvetica, sans-serif">'+\
	'\n\t\t\t\t<strong>Rocket Spawned:</strong> '+str(self._dict_items["rocket"]["used"])+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="5" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t\t\t<strong>Life Used:</strong> '+str(self._dict_items["life"]["used"])+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="center">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t\t\t<strong>Life Spawned:</strong> '+str(self._dict_items["life"]["spawned"])+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="25" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="top" bgcolor="#000000">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font size="3" color="#00EFD8" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t\t\t<strong>Weapon:</strong>'+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="center">'+\
	'\n\t\t<td height="3" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="center">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t\t\t<strong>Bullet Fired:</strong> '+str(self._dict_ammo["bullet"]["fired"])+\
	'\n\t\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="center">'+\
	'\n\t\t<td height="8" colspan="2"></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="center" valign="center">'+\
	'\n\t\t<td height="20" colspan="2">'+\
	'\n\t\t\t<font color="#ACBB21" size="2" face="Arial, Helvetica, sans-serif">'+\
	'\n\t\t\t\t<strong>Rocket Fired:</strong> '+str(self._dict_ammo["rocket"]["fired"])+\
	'\n\t\t\t</font>'+\
	'\n\t\t\t</td>'+\
	'\n\t\t</tr>'+\
	'\n\t\t</font>'+\
	'\n</strong>'+\
	'\n\t\t</div></td>'+\
	'\n\t</tr>'+\
	'\n\t<tr align="left" valign="top" bgcolor="#000000">'+\
	'<td height="25" colspan="2">'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n</table>'+\
	'\n<table width="560" border="0"  align="right" cellspacing="0" cellpadding="5">'+\
	'\n\t<tr align="center" valign="bottom" bgcolor="#000000">'+\
	'\n\t<td>'+\
	'\n\t\t<font color="#26B3FE" size="2" face="consola">'+\
	'\n\t\t\t<a href="http://www.itch.io/Invitation/PinkyBall">PinkyBall On Itch.IO</a>'+\
	'\n\t\t</font>'+\
	'\n\t</td>'+\
	'\n<td>'+\
	'\n\t<font color="#26B3FE" size="2" face="consola">'+\
	'\n\t\t<a href="http://www.itch.io/Invitation/">Itch.IO Invitation</a>'+\
	'\n\t\t</font>'+\
	'\n\t\t</td>'+\
	'\n\t</tr>'+\
	'\n\t</table>'+\
	'\n<body/>'

func get_date():
	var datetime = OS.get_datetime()
	return str(datetime["hour"])+"/"+str(datetime["month"])+"/"+str(datetime["day"])+"|"+str(datetime["hour"])+"/"+str(datetime["minute"])+"/"+str(datetime["second"])
