class_name SaveSettings

const saveGamePath = "user://Settings.json"

static func writeData(audio):
	var dic: Dictionary
	dic["audio"] = audio
	var file = FileAccess.open(saveGamePath, FileAccess.WRITE)
	file.store_string(JSON.stringify(dic))

static func readData():
	if FileAccess.file_exists(saveGamePath):
		var file = FileAccess.open(saveGamePath, FileAccess.READ).get_as_text()
		return JSON.parse_string(file)
	return null
