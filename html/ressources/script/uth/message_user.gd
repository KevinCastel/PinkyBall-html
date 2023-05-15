extends Node2D

var _show = true

var _alpha_incremante = 0.005

var _chrono_interlude = 0
var _max_chrono_interlude = 1 #used to wait between the show and hide mode

onready var _parent_game_node = self.find_parent("game")

func reset():
	"""
		Called when a message object was already existing
		
	"""
	self._show = true
	self._chrono_interlude = 0

func spawn(global_pos = Vector2.ZERO):
	"""
		Replace the basic _ready() function
		
		Take Args As:
			global_pos : Vector2
	"""
	self.modulate.a = 0
	
	self.global_position = global_pos

func force_position(value:int, value_index:String):
	"""
		Force the position for escaping position bug,
		
		Use value (int) for moving the x or y,
		value_index (string) used for know if it
		have to modify the 'x' or 'y' value
	"""
	var label_obj = self.get_node("label")
	if value_index == "x":
		label_obj.rect_position.x = value
	elif value_index == "y":
		label_obj.rect_position.y = value

func _process(_delta):
	"""main runtime of this object"""
	if self._parent_game_node._pause: return
	
	var m = self.modulate.a
	
	if self._show:
		self.modulate.a += self._alpha_incremante
		self._show = (int(m) < 3)
	elif self._chrono_interlude < self._max_chrono_interlude:
		self._chrono_interlude += 1
	elif m > 0:
		self.modulate.a -= self._alpha_incremante
	else:
		self.destroy()

func set_text(text):
	"""Set the message to the user"""
	self.get_node("label").text = text

func destroy():
	self.queue_free()
