#!/bin/sh


export XDG_CONFIG_HOME=/home/phablet/.config/organicmaps.pparent/
export QT_PLUGIN_PATH=$(pwd)/lib/aarch64-linux-gnu/qt6/plugins
export QT_SCALE_FACTOR=2
export QT_IM_MODULE=maliit
export QT_OPENGL_VARIANT=gles
#! Enable this to run with XWayland
#export QT_QPA_PLATFORM=xcb

omim-build-release/OMaps -resources_path /home/phablet/.config/organicmaps.pparent/OMaps/R/ -data_path /home/phablet/.config/organicmaps.pparent/OMaps/Resources/
