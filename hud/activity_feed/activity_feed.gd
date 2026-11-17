extends Control

@onready var message_feed = $MessageFeed

func add_feed_message(text: String, color: Color = Color.GOLD, duration: float = 5.0) -> void:
	var msg = Label.new()
	msg.text = text
	msg.modulate = color
	message_feed.add_child(msg)
	
	var tween = create_tween()
	tween.tween_interval(duration)
	tween.tween_property(msg, "modulate:a", 0.0, 1.0)
	tween.tween_callback(msg.queue_free)
