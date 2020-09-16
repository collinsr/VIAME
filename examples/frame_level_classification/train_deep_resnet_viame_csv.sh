#!/bin/bash

# Path to VIAME installation
export VIAME_INSTALL="$(cd "$(dirname ${BASH_SOURCE[0]})" && pwd)/../.."

# Core processing options
export INPUT_DIRECTORY=training_data

# Setup paths and run command
source ${VIAME_INSTALL}/setup_viame.sh

viame_train_detector \
  -i ${INPUT_DIRECTORY} \
  -c ${VIAME_INSTALL}/configs/pipelines/train_netharn_resnet.viame_csv.conf \
  --threshold 0.0