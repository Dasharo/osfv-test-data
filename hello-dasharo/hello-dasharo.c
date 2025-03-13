
#include "efi.h"

#define HELLO_MESSAGE L"UEFI Hello, Dasharo Universe!\r\n"
#define HELLO_INTERVAL 10000000
#define HELLO_COUNT 3

typedef struct {
  EFI_SYSTEM_TABLE  *st;
} Timer_Context;

EFI_EVENT timer_eev;
INT32 hello_count = HELLO_COUNT;

VOID EFIAPI print_hello(
			__attribute__((unused)) IN EFI_EVENT event,
			IN VOID *Context
		 ) {

  Timer_Context context = *(Timer_Context *)Context;

  context.st->ConOut->OutputString(context.st->ConOut,
				   HELLO_MESSAGE);
  hello_count--;
}

EFI_STATUS EFIAPI efi_main (
			    IN EFI_HANDLE        ImageHandle,
			    IN EFI_SYSTEM_TABLE  *SystemTable
			   ) {
  (void)ImageHandle;

  Timer_Context context = { .st = SystemTable };

  SystemTable->BootServices->CloseEvent(timer_eev);

  SystemTable->BootServices->CreateEvent(EVT_TIMER | EVT_NOTIFY_SIGNAL,
					 TPL_CALLBACK,
					 print_hello,
					 (VOID *)&context,
					 &timer_eev);

  SystemTable->BootServices->SetTimer(timer_eev,
				      TimerPeriodic,
				      HELLO_INTERVAL);

  while(hello_count > 0x00) {}

  context.st->BootServices->CloseEvent(timer_eev);
  return EFI_SUCCESS;
}
