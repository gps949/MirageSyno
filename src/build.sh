#!/bin/bash
if [ -z ${IS_IN_CONTAINER+x} ]; then
    echo "This script expect to be run inside a docker container" 1>&2
    exit 1
fi

if [ -z ${PACKAGE_ARCH+x} ]; then
    echo "PACKAGE_ARCH is undefined. Please find and set you package arch:" 1>&2
    echo "https://www.synology.com/en-global/knowledgebase/DSM/tutorial/Compatibility_Peripherals/What_kind_of_CPU_does_my_NAS_have" 1>&2
    exit 2
fi

if [ -z ${DSM_VER+x} ]; then
    echo "DSM_VER is undefined. This should a version number like 6.2" 1>&2
    exit 3
fi

# Ensure that we are working directly in the root file system. Though this
# should always be the case in containers.
cd /

# Make the script quit if there are errors
set -e

# Install the toolchain for the given package arch and DSM version
build_env="/build_env/ds.$PACKAGE_ARCH-$DSM_VER"
if [ ! -d "$build_env" ]; then
    pkgscripts-ng/EnvDeploy -p $PACKAGE_ARCH -v $DSM_VER

    # Ensure the installed toolchain has support for CA signed certificates.
    # Without this wget on https:// will fail
    cp /etc/ssl/certs/ca-certificates.crt "$build_env/etc/ssl/certs/"
fi

# Disable quit if errors to allow printing of logfiles
set +e

# Build packages
#   -p              package arch
#   -v              DSM version
#   -S              no signing
#   --build-opt=-J  prevent parallel building (required)
#   --print-log     save build logs
#   -c mirage    project path in /source
pkgscripts-ng/PkgCreate.py \
    -p $PACKAGE_ARCH \
    -v $DSM_VER \
    -S \
    --build-opt=-J \
    --print-log \
    -c mirage

# Save package builder exit code. This allows us to print the logfiles and give
# a non-zero exit code on errors.
pkg_status=$?

echo "Build log"
echo "========="
cat "$build_env/logs.build"
echo

echo "Install log"
echo "==========="
cat "$build_env/logs.install"
echo

exit $pkg_status
