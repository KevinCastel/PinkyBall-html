extends Node

var _last_seven_keys_pressed = ""

var _last_second

func manage_cheat_code(_event):
	"""manage cheat code used as runtime when input are detected"""
	
	var now = self.get_seconds_now()
	
	if not self._last_second:
		self._last_second = self.get_seconds_now()
	elif self._last_second != now:
		self._last_second = now
	
	self.check_cheat_code()
	self.reset_cheat_code_input()

func get_seconds_now():
	"""set a seconds now and return it"""
	var second = OS.get_datetime()["second"]
	return second

func reset_cheat_code_input():
	"""reset when the last_seven"""
	if len(self._last_seven_keys_pressed) == 7:
		self._last_seven_keys_pressed = ""

func check_cheat_code():
	"""check if the last seven keys repressent a cheat code or not"""
	if self._last_seven_keys_pressed == "dev_admin":
		pass
