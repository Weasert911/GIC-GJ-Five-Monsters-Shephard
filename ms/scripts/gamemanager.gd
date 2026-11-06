extends Node

# =====================
# SIGNALS
# =====================
signal horn_changed(horn: String)
signal horn_played(horn: Vector2, origin: Vector2, radius: float)

signal score_changed(value: int)
signal portals_changed(used: int, max: int)
signal fail_triggered(text: String)

signal tier_changed(tier: int)
signal game_completed(stats: Dictionary)
func go_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")


# =====================
# TIERS
# =====================
const MAX_TIERS := 3
var current_tier := 1
var last_frame_texture: Texture2D
func capture_last_frame():
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	last_frame_texture = ImageTexture.create_from_image(img)

# 👉 Assign Marker2D nodes in the inspector
@export var tier_spawn_points: Array[Node2D] = []

func get_current_tier_spawn_position() -> Vector2:
	if tier_spawn_points.size() < current_tier:
		push_error("Tier spawn points not configured correctly")
		return Vector2.ZERO
	return tier_spawn_points[current_tier - 1].global_position

func advance_tier():
	if current_tier < MAX_TIERS:
		current_tier += 1
		reset_portals()  # reset portals per tier
		tier_changed.emit(current_tier)
	else:
		_finish_game()


func _finish_game():
	game_completed.emit({
		"score": score,
		"portals_used": portals_used,
		"tier": current_tier
	})

# =====================
# HORNS
# =====================
const HORNS := ["red", "green", "orange", "purple", "brown"]
var horn_index := 0
@export var horn_radius := 450.0

func cycle_horn():
	horn_index = (horn_index + 1) % HORNS.size()
	horn_changed.emit(current_horn())

func current_horn() -> String:
	return HORNS[horn_index]

func play_horn(origin: Vector2):
	horn_played.emit(current_horn(), origin, horn_radius)

# =====================
# SCORE
# =====================
var score := 0

func add_score(amount: int):
	score += amount
	score_changed.emit(score)

# =====================
# PORTALS
# =====================
const MAX_PORTALS := 5
var portals_used := 0

# Flag to prevent double increment when player presses interact multiple times
var portal_active := false

func try_place_portal() -> bool:
	if portals_used >= MAX_PORTALS or portal_active:
		return false

	portals_used += 1
	portal_active = true
	portals_changed.emit(portals_used, MAX_PORTALS)
	return true

func reset_portals():
	portals_used = 0
	portal_active = false
	portals_changed.emit(portals_used, MAX_PORTALS)

# Call this when player leaves portal area or tier changes to allow placing new portal
func deactivate_portal():
	portal_active = false

# =====================
# FAIL / RESET
# =====================
var restarting := false

func fail(text: String):
	if restarting:
		return

	restarting = true
	fail_triggered.emit(text)

	await get_tree().create_timer(2.0).timeout
	_restart_scene()

func _restart_scene():
	restarting = false
	score = 0
	current_tier = 1
	reset_portals()
	score_changed.emit(score)
	get_tree().reload_current_scene()
