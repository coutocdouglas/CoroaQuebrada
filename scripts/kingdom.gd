extends RefCounted
## Simulation owns all facts. A future AI adapter may only propose orders.

const RESOURCES = ["food", "wood", "iron", "gold"]
const Politics = preload("res://scripts/politics.gd")
const REGION_IDS = ["vale", "marca", "costa"]
const ACTIONS = ["aid", "buy_food", "tribute", "pact", "recruit", "audience"]
const SCHEMA_VERSION = 2
var state: Dictionary

func _init() -> void:
	new_game()

func region(id: String, title: String, lord: String, vassal: String, stock: Array, production: Array, consumption: int, loyalty: int) -> Dictionary:
	var inventory = {}
	var output = {}
	for i in RESOURCES.size():
		inventory[RESOURCES[i]] = stock[i]
		output[RESOURCES[i]] = production[i]
	return {"id": id, "name": title, "lord": lord, "vassal": vassal, "stock": inventory, "production": output, "consumption": consumption, "loyalty": loyalty, "unrest": 10}

func new_game() -> void:
	state = {
		"schema": SCHEMA_VERSION, "month": 1, "resolved_months": 0, "orders_left": 2,
		"legitimacy": 60, "troops": 20, "ended": false, "ending": "",
		"crown": {"food": 120, "wood": 60, "iron": 40, "gold": 160},
		"regions": {
			"vale": region("vale", "Vale do Trigo", "Lady Helena Verdan", "Sir Tomás do Moinho", [85, 35, 12, 80], [38, 9, 0, 0], 30, 55),
			"marca": region("marca", "Marca de Ferro", "Lorde Artur Ferren", "Lady Brina da Ponte", [35, 40, 80, 60], [16, 12, 18, 0], 24, 48),
			"costa": region("costa", "Costa das Marés", "Lady Maíra Salmar", "Sir Caio das Docas", [55, 60, 25, 120], [24, 16, 4, 0], 22, 62)
		},
		"history": [], "pending": [], "next_event_id": 1, "politics": Politics.initial_state(),
		"news": "Seu pai morreu deixando uma união frágil. A geada atingiu o Vale; a Marca pede auxílio. O conselho recomenda formar 30 soldados antes do sexto mês."
	}
	log_event("accession", "A Coroa muda de mãos. Três senhores renovam seus juramentos, mas exigem respeito às suas reservas e privilégios.")
	for id in REGION_IDS:
		Politics.open_petition(self, id)

func log_event(kind: String, message: String, origin: int = 0) -> int:
	var id = int(state.next_event_id)
	state.next_event_id = id + 1
	state.history.append({"id": id, "month": state.month, "kind": kind, "text": message, "origin": origin})
	return id

func schedule(kind: String, region_id: String, delay: int, origin: int) -> void:
	state.pending.append({"kind": kind, "region": region_id, "due": int(state.month) + delay, "origin": origin})

func preview_order(kind: String, region_id: String) -> Dictionary:
	if state.ended:
		return {"ok": false, "text": "A partida terminou. Comece um novo reinado."}
	if not ACTIONS.has(kind) or not REGION_IDS.has(region_id):
		return {"ok": false, "text": "Ordem ou região desconhecida."}
	if state.orders_left <= 0:
		return {"ok": false, "text": "As duas ordens deste mês já foram usadas. Avance o mês."}
	var r = state.regions[region_id]
	var cost = {"food": 0, "wood": 0, "iron": 0, "gold": 0}
	var detail = ""
	match kind:
		"audience":
			cost.gold = 10
			detail = "Ouvir %s e financiar sua administração local: 10 ouro transferidos à região, apoio do vassalo +10. O senhor perde 3 de lealdade por ser contornado." % r.vassal
		"aid":
			cost.food = 25
			detail = "Enviar 25 alimentos a %s. Entrega no próximo mês; lealdade +6 e agitação −5 na chegada. A população poderá lembrar da ajuda meses depois." % r.name
		"buy_food":
			var price = food_price(region_id)
			cost.gold = price
			if r.loyalty < 30 or r.stock.food < 30:
				return {"ok": false, "text": "O senhor recusa vender: lealdade abaixo de 30 ou menos de 30 alimentos em estoque."}
			detail = "Comprar 30 alimentos de %s por %d ouro. Pagamento imediato; entrega no próximo mês. O senhor aceita negociar nas condições atuais." % [r.name, price]
		"tribute":
			if r.stock.gold < 20:
				return {"ok": false, "text": "A região não possui os 20 de ouro exigidos."}
			detail = "Exigir tributo extraordinário de 20 ouro. Lealdade −10 agora; uma cobrança com baixa lealdade pode provocar resistência em dois meses."
		"pact":
			cost.gold = 20
			detail = "Investir 20 ouro em garantias de autonomia e negociação com %s. Ouro transferido ao senhor, lealdade +10; outros nobres podem exigir igualdade em dois meses." % r.lord
		"recruit":
			cost.gold = 15
			cost.iron = 10
			detail = "Recrutar 10 soldados de %s por 15 ouro e 10 ferro. Lealdade −4; a região perderá 6 alimentos de produção neste mês. Soldados consomem alimentos da Coroa." % r.name
	for resource in RESOURCES:
		if state.crown[resource] < cost[resource]:
			return {"ok": false, "text": "Reservas da Coroa insuficientes para esta ordem."}
	return {"ok": true, "text": detail, "cost": cost}

