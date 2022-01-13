#!/bin/bash

set -e  # Exit on any error

# Determine rootdir based on our script location
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
ROOTDIR="$(dirname $DIR)"

# Detect luamin binary, preferably use the local luamin, otherwise default to the global luamin
LUAMIN="${ROOTDIR}/scripts/node_modules/.bin/luamin"
if ! which $LUAMIN 1> /dev/null; then
    npm install --save https://github.com/Dimencia/luamin/tarball/master
fi
if ! which $LUAMIN 1> /dev/null; then
    echo "ERROR: Luamin install apparently failed, try again or install it yourself to scripts folder without -g"; exit 1
fi

LUAC="${ROOTDIR}/scripts/node_modules/.bin/du-lua"
if ! which $LUAC 1> /dev/null; then
    npm install @wolfe-labs/du-luac
fi
if ! which $LUAC 1> /dev/null; then
    echo "ERROR: LuaC install apparently failed, try again or install it yourself to scripts folder without -g"; exit 1
fi

# Parse args, or use defaults
MINIFY="${1:-false}"
# We expect this file to be run from the <repo>/scripts directory
LUA_SRC=${2:-$ROOTDIR/src/ArchHUD.lua}
CONF_DST=${3:-$ROOTDIR/ArchHUD.conf}

# Make a fresh work dir
WORK_DIR=${ROOTDIR}/scripts/work
(rm -rf $WORK_DIR/* || true) && mkdir -p $WORK_DIR

# Copy files to LuaC src in the appropriate structure
CLUA_SRC_DIR="${ROOTDIR}/scripts/LuaC/src"
rm -rf $CLUA_SRC_DIR
#mkdir -p "${CLUA_SRC_DIR}/autoconf/custom/archhud/custom"
mkdir -p "${CLUA_SRC_DIR}/Modules"
cp "${LUA_SRC}" "${CLUA_SRC_DIR}"
# Copy recursively (-a) require files and the custom folder with it
#cp -a "${ROOTDIR}/src/requires/." "${CLUA_SRC_DIR}/autoconf/custom/archhud"
cp -a "${ROOTDIR}/src/requires/." "${CLUA_SRC_DIR}/Modules"

# Run LuaC to merge
cd "${ROOTDIR}/scripts/LuaC"
$LUAC build # --project="${ROOTDIR}/scripts/LuaC/project.json" # This couldn't find the source file even when explicitly specified
# Pretend this is now the source file
LUA_SRC="${ROOTDIR}/scripts/LuaC/out/release/ArchHUD.lua"
cd "${ROOTDIR}"
rm -rf $CLUA_SRC_DIR #Clean up

# Extract the exports because the minifier will eat them.
grep "\-- \?export:" $LUA_SRC | sed -e 's/^[ \t]*/        /' -e 's/-- export:/--export:/' > $WORK_DIR/ArchHUD.exports

VERSION_NUMBER=`grep "VERSION_NUMBER = .*" $LUA_SRC | sed -E "s/\s*VERSION_NUMBER = (.*)/\1/"`
if [[ "${VERSION_NUMBER}" == "" ]]; then
    echo "ERROR: Failed to detect version number"; exit 1
fi

sed "/-- \?export:/d;/require 'src.slots'/d" $LUA_SRC > $WORK_DIR/ArchHUD.extracted.lua

# Minify the lua
if [[ "$MINIFY" == "true" ]]; then
    echo "Minifying ... "
    # Using stdin pipe to avoid a bug in luamin complaining about "No such file: ``"
    echo "$WORK_DIR/ArchHUD.extracted.lua" | $LUAMIN --file > $WORK_DIR/ArchHUD.min.lua
else
    cp $WORK_DIR/ArchHUD.extracted.lua $WORK_DIR/ArchHUD.min.lua
fi

# Wrap in AutoConf
SLOTS=(
    core:class=CoreUnit
    radar:class=RadarPVPUnit,select=manual,type=radar
    antigrav:class=AntiGravityGeneratorUnit
    warpdrive:class=WarpDriveUnit
    gyro:class=GyroUnit
    weapon:class=WeaponUnit,select=manual
    dbHud:class=databank,select=manual
    telemeter:class=TelemeterUnit,select=manual
    vBooster:class=VerticalBooster
    hover:class=Hovercraft
    door:class=DoorUnit,select=manual
    switch:class=ManualSwitchUnit,select=manual
    forcefield:class=ForceFieldUnit,select=manual
    atmofueltank:class=AtmoFuelContainer,select=manual
    spacefueltank:class=SpaceFuelContainer,select=manual
    rocketfueltank:class=RocketFuelContainer,select=manual
    shield:class=ShieldGeneratorUnit,select=manual
)

echo "Wrapping ..."
lua ${ROOTDIR}/scripts/wrap.lua --handle-errors-min --output yaml \
             --name "ArchHud - Archaegeo v$VERSION_NUMBER (Minified)" \
             $WORK_DIR/ArchHUD.min.lua $WORK_DIR/ArchHUD.wrapped.conf \
             --slots ${SLOTS[*]}

# Re-insert the exports
if [[ "$MINIFY" == "true" ]]; then
    sed "/script={}/e cat $WORK_DIR/ArchHUD.exports" $WORK_DIR/ArchHUD.wrapped.conf > $CONF_DST
else
    sed "/script = {}/e cat $WORK_DIR/ArchHUD.exports" $WORK_DIR/ArchHUD.wrapped.conf > $CONF_DST
fi

# Fix up minified L_TEXTs which requires a space after the comma
sed -i -E 's/L_TEXT\(("[^"]*"),("[^"]*")\)/L_TEXT(\1, \2)/g' $CONF_DST

echo "$VERSION_NUMBER" > ${ROOTDIR}/ArchHUD.conf.version

echo "Compiled v$VERSION_NUMBER at ${CONF_DST}"

rm $WORK_DIR/*

# Setup release
RELEASEDIR="${ROOTDIR}/release"
rm -rf "${RELEASEDIR}"
mkdir -p "${RELEASEDIR}/archhud/Modules"

# Copy in conf file
cp "${ROOTDIR}/ArchHUD.conf" "${RELEASEDIR}"
# Copy main lua file into main archhud folder where compile is
cp "${LUA_SRC}" "${RELEASEDIR}/archhud"
# Copy compile.bat in
cp "${ROOTDIR}/scripts/compile.bat" "${RELEASEDIR}/archhud"
# Copy recursively (-a) require files and the custom folder with it
cp -a "${ROOTDIR}/src/requires/." "${RELEASEDIR}/archhud/Modules"
# Rename custom folder so they know what they are, and so when they update, they don't replace their real plugins
mv "${RELEASEDIR}/archhud/Modules/custom" "${RELEASEDIR}/archhud/Modules/examples"
# And make a custom one again so they know where to put them (TODO: Rename to 'plugins'? 'ActivePlugins' or 'InstalledPlugins'?)
mkdir "${RELEASEDIR}/archhud/Modules/custom"
# Copy scripts they need to compile it...?  Well.  We can make the batch file do that, if they choose to compile it.  

#I guess lastly, zip it up.  
if ! which zip 1> /dev/null; then
    echo "WARNING: Build successful, but could not zip folder - zip not installed.  Try `sudo apt install zip`"; exit
else
    rm -f "${ROOTDIR}/ArchHUD.zip"
    cd "${RELEASEDIR}" #zip is kinda dumb so if I'm not in here, it adds the intervening folders to the zip
    zip -r "${ROOTDIR}/ArchHUD.zip" "ArchHUD.conf" "archhud"
    rm -rf "${RELEASEDIR}"  #Should we clear this after?  It's a lot that probably shouldn't go on github
fi
echo "Zipped and ready at ArchHUD.zip"