extends PanelContainer
signal govern_region(id: String)
const Canvas = preload("res://scripts/atlas_canvas.gd")
var canvas
var details: RichTextLabel
var regions_list: ItemList
var govern_button: Button
var snapshot: Dictionary = {}
var mode_picker: OptionButton

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var background = StyleBoxFlat.new()
	background.bg_color = Color("111d25")
	background.set_content_margin_all(18)
	add_theme_stylebox_override("panel",background)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation",12)
	add_child(column)
	var header = HBoxContainer.new()
	column.add_child(header)
	var title = Label.new()
	title.text = "COROA QUEBRADA  /  Atlas do reino"
	title.add_theme_font_size_override("font_size",24)
	title.add_theme_color_override("font_color",Color("ddc38b"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	header.add_child(button("Voltar ao conselho",func(): hide()))
	var subtitle = Label.new()
	subtitle.text = "12 regiões · Geografia do Azgaar · Explore os territórios e os caminhos do reino"
	subtitle.add_theme_color_override("font_color",Color("a0b1b8"))
	column.add_child(subtitle)
	var toolbar = HBoxContainer.new()
	column.add_child(toolbar)
	mode_picker = OptionButton.new()
	for title_text in ["Territórios","Caminhos terrestres e marítimos","Reservas conhecidas · alimentos"]: mode_picker.add_item(title_text)
	mode_picker.item_selected.connect(func(index):
		canvas.mode = ["political","routes","reserves"][index]
		canvas.queue_redraw()
		update_details())
	toolbar.add_child(mode_picker)
	toolbar.add_child(button("−",func(): canvas.zoom_at(1.0/1.2,canvas.size*0.5)))
	toolbar.add_child(button("+",func(): canvas.zoom_at(1.2,canvas.size*0.5)))
	toolbar.add_child(button("Reenquadrar",func(): canvas.reset_view()))
	var body = HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",16)
	column.add_child(body)
	canvas = Canvas.new()
	canvas.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	canvas.size_flags_vertical = Control.SIZE_EXPAND_FILL
	canvas.custom_minimum_size = Vector2(600,420)
	body.add_child(canvas)
	canvas.region_selected.connect(func(_id): update_details())
	var side = VBoxContainer.new()
	side.custom_minimum_size.x = 295
	body.add_child(side)
	regions_list = ItemList.new()
	regions_list.custom_minimum_size.y = 328
	regions_list.add_theme_font_size_override("font_size",15)
	for r in canvas.data.regions:
		regions_list.add_item("%02d  %s" % [r.number,r.name])
		regions_list.set_item_custom_fg_color(regions_list.item_count-1,Color(r.color).lightened(0.3))
	regions_list.item_selected.connect(func(index): canvas.select_region(canvas.data.regions[index].id))
	side.add_child(regions_list)
	details = RichTextLabel.new()
	details.bbcode_enabled = true
	details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	details.custom_minimum_size.y = 110
	details.add_theme_font_size_override("normal_font_size",15)
	side.add_child(details)
	govern_button = button("Governar esta região",func(): govern_region.emit(canvas.selected_id))
	side.add_child(govern_button)
	var note = Label.new()
	note.text = "Atlas em expansão: as decisões e os estoques da partida ainda abrangem Vale, Marca e Costa."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size",13)
	note.add_theme_color_override("font_color",Color("afbab9"))
	column.add_child(note)
	update_details()

func button(text: String, action: Callable) -> Button:
	var b = Button.new()
	b.text = text
	b.pressed.connect(action)
	return b

func set_kingdom(state: Dictionary) -> void:
	snapshot = state.regions.duplicate(true)
	canvas.set_kingdom(state)
	update_details()

func update_details() -> void:
	if not is_instance_valid(details): return
	var r = canvas.region_lookup[canvas.selected_id]
	regions_list.select(int(r.number)-1)
	var names = []
	for id in r.neighbors: names.append(canvas.region_lookup[id].name)
	var content = "[b]%s[/b]\nSede: %s\n%d povoações registradas\n\n" % [r.name,r.seat_name,r.settlements]
	if canvas.mode == "routes":
		var count = 0
		for route in canvas.data.routes:
			if r.id in route.regions: count += 1
		content += "%d caminhos tocam este território.\nDourado: terra · Azul: mar.\nCaminhos representam infraestrutura; ainda não são remessas comerciais.\n\n" % count
	elif canvas.mode == "reserves":
		content += "Verde: mais meses de alimento. Vermelho: menor cobertura. Cinza: sem simulação nesta versão.\n\n"
	if snapshot.has(r.id):
		var state = snapshot[r.id]
		content += "[b]Reservas do senhor[/b]\n%d alimentos · %d madeira\n%d ferro · %d ouro\nConsumo: %d alimentos/mês\nCobertura atual: %.1f meses\n\n" % [state.stock.food,state.stock.wood,state.stock.iron,state.stock.gold,state.consumption,float(state.stock.food)/maxf(1.0,state.consumption)]
	else:
		content += "Esta região já possui geografia. Seus governantes e sua economia serão integrados na próxima expansão.\n\n"
	content += "[b]Fronteiras terrestres[/b]\n" + ", ".join(names)
	details.text = content
	govern_button.disabled = not snapshot.has(r.id)

