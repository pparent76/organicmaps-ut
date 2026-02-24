#!/bin/bash
set -e  # Exit immediately on error

lsb_release -a
# ========================
# PROJECT CONFIGURATION
# ========================
PROJECT_NAME="organicmaps"
INSTALL_DIR="${BUILD_DIR}/install"

# =================================================
# STEP 6: Build organicmaps
# =================================================
echo "[1/4] Building organicmaps..."

if [ ! -d "$BUILD_DIR/organicmaps/" ]; then
    git clone --recurse-submodules https://github.com/organicmaps/organicmaps
    cp -r ${ROOT}/organicmaps $BUILD_DIR/
else
    echo "Source allready present skiping"
fi

if [ ! -f "$BUILD_DIR/omim-build-release/OMaps" ]; then
    mkdir -p $BUILD_DIR/organicmaps/build && cd $BUILD_DIR/organicmaps/build
    #$BUILD_DIR/organicmaps/tools/unix/build_omim.sh -r desktop
    cmake .. -DCMAKE_BUILD_TYPE=Release -GNinja -DCMAKE_TOOLCHAIN_FILE=${ROOT}/toolchain-arm64.cmake
    ninja desktop
else
    echo "Package allready built skipping..."
fi

# =================================================
# STEP 6: Install dependencies
# =================================================
echo "[2/4] Install dependencies..."

 cd ${BUILD_DIR}
 DEPENDENCIES="libb2-1 libqt6core6t64 libopengl0 libqt6gui6 libqt6network6 libqt6opengl6 libqt6qml6 libqt6qmlmeta6 libqt6qmlmodels6 libqt6qmlworkerscript6 libqt6quick6 libqt6svg6 libqt6waylandclient6 libqt6waylandcompositor6 libqt6wlshellintegration6 libts0t64 qt6-gtk-platformtheme qt6-qpa-plugins qt6-svg-plugins qt6-wayland libpugixml1v5 libstb0t64 libagg2t64 libqt6openglwidgets6 libqt6widgets6 libqt6positioning6 libqt6dbus6 libxcb-cursor0"
 
 for dep in $DEPENDENCIES ; do
    echo "Handle $dep"
     if [ ! -d "${dep}.deb_extract_chsdjksd" ]; then
        apt download $dep:arm64
        mv ${dep}_*.deb ${dep}.deb
        mkdir "${dep}.deb_extract_chsdjksd"
        dpkg-deb -x "${dep}.deb" "${dep}.deb_extract_chsdjksd"
     fi
 done

# ==============================
# STEP 6: Copying files
# ==============================  
echo "[3/4] Copying files..." 


cp ${ROOT}/organicmaps.desktop "$INSTALL_DIR/"
cp ${ROOT}/manifest.json "$INSTALL_DIR/"
cp ${ROOT}/organicmaps.apparmor "$INSTALL_DIR/"
cp ${ROOT}/launcher.sh "$INSTALL_DIR/"
cp ${ROOT}/icon.png "$INSTALL_DIR/"

echo "Copying libraries dependencies..."
cd ${BUILD_DIR}
# Copie des fichiers du dossier /lib/ de chaque paquet
rm -rvf $INSTALL_DIR/lib
mkdir -p "$INSTALL_DIR/lib/aarch64-linux-gnu/gtk-3.0/3.0.0/immodules/"
for DIR in *_extract_chsdjksd; do
    if [ -d "$DIR/usr/lib/aarch64-linux-gnu/" ]; then
        cp -r "$DIR/usr/lib/aarch64-linux-gnu/"* "$INSTALL_DIR/lib/aarch64-linux-gnu/"
    fi
done

mkdir -p $INSTALL_DIR/bin/

if [ -d $INSTALL_DIR/omim-build-release ]; then
    rm -rvf $INSTALL_DIR/omim-build-release || true;
fi
cp -r ${BUILD_DIR}/organicmaps/build $INSTALL_DIR/omim-build-release
#cp -r ${BUILD_DIR}/omim-build-release/OMaps.app $INSTALL_DIR/
chmod +x $INSTALL_DIR/omim-build-release/OMaps
chmod +x $INSTALL_DIR/launcher.sh



# ========================
# STEP 7: BUILD THE CLICK PACKAGE
# ========================
echo "[4/4] Building click package..."
# click build "$INSTALL_DIR"

echo "✅ Preparation done, building the .click package."
 
