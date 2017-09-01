# Neutralized ME with coreboot stuff

me.bin, descriptor.bin and bios.bin are extracted from OEM rom. This me.bin we provide is neutralized version of Intel ME. You can build the coreboot with it, or [fuck the ME by your own](https://hardenedlinux.github.io/firmware/2016/11/17/neutralize_ME_firmware_on_sandybridge_and_ivybridge.html).

Not all mainboards we've been playing with are supported by Coreboot. Make sure you got the right one:

| Mainboard            | CPU               | Tested BIOS   | HAP      |
|:--------------------:|:-----------------:|:-------------:|:--------:|
| GA-B75M-D3H          | SandyBridge       | OEM/Coreboot  | N/A      |
| GA-B75M-D3V          | IvyBridge         | OEM/Coreboot  | N/A      |
| Lenovo T420          | IvyBridge         | OEM/Coreboot  | N/A      |
| Lenovo X220/X220i    | SandyBridge       | OEM/Coreboot  | N/A      |
| Lenovo X230          | IvyBridge         | OEM/Coreboot  | N/A      |
| Chromebook XE550C22  | IvyBridge         | OEM/Coreboot  | N/A      |
| ASUS P10S-M WS       | Skylake           | OEM           | Partial  |

HAP is an undocumented kill switch in Intel ME being [disclosured by Mark Ermolov and Maxim Goryachy](http://blog.ptsecurity.com/2017/08/disabling-intel-me.html)( [Russian version](https://habrahabr.ru/company/pt/blog/336242/)) recently. [me_cleaner](https://github.com/corna/me_cleaner) added the support to [enable HAP bit](https://github.com/corna/me_cleaner/commit/ced3b46ba2ccd74602b892f9594763ef34671652). We will test enable HAP w/o removing ME code modules and you can find the result above.

* Full, mean it's fully work w/o any side effects
* Partial, mean it's only partially work with some side effects, e.g: some private OEM firmware implementation( more shitty SMIs?) might cause the machine boot slower or can't shutdown properly.
* NONE, mean it doesn't work at all

* [Info about ME](https://github.com/hardenedlinux/firmware-anatomy/blob/master/hack_ME/me_info.md)
* [Info about firmware security](https://github.com/hardenedlinux/firmware-anatomy/blob/master/hack_ME/firmware_security.md)
