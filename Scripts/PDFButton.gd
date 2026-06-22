extends Control

@onready var download_button = $DownloadButton
@onready var status_label = $StatusLabel

const SOURCE_PDF = "res://Assets/Files/CurriculumVitae-ArminPosadas.pdf"
const DOWNLOAD_FOLDER = "user://downloads/"

func _ready():
	download_button.pressed.connect(_on_download_button_pressed)
	_create_downloads_folder()

func _on_download_button_pressed():
	download_button.disabled = true
	download_button.text = "Copying..."
	
	var success = _copy_pdf_with_dirac()
	
	if success:
		status_label.text = "PDF saved successfully!"
	else:
		status_label.text = "Failed to save PDF"
	
	await get_tree().create_timer(2.0).timeout
	download_button.disabled = false
	download_button.text = "Download PDF"

func _copy_pdf_with_dirac() -> bool:
	# Using DirAccess to copy
	var source_path = SOURCE_PDF
	var filename = source_path.get_file()
	var dest_path = DOWNLOAD_FOLDER + filename
	
	# Remove timestamp if you want to keep the original filename
	# var dest_path = DOWNLOAD_FOLDER + "your-file.pdf"
	
	var dir = DirAccess.open("res://")
	if dir == null:
		print("Error: Cannot access res://")
		return false
	
	# Copy using DirAccess
	var error = dir.copy(source_path, dest_path)
	if error != OK:
		print("Error copying file: ", error)
		return false
	
	print("File copied to: ", dest_path)
	return true

func _create_downloads_folder():
	var dir = DirAccess.open("user://")
	if dir == null:
		DirAccess.make_dir_absolute(DOWNLOAD_FOLDER)
	else:
		if not dir.dir_exists("downloads"):
			dir.make_dir("downloads")
