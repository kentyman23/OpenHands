#!/bin/bash
set -e

LEVEL=$1
# three levels:
# - base, keyword "sweb.base"
# - env, keyword "sweb.env"
# - instance, keyword "sweb.eval"
SET=$2

if [ -z "$LEVEL" ]; then
    echo "Usage: $0 <cache_level> <set>"
    echo "cache_level: base, env, or instance"
    echo "set: lite, full"
    exit 1
fi

if [ -z "$SET" ]; then
    echo "Usage: $0 <cache_level> <set>"
    echo "cache_level: base, env, or instance"
    echo "set: lite, full, default is lite"
    SET="lite"
fi


if [ "$SET" == "full" ]; then
    IMAGE_FILE="$(dirname "$0")/all-visualswebench-full-instance-images.txt"
else
    IMAGE_FILE="$(dirname "$0")/all-visualswebench-full-instance-images.txt"
fi

# Define a pattern based on the level
case $LEVEL in
    base)
        PATTERN="sweb.base"
        ;;
    env)
        PATTERN="sweb.base\|sweb.env"
        ;;
    instance)
        PATTERN="sweb.base\|sweb.env\|sweb.eval"
        ;;
    *)
        echo "Invalid cache level: $LEVEL"
        echo "Valid levels are: base, env, instance"
        exit 1
        ;;
esac

echo "Pulling docker images for [$LEVEL] level"

echo "Pattern: $PATTERN"
echo "Image file: $IMAGE_FILE"

# Read each line from the file, filter by pattern, and pull the docker image
grep "$PATTERN" "$IMAGE_FILE" | while IFS= read -r image; do
    echo "Pulling $image into $image"
    docker pull $image
    # replace _s_ to __ in the image name
    renamed_image=$(echo "$image" | sed 's|.*/||; s/_s_/__/g')
    docker tag $image $renamed_image
done
