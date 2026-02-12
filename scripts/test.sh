#!/bin/bash

# Generate test image
convert -size 50x50 canvas:white canvas:red canvas:lime canvas:blue canvas:black +append rgb.png
convert -size 50x50 canvas:black canvas:yellow canvas:magenta canvas:cyan canvas:white +append ymc.png
convert rgb.png ymc.png -append test.png
rm rgb.png ymc.png
convert test.png -scale 200% ref_x2.png
convert test.png -scale 400% ref_x4.png

# Test
test_iteration=1
while read -r scale tilesize model; do
    echo "
Running test $test_iteration: scale=$scale, tilesize=$tilesize, model=$model"
    ./realesrgan-ncnn-vulkan -s $scale -t $tilesize -n $model -i test.png -o upscale$test_iteration.png > /dev/null || exit 1
    identify -format '%wx%h\n' upscale$test_iteration.png
    [ "$(identify -format '%wx%h\n' upscale$test_iteration.png)" = "$(identify -format '%wx%h\n' ref_x$scale.png)" ] || exit 2
    compare -metric AE -fuzz 5000 upscale$test_iteration.png ref_x$scale.png /dev/null 2>&1
    [ "$(compare -metric AE -fuzz 5000 upscale$test_iteration.png ref_x$scale.png /dev/null 2>&1 | cut -f 1 -d ' ')" -lt $(($scale*$scale*1000)) ] || exit 3
    test_iteration=$(($test_iteration+1))
# scale  tilesize  model
done << EOF
  2      0         realesr-animevideo
  4      0         realesr-animevideo
  2      32        realesr-animevideo
  2      200       realesr-animevideo
  2      0         realesr-general-wdn
  2      0         upscayl-lite
EOF
