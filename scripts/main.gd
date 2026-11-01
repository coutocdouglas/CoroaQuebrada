extends Control

const Kingdom = preload("res://scripts/kingdom.gd")
const ACTION_LABELS = ["Enviar auxílio alimentar", "Comprar alimentos", "Exigir tributo extraordinário", "Negociar autonomia", "Recrutar soldados"]
var game = Kingdom.new()
var region_picker: OptionButton
var action_picker: OptionButton
var summary: Label
var news: Label
var region_details: RichTextLabel
var chronicle: RichTextLabel
var preview: Label
var feedback: Label
var confirm_button: Button
var next_button: Button
var reset_dialog: ConfirmationDialog

func _ready() -> void:
	var theme_data = Theme.new()
	theme_data.default_font_size = 16
	for type in ["Button", "OptionButton"]:
		var box = StyleBoxFlat.new()
		box.bg_color = Color("263441")
		box.border_color = Color("8f784e")
		box.set_border_width_all(1)
		box.set_content_margin_all(10)
		theme_data.set_stylebox("normal", type, box)
	theme = theme_data
	var margin = MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 20)
	add_child(margin)
	var column = VBoxContainer.new()
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)
	var heading = Label.new()
	heading.text = "COROA QUEBRADA  /  Conselho Real"
	heading.add_theme_font_size_override("font_size", 24)
	heading.add_theme_color_override("font_color", Color("d9bb79"))
	column.add_child(heading)
	var subtitle = Label.new()
	subtitle.text = "Protótipo 0.1 • Primeiro ano do reinado • Simulação local, sem IA conectada"
	subtitle.modulate = Color("a9b7c3")
	column.add_child(subtitle)
	summary = Label.new()
	column.add_child(summary)
	news = Label.new()
	news.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	news.custom_minimum_size.y = 44
	news.add_theme_color_override("font_color", Color("e2cc9f"))
	column.add_child(news)
	var body = HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 24)
	column.add_child(body)
	var left = VBoxContainer.new()
	left.custom_minimum_size.x = 455
	left.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left.add_theme_constant_override("separation", 8)
	body.add_child(left)
	region_picker = OptionButton.new()
	for id in Kingdom.REGION_IDS:
		region_picker.add_item(game.state.regions[id].name)
	region_picker.item_selected.connect(func(_index): refresh())
	left.add_child(region_picker)
	region_details = RichTextLabel.new()
	region_details.bbcode_enabled = true
	region_details.custom_minimum_size.y = 100
	region_details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left.add_child(region_details)
	action_picker = OptionButton.new()
	for title in ACTION_LABELS:
		action_picker.add_item(title)
	action_picker.item_selected.connect(func(_index): refresh_preview())
	left.add_child(action_picker)
	preview = Label.new()
	preview.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview.custom_minimum_size.y = 72
	left.add_child(preview)
	confirm_button = make_button("Confirmar ordem", issue_order)
	left.add_child(confirm_button)
	var right = VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(right)
	var history_title = Label.new()
	history_title.text = "CRÔNICA DO REINADO"
	history_title.add_theme_color_override("font_color", Color("d9bb79"))
	right.add_child(history_title)
	chronicle = RichTextLabel.new()
	chronicle.bbcode_enabled = true
	chronicle.scroll_following = true
	chronicle.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_child(chronicle)
	feedback = Label.new()
	feedback.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	feedback.custom_minimum_size.y = 32
	column.add_child(feedback)
	var toolbar = HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 12)
	column.add_child(toolbar)
	next_button = make_button("Encerrar mês →", advance)
	toolbar.add_child(next_button)
	toolbar.add_child(make_button("Salvar reinado", save))
	toolbar.add_child(make_button("Carregar reinado", load_saved))
	toolbar.add_child(make_button("Novo reinado", func(): reset_dialog.popup_centered()))
	reset_dialog = ConfirmationDialog.new()
	reset_dialog.title = "Novo reinado"
	reset_dialog.dialog_text = "Descartar a partida atual e começar de novo? O arquivo salvo será preservado até você salvar novamente."
	reset_dialog.confirmed.connect(func(): game.new_game(); feedback.text = "Um novo reinado começou."; refresh())
	add_child(reset_dialog)
	refresh()

func make_button(title: String, callback: Callable) -> Button:
	var button = Button.new()
	button.text = title
	button.pressed.connect(callback)
	return button

func selected_region() -> String:
	return Kingdom.REGION_IDS[region_picker.selected]

func selected_action() -> String:
	return Kingdom.ACTIONS[action_picker.selected]

func refresh() -> void:
	var s = game.state
	var c = s.crown
	summary.text = "Mês %d / 12   •   Ordens %d/2   •   Legitimidade %d   •   Soldados %d\nCoroa: %d alimentos  |  %d madeira  |  %d ferro  |  %d ouro" % [mini(int(s.month), 12), s.orders_left, s.legitimacy, s.troops, c.food, c.wood, c.iron, c.gold]
	news.text = s.ending if s.ended else s.news
	var r = s.regions[selected_region()]
	var food_output = int(r.production.food)
	if s.month <= 2 and selected_region() == "vale":
		food_output = 12
	if r.get("recruitment_month", 0) == s.month:
		food_output = maxi(0, food_output - 6)
	region_details.text = "[b]%s[/b]\nSenhor: %s\nVassalo: %s\n\nLealdade: %d/100    Agitação: %d/100\n\n[b]Estoques do senhor[/b]\nAlimentos %d  •  Madeira %d  •  Ferro %d  •  Ouro %d\n\nProdução neste mês: %d alimentos, %d madeira, %d ferro\nConsumo mensal: %d alimentos\nRenda local: 8 ouro; tributo normal: 4 se lealdade ≥35.\nEstoques regionais não pertencem à Coroa." % [r.name, r.lord, r.vassal, r.loyalty, r.unrest, r.stock.food, r.stock.wood, r.stock.iron, r.stock.gold, food_output, r.production.wood, r.production.iron, r.consumption]
	chronicle.clear()
	for event in s.history:
		var source = " · consequência da ordem #%d" % event.origin if event.origin > 0 else ""
		chronicle.append_text("[color=#d9bb79]Mês %d · #%d%s[/color]\n%s\n\n" % [event.month, event.id, source, event.text])
	next_button.disabled = s.ended
	refresh_preview()

func refresh_preview() -> void:
	var proposal = game.preview_order(selected_action(), selected_region())
	preview.text = proposal.text
	confirm_button.disabled = not proposal.ok

func issue_order() -> void:
	feedback.text = game.execute_order(selected_action(), selected_region()).text
	refresh()

func advance() -> void:
	game.advance_month()
	feedback.text = "O mês foi resolvido. Confira as notícias e a crônica."
	refresh()

func save() -> void:
	var error = game.save_game()
	feedback.text = "Reinado salvo neste computador." if error == OK else "Não foi possível salvar: " + error_string(error)

func load_saved() -> void:
	var error = game.load_game()
	feedback.text = "Reinado carregado com histórico e consequências pendentes." if error == OK else "Não foi possível carregar. A partida atual foi preservada. " + error_string(error)
	refresh()