func food_price(region_id: String) -> int:
	var r = state.regions[region_id]
	return 24 + maxi(0, 60 - int(r.stock.food)) / 3 + maxi(0, 60 - int(r.loyalty)) / 5

func execute_order(kind: String, region_id: String) -> Dictionary:
	var proposal = preview_order(kind, region_id)
	if not proposal.ok:
		return proposal
	var r = state.regions[region_id]
	for resource in RESOURCES:
		state.crown[resource] -= proposal.cost[resource]
	state.orders_left -= 1
	var origin = log_event("order", proposal.text)
	match kind:
		"audience":
			r.stock.gold += 10
			var local = state.politics.regions[region_id]
			local.support = mini(100, int(local.support) + 10)
			r.loyalty = maxi(0, int(r.loyalty) - 3)
		"aid":
			schedule("aid_arrival", region_id, 1, origin)
		"buy_food":
			r.stock.food -= 30
			r.stock.gold += proposal.cost.gold
			schedule("purchase_arrival", region_id, 1, origin)
		"tribute":
			r.stock.gold -= 20
			state.crown.gold += 20
			r.loyalty = maxi(0, int(r.loyalty) - 10)
			if r.loyalty < 45:
				schedule("resistance", region_id, 2, origin)
		"pact":
			r.stock.gold += 20
			r.loyalty = mini(100, int(r.loyalty) + 10)
			schedule("noble_demands", region_id, 2, origin)
		"recruit":
			state.troops += 10
			r.loyalty = maxi(0, int(r.loyalty) - 4)
			r["recruitment_month"] = state.month
	return {"ok": true, "text": "Ordem registrada na crônica. " + proposal.text}

func advance_month() -> void:
	if state.ended:
		return
	for id in REGION_IDS:
		var r = state.regions[id]
		for resource in RESOURCES:
			var amount = int(r.production[resource])
			if resource == "food":
				if state.month <= 2 and id == "vale":
					amount = 12
				if r.get("recruitment_month", 0) == state.month:
					amount = maxi(0, amount - 6)
			r.stock[resource] += amount
		var shortage = maxi(0, int(r.consumption) - int(r.stock.food))
		r.stock.food = maxi(0, int(r.stock.food) - int(r.consumption))
		if shortage > 0:
			r.unrest = mini(100, int(r.unrest) + 12)
			r.loyalty = maxi(0, int(r.loyalty) - 5)
			state.legitimacy = maxi(0, int(state.legitimacy) - 3)
			log_event("famine", "%s: faltaram %d alimentos. A fome eleva a agitação e abala a autoridade real." % [r.name, shortage])
		else:
			r.unrest = maxi(0, int(r.unrest) - 1)
		# Local tax income is an explicit abstract source, not a trade transfer.
		r.stock.gold += 8
		if r.loyalty >= 35:
			var tax = mini(4, int(r.stock.gold))
			r.stock.gold -= tax
			state.crown.gold += tax
	state.crown.gold += 6
	var upkeep = 8 + ceili(float(state.troops) / 10.0)
	if state.crown.food < upkeep:
		state.legitimacy = maxi(0, int(state.legitimacy) - 8)
		state.troops = maxi(0, int(state.troops) - 5)
		log_event("desertion", "Faltou alimento nas reservas reais. Cinco soldados desertam e a legitimidade cai.")
	state.crown.food = maxi(0, int(state.crown.food) - upkeep)
	log_event("economy", "Produção, consumo e tributos do mês resolvidos. A Coroa consumiu até %d alimentos e recebeu rendas e tributos conforme a lealdade regional." % upkeep)
	state.resolved_months += 1
	state.month += 1
	resolve_pending()
	Politics.advance(self)
	if state.month == 6:
		if state.troops >= 30:
			state.legitimacy = mini(100, int(state.legitimacy) + 5)
			log_event("frontier", "A guarnição reforçada conteve os saqueadores da fronteira. Legitimidade +5.")
		else:
			state.crown.gold = maxi(0, int(state.crown.gold) - 25)
			state.legitimacy = maxi(0, int(state.legitimacy) - 8)
			log_event("frontier", "Sem os 30 soldados recomendados pelo conselho, a fronteira foi saqueada. Até 25 ouro perdidos; legitimidade −8.")
	state.orders_left = 2
	state.news = monthly_news()
	if state.resolved_months >= 12 or state.legitimacy <= 0:
		state.ended = true
		state.ending = ending_text()
		log_event("ending", state.ending)

