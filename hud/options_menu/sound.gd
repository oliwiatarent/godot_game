extends MarginContainer

@onready var music_slider: HSlider = %MusicVolumeSlider
@onready var sfx_slider: HSlider = %SFXVolumeSlider
@onready var communication_slider: HSlider = %CommunicationVolumeSlider

func _ready() -> void:
	music_slider.value_changed.connect(_on_audio_slider_changed.bind("Music"))
	sfx_slider.value_changed.connect(_on_audio_slider_changed.bind("SFX"))
	communication_slider.value_changed.connect(_on_audio_slider_changed.bind("Communication"))
	_update_ui_state()

func _update_ui_state() -> void:
	if SettingsManager.settings_data.sound_levels.has("Music"):
		music_slider.value = SettingsManager.settings_data.sound_levels["Music"]
	if SettingsManager.settings_data.sound_levels.has("SFX"):
		sfx_slider.value = SettingsManager.settings_data.sound_levels["SFX"]
	if SettingsManager.settings_data.sound_levels.has("Communication"):
		communication_slider.value = SettingsManager.settings_data.sound_levels["Communication"]

func _on_audio_slider_changed(value: float, bus_name: String) -> void:
	SettingsManager.settings_data.sound_levels[bus_name] = value
	SettingsManager.apply_settings()
	SettingsManager.is_modified = true
