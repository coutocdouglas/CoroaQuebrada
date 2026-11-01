extends RefCounted
## All negotiation outcomes are rules, not generated prose.

const IDS = ["vale", "marca", "costa"]
const PROFILES = {
	"vale": {"interest": "Proteger as colheitas e a população", "petition": "relief", "support": 60},
	"marca": {"interest": "Preservar autonomia e abastecer fortalezas", "petition": "barter", "support": 45},
	"costa": {"interest": "Expandir comércio e influência", "petition": "charter", "support": 55}
}

static func initial_state() -> Dictionary:
	var regions = {}
	for id in IDS:
		regions[id] = {"support": PROFILES[id].support, "next_petition": 1, "last_relief": 0}
	return {"regions": regions, "petitions": [], "next_id": 1}

static func petition_for(game, region_id: String) -> Dictionary:
	for petition in game.state.politics.petitions:
		if petition.region == region_id and petition.status == "open":
			return petition
	return {}

static func describe(kind: String) -> String:
	match kind:
		"relief": return "Socorro às aldeias: enviar 20 alimentos reais. Entrega no mês seguinte; +7 lealdade e +3 apoio do vassalo na chegada."
		"barter": return "Troca de abastecimento: enviar 20 alimentos reais por 12 ferro regional. Ambas as cargas chegam no próximo mês; +7 lealdade na entrega."
		"charter": return "Carta comercial: transferir 15 ouro ao senhor por 10 madeira regional. Madeira chega no próximo mês; +7 lealdade na entrega. Outros senhores perdem 2 de lealdade pelo privilégio."
	return ""

static func proposal(game, region_id: String, accept: bool) -> Dictionary:
	var p = petition_for(game, region_id)
	if game.state.ended or game.state.orders_left <= 0 or p.is_empty():
		return {"ok": false, "text": "Não há pedido aberto ou ordens disponíveis."}
	if not accept:
		return {"ok": true, "text": "Recusar o pedido: lealdade −5. A decisão será lembrada na crônica."}
	var cost = {"food": 0, "wood": 0, "iron": 0, "gold": 0}
	var r = game.state.regions[region_id]
	match p.kind:
		"relief": cost.food = 20
		"barter":
			cost.food = 20
			if r.stock.iron < 12:
				return {"ok": false, "text": "O senhor já não possui os 12 ferro prometidos. Recuse ou aguarde novas reservas."}
		"charter":
			cost.gold = 15
			if r.stock.wood < 10:
				return {"ok": false, "text": "O senhor já não possui a madeira prometida."}
	for resource in cost:
		if game.state.crown[resource] < cost[resource]:
			return {"ok": false, "text": "A Coroa não possui recursos para cumprir este acordo."}
	return {"ok": true, "text": describe(p.kind), "cost": cost}

static func respond(game, region_id: String, accept: bool) -> Dictionary:
	var preview = proposal(game, region_id, accept)
	if not preview.ok:
		return preview
	var p = petition_for(game, region_id)
	var r = game.state.regions[region_id]
	game.state.orders_left -= 1
	p.status = "accepted" if accept else "refused"
	var origin = game.log_event("diplomacy", "%s: %s" % [r.lord, preview.text], p.origin)
	if not accept:
		r.loyalty = maxi(0, int(r.loyalty) - 5)
		return {"ok": true, "text": "Pedido recusado e registrado."}
	for resource in preview.cost:
		game.state.crown[resource] -= preview.cost[resource]
	var event = {"kind": "negotiation_delivery", "region": region_id, "due": int(game.state.month) + 1, "origin": origin, "deal": p.kind}
	if p.kind == "barter":
		r.stock.iron -= 12
	elif p.kind == "charter":
		r.stock.wood -= 10
		r.stock.gold += 15
	game.state.pending.append(event)
	return {"ok": true, "text": "Acordo firmado. A entrega e a reação política ocorrerão no próximo mês."}

