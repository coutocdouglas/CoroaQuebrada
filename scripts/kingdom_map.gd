extends Control
## A read-only view of the simulation. Geometry never owns territory or resources.
signal region_selected(region_id: String)

const IDS = ["vale", "marca", "costa"]
const CENTERS = {"vale": Vector2(4, 6), "marca": Vector2(12, 3), "costa": Vector2(11, 10)}
const COLORS = {"vale": Color("789258"), "marca": Color("7d8271"), "costa": Color("4d8e77")}
const FLAGS = {"vale": Color("d2b95e"), "marca": Color("c47360"), "costa": Color("65b7c7")}
const ROAD = [Vector2(4,6), Vector2(8,6), Vector2(12,6), Vector2(12,3)]
const SOUTH_ROAD = [Vector2(8,6), Vector2(8,10), Vector2(11,10)]
const VILLAGES = [Vector2(3,7), Vector2(5,4), Vector2(10,4), Vector2(13,5), Vector2(9,10), Vector2(13,9)]
const FIELDS = [Vector2(2,5), Vector2(3,4), Vector2(4,8), Vector2(6,8), Vector2(6,3), Vector2(10,10)]
var snapshot: Dictionary = {}
var selected_id = "vale"
var hovered_id = ""
var map_scale = 1.0
var map_offset = Vector2.ZERO

func _ready() -> void:
	custom_minimum_size = Vector2(580, 340)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	clip_contents = true
	resized.connect(queue_redraw)
	mouse_exited.connect(func(): hovered_id = ""; tooltip_text = ""; queue_redraw())
	focus_mode = Control.FOCUS_ALL
	tooltip_text = "Clique em um território para abrir seus dados e decisões."

func set_kingdom(state: Dictionary, region_id: String) -> void:
	# Copy only values needed by the view. Loading and starting a game can replace the state.
	snapshot = {"month": state.month, "troops": state.troops, "regions": {}}
	for id in IDS:
		var r = state.regions[id]
		snapshot.regions[id] = {
			"name": r.name, "food": r.stock.food, "consumption": r.consumption,
			"loyalty": r.loyalty, "unrest": r.unrest,
			"recruited": r.get("recruitment_month", 0) == state.month,
			"petition": false
		}
		for p in state.politics.petitions:
			if p.region == id and p.status == "open": snapshot.regions[id].petition = true
	if IDS.has(region_id): selected_id = region_id
	queue_redraw()

func update_transform() -> void:
	# World bounds include castles, labels, coast and the lower legend.
	map_scale = maxf(0.1, minf((size.x - 36.0) / 870.0, (size.y - 90.0) / 455.0))
	map_offset = Vector2(size.x * 0.5 + 25.0 * map_scale, 42.0 + maxf(0.0, (size.y - 90.0 - 455.0 * map_scale) * 0.5))

static func project(cell: Vector2) -> Vector2:
	return Vector2((cell.x - cell.y) * 27.0, (cell.x + cell.y) * 13.5)

func cell_to_screen(cell: Vector2) -> Vector2:
	update_transform()
	return project(cell) * map_scale + map_offset

static func tile_region(x: int, y: int) -> String:
	if x < 0 or y < 0 or x >= 18 or y >= 14: return ""
	if (x >= 16 and y >= 6) or (y >= 12 and x >= 8) or (x == 0 and y < 3) or (x >= 15 and y <= 1): return ""
	if x >= 8 and y < 7: return "marca"
	if x < 8 and y < 11: return "vale"
	return "costa"

func region_at(point: Vector2) -> String:
	update_transform()
	var local = (point - map_offset) / map_scale
	# Castles and their labels may extend above a tile: include their whole footprint.
	for id in IDS:
		var center = project(CENTERS[id])
		if Rect2(center + Vector2(-97,31), Vector2(205,57)).has_point(local): return id
		if Rect2(center + Vector2(-64, -75), Vector2(128, 98)).has_point(local): return id
	# Tiles are centered on integer grid coordinates, not their upper corners.
	var x = roundi(local.x / 54.0 + local.y / 27.0)
	var y = roundi(local.y / 27.0 - local.x / 54.0)
	return tile_region(x, y)

