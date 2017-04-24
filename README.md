# Assembly Bootable Adder
To run this file:  
nasm kernel.asm -f bin -o kernel.bin  
dd status=noxfer conv=notrunc if=kernel.bin of=kernel.flp  
qemu-system-x86_64 -fda kernel.flp  

This is a bootable calculator made in assembly, to boot you will need to first make and image file, which would be the .flp generated with the above commands and then run these other couple:  
sudo umount /dev/sdc<?>  
sudo dd bs=4M if=input.iso of=/dev/sdc<?>  
where  input.iso is the input file, and /dev/sdc<?> is the USB device you're writing to.


