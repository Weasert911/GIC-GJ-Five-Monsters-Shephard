extends CanvasLayer

@onready var label := $Label
@onready var bg: TextureRect = $TextureRect

func _ready():
	# Assign captured last frame
	if GameManager.last_frame_texture:
		bg.texture = GameManager.last_frame_texture

	# Start auto transition
	_go_to_main_menu_delayed()


func show_stats(stats: Dictionary):
	label.text = """
COMPLETED
Score: %d
Tiers: %d
""" % [
		stats["score"],
		stats["tier"]
	]


func _go_to_main_menu_delayed():
	await get_tree().create_timer(4.0).timeout
	GameManager.go_to_main_menu()