func resolve_pending() -> void:
	var due = []
	var remaining = []
	for event in state.pending:
		if event.due <= state.month:
			due.append(event)
		else:
			remaining.append(event)
	state.pending = remaining
	for event in due:
		var r = state.regions[event.region]
		match event.kind:
			"negotiation_delivery":
				Politics.deliver(self, event)
			"regional_delivery":
				r.stock.food += 15
				log_event("delivery", "Chegaram a %s os 15 alimentos comprados pelo senhor regional." % r.name, event.origin)
			"aid_arrival":
				r.stock.food += 25
				r.loyalty = mini(100, int(r.loyalty) + 6)
				r.unrest = maxi(0, int(r.unrest) - 5)
				log_event("delivery", "Chegaram 25 alimentos reais a %s. A população agradece; lealdade +6." % r.name, event.origin)
				schedule("popular_support", event.region, 8, event.origin)
			"purchase_arrival":
				state.crown.food += 30
				log_event("delivery", "Chegaram à Coroa 30 alimentos comprados em %s." % r.name, event.origin)
			"resistance":
				if r.loyalty < 45:
					r.unrest = mini(100, int(r.unrest) + 10)
					state.legitimacy = maxi(0, int(state.legitimacy) - 4)
					log_event("reaction", "%s protesta contra o tributo extraordinário. Agitação +10; legitimidade −4." % r.lord, event.origin)
				else:
					log_event("reaction", "A relação com %s melhorou; a resistência ao tributo foi desmobilizada." % r.name, event.origin)
			"noble_demands":
				for id in REGION_IDS:
					if id != event.region:
						state.regions[id].loyalty = maxi(0, int(state.regions[id].loyalty) - 3)
				log_event("reaction", "O acordo com %s criou precedente: os outros senhores exigem condições iguais. Lealdade deles −3." % r.lord, event.origin)
			"popular_support":
				if r.unrest < 60:
					state.legitimacy = mini(100, int(state.legitimacy) + 4)
					log_event("memory", "Moradores de %s recordam a ajuda real de meses atrás e defendem a Coroa. Legitimidade +4." % r.name, event.origin)
				else:
					log_event("memory", "Em %s, a crise atual sufocou a gratidão pela antiga ajuda real." % r.name, event.origin)

func monthly_news() -> String:
	var weakest = "vale"
	for id in REGION_IDS:
		if state.regions[id].stock.food < state.regions[weakest].stock.food:
			weakest = id
	var r = state.regions[weakest]
	if r.stock.food < r.consumption:
		return "%s alerta: as reservas de alimentos estão abaixo do consumo mensal. Ajuda e comércio demoram um mês para chegar." % r.name
	if state.month < 6:
		return "A fronteira exige 30 soldados até o início do sexto mês. A geada reduz a colheita do Vale nos dois primeiros meses."
	return "O conselho avalia a paz: %s tem as menores reservas de alimentos. Revise as relações e os efeitos das suas antigas ordens." % r.name

