#!/bin/bash
pushd build > /dev/null

export MTOOLSRC=niwohlos.cfg
export PATH_WAS=$PATH
export PATH=$PATH:/usr/local/sbin:/usr/sbin:/sbin

mkdir -p root/boot/grub

cat << EOF > $MTOOLSRC
drive x:
  file="images/floppy.img" cylinders=80 heads=2 sectors=18 filter
EOF

echo 'DD      /dev/zero -> floppy.img'
dd if=/dev/zero of=images/floppy.img bs=512 count=2880 &> /dev/null

echo 'CP      kernel -> root/'
cp ../src/kernel/kernel root
strip -s root/kernel
gzip -9 root/kernel
mv root/kernel{.gz,}
cp scripts/i386-default-menu.lst root/boot/grub/menu.lst
cp scripts/i386-default-stage1 root/boot/grub/stage1
cp scripts/i386-default-stage2 root/boot/grub/stage2

echo 'MFMT    floppy.img'
mformat -l NIWOHLOS x: > /dev/null
echo 'CP      root/* -> floppy.img/'
mcopy -s root/* x:/ > /dev/null
echo 'GRUB    floppy.img'
echo -e 'device (fd0) images/floppy.img\nroot (fd0)\nsetup (fd0)\nquit' | grub --batch &> /dev/null

rm -rf root $MTOOLSRC

export PATH=$PATH_WAS

popd > /dev/null
