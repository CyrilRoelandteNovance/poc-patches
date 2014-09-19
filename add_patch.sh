#!/bin/sh

x=$(dirname $0)
x=$(cd $x && pwd)

if [ "$(pwd)" != "$x" ]
then
    echo $(pwd)
    echo $x
    echo "Yeah well, this needs to be run from $x"
    exit 1
fi

if [ $# -ne 2 ]
then
    echo "Usage: $(basename $0) project patch"
    exit 1
fi

# add_patch_to_project PROJECT PATCH
add_patch_to_project() {
    project=$1
    patch=$2

    # Gather the latest version of the code from the deb
    # TODO

    # Set up quilt
    OLD_QUILT_PATCHES=$QUILT_PATCHES
    OLD_QUILT_SERIES=$QUILT_SERIES
    export QUILT_PATCHES=$project/patches
    export QUILT_SERIES=$project/patches/series

    # Apply all current patches
    quilt push -a

    # Import the new patch and try to apply it
    patch_basename=$(basename $patch)
    quilt import -p0 $patch

    quilt push

    if [ "$?" -eq "0" ]
    then
        echo "This patch seems to work, you may commit it with:
git add $QUILT_PATCHES/$patch_basename
git add $QUILT_SERIES
git commit
"
    else
        quilt delete -r $QUILT_PATCHES/$patch_basename
        echo "This patch does not apply, please re-write it."
    fi

    # Let's go back to the original state
    echo "Reverting all patches..."
    quilt pop -a

    # Reset QUILT_* :)
    QUILT_PATCHES=$OLD_QUILT_PATCHES
    QUILT_SERIES=$OLD_QUILT_SERIES
}

add_patch_to_project $1 $2
