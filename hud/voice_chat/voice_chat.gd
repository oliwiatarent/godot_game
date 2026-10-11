extends Control

@onready var push_to_talk_button: Button = $PushToTalkButton


func _ready() -> void:
	if MultiplayerManager.vc and push_to_talk_button:
		push_to_talk_button.visible = MultiplayerManager.vc.can_transmit


func _on_push_to_talk_button_button_down() -> void:
	MultiplayerManager.vc.set_mic_active(true)
		
		
func _on_push_to_talk_button_button_up() -> void:
	MultiplayerManager.vc.set_mic_active(false)
