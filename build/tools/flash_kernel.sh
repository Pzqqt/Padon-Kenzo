#!/sbin/sh
 #
 # Copyright © 2017, Umang Leekha "umang96" <umangleekha3@gmail.com> 
 #
 # Live ramdisk patching script
 #
 # This software is licensed under the terms of the GNU General Public
 # License version 2, as published by the Free Software Foundation, and
 # may be copied, distributed, and modified under those terms.
 #
 # This program is distributed in the hope that it will be useful,
 # but WITHOUT ANY WARRANTY; without even the implied warranty of
 # MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 # GNU General Public License for more details.
 #
 # Please maintain this if you use this script or any part of it
 #
selinx=$(cat /tmp/aroma/padon.prop | grep -e "sel" | cut -d '=' -f2)
qc=$(cat /tmp/aroma/padon.prop | grep -e "crate" | cut -d '=' -f2)
therm=$(cat /tmp/aroma/padon.prop | grep -e "thermal" | cut -d '=' -f2)
net=$(cat /tmp/aroma/padon.prop | grep -e "netmode" | cut -d '=' -f2)
jk=$(cat /tmp/aroma/padon.prop | grep -e "jack" | cut -d '=' -f2)
ros=$(cat /tmp/aroma/ros.prop | cut -d '=' -f2)
#force permissive
selinx=3
zim=/tmp/Image1
if [ $qc -eq 1 ]; then
dim=/tmp/dt1.img
elif [ $qc -eq 2 ]; then
dim=/tmp/dt2.img
fi
cmd="androidboot.hardware=qcom ehci-hcd.park=3 androidboot.bootdevice=7824900.sdhci lpm_levels.sleep_disabled=1 ramoops_memreserve=4M"
if [ $selinx -eq 2 ]; then
cmd=$cmd" androidboot.selinux=enforcing"
elif [ $selinx -eq 3 ]; then
cmd=$cmd" androidboot.selinux=permissive"
fi
if [ $net -eq 1 ]; then
cmd=$cmd" android.gdxnetlink=old"
elif [ $net -eq 2 ]; then
cmd=$cmd" android.gdxnetlink=los"
fi
if [ $jk -eq 2 ]; then
cmd=$cmd" android.audiojackmode=stock"
fi
if [ $therm -eq 1 ]; then
echo "Using old thermal engine"
cp -rf /tmp/old-thermal/* /system/vendor/
chmod 0755 /system/vendor/bin/thermal-engine
chmod 0644 /system/vendor/lib/libthermalclient.so
chmod 0644 /system/vendor/lib64/libthermalclient.so
chmod 0644 /system/vendor/lib64/libthermalioctl.so
fi
if ! [ -f /system/etc/padon.sh ]; then
cp /tmp/padon.sh /system/etc/padon.sh
fi
rm -rf /system/etc/radon.sh
chmod 644 /system/etc/padon.sh
cp -f /tmp/cpio /sbin/cpio
cd /tmp/
/sbin/busybox dd if=/dev/block/bootdevice/by-name/boot of=./boot.img
./unpackbootimg -i /tmp/boot.img
if [ $(cat /tmp/boot.img-cmdline | grep -c "snd-soc-msm8x16-wcd.dig_core_collapse_enable=0") -ne 0 ];then
# Found Shox Audio Mod cmdline, add it
cmd=$cmd" snd-soc-msm8x16-wcd.dig_core_collapse_enable=0"
fi
mkdir /tmp/ramdisk
cp /tmp/boot.img-ramdisk.gz /tmp/ramdisk/
cd /tmp/ramdisk/
gunzip -c /tmp/ramdisk/boot.img-ramdisk.gz | /tmp/cpio -i
rm /tmp/ramdisk/boot.img-ramdisk.gz
rm /tmp/boot.img-ramdisk.gz
cp /tmp/init.padon.rc /tmp/ramdisk/
# COMPATIBILITY FIXES START
cp /tmp/init.qcom.post_boot.sh /system/etc/init.qcom.post_boot.sh
chmod 644 /system/etc/init.qcom.post_boot.sh
if [ -f /tmp/ramdisk/fstab.qcom ];
then
if ([ "`grep "context=u:object_r:firmware_file:s0" /tmp/ramdisk/fstab.qcom`" ]);
then
rm /tmp/ramdisk/fstab.qcom
cp /tmp/fstab.qcom /tmp/ramdisk/fstab.qcom
else
rm /tmp/ramdisk/fstab.qcom
cp /tmp/fstab.qcom.no-context /tmp/ramdisk/fstab.qcom
fi
chmod 640 /tmp/ramdisk/fstab.qcom
fi
# COMPATIBILITY FIXES END
# CLEAN RAMDISK
rm -rf /tmp/ramdisk/init.darkness.rc
rm -rf /tmp/ramdisk/init.radon.rc
sed -i '/^import \/init\.radon\.rc/d' /tmp/ramdisk/init.rc
sed -i '/^import init\.radon\.rc/d' /tmp/ramdisk/init.qcom.rc
sed -i '/^import init\.padon\.rc/d' /tmp/ramdisk/init.qcom.rc
# CLEAN END
rm -rf /tmp/ramdisk/init.spectrum.rc
rm -rf /tmp/ramdisk/init.spectrum.sh
if [ $ros -eq 2 ]; then
mv /tmp/S_init.spectrum.rc /tmp/ramdisk/init.spectrum.rc
mv /tmp/init.spectrum.sh /tmp/ramdisk/init.spectrum.sh
chmod 0750 /tmp/ramdisk/init.spectrum.rc
chmod 0750 /tmp/ramdisk/init.spectrum.sh
if [ $(grep -c "import /init.spectrum.rc" /tmp/ramdisk/init.rc) == 0 ]; then
    sed -i "/import \/init\.\${ro.hardware}\.rc/aimport /init.spectrum.rc" /tmp/ramdisk/init.rc
fi
else
sed -i '/^import \/init\.spectrum\.rc/d' /tmp/ramdisk/init.rc
fi
chmod 0750 /tmp/ramdisk/init.padon.rc
if [ $(grep -c "import /init.padon.rc" /tmp/ramdisk/init.rc) == 0 ]; then
    sed -i "/import \/init\.\${ro.hardware}\.rc/aimport /init.padon.rc" /tmp/ramdisk/init.rc
fi
find . | cpio -o -H newc | gzip > /tmp/boot.img-ramdisk.gz
rm -r /tmp/ramdisk
cd /tmp/
./mkbootimg --kernel $zim --ramdisk /tmp/boot.img-ramdisk.gz --cmdline "$cmd"  --base 0x80000000 --pagesize 2048 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --dt $dim -o /tmp/newboot.img
/sbin/busybox dd if=/tmp/newboot.img of=/dev/block/bootdevice/by-name/boot
