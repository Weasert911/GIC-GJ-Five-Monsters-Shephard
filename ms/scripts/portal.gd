extends Area2D
class_name Portal

# ---------------------
# CONFIGURATION
# ---------------------
@export var is_exit := true                 # true: player can advance; false: enemy sink
@export var tier_positions: Array[Vector2] = []  # teleport positions for each tier (assign in editor)
@export var interaction_radius := 32.0

# ---------------------
# READY
# ---------------------
func _ready():
	add_to_group("portals")
	body_entered.connect(_on_body_entered)

# ---------------------
# ENEMY ENTERS PORTAL
# ---------------------
func _on_body_entered(body):
	if body.is_in_group("enemy"):
		var reward := 15 if randf() < 0.5 else 30
		GameManager.add_score(reward)
		body.queue_free()

# ---------------------
# PLAYER INTERACTION
# ---------------------
func interact_player(player: Node2D):
	# If too far → spawn a portal at player position instead
	if player.global_position.distance_to(global_position) > interaction_radius:
		player._place_portal()
		return

	if not is_exit:
		# Non-exit portal → do nothing for player
		return

	# ---------------------
	# PLAYER ADVANCES TIERS
	# ---------------------
	var next_tier := GameManager.current_tier + 1
	if next_tier <= GameManager.MAX_TIERS:
		GameManager.advance_tier()          # increments tier
		GameManager.reset_portals()          # reset portals for new tier

		# Teleport player if spawn point assigned
		if tier_positions.size() >= next_tier:
			player.global_position = tier_positions[next_tier - 1]
	else:
		# Last tier completed → trigger game completion
		GameManager.advance_tier()
