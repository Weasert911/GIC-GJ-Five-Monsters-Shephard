extends CanvasLayer

# =====================
# NODES
# =====================
@onready var portal_label: Label = $Control/Label
@onready var score_label: Label = $Control/Label3
@onready var death_label: Label = $Control/Label2
@onready var vignette: ColorRect = $Control/ColorRect
@onready var vignette_mat: ShaderMaterial = vignette.material

@onready var hearts := [
	$Control/HBoxContainer/TextureRect,
	$Control/HBoxContainer/TextureRect2,
	$Control/HBoxContainer/TextureRect3
]

@onready var horn_sprites := [
	$Control/BoxContainer/HornRed,
	$Control/BoxContainer/HornGreen,
	$Control/BoxContainer/HornOrange,
	$Control/BoxContainer/HornPurple,
	$Control/BoxContainer/HornBrown
]

@onready var horn_sounds := [
	preload("res://assets/music/horn1.mp3"),
	preload("res://assets/music/horn2.mp3"),
	preload("res://assets/music/horn3.mp3"),
	preload("res://assets/music/horn4.mp3"),
	preload("res://assets/music/horn5.mp3")
]

# =====================
# READY
# =====================
func _ready():
	death_label.visible = false
	reset_vignette()

	GameManager.score_changed.connect(update_score)
	GameManager.portals_changed.connect(update_portals)
	GameManager.fail_triggered.connect(show_fail)
	GameManager.horn_changed.connect(update_horn_display)

	update_score(GameManager.score)
	update_portals(GameManager.portals_used, GameManager.MAX_PORTALS)

	# Player health (optional)
	var player := get_tree().get_first_node_in_group("player")
	if player and player.has_signal("health_changed"):
		player.health_changed.connect(update_health)

	# Init horn UI
	update_horn_display(GameManager.current_horn())

# =====================
# INPUT
# =====================
func _input(event):
	if event.is_action_pressed("horn_next"):
		GameManager.cycle_horn()
	elif event.is_action_pressed("play_horn"):
		play_current_horn()

# =====================
# HORNS
# =====================
func update_horn_display(horn: String):
	for i in range(horn_sprites.size()):
		horn_sprites[i].visible = (GameManager.HORNS[i] == horn)

func play_current_horn():
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return

	# ---- AUDIO ----
	var horn_index := GameManager.horn_index
	var horn_audio := AudioStreamPlayer2D.new()
	horn_audio.stream = horn_sounds[horn_index]
	horn_audio.global_position = player.global_position
	get_tree().current_scene.add_child(horn_audio)
	horn_audio.play()

	_cleanup_audio(horn_audio)

	# ---- GAME LOGIC ----
	GameManager.play_horn(player.global_position)

func _cleanup_audio(audio: AudioStreamPlayer2D):
	await audio.finished
	audio.queue_free()

# =====================
# UI UPDATES
# =====================
func update_score(value: int):
	score_label.text = "Score: %d" % value

func update_portals(used: int, max: int):
	portal_label.text = "Portals: %d / %d" % [max - used, max]

func update_health(hp: int):
	for i in range(hearts.size()):
		hearts[i].visible = i < hp

# =====================
# FAIL SCREEN
# =====================
func show_fail(text: String):
	death_label.text = text
	death_label.visible = true
	play_vignette()

# =====================
# VIGNETTE
# =====================
func play_vignette():
	if vignette_mat == null:
		return

	vignette_mat.set_shader_parameter("strength", 0.25)
	var tween := create_tween()
	tween.tween_property(
		vignette_mat,
		"shader_parameter/strength",
		0.35,
		0.6
	)

func reset_vignette():
	if vignette_mat:
		vignette_mat.set_shader_parameter("strength", 0.0)