func select_at(point: Vector2) -> bool:
	var id = region_at(point)
	if id.is_empty(): return false
	selected_id = id
	region_selected.emit(id)
	queue_redraw()
	return true

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if select_at(event.position):
			grab_focus()
			accept_event()
	elif event is InputEventMouseMotion:
		var id = region_at(event.position)
		if hovered_id != id:
			hovered_id = id
			if not id.is_empty() and snapshot.regions.has(id):
				var r = snapshot.regions[id]
				tooltip_text = "%s\nAlimentos: %d • Consumo/mês: %d\nLealdade: %d • Agitação: %d\nClique para governar esta região." % [r.name, r.food, r.consumption, r.loyalty, r.unrest]
			else: tooltip_text = "Mar das Marés • Clique em um território."
			queue_redraw()
	elif event is InputEventKey and event.pressed and not event.echo:
		var index = IDS.find(selected_id)
		if event.keycode in [KEY_RIGHT, KEY_DOWN]: index = (index + 1) % IDS.size()
		elif event.keycode in [KEY_LEFT, KEY_UP]: index = (index + IDS.size() - 1) % IDS.size()
		else: return
		selected_id = IDS[index]
		region_selected.emit(selected_id)
		queue_redraw()
		accept_event()

func diamond(center: Vector2, half_width: float = 27.0, half_height: float = 13.5) -> PackedVector2Array:
	return PackedVector2Array([center + Vector2(0,-half_height), center + Vector2(half_width,0), center + Vector2(0,half_height), center + Vector2(-half_width,0)])

func polygon(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), color)

