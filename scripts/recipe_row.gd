extends Button

@export var icon_rect: TextureRect
@export var name_label: Label

func setup(recipe: Recipe) -> void:
	icon_rect.texture = recipe.icon
	name_label.text = recipe.display_name if recipe.display_name != "" else recipe.recipe_id.capitalize()
	name_label.add_theme_font_size_override("font_size", 24)   # เพิ่มบรรทัดนี้
