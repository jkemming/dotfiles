function remove-exif
    exiftool -all:all= -overwrite_original $argv
end
