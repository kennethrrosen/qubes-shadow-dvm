# QubesOS Truly Disposable Qube for Secure Browsing

Inspired by Unman's [Really Disposable Qubes](https://github.com/unman/notes/blob/master/Really_Disposable_Qubes.md) scripts. Run in dom0. The below script will create a Qube, launch the Tor browser, wait for the browser to close, then remove the qube and its RAM pool. The qube is built in a new RAM-based storage pool and disappears once the script deletes the RAM disk.

As Unman notes: 
> None of this is forensically reliable, although it is better than using a standard pool. (Refer to this [issue](https://github.com/QubesOS/qubes-issues/issues/4972), particularly if you are using Xfce, and check the associated issues.) There's an effort to remove most of the log references, although the stupidity of journalctl means that you'll have to wipe the journal if you want to delete references there.

I've provided the script below for easy perusal; also included in the repo for an easy clone. You can also make a simple `dom0` script as well as add to your taskbar. Here's another varient that [sends logs to /dev/null]( https://forum.qubes-os.org/t/really-disposable-ram-based-qubes/21532).

### shadow-qube

```
#!/bin/sh

nohup bash /home/kennethrrosen/shadow_qube.sh >/dev/null 2>&1 &
```


### Bash script

```
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
```