func text_at(point: Vector2, text: String, font_size: int, color: Color, centered: bool = false) -> void:
	var font = ThemeDB.fallback_font
	if centered: point.x -= font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x / 2.0
	draw_string(font, point, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

func _draw() -> void:
	draw_style_box(panel_style(), Rect2(Vector2.ZERO, size))
	if snapshot.is_empty(): return
	update_transform()
	text_at(Vector2(18, 24), "TERRITÓRIOS DA COROA", 14, Color("d9bb79"))
	text_at(Vector2(size.x - 18, 24), "N", 15, Color("c5d4ca"), true)
	draw_set_transform(map_offset, 0, Vector2.ONE * map_scale)
	# Calm water underneath one contiguous landmass.
	for x in range(19):
		for y in range(15):
			if tile_region(x, y).is_empty():
				var p = project(Vector2(x,y))
				draw_polyline(PackedVector2Array([p+Vector2(-10,0),p+Vector2(0,3),p+Vector2(10,0)]), Color(0.25,0.46,0.52,0.35), 1, true)
	# Ground drawn back to front, with a raised edge along the coastline.
	for depth in range(32):
		for x in range(18):
			var y = depth - x
			if y < 0 or y >= 14: continue
			var id = tile_region(x,y)
			if id.is_empty(): continue
			var p = project(Vector2(x,y))
			var shape = diamond(p)
			polygon([shape[1],shape[2],shape[2]+Vector2(0,9),shape[1]+Vector2(0,9)], Color("35483e"))
			polygon([shape[2],shape[3],shape[3]+Vector2(0,9),shape[2]+Vector2(0,9)], Color("293e37"))
			var color: Color = COLORS[id]
			color = color.lightened(float((x * 17 + y * 31) % 7) * 0.012)
			if id == selected_id: color = color.lightened(0.09)
			elif id == hovered_id: color = color.lightened(0.04)
			draw_colored_polygon(shape, color)
			draw_polyline(PackedVector2Array([shape[0],shape[1],shape[2],shape[3],shape[0]]), Color(0.13,0.22,0.17,0.13), 0.8, true)
	# Roads are geographical decoration in 0.4: they do not alter trade rules yet.
	for path in [ROAD, SOUTH_ROAD]:
		var points = PackedVector2Array()
		for cell in path: points.append(project(cell))
		draw_polyline(points, Color("59654d"), 11, true)
		draw_polyline(points, Color("c1ad7c"), 7, true)
	# Border edges only, so the map stays readable rather than a grid of outlines.
	for x in range(18):
		for y in range(14):
			var id = tile_region(x,y)
			if id.is_empty(): continue
			var d = diamond(project(Vector2(x,y)))
			var edge_color = Color("eed18a") if id == selected_id else Color("3c5449")
			var neighbors = [Vector2i(x,y-1),Vector2i(x+1,y),Vector2i(x,y+1),Vector2i(x-1,y)]
			for i in range(4):
				if tile_region(neighbors[i].x, neighbors[i].y) != id:
					draw_line(d[i], d[(i+1)%4], edge_color, 2.2 if id == selected_id else 1.3, true)
	# Terrain props share the tile depth order; no global random state is consumed.
	for depth in range(32):
		for x in range(18):
			var y = depth - x
			if y < 0 or y >= 14: continue
			var cell = Vector2(x,y)
			var id = tile_region(x,y)
			if id.is_empty(): continue
			var p = project(cell)
			var r = snapshot.regions[id]
			if FIELDS.has(cell):
				field(p, r.food < r.consumption, id == "vale" and snapshot.month <= 2)
			elif VILLAGES.has(cell):
				house(p+Vector2(-9,0), r.unrest >= 40)
				house(p+Vector2(9,5), r.unrest >= 40)
			elif cell == CENTERS[id]:
				castle(p, id)
			elif not on_road(cell) and not near_castle(cell):
				if id == "marca" and (x * 7 + y * 3) % 6 == 0:
					mountain(p)
				elif (x * 13 + y * 7) % 8 == 0:
					tree(p, id == "marca")
			if r.recruited and cell == CENTERS[id] + Vector2(2,1): camp(p)
	# A small harbor on the coast, without pretending there is a naval simulation.
	var port = project(Vector2(15,10))
	polygon([port+Vector2(-8,2),port+Vector2(43,27),port+Vector2(50,23),port+Vector2(0,-2)], Color("a78b60"))
	for i in range(5): draw_line(port+Vector2(i*9, i*4.5-2),port+Vector2(i*9-5,i*4.5+4),Color("5c6350"),1)
	var boat = port + Vector2(35,39)
	polygon([boat+Vector2(-15,-4),boat+Vector2(17,-1),boat+Vector2(6,7),boat+Vector2(-8,5)],Color("674d36"))
	draw_line(boat+Vector2(0,3),boat+Vector2(0,-29),Color("d0b685"),2)
	polygon([boat+Vector2(1,-28),boat+Vector2(1,-7),boat+Vector2(19,-10)],Color("e0dbbb"))
	# Labels after props, with direct indicators from the current save.
	for id in IDS: region_label(id)
	draw_set_transform(Vector2.ZERO)
	text_at(Vector2(16,size.y-34), "Clique em uma região para governar • Setas: trocar seleção", 13, Color("bacac2"))
	text_at(Vector2(16,size.y-14), "Borda dourada: seleção   •   !: pedido aberto   •   Estoques em alerta: escassez", 12, Color("91a69e"))

func panel_style() -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color("152b32")
	style.border_color = Color("475b55")
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	return style

func on_road(cell: Vector2) -> bool:
	return (cell.y == 6 and cell.x >= 4 and cell.x <= 12) or (cell.x == 12 and cell.y >= 3 and cell.y <= 6) or (cell.x == 8 and cell.y >= 6 and cell.y <= 10) or (cell.y == 10 and cell.x >= 8 and cell.x <= 11)

func near_castle(cell: Vector2) -> bool:
	for center in CENTERS.values():
		if cell.distance_to(center) < 1.8: return true
	return false

func field(p: Vector2, scarce: bool, frost: bool) -> void:
	var soil = Color("af9653")
	if scarce: soil = Color("846f4e")
	if frost: soil = Color("bbc3a6")
	draw_colored_polygon(diamond(p,23,11),soil)
	for i in range(-3,4):
		draw_line(p+Vector2(i*4-9,-i*2-4),p+Vector2(i*4+9,-i*2+5), Color("ddd294") if not scarce else Color("605743"), 1.5, true)

func tree(p: Vector2, alpine: bool) -> void:
	draw_ellipse_shadow(p, Vector2(12,5))
	draw_line(p,p+Vector2(0,-18),Color("725c3d"),3)
	var color = Color("325d48") if not alpine else Color("415d50")
	for i in range(3):
		var height = 12.0 + i*8
		polygon([p+Vector2(-11+i*2,-height+4),p+Vector2(10-i*2,-height+4),p+Vector2(0,-height-16)],color.lightened(i*0.045))

func draw_ellipse_shadow(p: Vector2, radius: Vector2) -> void:
	var points = []
	for i in range(16):
		var angle = float(i) / 16.0 * TAU
		points.append(p+Vector2(cos(angle)*radius.x, sin(angle)*radius.y))
	polygon(points,Color(0.03,0.08,0.06,0.24))

func house(p: Vector2, unrest: bool) -> void:
	draw_ellipse_shadow(p+Vector2(0,3),Vector2(16,6))
	polygon([p+Vector2(-10,-4),p+Vector2(0,1),p+Vector2(0,-14),p+Vector2(-10,-19)],Color("b3ac83"))
	polygon([p+Vector2(0,1),p+Vector2(13,-5),p+Vector2(13,-20),p+Vector2(0,-14)],Color("d8cba0"))
	polygon([p+Vector2(-13,-20),p+Vector2(0,-28),p+Vector2(16,-21),p+Vector2(2,-13)],Color("994f3d"))
	draw_line(p+Vector2(6,-4),p+Vector2(6,-13),Color("544536"),4)
	if unrest:
		draw_line(p+Vector2(17,-7),p+Vector2(17,-24),Color("c78654"),2)
		text_at(p+Vector2(17,-26),"!",17,Color("f2a562"),true)

func mountain(p: Vector2) -> void:
	draw_ellipse_shadow(p+Vector2(0,4),Vector2(24,8))
	polygon([p+Vector2(-25,0),p+Vector2(0,-43),p+Vector2(6,11)],Color("65736c"))
	polygon([p+Vector2(0,-43),p+Vector2(29,-1),p+Vector2(6,11)],Color("a4ada0"))
	polygon([p+Vector2(-8,-29),p+Vector2(0,-43),p+Vector2(11,-27),p+Vector2(3,-31),p+Vector2(-1,-25)],Color("d5d9c6"))

func castle(p: Vector2, id: String) -> void:
	draw_ellipse_shadow(p+Vector2(0,8),Vector2(38,13))
	polygon([p+Vector2(-30,-8),p+Vector2(0,7),p+Vector2(32,-9),p+Vector2(0,-25)],Color("626f63"))
	for shift in [Vector2(-22,-4),Vector2(0,-16),Vector2(23,-4)]:
		var q = p+shift
		polygon([q+Vector2(-8,0),q+Vector2(0,4),q+Vector2(0,-31),q+Vector2(-8,-35)],Color("899383"))
		polygon([q+Vector2(0,4),q+Vector2(10,-1),q+Vector2(10,-36),q+Vector2(0,-31)],Color("c0c4a6"))
		polygon([q+Vector2(-10,-35),q+Vector2(0,-48),q+Vector2(12,-36),q+Vector2(0,-30)],Color("74564b"))
		draw_line(q+Vector2(5,-15),q+Vector2(5,-22),Color("394a42"),3)
	polygon([p+Vector2(-17,-5),p+Vector2(0,3),p+Vector2(21,-6),p+Vector2(21,-24),p+Vector2(0,-13),p+Vector2(-17,-22)],Color("b2b89b"))
	draw_line(p+Vector2(4,-1),p+Vector2(4,-14),Color("46574b"),7)
	var flag = p+Vector2(0,-65)
	draw_line(flag+Vector2(0,25),flag,Color("ddcf9b"),2)
	polygon([flag,flag+Vector2(23,3),flag+Vector2(18,15),flag+Vector2(0,12)],FLAGS[id])
	draw_line(flag+Vector2(7,3),flag+Vector2(7,11),Color("efe4c2"),2)

func camp(p: Vector2) -> void:
	polygon([p+Vector2(-13,1),p+Vector2(0,-20),p+Vector2(12,1)],Color("d6c5a0"))
	polygon([p+Vector2(0,-20),p+Vector2(18,-12),p+Vector2(25,5),p+Vector2(12,1)],Color("978365"))
	text_at(p+Vector2(0,22),"Mobilização",15,Color("f1deac"),true)

func region_label(id: String) -> void:
	var r = snapshot.regions[id]
	var p = project(CENTERS[id]) + Vector2(0,34)
	var width = 193.0
	draw_style_box(label_style(id == selected_id),Rect2(p+Vector2(-width/2,-3),Vector2(width,57)))
	text_at(p+Vector2(0,16),r.name,18,Color("f2e4bb"),true)
	var scarce = r.food < r.consumption
	text_at(p+Vector2(0,38),"Alimentos %d  •  Lealdade %d" % [r.food,r.loyalty],14,Color("edab77") if scarce else Color("c0d1bf"),true)
	if r.petition:
		draw_circle(p+Vector2(99,7),10,Color("d4af60"))
		text_at(p+Vector2(99,13),"!",17,Color("28382f"),true)

func label_style(selected: bool) -> StyleBoxFlat:
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.065,0.12,0.12,0.94)
	style.border_color = Color("dfc07c") if selected else Color("516d5d")
	style.set_border_width_all(2 if selected else 1)
	style.set_corner_radius_all(4)
	return style
