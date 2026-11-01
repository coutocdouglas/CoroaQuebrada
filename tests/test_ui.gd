extends SceneTree

var failures = 0
var checks = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run_checks")

func run_checks() -> void:
	var ui = load("res://scenes/main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	check(ui.region_picker.item_count == 3 and ui.action_picker.item_count == 5, "Interface oferece três regiões e cinco ações")
	check(ui.next_button.get_global_rect().end.y <= ui.size.y, "Botão de avanço cabe na tela")
	ui.region_picker.select(1)
	ui.region_picker.item_selected.emit(1)
	check("Artur" in ui.region_details.text, "Seleção de região atualiza detalhes")
	ui.confirm_button.pressed.emit()
	check(ui.game.state.crown.food == 95 and ui.game.state.orders_left == 1, "Botão confirmar executa ordem validada")
	ui.next_button.pressed.emit()
	check(ui.game.state.month == 2 and ui.game.state.regions.marca.stock.food == 52, "Botão encerrar mês aplica entrega")
	for i in range(11):
		ui.next_button.pressed.emit()
	check(ui.next_button.disabled and ui.confirm_button.disabled, "Final desativa ações da interface")
	check("Doze meses" in ui.news.text, "Interface apresenta resultado do reinado")
	ui.reset_dialog.confirmed.emit()
	check(ui.game.state.month == 1 and not ui.next_button.disabled, "Novo reinado reinicia a interface")
	ui.queue_free()
	await process_frame
	print("INTERFACE: %d verificações, %d falhas" % [checks, failures])
	quit(1 if failures > 0 else 0)
