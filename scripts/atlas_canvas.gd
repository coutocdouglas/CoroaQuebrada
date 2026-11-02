extends Control
signal region_selected(id: String)
const DATA_PATH = "res://data/world/atlas.json"
var data: Dictionary
var terrain: Array = []
var borders: Array = []
var rivers: Array = []
var routes: Array = []
var selected_id = "coroa"
var mode = "political"
var zoom = 1.0
var pan = Vector2.ZERO
var snapshot: Dictionary = {}
var dragging = false
var drag_distance = 0.0
var region_lookup: Dictionary = {}
var hover_id = ""

func _ready() -> void:
	clip_contents = true
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	data = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	for r in data.regions: region_lookup[r.id] = r
	for c in data.terrain:
		var polygon = points(c.polygon)
		terrain.append({"id": c.id, "region": c.region, "height": c.height, "polygon": polygon, "bounds": polygon_bounds(polygon)})
	for edge in data.borders: borders.append({"points": points(edge.points), "regions": edge.regions, "coast": edge.coast})
	for river in data.rivers: rivers.append(points(river.points))
	for route in data.routes: routes.append({"points": points(route.points), "regions": route.regions, "group": route.group})
	resized.connect(queue_redraw)
	mouse_exited.connect(func(): hover_id = ""; tooltip_text = ""; queue_redraw())

func points(values: Array) -> PackedVector2Array:
	var result = PackedVector2Array()
	for p in values: result.append(Vector2(p[0], p[1]))
	return result

func polygon_bounds(poly: PackedVector2Array) -> Rect2:
	var bounds = Rect2(poly[0], Vector2.ZERO)
	for p in poly: bounds = bounds.expand(p)
	return bounds

func scale_factor() -> float:
	return maxf(0.05, minf(size.x / 1600.0, size.y / 1000.0)) * zoom

func offset() -> Vector2:
	return (size - Vector2(1600,1000) * scale_factor()) * 0.5 + pan

func to_screen(p: Vector2) -> Vector2:
	return p * scale_factor() + offset()

func to_world(p: Vector2) -> Vector2:
	return (p - offset()) / scale_factor()

func region_at(screen_position: Vector2) -> String:
	var p = to_world(screen_position)
	for c in terrain:
		if not c.region.is_empty() and c.bounds.has_point(p) and Geometry2D.is_point_in_polygon(p, c.polygon):
			return c.region
	return ""

func select_region(id: String) -> void:
	if not region_lookup.has(id): return
	selected_id = id
	region_selected.emit(id)
	queue_redraw()

func set_kingdom(state: Dictionary) -> void:
	snapshot = state.regions.duplicate(true)
	queue_redraw()

func reset_view() -> void:
	zoom = 1.0
	pan = Vector2.ZERO
	queue_redraw()

func zoom_at(factor: float, position: Vector2) -> void:
	var world_point = to_world(position)
	zoom = clampf(zoom * factor, 1.0, 6.0)
	pan += position - to_screen(world_point)
	clamp_pan()
	queue_redraw()

func clamp_pan() -> void:
	var limit = Vector2(1600,1000) * scale_factor() * 0.45
	pan = pan.clamp(-limit, limit)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_at(1.2, event.position)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_at(1.0/1.2, event.position)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_distance = 0.0
				grab_focus()
			else:
				dragging = false
				if drag_distance < 6.0: select_region(region_at(event.position))
		accept_event()
	elif event is InputEventMouseMotion:
		if dragging and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
			pan += event.relative
			drag_distance += event.relative.length()
			clamp_pan()
		else:
			dragging = false
			hover_id = region_at(event.position)
			tooltip_text = region_lookup[hover_id].name if region_lookup.has(hover_id) else "Mar ou terras além do reino"
		queue_redraw()
	elif event is InputEventKey and event.pressed:
		if event.keycode == KEY_HOME: reset_view()
		elif event.keycode in [KEY_PLUS, KEY_EQUAL, KEY_KP_ADD]: zoom_at(1.2,size*0.5)
		elif event.keycode in [KEY_MINUS, KEY_KP_SUBTRACT]: zoom_at(1.0/1.2,size*0.5)
		else: return
		accept_event()

func territory_color(c: Dictionary) -> Color:
	var color = Color("52665d")
	if not c.region.is_empty():
		color = Color(region_lookup[c.region].color)
		if mode == "reserves":
			color = Color("59636a")
			if snapshot.has(c.region):
				var r = snapshot[c.region]
				var months = float(r.stock.food) / maxf(1.0, r.consumption)
				color = Color("b56d59").lerp(Color("6fa48a"), clampf(months / 4.0,0.0,1.0))
		if c.region == selected_id: color = color.lightened(0.13)
		elif c.region == hover_id: color = color.lightened(0.06)
	return color.darkened(clampf((float(c.height)-20.0)/180.0,0.0,0.3))

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("172e3a"))
	if data == null: return
	var s = scale_factor()
	draw_set_transform(offset(),0,Vector2.ONE*s)
	for c in terrain:
		draw_colored_polygon(c.polygon,territory_color(c))
	for line in rivers:
		draw_polyline(line,Color("598fa4"),0.9/s,true)
	for edge in borders:
		var selected = selected_id in edge.regions
		draw_polyline(edge.points,Color("e6d5a6") if selected else Color("34463f"), (1.8 if selected else 0.65)/s,true)
	if mode == "routes":
		for route in routes:
			var active = selected_id in route.regions
			var color = Color("f1c783") if active else Color("a4a387",0.48)
			if route.group == "searoutes": color = Color("83cbd7") if active else Color("6a9da8",0.5)
			draw_polyline(route.points,color,(2.0 if active else 0.8)/s,true)
	for town in data.settlements:
		var is_seat = town.id == region_lookup[town.region].seat_id
		if zoom < 1.5 and not is_seat: continue
		var pos = Vector2(town.position[0],town.position[1])
		draw_circle(pos, (3.5 if is_seat else 1.8)/s, Color("f3e1b0"))
		if town.port: draw_arc(pos,5.5/s,0,TAU,12,Color("8dcad2"),1.0/s,true)
	draw_set_transform(Vector2.ZERO)
	for r in data.regions:
		var position = to_screen(Vector2(r.anchor[0],r.anchor[1]))
		draw_circle(position,12,Color("17232b"))
		draw_arc(position,12,0,TAU,20,Color(r.color).lightened(0.3),1.5,true)
		var number = str(int(r.number))
		var font = ThemeDB.fallback_font
		draw_string(font,position+Vector2(-font.get_string_size(number,HORIZONTAL_ALIGNMENT_LEFT,-1,13).x*0.5,4),number,HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color("f0e2bd"))
		if zoom >= 2.0 or r.id == selected_id:
			var text_size = font.get_string_size(r.name,HORIZONTAL_ALIGNMENT_LEFT,-1,14)
			var origin = position+Vector2(-text_size.x*0.5,29)
			draw_rect(Rect2(origin+Vector2(-5,-16),text_size+Vector2(10,6)),Color("14222b",0.92))
			draw_string(font,origin,r.name,HORIZONTAL_ALIGNMENT_LEFT,-1,14,Color("f0e2bd"))
	draw_string(ThemeDB.fallback_font,Vector2(16,size.y-16),"RODA: ZOOM   ·   ARRASTE: MOVER   ·   HOME: REENQUADRAR",HORIZONTAL_ALIGNMENT_LEFT,-1,12,Color("a4b6ba"))

