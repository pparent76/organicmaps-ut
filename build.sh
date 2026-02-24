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

# if [ ! -d "$BUILD_DIR/organicmaps/" ]; then
#     git clone --recurse-submodules https://github.com/organicmaps/organicmaps
# else
#     echo "Source allready present skiping"
# fi
# 
# if [ ! -f "$BUILD_DIR/organicmaps/build/OMaps" ]; then
#     mkdir -p $BUILD_DIR/organicmaps/build && cd $BUILD_DIR/organicmaps/build
#     #$BUILD_DIR/organicmaps/tools/unix/build_omim.sh -r desktop
#     cmake .. -DCMAKE_BUILD_TYPE=Release -GNinja -DCMAKE_TOOLCHAIN_FILE=${ROOT}/toolchain-arm64.cmake
#     ninja desktop
# else
#     echo "Package allready built skipping..."
# fi

# =================================================
# STEP 6: Install dependencies
# =================================================
echo "[2/4] Install dependencies..."


 DEPENDENCIES="libb2-1 libopengl0 libpugixml1v5 libxcb-cursor0 "
  for dep in $DEPENDENCIES ; do
    echo "Handle $dep"
     if [ ! -d "${dep}.deb_extract_chsdjksd" ]; then
        apt download $dep:arm64
        mv ${dep}_*.deb ${dep}.deb
        mkdir "${dep}.deb_extract_chsdjksd"
        dpkg-deb -x "${dep}.deb" "${dep}.deb_extract_chsdjksd"
     fi
 done
mkdir -p $BUILD_DIR/ubports-apt/etc/apt
mkdir -p $BUILD_DIR/ubports-apt/var/lib/apt/lists/partial
mkdir -p $BUILD_DIR/ubports-apt/var/cache/apt/archives/partial
mkdir -p $BUILD_DIR/ubports-apt/etc/apt/sources.list.d/

echo "deb https://repo.ubports.com/ 24.04-2.x main" > $BUILD_DIR//ubports-apt/etc/apt/sources.list

apt -o Dir=$BUILD_DIR/ubports-apt -o Dir::Etc=$BUILD_DIR/ubports-apt/etc/apt -o Dir::State=$BUILD_DIR/ubports-apt/var/lib/apt  -o Dir::Cache=~$BUILD_DIR/ubports-apt/var/cache/apt -o Dir::Etc::trusted=/etc/apt/trusted.gpg -o Dir::Etc::trustedparts=/etc/apt/trusted.gpg.d update

 cd ${BUILD_DIR}
 DEPENDENCIES="libqt6core6t64 libopengl0 libqt6gui6 libqt6network6 libqt6opengl6 libqt6qml6 libqt6qmlmeta6 libqt6qmlmodels6 libqt6qmlworkerscript6 libqt6quick6 libqt6svg6 libqt6waylandclient6 libqt6waylandcompositor6 libqt6wlshellintegration6 qt6-gtk-platformtheme qt6-qpa-plugins qt6-svg-plugins qt6-wayland libpugixml1v5 libqt6openglwidgets6 libqt6widgets6 libqt6positioning6 libqt6dbus6 maliit-inputcontext-qt6 qtubuntu-qt6"
 
 for dep in $DEPENDENCIES ; do
    echo "Handle $dep"
     if [ ! -d "${dep}.deb_extract_chsdjksd" ]; then
        apt -o Dir=$BUILD_DIR/ubports-apt -o Dir::Etc=$BUILD_DIR/ubports-apt/etc/apt -o Dir::State=$BUILD_DIR/ubports-apt/var/lib/apt -o Dir::Cache=$BUILD_DIR/ubports-apt/var/cache/apt download $dep:arm64
        mv ${dep}_*.deb ${dep}.deb
        mkdir "${dep}.deb_extract_chsdjksd"
        dpkg-deb -x "${dep}.deb" "${dep}.deb_extract_chsdjksd"
     fi
 done
 
  echo "Handle qtubuntu-qt6"
  wget https://repo.ubports.com/pool/main/q/qtubuntu-gles/qtubuntu-qt6_0.66~20251210073359.15~5499edf+ubports24.04.2_arm64.deb

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
 
