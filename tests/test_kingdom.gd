extends SceneTree

const Kingdom = preload("res://scripts/kingdom.gd")
var failures = 0
var checks = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var game = Kingdom.new()
	check(game.state.regions.vale.production.iron == 0 and game.state.regions.vale.stock.iron > 0, "Uma região pode acumular recurso que não produz")
	var before = game.state.duplicate(true)
	check(not game.execute_order("inventar_ouro", "vale").ok, "Ordens desconhecidas são recusadas")
	check(game.state == before, "Ordem inválida não altera estado")
	game.state.crown.food = 0
	before = game.state.duplicate(true)
	check(not game.execute_order("aid", "marca").ok and game.state == before, "Custos insuficientes não geram efeitos parciais")
	game.new_game()
	game.execute_order("aid", "marca")
	var origin = game.state.history.back().id
	check(game.state.crown.food == 95 and game.state.regions.marca.stock.food == 35, "Auxílio sai da Coroa antes de chegar à região")
	game.advance_month()
	check(game.state.regions.marca.stock.food == 52, "Auxílio chega uma única vez no mês seguinte, após consumo")
	for i in range(8):
		game.advance_month()
	var remembered = false
	for event in game.state.history:
		if event.kind == "memory" and event.origin == origin and event.month == 10:
			remembered = true
	check(remembered, "Ajuda do mês 1 é lembrada no mês 10 com vínculo à ordem original")
	game.new_game()
	var price = game.food_price("vale")
	game.execute_order("buy_food", "vale")
	check(game.state.crown.gold == 160 - price and game.state.regions.vale.stock.gold == 80 + price, "Compra transfere ouro sem criar moeda")
	check(game.state.regions.vale.stock.food == 55 and game.state.crown.food == 120, "Compra retira alimentos e mantém carga em trânsito")
	game.advance_month()
	check(game.state.crown.food == 140, "Compra chega descontando manutenção mensal")
	game.new_game()
	game.execute_order("tribute", "marca")
	game.execute_order("pact", "marca")
	before = game.state.duplicate(true)
	check(not game.execute_order("aid", "marca").ok and game.state == before, "Duas ordens por mês são um limite real")
	game.advance_month()
	game.advance_month()
	check(game.state.legitimacy == 60, "Reconciliação evita punição de resistência ao tributo")
	var reconciled = false
	for event in game.state.history:
		if "desmobilizada" in event.text:
			reconciled = true
	check(reconciled, "Histórico registra resistência desmobilizada")
	game.new_game()
	game.execute_order("tribute", "marca")
	game.advance_month()
	game.advance_month()
	check(game.state.legitimacy == 56, "Baixa lealdade mantém consequência adiada do tributo")
	game.new_game()
	game.execute_order("aid", "marca")
	var path = "user://test_reinado.json"
	check(game.save_game(path) == OK, "Salvamento funciona")
	check(game.save_game(path) == OK, "Novo salvamento substitui arquivo anterior")
	var loaded = Kingdom.new()
	check(loaded.load_game(path) == OK, "Carregamento funciona")
	game.advance_month()
	loaded.advance_month()
	check(game.state == loaded.state, "Carregamento preserva consequência pendente e evolução")
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string('{"schema":1,"month":2}')
	file.close()
	before = loaded.state.duplicate(true)
	check(loaded.load_game(path) == ERR_INVALID_DATA and loaded.state == before, "Save inválido é recusado sem destruir partida atual")
	DirAccess.remove_absolute(path)
	game.new_game()
	for month in range(12):
		game.advance_month()
		check(game.valid_state(game.state), "Estado válido após mês %d" % (month + 1))
	check(game.state.ended and game.state.resolved_months == 12, "Partida conclui exatamente doze meses")
	before = game.state.duplicate(true)
	game.advance_month()
	check(game.state == before and not game.execute_order("pact", "vale").ok, "Reinado concluído não recebe novas ações")
	# Exercise every action through full campaigns and check bounds after each turn.
	for action in Kingdom.ACTIONS:
		game.new_game()
		for month in range(12):
			for id in Kingdom.REGION_IDS:
				game.execute_order(action, id)
			game.advance_month()
			check(game.valid_state(game.state), "Invariantes preservados na campanha de %s, mês %d" % [action, month + 1])
	print("TESTES: %d verificações, %d falhas" % [checks, failures])
	quit(1 if failures > 0 else 0)
