class_name SaveSettings

const saveGamePath = "user://Settings.json"

static var masterVol:= 0
static var musicVol:= 0
static var SFXVol:= 0


static func writeData():
	var dic: Dictionary
	dic["master"] = masterVol
	dic["music"] = musicVol
	dic["sfx"] = SFXVol
	var file = FileAccess.open(saveGamePath, FileAccess.WRITE)
	file.store_string(JSON.stringify(dic))

static func readData():
	if FileAccess.file_exists(saveGamePath):
		var file = FileAccess.open(saveGamePath, FileAccess.READ).get_as_text()
		var content = JSON.parse_string(file)
		if(content == null || content.master == null || content.music == null || content.sfx == null):
			writeData()
		return JSON.parse_string(file)
	return null
