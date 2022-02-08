# Edge-Core Wedge100BF ONIE recover procedures

## USB recovery for Wedge100BF-32QS

Required material:
*  1 USB stick formated in FAT32 with at least 28 MB of storage capacity
*  1 machine with USB port to dump the ISO image on the USB stick
*  Physical access to the Edge-Core Wedge100BF-32QS switch to recover ONIE on

###  Download ONIE ISO image  
http://fedora-serv.inria.fr/pub/inria/proj/diana/sopnode/edgecore/images/Wedge100BF-32QS-r0_ONIE_v2018_05_00_10.iso 

md5 Wedge100BF-32QS-r0_ONIE_v2018_05_00_10.iso: `4cc1045578f250c3c692a7622d48fb94`

### Burn the ONIE ISO image to the USB-stick
1. Plug the USB stick on the dumping machine
2. Determine the device name of the partition (e.g., `fdisk -l` on Ubuntu 20.04, `diskutil list` on MacOS 11.6.1)
3. Copy the ISO image to the partition
`sudo dd if=Wedge100BF-32QS-r0_ONIE_v2018_05_00_10.iso of=</path/to/the/partition>`
4. Eject the USB stick

### Prepare the switch for installation
1. Plug the USB stick to the Wedge100BF-32QS USB port
2. Reboot the switch and enter the BIOS (hit ESC key during boot)
3. Configure BOOT Override to start with the USB stick partition containing the image
4. Save the setup and reboot

### Install ONIE on the switch
1. Wait for the prompt to appear
2. Select _ONIE: Embed ONIE_
3. The switch reboots after completion
4. DONE
