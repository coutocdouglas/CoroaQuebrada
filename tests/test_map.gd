extends SceneTree

const Map = preload("res://scripts/kingdom_map.gd")
const Kingdom = preload("res://scripts/kingdom.gd")
var checks = 0
var failures = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var game = Kingdom.new()
	var map = Map.new()
	root.add_child(map)
	map.size = Vector2(820,460)
	map.set_kingdom(game.state,"vale")
	await process_frame
	var before = game.state.duplicate(true)
	for dimensions in [Vector2(580,340),Vector2(820,460),Vector2(1250,700)]:
		map.size = dimensions
		for id in Kingdom.REGION_IDS:
			check(map.region_at(map.cell_to_screen(Map.CENTERS[id])) == id, "Castelo %s é selecionável em %s" % [id, dimensions])
			check(map.select_at(map.cell_to_screen(Map.CENTERS[id])) and map.selected_id == id, "Seleção é estável após redimensionamento")
			var label = map.cell_to_screen(Map.CENTERS[id]) + Vector2(0,50)*map.map_scale
			check(map.region_at(label) == id, "Cartão do território também é clicável")
	check(not map.select_at(Vector2(-1000,-1000)), "Clique fora do mapa não seleciona território")
	check(map.region_at(map.cell_to_screen(Vector2(17,12))).is_empty(), "Mar não é tratado como região")
	check(game.state == before, "Explorar o mapa não altera economia, ordens ou histórico")
	game.state.regions.vale.stock.food = 0
	game.state.regions.vale.unrest = 50
	map.set_kingdom(game.state,"vale")
	check(map.snapshot.regions.vale.food == 0 and map.snapshot.regions.vale.unrest == 50, "Mapa reflete escassez e agitação reais")
	check(map.snapshot.regions.vale.petition, "Pedidos abertos aparecem no mapa")
	game.execute_order("recruit","marca")
	map.set_kingdom(game.state,"marca")
	check(map.snapshot.regions.marca.recruited, "Recrutamento marca a mobilização na região certa")
	game.advance_month()
	map.set_kingdom(game.state,"marca")
	check(not map.snapshot.regions.marca.recruited and map.snapshot.month == 2, "Atualização do mês remove mobilização temporária")
	game.new_game()
	map.set_kingdom(game.state,"vale")
	check(map.snapshot.regions.vale.food == 85, "Novo reinado substitui os dados antigos do mapa")
	map.snapshot.regions.vale.food = 999
	check(game.state.regions.vale.stock.food == 85, "View não compartilha estoque mutável com a simulação")
	map.queue_free()
	var ui = load("res://scenes/main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	check(ui.view_tabs.current_tab == 0 and ui.realm_map.is_visible_in_tree(), "Mapa é a primeira tela da partida")
	before = ui.game.state.duplicate(true)
	var click = InputEventMouseButton.new()
	click.button_index = MOUSE_BUTTON_LEFT
	click.pressed = true
	click.position = ui.realm_map.cell_to_screen(Map.CENTERS.marca)
	ui.realm_map._gui_input(click)
	check(ui.selected_region() == "marca" and "Artur" in ui.region_details.text, "Clique real atualiza seleção e painel de ordens")
	check(ui.game.state == before, "Seleção por clique não consome ordem")
	ui.confirm_button.pressed.emit()
	check(ui.game.state.pending.back().region == "marca", "Ordem após clique é enviada à região selecionada no mapa")
	ui.region_picker.select(2)
	ui.region_picker.item_selected.emit(2)
	check(ui.realm_map.selected_id == "costa", "Seleção tradicional também atualiza borda do mapa")
	ui.view_tabs.current_tab = 1
	await process_frame
	check(ui.chronicle.is_visible_in_tree() and not ui.realm_map.is_visible_in_tree(), "Crônica continua disponível na segunda aba")
	ui.next_button.pressed.emit()
	check(ui.realm_map.snapshot.month == 2, "Mapa escondido recebe os dados novos do mês")
	ui.view_tabs.current_tab = 0
	await process_frame
	var key = InputEventKey.new()
	key.keycode = KEY_RIGHT
	key.pressed = true
	ui.realm_map._gui_input(key)
	check(ui.selected_region() == "vale", "Teclado percorre regiões com a mesma integração")
	check(ui.next_button.get_global_rect().end.y <= ui.size.y, "Mapa não esconde controles de avanço")
	ui.queue_free()
	await process_frame
	print("MAPA: %d verificações, %d falhas" % [checks, failures])
	quit(1 if failures else 0)
