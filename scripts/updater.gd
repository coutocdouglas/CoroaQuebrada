extends Node
## Downloads are opt-in. Only this repository's versioned Windows assets are accepted.
signal status_changed(message: String)
signal available(release: Dictionary)
signal ready_to_restart

const API = "https://api.github.com/repos/coutocdouglas/CoroaQuebrada/releases?per_page=100"
const DOWNLOAD_ROOT = "https://github.com/coutocdouglas/CoroaQuebrada/releases/download/"
const MAX_BYTES = 536870912
var selected: Dictionary = {}
var request_node: HTTPRequest
var phase = ""
var package_path = ""
var busy = false
var prepared = false

static func version_parts(value: String) -> Array:
	var regex = RegEx.new()
	regex.compile("^v?([0-9]+)\\.([0-9]+)\\.([0-9]+)$")
	var result = regex.search(value)
	if result == null: return []
	return [int(result.get_string(1)), int(result.get_string(2)), int(result.get_string(3))]

static func newer(candidate: String, current: String) -> bool:
	var a = version_parts(candidate)
	var b = version_parts(current)
	if a.is_empty() or b.is_empty(): return false
	for i in range(3):
		if a[i] != b[i]: return a[i] > b[i]
	return false

static func choose_release(data: Variant, current: String) -> Dictionary:
	if not data is Array: return {}
	var best = {}
	for release in data:
		if not release is Dictionary or release.get("draft", true) != false: continue
		var tag = release.get("tag_name", "")
		if not tag is String or not newer(tag, current): continue
		if not best.is_empty() and not newer(tag, best.tag): continue
		var version = tag.trim_prefix("v")
		var filename = "CoroaQuebrada-v%s-Windows.zip" % version
		if not release.get("assets") is Array: continue
		for asset in release.assets:
			if not asset is Dictionary or asset.get("name") != filename: continue
			if asset.get("state") != "uploaded": continue
			var url = DOWNLOAD_ROOT + tag + "/" + filename
			if asset.get("browser_download_url") != url: continue
			var digest = asset.get("digest", "")
			if not digest is String or not digest.begins_with("sha256:"): continue
			var hash_value = digest.trim_prefix("sha256:").to_lower()
			if hash_value.length() != 64 or not hash_value.is_valid_hex_number(): continue
			var size = asset.get("size", 0)
			if not (size is int or size is float) or size <= 0 or size > MAX_BYTES or floor(size) != size: continue
			best = {"tag": tag, "version": version, "url": url, "sha256": hash_value, "size": int(size)}
	return best

func _ready() -> void:
	request_node = HTTPRequest.new()
	request_node.timeout = 25
	request_node.use_threads = true
	request_node.body_size_limit = 2097152
	add_child(request_node)
	request_node.request_completed.connect(completed)

func check_updates() -> void:
	if busy: return
	if prepared:
		status_changed.emit("Atualização pronta. Clique em Salvar e reiniciar.")
		return
	selected = {}
	phase = "check"
	busy = true
	request_node.download_file = ""
	request_node.body_size_limit = 2097152
	request_node.timeout = 25
	status_changed.emit("Consultando versões no GitHub…")
	var error = request_node.request(API, ["Accept: application/vnd.github+json", "User-Agent: CoroaQuebrada"])
	if error != OK: fail("Não foi possível consultar atualizações. Você pode continuar jogando.")

func download_update() -> void:
	if busy or selected.is_empty(): return
	if OS.get_name() != "Windows" or OS.has_feature("editor"):
		fail("Para atualizar, abra a versão instalada do jogo no Windows.")
		return
	var error = DirAccess.make_dir_recursive_absolute("user://updates")
	if error != OK:
		fail("Não foi possível preparar a pasta de atualização.")
		return
	package_path = "user://updates/update-v%s.zip" % selected.version
	request_node.download_file = package_path
	request_node.body_size_limit = MAX_BYTES
	request_node.timeout = 300
	phase = "download"
	busy = true
	status_changed.emit("Baixando versão %s… O jogo pode continuar aberto." % selected.version)
	error = request_node.request(selected.url, ["User-Agent: CoroaQuebrada"])
	if error != OK: fail("Não foi possível iniciar o download. Tente novamente mais tarde.")

func completed(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	busy = false
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		fail("Atualização indisponível no momento (rede ou GitHub). Sua partida pode continuar normalmente.")
		return
	if phase == "check":
		var data = JSON.parse_string(body.get_string_from_utf8())
		if not data is Array:
			fail("Não foi possível interpretar a resposta do GitHub. Tente novamente mais tarde.")
			return
		selected = choose_release(data, str(ProjectSettings.get_setting("application/config/version")))
		if selected.is_empty():
			status_changed.emit("Você já está na versão mais recente compatível.")
		else:
			status_changed.emit("Versão %s disponível para baixar." % selected.version)
			available.emit(selected)
	elif phase == "download":
		var file = FileAccess.open(package_path, FileAccess.READ)
		if file == null:
			fail("Não foi possível ler o arquivo baixado.")
			return
		var size = file.get_length()
		file.close()
		if size != selected.size or FileAccess.get_sha256(package_path) != selected.sha256:
			DirAccess.remove_absolute(package_path)
			fail("O arquivo baixado não passou na verificação. Nada foi instalado; tente baixar novamente.")
			return
		prepared = true
		status_changed.emit("Versão %s pronta. Salve e reinicie para atualizar." % selected.version)
		ready_to_restart.emit()

func fail(message: String) -> void:
	busy = false
	status_changed.emit(message)

func apply_update() -> Error:
	if not prepared or selected.is_empty(): return ERR_UNCONFIGURED
	var install_dir = OS.get_executable_path().get_base_dir()
	var helper = install_dir.path_join("Atualizar.ps1")
	if not FileAccess.file_exists(helper):
		fail("O componente de atualização não foi encontrado. Reinstale pelo instalador oficial.")
		return ERR_FILE_NOT_FOUND
	var arguments = PackedStringArray([
		"-NoProfile", "-NonInteractive", "-WindowStyle", "Hidden", "-ExecutionPolicy", "Bypass", "-File", helper,
		"-InstallDir", install_dir, "-Package", ProjectSettings.globalize_path(package_path),
		"-ExpectedHash", selected.sha256, "-ParentId", str(OS.get_process_id()), "-Version", selected.version
	])
	var powershell = OS.get_environment("SystemRoot").path_join("System32/WindowsPowerShell/v1.0/powershell.exe")
	var process = OS.create_process(powershell, arguments)
	if process == -1:
		fail("Não foi possível iniciar o atualizador. O jogo permanece aberto.")
		return ERR_CANT_FORK
	return OK
