extends StarMonkeyGroundLevelChunk

func _ready() -> void:
	super._ready()
	
	if StarMonkey.locale == StarMonkey.Locales.EN:
		%ForgottenCityJP.visible = false
		%ForgottenCityJP.queue_free()
	else:
		%ForgottenCity.visible = false
		%ForgottenCity.queue_free()
