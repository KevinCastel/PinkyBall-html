extends Camera2D


var _move_speed = 0.5 #camera position lerp speed
var _zoom_speed = 0.05 #camera zoom lerp speed
var _min_zoom = 1.0 #camera won't zoom closer than this
var _max_zoom = 1.7 #camera won't zoom farther than this
var _margin = Vector2(300, 150) # include some buffer area around target 400,200

onready var _screen_size = get_viewport_rect().size

var _list_targets = []

func add_target(obj):
	"""add object as target"""
	if not obj in self._list_targets:
		self._list_targets.append(obj)

func remove_target(obj):
	"""remove obj that is ones of the target
	of this camera"""
	var index
	if obj in self._list_targets:
		index = self._list_targets.find(obj)
		self._list_targets.remove(index)

func _process(_delta):
	"""runtime"""
	if !self._list_targets:
		return
	
	var p = Vector2.ZERO
	for target in self._list_targets:
		if target:
			p += target.position
	
	p /= _list_targets.size()
	position = lerp(position, p, self._move_speed)
	
	#Find the zoom that will contain all targets
	var r = Rect2(position, Vector2.ONE)
	for target in self._list_targets:
		r = r.expand(target.position)
	
	r = r.grow_individual(self._margin.x, self._margin.y,
						self._margin.x, self._margin.y)
	
	var z
	if r.size.x > r.size.y * self._screen_size.aspect():
		z = clamp(r.size.x / self._screen_size.x,
				self._min_zoom, self._max_zoom)
	
	else:
		z = clamp(r.size.y / self._screen_size.y,
					self._min_zoom, self._max_zoom)
	
	self.zoom = lerp(self.zoom, Vector2.ONE * z, self._zoom_speed)
