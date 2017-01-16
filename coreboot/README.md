# Neutralized ME with coreboot stuff

me.bin, descriptor.bin and bios.bin are extracted from OEM rom. This me.bin we provide is neutralized version of Intel ME. You can build the coreboot with it, or [fuck the ME by your own](https://hardenedlinux.github.io/firmware/2016/11/17/neutralize_ME_firmware_on_sandybridge_and_ivybridge.html).

Not all mainboards we've been playing with are supported by Coreboot. Coreboot supported list:

* Gigabyte: GA-B75M-D3H, GA-B75M-D3V
* Lenovo: T420, X220/x220i, x230
* samsung: lumpy (chromebook xe550c22)


Neutralized ME without Coreboot supported:

* ASUS: P10S-M WS