func ending_text() -> String:
	if state.legitimacy <= 0:
		return "A autoridade real desmoronou. Seu reinado terminou antes do primeiro aniversário."
	var loyal = 0
	for id in REGION_IDS:
		if state.regions[id].loyalty >= 45:
			loyal += 1
	if loyal == 3 and state.legitimacy >= 50:
		return "Doze meses de Coroa: o reino permanece unido, e os três senhores reconhecem sua autoridade."
	return "Doze meses de Coroa: você preservou o trono, mas apenas %d dos três senhores sustentam sua autoridade. A união segue frágil." % loyal

func save_game(path: String = "user://reinado.json") -> Error:
	var file = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return FileAccess.get_open_error()
	file.store_string(JSON.stringify(state, "\t"))
	file.close()
	return DirAccess.rename_absolute(path + ".tmp", path)

func load_game(path: String = "user://reinado.json") -> Error:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	var parsed = JSON.parse_string(file.get_as_text())
	# Migrate on a temporary object. Never rewrite the player's file on load.
	if parsed is Dictionary and parsed.get("schema") == 1:
		parsed.schema = SCHEMA_VERSION
		parsed.politics = Politics.initial_state()
		for id in REGION_IDS:
			parsed.politics.regions[id].next_petition = parsed.get("month", 1)
	if not valid_state(parsed):
		return ERR_INVALID_DATA
	# JSON numbers are floats; restore integer quantities before simulation resumes.
	state = normalize_numbers(parsed)
	return OK

func normalize_numbers(value: Variant) -> Variant:
	if value is float:
		return int(value)
	if value is Dictionary:
		for key in value:
			value[key] = normalize_numbers(value[key])
	elif value is Array:
		for i in value.size():
			value[i] = normalize_numbers(value[i])
	return value

func valid_state(data: Variant) -> bool:
	if not data is Dictionary or data.get("schema") != SCHEMA_VERSION:
		return false
	if not Politics.valid(data.get("politics")):
		return false
	for key in ["month", "resolved_months", "orders_left", "legitimacy", "troops", "next_event_id"]:
		if not data.get(key) is float and not data.get(key) is int:
			return false
		if not is_finite(float(data[key])) or floor(data[key]) != data[key]:
			return false
	if data.month < 1 or data.month > 13 or data.orders_left < 0 or data.orders_left > 2:
		return false
	if data.resolved_months != data.month - 1 or data.legitimacy < 0 or data.legitimacy > 100 or data.troops < 0:
		return false
	if not data.get("ended") is bool or not data.get("ending") is String or not data.get("news") is String:
		return false
	if data.ended != (data.resolved_months >= 12 or data.legitimacy <= 0) or data.next_event_id < 1:
		return false
	if not valid_stock(data.get("crown")) or not data.get("regions") is Dictionary:
		return false
	for id in REGION_IDS:
		var r = data.regions.get(id)
		if not r is Dictionary or not valid_stock(r.get("stock")) or not valid_stock(r.get("production")):
			return false
		for key in ["name", "lord", "vassal"]:
			if not r.get(key) is String:
				return false
		for key in ["consumption", "loyalty", "unrest"]:
			if not (r.get(key) is float or r.get(key) is int) or r[key] < 0:
				return false
		if r.loyalty > 100 or r.unrest > 100:
			return false
	if not data.get("history") is Array or not data.get("pending") is Array:
		return false
	for event in data.history:
		if not event is Dictionary:
			return false
		for key in ["id", "month", "origin"]:
			if not (event.get(key) is float or event.get(key) is int):
				return false
		if not event.get("text") is String or not event.get("kind") is String:
			return false
	for event in data.pending:
		if not event is Dictionary or not REGION_IDS.has(event.get("region")):
			return false
		if not ["aid_arrival", "purchase_arrival", "resistance", "noble_demands", "popular_support", "negotiation_delivery", "regional_delivery"].has(event.get("kind")):
			return false
		if event.kind == "negotiation_delivery" and not ["relief", "barter", "charter"].has(event.get("deal")):
			return false
		if not (event.get("due") is float or event.get("due") is int) or not (event.get("origin") is float or event.get("origin") is int):
			return false
	return true

func valid_stock(stock: Variant) -> bool:
	if not stock is Dictionary:
		return false
	for resource in RESOURCES:
		var value = stock.get(resource)
		if not (value is float or value is int) or not is_finite(float(value)) or value < 0 or floor(value) != value:
			return false
	return true
