
#include "efi.h"

#define HELLO_MESSAGE L"UEFI Hello, Dasharo Universe!\r\n"
#define HELLO_INTERVAL_PRE 10000000
#define HELLO_INTERVAL_POST 5000000

EFI_STATUS EFIAPI efi_main (
			    IN EFI_HANDLE        ImageHandle,
			    IN EFI_SYSTEM_TABLE  *SystemTable
			   ) {
  (void)ImageHandle;
  SystemTable->BootServices->Stall(HELLO_INTERVAL_PRE);

  SystemTable->ConOut->OutputString(SystemTable->ConOut,
				   HELLO_MESSAGE);

  // this is for manual (visual) testing
  SystemTable->BootServices->Stall(HELLO_INTERVAL_POST);
  return EFI_SUCCESS;
}
