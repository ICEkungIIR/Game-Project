extends HBoxContainer

@export var icon: TextureRect
@export var name_label: Label
@export var amount_label: Label

func setup(item_id: String, have: int, need: int) -> void:
	name_label.text = item_id.capitalize()
	name_label.add_theme_font_size_override("font_size", 20)
	amount_label.add_theme_font_size_override("font_size", 20)

	# TODO: ถ้ามี DB ที่ดึงไอคอนวัตถุดิบทั่วไปได้ (ไม่ใช่แค่พืชปลูก) ใส่ตรงนี้
	# icon.texture = ItemDB.get_icon(item_id)

	amount_label.text = "%d/%d" % [have, need]
	if have >= need:
		amount_label.add_theme_color_override("font_color", Color.WHITE)
	else:
		amount_label.add_theme_color_override("font_color", Color.RED)
