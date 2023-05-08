#!/bin/bash
#A script to create, launch, and clean up a truly disposable QubesOS qube for secure browsing.
#Tor browser can be replaced with your browser or template of choice.
#Just check the variables or add your own.
#This script assumes you have a kicksecure TemplateVM
#Inspired by unman: https://github.com/unman/notes/Really_Disposable_Qubes.md
#

set -e

TMP_DIR="/home/user/tmp"
TMPFS_SIZE="5G"
QUBE_NAME="shadow"
NET_VM="sys-whonix"
TEMP="kicksecure-16"
BROWSER="torbrowser"
MEM="1000"

if qvm-check "${QUBE_NAME}" > /dev/null 2>&1; then
        echo "A qube named \"${QUBE_NAME}\" already exists. Exiting."
        exit 1
fi

sudo swapoff -a
mkdir -p "${TMP_DIR}"

sudo mount -t tmpfs -o size="${TMPFS_SIZE}" shadowy "${TMP_DIR}"
qvm-pool add -o revisions_to_keep=1 -o dir_path="${TMP_DIR}" shadowy file
qvm-create "${QUBE_NAME}" -P shadowy -t "${TEMP}" -l red --property netvm="${NET_VM}" --property memory="${MEM}"
qvm-run -a "${QUBE_NAME}" "${BROWSER}"
wait

qvm-kill "${QUBE_NAME}"
qvm-remove -f "${QUBE_NAME}"
qvm-pool rm shadowy
sudo umount shadowy
sudo rm -rf "${TMP_DIR}" \
        /var/log/libvirt/1ibx1/new.log \
        /var/log/libvirt/1ibx1/new.log.old \
        /var/log/qubes/vm-new.log \
        /var/log/qubes/guid.new.log \
        /var/log/qubes/guid.new.log.old \
        /var/log/qubes/qrexec.new.log \
        /var/log/qubes/qubesdb.new.log \
        /var/log/qubesdb.new.log \
        /var/log/guid/new.log \
        /var/log/qrexec.new.log \
        /var/log/pacat.new.log \
        /var/log/xen/console/guest-new.log

notify-send -t 5000 "${QUBE_NAME} qube" "${QUBE_NAME} qube remnants cleared."
