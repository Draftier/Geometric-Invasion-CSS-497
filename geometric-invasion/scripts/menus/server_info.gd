extends HBoxContainer

@onready var ip_address_label : Label = %IpAddressLabel
@onready var stale_server_timer : Timer = %StaleServerTimer

signal entry_refreshed

func _ready() -> void:
	stale_server_timer.start()
	
func reset_timer() -> void:
	stale_server_timer.stop()
	stale_server_timer.start()

func _on_join_button_pressed() -> void:
	NetworkManager.start_client(ip_address_label.text)

func _on_stale_server_timer_timeout() -> void:
	# If server is not refreshed enough (timer is not reset enough)
	# Remove server entry
	self.queue_free()