static func deliver(game, event: Dictionary) -> void:
	var r = game.state.regions[event.region]
	var local = game.state.politics.regions[event.region]
	var result = ""
	match event.deal:
		"relief":
			result = "Chegaram 20 alimentos às aldeias; apoio do vassalo +3."
			r.stock.food += 20
			local.support = mini(100, int(local.support) + 3)
			game.schedule("popular_support", event.region, 8, event.origin)
		"barter":
			result = "Chegaram 20 alimentos à região e 12 ferro à Coroa."
			r.stock.food += 20
			game.state.crown.iron += 12
		"charter":
			result = "Chegaram 10 madeira à Coroa. O privilégio comercial reduziu a lealdade dos outros senhores em 2."
			game.state.crown.wood += 10
			for id in IDS:
				if id != event.region:
					game.state.regions[id].loyalty = maxi(0, int(game.state.regions[id].loyalty) - 2)
	r.loyalty = mini(100, int(r.loyalty) + 7)
	game.log_event("treaty_delivery", "Acordo de %s cumprido. %s Lealdade local +7." % [r.name, result], event.origin)

static func advance(game) -> void:
	var s = game.state
	# Expiration is evaluated after the player has had two full decision months.
	for p in s.politics.petitions:
		if p.status == "open" and p.expires <= s.month:
			p.status = "expired"
			var r = s.regions[p.region]
			r.loyalty = maxi(0, int(r.loyalty) - 3)
			game.log_event("petition_expired", "%s interpreta o silêncio real como descaso. Pedido expirado; lealdade −3." % r.lord, p.origin)
	if s.month > 12 or s.legitimacy <= 0:
		return
	for id in IDS:
		var r = s.regions[id]
		var local = s.politics.regions[id]
		# Vassals act with regional funds, with a three-month cooldown.
		if r.unrest >= 25 and local.support >= 55 and r.stock.gold >= 8 and (local.last_relief == 0 or s.month - local.last_relief >= 3):
			r.stock.gold -= 8
			r.unrest = maxi(0, int(r.unrest) - 6)
			local.last_relief = s.month
			game.log_event("vassal_action", "%s organiza socorro e mediação em %s usando 8 ouro regionais. Agitação −6; a iniciativa partiu do vassalo." % [r.vassal, r.name])
		if petition_for(game, id).is_empty() and local.next_petition <= s.month:
			open_petition(game, id)
	# Lords trade their own surplus without waiting for royal orders.
	# At most one route per month; food remains in transit until next month.
	if s.month >= 3:
		for buyer_id in IDS:
			var buyer = s.regions[buyer_id]
			if buyer.stock.food >= buyer.consumption or buyer.stock.gold < 12:
				continue
			for seller_id in IDS:
				if seller_id == buyer_id:
					continue
				var seller = s.regions[seller_id]
				if seller.stock.food - 15 < seller.consumption * 2:
					continue
				buyer.stock.gold -= 12
				seller.stock.gold += 12
				seller.stock.food -= 15
				var origin = game.log_event("regional_trade", "%s compra 15 alimentos de %s por 12 ouro de suas próprias reservas. Entrega no próximo mês." % [buyer.lord, seller.lord])
				game.schedule("regional_delivery", buyer_id, 1, origin)
				return

static func open_petition(game, id: String) -> void:
	var s = game.state
	var origin = game.log_event("petition", "%s apresenta ao conselho: %s Responda em dois meses; cada resposta usa uma ordem." % [s.regions[id].lord, describe(PROFILES[id].petition)])
	s.politics.petitions.append({"id": s.politics.next_id, "region": id, "kind": PROFILES[id].petition, "status": "open", "expires": int(s.month) + 2, "origin": origin})
	s.politics.next_id += 1
	s.politics.regions[id].next_petition = int(s.month) + 4

static func valid(data: Variant) -> bool:
	if not data is Dictionary or not data.get("regions") is Dictionary or not data.get("petitions") is Array:
		return false
	if not integer(data.get("next_id"), 1): return false
	for id in IDS:
		var r = data.regions.get(id)
		if not r is Dictionary: return false
		if not integer(r.get("support"), 0, 100) or not integer(r.get("next_petition"), 1) or not integer(r.get("last_relief"), 0): return false
	var seen = []
	for p in data.petitions:
		if not p is Dictionary: return false
		if not IDS.has(p.get("region")) or not ["relief", "barter", "charter"].has(p.get("kind")): return false
		if not ["open", "accepted", "refused", "expired"].has(p.get("status")): return false
		if not integer(p.get("id"), 1) or not integer(p.get("expires"), 1) or not integer(p.get("origin"), 1): return false
		if p.id >= data.next_id or seen.has(p.id): return false
		seen.append(p.id)
	return true

static func integer(value: Variant, minimum: int, maximum: int = 2147483647) -> bool:
	return (value is int or value is float) and is_finite(float(value)) and floor(value) == value and value >= minimum and value <= maximum
