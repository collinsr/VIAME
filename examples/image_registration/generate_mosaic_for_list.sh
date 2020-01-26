#!/bin/sh

# Setup VIAME Paths (no need to run multiple times if you already ran it)

export VIAME_INSTALL="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)/../.."
export INPUT_IMAGE_PATTERN=/path/to/images/*.png

source ${VIAME_INSTALL}/setup_viame.sh 

# Run pipelines

ls ${INPUT_IMAGE_PATTERN} > input_list.txt

kwiver runner ${VIAME_INSTALL}/configs/pipelines/register_using_homographies.pipe \
              -s input:video_filename=input_list.txt

python create_mosaic.py first_mosaic.png output-homog.txt "${INPUT_IMAGE_PATTERN}" --step 1
