function remove-exif
	exiftool -all:all= -overwrite_original *.jpg
end
