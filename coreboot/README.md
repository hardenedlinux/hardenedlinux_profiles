# Neutralized ME with coreboot stuff

me.bin, descriptor.bin and bios.bin are extracted from OEM rom. This me.bin we provide is neutralized version of Intel ME. You can build the coreboot with it, or [fuck the ME by your own](https://hardenedlinux.github.io/firmware/2016/11/17/neutralize_ME_firmware_on_sandybridge_and_ivybridge.html).

Not all mainboards we've been playing with are supported by Coreboot. Make sure you got the right one:

| Mainboard            | CPU               | Tested BIOS   |
|----------------------|-------------------|---------------|
| GA-B75M-D3H          | SandyBridge       | OEM/Coreboot  |
| GA-B75M-D3V          | IvyBridge         | OEM/Coreboot  |
| Lenovo T420          | IvyBridge         | OEM/Coreboot  |
| Lenovo X220/X220i    | SandyBridge       | OEM/Coreboot  |
| Lenovo X230          | IvyBridge         | OEM/Coreboot  |
| Chromebook XE550C22  | IvyBridge         | OEM/Coreboot  |
| ASUS P10S-M WS       | Skylake           | OEM           |

