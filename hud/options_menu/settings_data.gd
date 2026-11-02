extends Resource
class_name SettingsData

@export var fullscreen: bool = false
@export var resolution: Vector2i = Vector2i(1920, 1080)
@export var keybindings: Dictionary = {}
@export var sound_levels: Dictionary = {
	"Music": 100.0,
	"SFX": 100.0,
	"Communication": 100.0
}
