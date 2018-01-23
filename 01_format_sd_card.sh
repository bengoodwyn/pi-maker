#!/bin/bash -e

SDCARD_DEV="${1}"
DOWNLOAD_URL="http://downloads.raspberrypi.org/raspbian_lite/images/raspbian_lite-2017-12-01/2017-11-29-raspbian-stretch-lite.zip"
EXPECTED_SHA="e942b70072f2e83c446b9de6f202eb8f9692c06e7d92c343361340cc016e0c9f"

if [ 0 -ne $(id -u) ]; then
    echo "You need root"
    exit 1
fi

if [ -z "${SDCARD_DEV}" ]; then
    echo "Usage: ${0} /dev/sdX"
    echo ""
    echo "Devices:"
    lsblk --nodeps -o KNAME,SIZE,MODEL
    exit 1
fi

mkdir -p .cache
pushd .cache &>/dev/null

function cleanup {
    rm -f *.img
    if [ -e boot ]; then
        umount boot
        rm -rf boot
    fi
}
trap cleanup ERR

echo ""
echo "WARNING: Overwriting the following device!"
lsblk --nodeps -o KNAME,SIZE,MODEL ${SDCARD_DEV}
echo ""
echo -n "Are you sure? (y/n)"
read -s -n 1 SURE
echo ""
if [[ "${SURE}" != "y" ]]; then
    exit 1
fi

echo -n "Wifi SSID: "
read SSID

echo -n "Wifi PASSPHRASE: "
read -s PASSPHRASE
echo ""

if [ ! -e raspbian.zip ]; then
    echo "Downloading Raspbian Lite"
    curl -fL "${DOWNLOAD_URL}" -o raspbian.zip
fi

echo "Verifying SHA"
ACTUAL_SHA=$(sha256sum raspbian.zip | awk '{print $1}')
if [ "${ACTUAL_SHA}" != "${EXPECTED_SHA}" ]; then
    echo "ERROR: Actual SHA (${ACTUAL_SHA}) does not match expected SHA (${EXPECTED_SHA})"
    rm -f raspbian.zip
    exit 1
fi

echo "Extracting image"
rm -f *.img
unzip raspbian.zip
mv 2017-11-29-raspbian-stretch-lite.img raspbian.img

echo "Writing image to ${SDCARD_DEV}"
dd if=raspbian.img of=${SDCARD_DEV} bs=1M
sync
rm -f *.img

echo "Mounting ${SDCARD_DEV}"
mkdir -p boot
mount ${SDCARD_DEV}1 boot

echo "Enabling SSH"
touch boot/ssh

echo "Configuring Wifi"
cat <<EOF > boot/wpa_supplicant.conf
country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
network={
    ssid="${SSID}"
    scan_ssid=1
    psk="${PASSPHRASE}"
    key_mgmt=WPA-PSK
}
EOF

echo "Umounting ${SDCARD_DEV}"
sync
umount boot
rmdir boot
sync

echo "Format complete"
popd &>/dev/null
