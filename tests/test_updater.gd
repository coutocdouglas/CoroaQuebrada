extends SceneTree
const Updater = preload("res://scripts/updater.gd")
var checks = 0
var failures = 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func release(version: String) -> Dictionary:
	return {"tag_name": "v" + version, "draft": false, "prerelease": true, "assets": [{
		"name": "CoroaQuebrada-v%s-Windows.zip" % version, "state": "uploaded",
		"browser_download_url": Updater.DOWNLOAD_ROOT + "v%s/CoroaQuebrada-v%s-Windows.zip" % [version, version],
		"digest": "sha256:" + "a".repeat(64), "size": 40000000
	}]}

func _initialize() -> void:
	check(Updater.newer("v0.10.0", "0.9.9"), "Versões são comparadas numericamente")
	check(not Updater.newer("v0.3.0", "0.3.0"), "Versão instalada não é oferecida novamente")
	check(not Updater.newer("v0.2.0", "0.3.0"), "Não ocorre downgrade")
	for bad in ["v0.4.0-beta", "../0.4.0", "v1.2", "banana", "1.2.3/evil"]:
		check(Updater.version_parts(bad).is_empty(), "Versões inválidas são rejeitadas")
	var selected = Updater.choose_release([release("0.3.1"), release("0.4.0"), release("0.3.2")], "0.3.0")
	check(selected.version == "0.4.0", "Escolhe a maior versão compatível, mesmo fora de ordem")
	check(Updater.choose_release([release("0.2.0")], "0.3.0").is_empty(), "Ignora versões antigas")
	for change in ["draft", "url", "hash", "size", "missing", "incomplete"]:
		var item = release("0.4.0")
		match change:
			"draft": item.draft = true
			"url": item.assets[0].browser_download_url = "https://example.com/update.zip"
			"hash": item.assets[0].digest = "sha256:invalid"
			"size": item.assets[0].size = Updater.MAX_BYTES + 1
			"missing": item.assets.clear()
			"incomplete": item.assets[0].state = "new"
		check(Updater.choose_release([item], "0.3.0").is_empty(), "Recusa metadados inseguros: " + change)
	check(Updater.choose_release({"message": "rate limit"}, "0.3.0").is_empty(), "Resposta de erro não é tratada como versão")
	var node = Updater.new()
	var message = [""]
	node.status_changed.connect(func(value): message[0] = value)
	node.busy = true
	node.phase = "check"
	node.completed(HTTPRequest.RESULT_CANT_CONNECT, 0, PackedStringArray(), PackedByteArray())
	check(not node.busy and "continuar" in message[0], "Falha de rede libera a interface e permite continuar jogando")
	var path = "user://test_corrupt_update.zip"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string("corrompido")
	file.close()
	node.phase = "download"
	node.package_path = path
	node.selected = {"version": "0.4.0", "size": 10, "sha256": "a".repeat(64)}
	node.completed(HTTPRequest.RESULT_SUCCESS, 200, PackedStringArray(), PackedByteArray())
	check(not node.prepared and not FileAccess.file_exists(path), "Download com hash errado é removido sem preparar instalação")
	check(node.apply_update() == ERR_UNCONFIGURED, "Atualizador não inicia sem pacote validado")
	node.free()
	print("ATUALIZADOR: %d verificações, %d falhas" % [checks, failures])
	quit(1 if failures else 0)
