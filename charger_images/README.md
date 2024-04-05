## Battery Charger Images
This modification allows you to change the images displayed when charging. That's all it does. Here are the instructions on how to use the modification to its full potential.

---

### Installation
* Open the drive on your SD Card where the folders `dtbs` and `modules` reside.
* Make a backup (or rename) of the `ramdisk.img` file. Put it somewhere safe.
* Copy the `ramdisk.img` file and `battery` folder to the drive above.
* Say **yes** to the overwrite dialog of the `ramdisk.img` file.
* Edit the images inside the `battery` folder.
 * These images can be scaled to `640x480` and need to be in the `PNG` format.
 * Use a PNG Compressor/Optimiser to lower the file size if required.

### Removal
* Hoping that you made a backup copy of the `ramdisk.img` file somewhere!
* Copy, and overwrite, the `ramdisk.img` file to the drive mentioned earlier.

---

### Manual Compilation _(expert)_
If you do something bad here, it will render your device unbootable. Restore a backed up copy of the `ramdisk.img` file and all will be good. The `cpio` and `uboot-tools` packages will need to be installed in your Linux distribution for this.

#### Extraction
```
mkdir ~/ramdisk
cd ~/ramdisk
cat /location/of/your/ramdisk.img | cpio -idmv
```

#### Compiling
```
find . | cpio -o -c -R root:root > ../tempdisk
cd ..
mkimage -A arm -O linux -T ramdisk -C none -n RAMFS -a 0X2000000 -e 0X2000000 -d tempdisk ramdisk.img
rm tempdisk
```
