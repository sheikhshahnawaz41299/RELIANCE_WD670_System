### Prerequisite
- [ubireader](https://github.com/onekey-sec/ubi_reader)
- mkfs.ubifs and ubinize (search, how to install it)


### Unpack

unpack system.ubi
```bash
ubireader_extract_images system.ubi -o system_u
cd ./system_u/system.ubi/
```
Now you will get file with .ubifs

We need to modify "img-396211929_vol-rootfs.ubifs"

unpack ubifs
```bash
ubireader_extract_files -k -o ./rootfs img-396211929_vol-rootfs.ubifs
```

### Repack

repack .ubifs 
```bash
mkfs.ubifs -m 4096 -e 253952 -c 261 -x lzo -f 8 -k r5 -p 1 -l 4 -r rootfs/ img-396211929_vol-rootfs.ubifs
```

Repack to img
```bash
ubinize -p 262144 -m 4096 -O 4096 -s 4096 -x 1 -o system_TEST.ubi img-396211929.ini
```
