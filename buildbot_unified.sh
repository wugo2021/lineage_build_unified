#!/bin/bash
#
PATH="${HOME}/.bin:${PATH}"
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/.bin/repo
chmod a+rx ~/.bin/repo
#
echo ""
echo "LineageOS 18.x Unified Buildbot - Iceows version"
echo "Executing in 5 seconds - CTRL-C to exit"
echo ""
sleep 5

if [ $# -lt 2 ]
then
    echo "Not enough arguments - exiting"
    echo ""
    exit 1
fi

MODE=${1}
if [ ${MODE} != "device" ] && [ ${MODE} != "treble" ]
then
    echo "Invalid mode - exiting"
    echo ""
    exit 1
fi

NOSYNC=false
PERSONAL=false
ICEOWS=false
for var in "${@:2}"
do
    if [ ${var} == "nosync" ]
    then
        NOSYNC=true
    fi
    if [ ${var} == "personal" ]
    then
        PERSONAL=true
    fi
    if [ ${var} == "iceows" ]
    then
        ICEOWS=true
    fi    
done

echo "Building with NoSync : $NOSYNC - Personal patch : $PERSONAL - Iceows patch : $ICEOWS - Mode : ${MODE}"



# Abort early on error
set -eE
trap '(\
echo;\
echo \!\!\! An error happened during script execution;\
echo \!\!\! Please check console output for bad sync,;\
echo \!\!\! failed patch application, etc.;\
echo\
)' ERR

START=`date +%s`
BUILD_DATE="$(date +%Y%m%d)"
WITHOUT_CHECK_API=true
WITH_SU=true

prep_build() {
	echo "Preparing local manifests"
	mkdir -p .repo/local_manifests
	cp ./lineage_build_unified/local_manifests_${MODE}/*.xml .repo/local_manifests
	echo ""

	echo "Syncing repos"
	repo sync -c --force-sync --no-clone-bundle --no-tags -j$(nproc --all)
	echo ""

	echo "Setting up build environment"
	source build/envsetup.sh &> /dev/null
	mkdir -p ~/build-output
	echo ""
}

apply_patches() {
    echo "Applying patch group ${1}"
    bash ./lineage_build_unified/apply_patches.sh ./lineage_patches_unified/${1}
}

prep_device() {
    :
}

prep_treble() {
    echo "Applying patch treble prerequisite and phh"
    apply_patches patches_treble_prerequisite
    apply_patches patches_treble_phh
}

finalize_device() {
    :
}

finalize_treble() {
    rm -f device/*/sepolicy/common/private/genfs_contexts
    cd device/phh/treble
    git clean -fdx
    bash generate.sh lineage
    cd ../../..
}

build_device() {
    if [ ${1} == "arm64" ]
    then
        lunch lineage_arm64-userdebug
        make -j$(nproc --all) systemimage
        mv $OUT/system.img ~/build-output/lineage-18.1-$BUILD_DATE-UNOFFICIAL-arm64$(${PERSONAL} && echo "-personal" || echo "").img
    else
        brunch ${1}
        mv $OUT/lineage-*.zip ~/build-output/lineage-18.1-$BUILD_DATE-UNOFFICIAL-${1}$($PERSONAL && echo "-personal" || echo "").zip
    fi
}

build_treble() {
    case "${1}" in
        ("32B") TARGET=treble_arm_bvS;;
        ("32BZ") TARGET=treble_arm_bvZ;;
        ("32BN") TARGET=treble_arm_bvN;;
        ("A64B") TARGET=treble_a64_bvS;;
        ("A64BZ") TARGET=treble_a64_bvZ;;
        ("A64BN") TARGET=treble_a64_bvN;;
        ("64B") TARGET=treble_arm64_bvS;;
        ("64BZ") TARGET=treble_arm64_bvZ;;
        ("64BN") TARGET=treble_arm64_bvN;;
        (*) echo "Invalid target - exiting"; exit 1;;
    esac
    lunch lineage_${TARGET}-userdebug
    make installclean
    make -j$(nproc --all) systemimage
    make vndk-test-sepolicy
    mv $OUT/system.img ~/build-output/lineage-18.1-$BUILD_DATE-UNOFFICIAL-${TARGET}$(${PERSONAL} && echo "-personal" || echo "").img
}

if ${NOSYNC}
then
    echo "ATTENTION: syncing/patching skipped!"
    echo ""
    echo "Setting up build environment"
    source build/envsetup.sh &> /dev/null
    echo ""
else
    prep_build
    echo "Applying patches"
    prep_${MODE}
    apply_patches patches_platform
    apply_patches patches_${MODE}
    if ${PERSONAL}
    then
        apply_patches patches_platform_personal
        apply_patches patches_${MODE}_personal
    fi
    if ${ICEOWS}
    then
        apply_patches patches_platform_iceows
        apply_patches patches_${MODE}_iceows
    fi
    
    finalize_${MODE}
    echo ""
fi

for var in "${@:2}"
do
    if [ ${var} == "nosync" ] || [ ${var} == "personal" ]  || [ ${var} == "iceows" ]
    then
        continue
    fi
    echo "Starting $(${PERSONAL} && echo "personal " || echo "")build for ${MODE} ${var}"
    build_${MODE} ${var}
done
ls ~/build-output | grep 'lineage' || true

END=`date +%s`
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))
echo "Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo ""
