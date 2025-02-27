class_name SaveLoadPicture extends Node

## from filename to png
static func load_image_to_raw_png(file_path:String):
	var image_raw = FileAccess.get_file_as_bytes(file_path)
	var image = Image.new()
	file_path = file_path.to_lower()
	if file_path.contains(".bmp"):
		image.load_bmp_from_buffer(image_raw)
		
	elif file_path.contains(".jpg") || file_path.contains(".jepg"):
		image.load_jpg_from_buffer(image_raw)
		
	elif file_path.contains(".ktx"):
		image.load_ktx_from_buffer(image_raw)
		
	elif file_path.contains(".png"):
		image.load_png_from_buffer(image_raw)
		
	elif file_path.contains(".svg"):
		image.load_svg_from_buffer(image_raw)
		
	elif file_path.contains(".tga"):
		image.load_tga_from_buffer(image_raw)
		
	elif file_path.contains(".webp"):
		image.load_webp_from_buffer(image_raw)
		
	return image.save_png_to_buffer()
	
## from array to texture2D
static func load_image_from_raw_png(image_raw):
	var image = Image.new()
	image.load_png_from_buffer(image_raw)
	return ImageTexture.create_from_image(image)
