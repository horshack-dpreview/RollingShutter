:: Extracts the first iframe from a video file and saves it
:: as a JPG to <source video path/filename>.JPG
::
:: Usage: extract_first_iframe_as_jpg [source video path/filename]
:: From: https://www.bogotobogo.com/FFMpeg/ffmpeg_thumbnails_select_scene_iframe.php
::
set param_dir=%~dp1
set root_filename=%~n1
ffmpeg -i %1 -frames:v 1 -f image2 -vf "select='eq(pict_type,PICT_TYPE_I)'" -vsync vfr -q:v 1 %param_dir%%root_filename%.jpg