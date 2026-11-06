extends Control

func _ready():
	if GameManager.game_completed.is_connected(_on_game_completed):
		return
	GameManager.game_completed.connect(_on_game_completed)

func _on_game_completed(stats: Dictionary):
	await GameManager.capture_last_frame()
	var stats_screen := preload("res://scenes/StatsScreen.tscn").instantiate()
	add_child(stats_screen)
	stats_screen.show_stats(stats)
