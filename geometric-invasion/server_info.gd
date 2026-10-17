extends HBoxContainer

@onready var ip_address_label : Label = %IpAddressLabel

func _on_join_button_pressed() -> void:
	NetworkManager.start_client(ip_address_label.text)
