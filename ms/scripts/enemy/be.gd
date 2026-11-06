extends CharacterBody2D

# =====================
# EXPORTS
# =====================
@export var attack_speed := 420.0
@export var slide_time := 0.6
@export var floor_check_distance := 16.0
@export var wall_check_distance := 6.0

# =====================
# NODES
# =====================
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# =====================
# STATE
# =====================
var dir := 1
var attacking := false
var start_y := 0.0

func _ready():
	add_to_group("enemy")
	start_y = global_position.y
	sprite.play("idle")

	# 🔴 THIS IS THE IMPORTANT PART
	GameManager.horn_played.connect(_on_horn_played)

func _physics_process(delta):
	if attacking:
		handle_navigation()
		velocity.x = dir * attack_speed
	else:
		velocity.x = 0

	# HARD lock Y
	velocity.y = 0
	global_position.y = start_y

	move_and_slide()

# =====================
# WALL + EDGE CHECK (ONLY DURING ATTACK)
# =====================
func handle_navigation():
	var space_state = get_world_2d().direct_space_state

	# Wall check
	var wall_query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(dir * wall_check_distance, 0)
	)
	wall_query.exclude = [self]

	if space_state.intersect_ray(wall_query):
		stop_attack()
		return

	# Floor check
	var floor_query := PhysicsRayQueryParameters2D.create(
		global_position + Vector2(dir * floor_check_distance, 0),
		global_position + Vector2(dir * floor_check_distance, 12)
	)
	floor_query.exclude = [self]

	if not space_state.intersect_ray(floor_query):
		stop_attack()

# =====================
# HORN SIGNAL HANDLER
# =====================
func _on_horn_played(horn: String, origin: Vector2, radius: float):
	# Only react to correct horn
	if horn != "brown":
		return

	# Optional distance check (recommended)
	if global_position.distance_to(origin) > radius:
		return

	start_attack()

# =====================
# ATTACK LOGIC
# =====================
func start_attack():
	if attacking:
		return

	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return

	dir = sign(player.global_position.x - global_position.x)
	sprite.flip_h = dir < 0

	attacking = true
	sprite.play("slide")

	_end_attack_after_time()
func _end_attack_after_time():
	await get_tree().create_timer(slide_time).timeout
	stop_attack()

func stop_attack():
	attacking = false
	velocity.x = 0
	sprite.play("idle")
