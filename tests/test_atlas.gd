extends SceneTree
var checks = 0
var failures = 0
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred("run_checks")
func run_checks() -> void:
	var ui = load("res://scenes/main.tscn").instantiate()
	root.add_child(ui)
	await process_frame
	await process_frame
	var canvas = ui.atlas.canvas
	var before = ui.game.state.duplicate(true)
	check(ui.atlas.visible and canvas.data.regions.size() == 12,"Atlas abre com 12 regiões")
	for dimensions in [Vector2(600,420),Vector2(930,590),Vector2(1300,800)]:
		canvas.size = dimensions
		canvas.reset_view()
		for r in canvas.data.regions:
			var cell = canvas.terrain.filter(func(c): return c.region == r.id)[0]
			var center = Vector2.ZERO
			for p in cell.polygon: center += p
			center /= cell.polygon.size()
			check(canvas.region_at(canvas.to_screen(center)) == r.id,"Território clicável: " + r.id)
	var point = canvas.size * 0.5
	var world = canvas.to_world(point)
	canvas.zoom_at(1.5,point)
	check(canvas.to_world(point).distance_to(world)<0.01,"Zoom preserva o ponto sob o cursor")
	canvas.reset_view()
	check(canvas.zoom == 1.0 and canvas.pan == Vector2.ZERO,"Reenquadramento restaura a vista")
	canvas.select_region("ilhas")
	check(ui.atlas.govern_button.disabled,"Região nova não emite ordens econômicas falsas")
	canvas.select_region("vale")
	check(not ui.atlas.govern_button.disabled,"Região simulada permite voltar ao conselho")
	ui.atlas.mode_picker.select(2)
	ui.atlas.mode_picker.item_selected.emit(2)
	check(canvas.mode == "reserves" and canvas.snapshot.vale.stock.food == ui.game.state.regions.vale.stock.food,"Reservas vêm da partida")
	canvas.snapshot.vale.stock.food = 9999
	check(ui.game.state == before,"Navegação e cópias do atlas não alteram a simulação")
	ui.atlas.govern_button.pressed.emit()
	check(not ui.atlas.visible and ui.selected_region() == "vale","Governar abre o conselho da região selecionada")
	ui.game.state.regions.vale.stock.food = 10
	ui.refresh()
	check(canvas.snapshot.vale.stock.food == 10,"Atlas escondido recebe estoques novos")
	ui.atlas.show()
	await process_frame
	check(ui.atlas.get_global_rect().end.y <= ui.size.y,"Atlas cabe na janela")
	ui.queue_free()
	await process_frame
	print("ATLAS: %d verificações, %d falhas" % [checks,failures])
	quit(1 if failures else 0)
