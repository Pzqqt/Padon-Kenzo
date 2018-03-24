#!/sbin/sh

rm -rf /tmp/init.padon.rc
CONFIGFILE="/tmp/init.padon.rc"
PROFILE=$(cat /tmp/aroma/profile.prop | cut -d '=' -f2)
CMODE=$(cat /tmp/aroma/padon.prop | grep -e "cmode" | cut -d '=' -f2)
if [ $PROFILE == 1 ]; then
TLS="50 1017600:60 1190400:70 1305600:80 1382400:90 1401600:95"
TLB="85 1382400:90 1747200:95"
BOOST="0:1305600 4:1113600"
HSFS=1440000
HSFB=1382400
FMS=691200
FMB=883200
FMAS=1440000
FMAB=1843200
TR=20000
AID=N
ABST=0
TBST=1
GHLS=100
GHLB=90
SWAP=30
VFS=100
GLVL=6
GFREQ=266666667
elif [ $PROFILE == 2 ]; then
TLS="75 1017600:85 1190400:95"
TLB="90 1305600:95"
BOOST="0"
HSFS=1305600
HSFB=1612600
FMS=691200
FMB=883200
FMAS=1305600
FMAB=1612600
TR=40000
AID=Y
ABST=0
TBST=0
GHLS=100
GHLB=100
SWAP=20
VFS=40
GLVL=7
GFREQ=200000000
elif [ $PROFILE == 3 ]; then
TLS="40 1017600:50 1190400:60 1305600:70 1382400:80 1401600:90"
TLB="75 1382400:80 1747200:85"
BOOST="0:1305600 4:1305600"
HSFS=1440000
HSFB=1382400
FMS=691200
FMB=883200
FMAS=1440000
FMAB=1843200
TR=20000
AID=N
ABST=1
TBST=1
GHLS=95
GHLB=80
SWAP=40
VFS=100
GLVL=6
GFREQ=266666667
fi
DT2W=$(cat /tmp/aroma/padon.prop | grep -e "d2w" | cut -d '=' -f2)
if [ $DT2W == 1 ]; then
DTP=1
VIBS=50
elif [ $DT2W == 2 ]; then
DTP=1
VIBS=0
elif [ $DT2W == 3 ]; then
DTP=0
VIBS=50
fi
DFSC=$(cat /tmp/aroma/padon.prop | grep -e "fsync" | cut -d '=' -f2)
if [ $DFSC == 1 ]; then
DFS=1
elif [ $DFSC == 2 ]; then
DFS=0
fi
FC=$(cat /tmp/aroma/padon.prop | grep -e "usbfc" | cut -d '=' -f2)
if [ $FC = 1 ]; then
USB=1
elif [ $FC = 0 ]; then
USB=0
fi
echo "# VARIABLES FOR SH" >> $CONFIGFILE
echo "# zrammode=$PROFILE" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# USER TWEAKS" >> $CONFIGFILE
echo "service usertweaks /system/bin/sh /system/etc/padon.sh" >> $CONFIGFILE
echo "class main" >> $CONFIGFILE
echo "group root" >> $CONFIGFILE
echo "user root" >> $CONFIGFILE
echo "oneshot" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "on property:dev.bootcomplete=1" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# SWAPPINESS AND VFS CACHE PRESSURE" >> $CONFIGFILE
echo "write /proc/sys/vm/swappiness $SWAP" >> $CONFIGFILE
echo "write /proc/sys/vm/vfs_cache_pressure $VFS" >> $CONFIGFILE
if ! [ $DT2W == 4 ]; then
echo "" >> $CONFIGFILE
echo "# DT2W" >> $CONFIGFILE
echo "write /sys/android_touch/doubletap2wake " $DTP >> $CONFIGFILE
echo "write /sys/android_touch/vib_strength " $VIBS >> $CONFIGFILE
fi
echo "" >> $CONFIGFILE
COLOR=$(cat /tmp/aroma/padon.prop | grep -e "color" | cut -d '=' -f2)
echo "# KCAL" >> $CONFIGFILE
if [ $COLOR == 1 ]; then
echo "write /sys/devices/platform/kcal_ctrl.0/kcal_sat 269" >> $CONFIGFILE
echo "write /sys/devices/platform/kcal_ctrl.0/kcal_val 256" >> $CONFIGFILE
echo "write /sys/devices/platform/kcal_ctrl.0/kcal_cont 256" >> $CONFIGFILE
echo "write /sys/devices/platform/kcal_ctrl.0/kcal \"254 252 230"\" >> $CONFIGFILE
elif [ $COLOR == 2 ]; then
echo "write /sys/devices/platform/kcal_ctrl.0/kcal_sat 269" >> $CONFIGFILE
echo "write /sys/devices/platform/kcal_ctrl.0/kcal_val 256" >> $CONFIGFILE
echo "write /sys/devices/platform/kcal_ctrl.0/kcal_cont 256" >> $CONFIGFILE
echo "write /sys/devices/platform/kcal_ctrl.0/kcal \"254 254 240"\" >> $CONFIGFILE
elif [ $COLOR == 3 ]; then
echo "write /sys/devices/platform/kcal_ctrl.0/kcal_sat 270" >> $CONFIGFILE
echo "write /sys/devices/platform/kcal_ctrl.0/kcal_val 257" >> $CONFIGFILE
echo "write /sys/devices/platform/kcal_ctrl.0/kcal_cont 265" >> $CONFIGFILE
echo "write /sys/devices/platform/kcal_ctrl.0/kcal \"256 256 256"\" >> $CONFIGFILE
elif [ $COLOR == 4 ]; then
echo "write /sys/devices/platform/kcal_ctrl.0/kcal_sat 255" >> $CONFIGFILE
echo "write /sys/devices/platform/kcal_ctrl.0/kcal_val 255" >> $CONFIGFILE
echo "write /sys/devices/platform/kcal_ctrl.0/kcal_cont 255" >> $CONFIGFILE
echo "write /sys/devices/platform/kcal_ctrl.0/kcal \"256 256 256"\" >> $CONFIGFILE
fi
echo "" >> $CONFIGFILE
echo "# CHARGING RATE" >> $CONFIGFILE
CRATE=$(cat /tmp/aroma/padon.prop | grep -e "crate" | cut -d '=' -f2)
if [ $CRATE == 1 ]; then
CHG=2000
elif [ $CRATE == 2 ]; then
CHG=2400
fi 
echo "chmod 666 /sys/module/qpnp_smbcharger/parameters/default_dcp_icl_ma" >> $CONFIGFILE
echo "chmod 666 /sys/module/qpnp_smbcharger/parameters/default_hvdcp_icl_ma" >> $CONFIGFILE
echo "chmod 666 /sys/module/qpnp_smbcharger/parameters/default_hvdcp3_icl_ma" >> $CONFIGFILE
echo "write /sys/module/qpnp_smbcharger/parameters/default_dcp_icl_ma $CHG" >> $CONFIGFILE
echo "write /sys/module/qpnp_smbcharger/parameters/default_hvdcp_icl_ma $CHG" >> $CONFIGFILE
echo "write /sys/module/qpnp_smbcharger/parameters/default_hvdcp3_icl_ma $CHG" >> $CONFIGFILE
echo "write /sys/kernel/fast_charge/force_fast_charge $USB" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# DISABLE BCL & CORE CTL" >> $CONFIGFILE
echo "write /sys/module/msm_thermal/core_control/enabled 0" >> $CONFIGFILE
echo "write /sys/devices/soc.0/qcom,bcl.56/mode disable" >> $CONFIGFILE
echo "write /sys/devices/soc.0/qcom,bcl.56/hotplug_mask 0" >> $CONFIGFILE
echo "write /sys/devices/soc.0/qcom,bcl.56/hotplug_soc_mask 0" >> $CONFIGFILE
echo "write /sys/devices/soc.0/qcom,bcl.56/mode disable" >> $CONFIGFILE
echo "chmod 0644 /sys/module/msm_thermal/vdd_restriction/enable" >> $CONFIGFILE
echo "write /sys/module/msm_thermal/vdd_restriction/enable 0" >> $CONFIGFILE
echo "chmod 0444 /sys/module/msm_thermal/vdd_restriction/enable" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# BRING CORES ONLINE" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu0/online 1" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu1/online 1" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu2/online 1" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu3/online 1" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu4/online 1" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu5/online 1" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# TWEAK A53 CLUSTER GOVERNOR" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu0/online 1" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor \"interactive\"" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu0/cpufreq/interactive/above_hispeed_delay 0" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu0/cpufreq/interactive/go_hispeed_load $GHLS" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu0/cpufreq/interactive/timer_rate $TR" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu0/cpufreq/interactive/hispeed_freq $HSFS" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu0/cpufreq/interactive/io_is_busy 0" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu0/cpufreq/interactive/target_loads \"$TLS\"" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu0/cpufreq/interactive/min_sample_time 40000" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq $FMS" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq $FMAS" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# TWEAK A72 CLUSTER GOVERNOR" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu4/online 1" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor \"interactive\"" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu4/cpufreq/interactive/above_hispeed_delay \"19000 1382400:39000\"" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu4/cpufreq/interactive/go_hispeed_load $GHLB" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu4/cpufreq/interactive/timer_rate $TR" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu4/cpufreq/interactive/hispeed_freq $HSFB" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu4/cpufreq/interactive/io_is_busy 0" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu4/cpufreq/interactive/target_loads \"$TLB\"" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu4/cpufreq/interactive/min_sample_time 40000" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu4/cpufreq/scaling_min_freq $FMB" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq $FMAB" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# GPU SETTINGS" >> $CONFIGFILE
echo "write /sys/devices/soc.0/1c00000.qcom,kgsl-3d0/kgsl/kgsl-3d0/default_pwrlevel $GLVL" >> $CONFIGFILE
echo "write /sys/devices/soc.0/1c00000.qcom,kgsl-3d0/kgsl/kgsl-3d0/min_pwrlevel $GLVL" >> $CONFIGFILE
echo "write /sys/devices/soc.0/1c00000.qcom,kgsl-3d0/kgsl/kgsl-3d0/devfreq/min_freq $GFREQ" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# CPU BOOST PARAMETERS" >> $CONFIGFILE
echo "write /sys/module/cpu_boost/parameters/input_boost_freq \"$BOOST\"" >> $CONFIGFILE
echo "write /sys/module/cpu_boost/parameters/input_boost_ms 40" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# SET IO SCHEDULER" >> $CONFIGFILE
if [ $PROFILE == 1 ]; then
echo "setprop sys.io.scheduler \"maple\"" >> $CONFIGFILE
else
echo "setprop sys.io.scheduler \"fiops\"" >> $CONFIGFILE
fi
echo "write /sys/block/mmcblk0/queue/read_ahead_kb 512" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# TOUCH BOOST" >> $CONFIGFILE
echo "write /sys/module/msm_performance/parameters/touchboost $TBST" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# ADRENO IDLER" >> $CONFIGFILE
echo "write /sys/module/adreno_idler/parameters/adreno_idler_active $AID" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# ADRENO BOOST" >> $CONFIGFILE
echo "write /sys/class/kgsl/kgsl-3d0/devfreq/adrenoboost $ABST" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# FSYNC" >> $CONFIGFILE
echo "write /sys/module/sync/parameters/fsync_enabled $DFS" >> $CONFIGFILE
echo "" >> $CONFIGFILE
echo "# CORE MODE" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu4/core_ctl/min_cpus 0" >> $CONFIGFILE
if [ $CMODE == 1 ]; then
echo "write /sys/devices/system/cpu/cpu4/core_ctl/max_cpus 0" >> $CONFIGFILE
elif [ $CMODE == 2 ]; then
echo "write /sys/devices/system/cpu/cpu4/core_ctl/max_cpus 2" >> $CONFIGFILE
fi
echo "" >> $CONFIGFILE
VOLT=$(cat /tmp/aroma/padon.prop | grep -e "uv" | cut -d '=' -f2)
echo "# CPU & GPU UV" >> $CONFIGFILE
echo "write /sys/devices/system/cpu/cpu0/cpufreq/GPU_mV_table \"700 720 760 800 860 900 920 980 1020\"" >> $CONFIGFILE
if [ $VOLT == 1 ]; then
echo "write /sys/devices/system/cpu/cpu0/cpufreq/UV_mV_table \"740 760 820 920 980 1020 1050 1060 1070 780 800 870 910 970 1020 1040\"" >> $CONFIGFILE
elif [ $VOLT == 2 ]; then
echo "write /sys/devices/system/cpu/cpu0/cpufreq/UV_mV_table \"720 740 800 900 960 1000 1030 1040 1050 760 780 850 890 950 1000 1020 1020\"" >> $CONFIGFILE
fi
echo "" >> $CONFIGFILE
echo "# RUN USERTWEAKS SERVICE" >> $CONFIGFILE
echo "start usertweaks" >> $CONFIGFILE
