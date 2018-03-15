#!/sbin/sh

toolbox_mount() {
  RW=rw
  if [ ! -z "$2" ]; then
    RW=$2
  fi

  DEV=
  POINT=
  FS=
  for i in `cat /etc/fstab | grep "$1"`; do
    if [ -z "$DEV" ]; then
      DEV=$i
    elif [ -z "$POINT" ]; then
      POINT=$i
    elif [ -z "$FS" ]; then
      FS=$i
      break
    fi
  done
  if (! is_mounted $1 $RW); then mount -t $FS -o $RW $DEV $POINT; fi
  if (! is_mounted $1 $RW); then mount -t $FS -o $RW,remount $DEV $POINT; fi

  DEV=
  POINT=
  FS=
  for i in `cat /etc/recovery.fstab | grep "$1"`; do
    if [ -z "$POINT" ]; then
      POINT=$i
    elif [ -z "$FS" ]; then
      FS=$i
    elif [ -z "$DEV" ]; then
      DEV=$i
      break
    fi
  done
  if [ "$FS" = "emmc" ]; then
    if (! is_mounted $1 $RW); then mount -t ext4 -o $RW $DEV $POINT; fi
    if (! is_mounted $1 $RW); then mount -t ext4 -o $RW,remount $DEV $POINT; fi
    if (! is_mounted $1 $RW); then mount -t f2fs -o $RW $DEV $POINT; fi
    if (! is_mounted $1 $RW); then mount -t f2fs -o $RW,remount $DEV $POINT; fi
  else
    if (! is_mounted $1 $RW); then mount -t $FS -o $RW $DEV $POINT; fi
    if (! is_mounted $1 $RW); then mount -t $FS -o $RW,remount $DEV $POINT; fi
  fi
}

toolbox_mount /system
[ -f /system/build.prop ]
