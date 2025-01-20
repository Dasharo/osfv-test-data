# ESP scanning

## qemu-disk.img

* Content: `.efi` files on ESP partition in proper paths, so we can test if
  they are detected by the
  [boot manager](https://github.com/Dasharo/edk2/blob/dasharo/MdeModulePkg/Library/UefiBootManagerLib/BmBoot.c#L2541)

```
└── EFI
    ├── Centos
    │   ├── grubx64.efi
    │   └── shimx64.efi
    ├── debian
    │   ├── grubx64.efi
    │   └── shimx64.efi
    ├── DTS
    │   ├── grubx64.efi
    │   └── shimx64.efi
    ├── Fedora
    │   ├── grubx64.efi
    │   └── shimx64.efi
    ├── Microsoft
    │   └── Boot
    │       └── bootmgfw.efi
    ├── opensuse
    │   ├── grubx64.efi
    │   └── shimx64.efi
    ├── qubes
    │   ├── grubx64.efi
    │   └── shimx64.efi
    ├── Redhat
    │   ├── elilo.efi
    │   ├── grubx64.efi
    │   └── shimx64.efi
    ├── Suse
    │   └── elilo.efi
    └── Ubuntu
        ├── grubx64.efi
        └── shimx64.efi
```

* Building: not documented at the moment
