extends SceneTree

const Kingdom = preload("res://scripts/kingdom.gd")
const Politics = preload("res://scripts/politics.gd")
var checks = 0
var failures = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var game = Kingdom.new()
	check(game.state.politics.petitions.size() == 3, "Três interesses geram pedidos próprios")
	var before = game.state.duplicate(true)
	Politics.proposal(game, "marca", true)
	check(game.state == before, "Consultar um acordo não altera a partida")
	check(Politics.respond(game, "marca", true).ok, "Troca de ferro aceita")
	check(game.state.crown.food == 100 and game.state.regions.marca.stock.iron == 68, "Cargas saem de ambos os estoques ao firmar troca")
	check(game.state.crown.iron == 40 and game.state.regions.marca.stock.food == 35, "Nenhuma carga é recebida antes da viagem")
	before = game.state.duplicate(true)
	check(not Politics.respond(game, "marca", true).ok and game.state == before, "Acordo não pode ser cobrado duas vezes")
	game.advance_month()
	check(game.state.crown.iron == 52 and game.state.regions.marca.stock.food == 47, "Ambas as cargas chegam no mês seguinte, com consumo contabilizado")
	check(game.state.regions.marca.loyalty == 55, "Lealdade muda somente ao cumprir acordo")
	game.new_game()
	game.state.crown.food = 0
	before = game.state.duplicate(true)
	check(not Politics.respond(game, "marca", true).ok and game.state == before, "Sem recursos, acordo não consome ordem nem estoque regional")
	check(Politics.respond(game, "marca", false).ok and game.state.regions.marca.loyalty == 43, "Recusar é decisão válida mesmo sem alimentos")
	game.new_game()
	game.state.regions.marca.stock.iron = 0
	before = game.state.duplicate(true)
	check(not Politics.respond(game, "marca", true).ok and game.state == before, "Contrapartida regional também é validada")
	game.new_game()
	game.advance_month()
	check(not Politics.petition_for(game, "vale").is_empty(), "Pedido segue aberto no segundo mês")
	game.advance_month()
	check(Politics.petition_for(game, "vale").is_empty() and game.state.regions.vale.loyalty == 52, "Pedido ignorado expira na abertura do terceiro mês")
	game.advance_month()
	check(game.state.regions.vale.loyalty == 52, "Expiração não cobra lealdade repetidamente")
	game.advance_month()
	check(not Politics.petition_for(game, "vale").is_empty(), "Novo pedido respeita intervalo de quatro meses")
	game.new_game()
	Politics.respond(game, "costa", true)
	check(game.state.crown.gold == 145 and game.state.regions.costa.stock.gold == 135 and game.state.regions.costa.stock.wood == 50, "Carta comercial transfere ouro e reserva madeira")
	game.advance_month()
	check(game.state.crown.wood == 70 and game.state.regions.vale.loyalty == 53, "Carta entrega madeira e cria precedente político")
	game.new_game()
	game.execute_order("audience", "marca")
	check(game.state.politics.regions.marca.support == 55 and game.state.regions.marca.loyalty == 45, "Vassalo e senhor têm relações independentes com a Coroa")
	game.state.regions.marca.unrest = 30
	var gold_before = game.state.regions.marca.stock.gold
	game.advance_month()
	check(game.state.regions.marca.unrest == 23 and game.state.regions.marca.stock.gold == gold_before - 4, "Vassalo usa fundos regionais para conter crise, além da renda e tributo")
	var relief_events = game.state.history.filter(func(e): return e.kind == "vassal_action").size()
	Politics.advance(game)
	check(game.state.history.filter(func(e): return e.kind == "vassal_action").size() == relief_events, "Socorro autônomo respeita intervalo")
	# Isolate a trade route and account for all physical stocks before delivery.
	game.new_game()
	game.state.month = 3
	game.state.resolved_months = 2
	game.state.regions.marca.stock.food = 0
	game.state.regions.vale.stock.food = 100
	game.state.regions.costa.stock.food = 0
	game.state.regions.costa.stock.gold = 0
	var total_gold = 0
	for id in Kingdom.REGION_IDS: total_gold += game.state.regions[id].stock.gold
	Politics.advance(game)
	check(game.state.regions.vale.stock.food == 85 and game.state.regions.marca.stock.food == 0, "Senhor reserva excedente e envia carga em trânsito")
	var after_gold = 0
	for id in Kingdom.REGION_IDS: after_gold += game.state.regions[id].stock.gold
	check(total_gold == after_gold, "Comércio entre senhores conserva moeda")
	game.state.month = 4
	game.resolve_pending()
	check(game.state.regions.marca.stock.food == 15, "Entrega regional credita o comprador certo")
	game.new_game()
	Politics.respond(game, "marca", true)
	var path = "user://test_politics.json"
	check(game.save_game(path) == OK, "Salva acordo em trânsito")
	var restored = Kingdom.new()
	check(restored.load_game(path) == OK, "Recupera relações, pedidos e cargas")
	game.advance_month()
	restored.advance_month()
	check(game.state == restored.state, "Partida retomada cumpre o acordo uma única vez")
	DirAccess.remove_absolute(path)
	var old_path = "res://tests/fixtures/reinado_v1.json"
	var original = FileAccess.get_file_as_string(old_path)
	check(restored.load_game(old_path) == OK, "Save real da versão 0.1 é migrado")
	check(restored.state.schema == 2 and restored.state.month == 1 and restored.state.crown.food == 95, "Migração preserva mês, recursos e ordens antigas")
	restored.advance_month()
	check(restored.state.regions.marca.stock.food == 52, "Migração mantém entrega antiga pendente")
	check(FileAccess.get_file_as_string(old_path) == original, "Carregar não sobrescreve save antigo")
	var invalid = game.state.duplicate(true)
	invalid.politics.regions.vale.support = 101
	check(not game.valid_state(invalid), "Save com apoio fora dos limites é recusado")
	invalid = game.state.duplicate(true)
	invalid.pending.append({"kind": "negotiation_delivery", "deal": "free_gold", "region": "vale", "due": 2, "origin": 1})
	check(not game.valid_state(invalid), "Save não pode inventar tipo de acordo")
	for response in [true, false]:
		game.new_game()
		for month in range(12):
			for id in Kingdom.REGION_IDS: Politics.respond(game, id, response)
			game.advance_month()
			check(game.valid_state(game.state), "Campanha diplomática mantém estado válido")
	print("POLÍTICA: %d verificações, %d falhas" % [checks, failures])
	quit(1 if failures else 0)
