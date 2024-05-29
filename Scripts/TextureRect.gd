extends TextureRect
 
var on : bool = false
@export var i: int

func _get_drag_data(at_position):
	var preview_texture = TextureRect.new()
 
	preview_texture.texture = texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(30,30)
 
	var preview = Control.new()
	preview.add_child(preview_texture)
 
	set_drag_preview(preview)
 
	return preview_texture.texture
 

func _can_drop_data(_pos, data):
	return data is Texture2D
 
 
func _drop_data(_pos, data):
	get_tree().root.get_child(0).dropped(self)
	texture = data
 
func ClearTexture():
	on = false
	texture = null
	$Label.text = null

func TextureNote(tex, _char):
	texture = tex
	on = true
	$Label.text = _char
