extends Button

@export var pdf_path: String = "res://Assets/Files/CurriculumVitae-ArminPosadas.pdf"

func _on_pressed() -> void:
	var file = FileAccess.open(pdf_path, FileAccess.READ)
	if not file:
		print("Error: Could not load PDF file at ", pdf_path)
		return
	
	var pdf_data = file.get_buffer(file.get_length())
	file.close()

	JavaScriptBridge.download_buffer(pdf_data, "document.pdf", "application/pdf")
