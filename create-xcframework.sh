#!/bin/sh

PurpleColor='\033[0;35m'
NoColor='\033[0m'
UnderlineGreen='\033[4;32m'
usage() { echo "Usage: $0 [-s <schemeName>] [-p <projectName>] [-w <workspaceName>] [-k]\nSet either <projectName> or <workspaceName>\n-k => Keep build folder\n${UnderlineGreen}E.g;${PurpleColor} ./create-xcframework.sh -s PMPageControl -w PMPageControl.xcworkspace -k${NoColor}" 1>&2; exit 1; }

SCHEME_NAME=''
PROJECT_ARG=''
KEEP_ARCHIVE=false
while getopts ":s:p:w:k" o; do
    case "${o}" in
        s)
            SCHEME_NAME=${OPTARG}
            ;;
        p)
            PROJECT_ARG="-project ${OPTARG}"
            ;;
        w)
            PROJECT_ARG="-workspace ${OPTARG}"
            ;;
        k)
            KEEP_ARCHIVE=true
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [ -z "${SCHEME_NAME}" ] || [ -z "${PROJECT_ARG}" ]; then
    usage
fi

PROJECT_DIR=$PWD
ARCHIVE_PATH="${PROJECT_DIR}/Build"
SIMULATOR_BUILD_PATH="${ARCHIVE_PATH}/${SCHEME_NAME}-simulator.xcarchive"
DEVICE_BUILD_PATH="${ARCHIVE_PATH}/${SCHEME_NAME}-device.xcarchive"
OUPUT_DIR="${PROJECT_DIR}/Product"

# Remove prev ver if needed
rm -rf "${SIMULATOR_BUILD_PATH}"
rm -rf "${DEVICE_BUILD_PATH}"
rm -rf "${OUPUT_DIR}/${SCHEME_NAME}.xcframework"

# Build for simulator
xcodebuild archive -scheme ${SCHEME_NAME} ${PROJECT_ARG} -destination="generic/platform=iOS Simulator" -archivePath "${SIMULATOR_BUILD_PATH}" -sdk iphonesimulator SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES
# Build for device
xcodebuild archive -scheme ${SCHEME_NAME} ${PROJECT_ARG} -destination="generic/platform=iOS" -archivePath "${DEVICE_BUILD_PATH}" -sdk iphoneos SKIP_INSTALL=NO BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

if [ ! -d "$OUPUT_DIR" ]; then
    mkdir "${OUPUT_DIR}"
else
    echo "${OUPUT_DIR} already created."
fi
xcodebuild  -create-xcframework \
            -archive "${SIMULATOR_BUILD_PATH}" -framework ${SCHEME_NAME}.framework \
			-archive "${DEVICE_BUILD_PATH}" -framework ${SCHEME_NAME}.framework \
            -output ${OUPUT_DIR}/${SCHEME_NAME}.xcframework
echo "${PurpleColor}xcframework created at ${OUPUT_DIR}/${SCHEME_NAME}.xcframework${NoColor}"

# Cleanup build folder
if [ $KEEP_ARCHIVE = false ]; then
    rm -rf "${ARCHIVE_PATH}"
fi
open "${OUPUT_DIR}"
