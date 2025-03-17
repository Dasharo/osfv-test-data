
#include <stdint.h>
#include <uchar.h>

#define IN
#define OUT
#define OPTIONAL
#define CONST const

#define EFIAPI __attribute__((ms_abi))

#define FALSE 0
#define TRUE 1
typedef uint8_t  BOOLEAN;
typedef int64_t  INTN;
typedef uint64_t UINTN;
typedef int8_t   INT8;
typedef uint8_t  UINT8;
typedef int16_t  INT16;
typedef uint16_t UINT16;
typedef int32_t  INT32;
typedef uint32_t UINT32;
typedef int64_t  INT64;
typedef uint64_t UINT64;
typedef char     CHAR8;

#ifndef _UCHAR_H
    typedef uint_least16_t char16_t;
#endif
typedef char16_t CHAR16;

typedef void VOID;

typedef UINTN EFI_STATUS;
typedef VOID *EFI_HANDLE;
typedef VOID *EFI_EVENT;
typedef UINTN EFI_TPL;

#define EFI_SUCCESS 0ULL

/*** PROTOCOLS ***/

typedef struct EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL;

typedef EFI_STATUS (EFIAPI *EFI_TEXT_RESET) (
    IN EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *This,
    IN BOOLEAN                         ExtendedVerification
);

typedef EFI_STATUS (EFIAPI *EFI_TEXT_STRING) (
    IN EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *This,
    IN CHAR16                          *String
);

typedef struct EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL {
    EFI_TEXT_RESET               Reset;
    EFI_TEXT_STRING              OutputString;
} EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL;

// ---

typedef struct EFI_SIMPLE_TEXT_INPUT_PROTOCOL EFI_SIMPLE_TEXT_INPUT_PROTOCOL;

typedef EFI_STATUS (EFIAPI *EFI_INPUT_RESET) (
    IN EFI_SIMPLE_TEXT_INPUT_PROTOCOL *This,
    IN BOOLEAN                        ExtendedVerification
);

typedef struct {
    UINT16 ScanCode;
    CHAR16 UnicodeChar;
} EFI_INPUT_KEY;

typedef EFI_STATUS (EFIAPI *EFI_INPUT_READ_KEY) (
    IN EFI_SIMPLE_TEXT_INPUT_PROTOCOL *This,
    OUT EFI_INPUT_KEY                 *Key
);

// ---

typedef EFI_STATUS (EFIAPI *EFI_FREE_POOL) (
    IN VOID *Buffer
);

// ---

typedef VOID (EFIAPI *EFI_EVENT_NOTIFY) (
    IN EFI_EVENT Event,
    IN VOID      *Context
);

typedef EFI_STATUS (EFIAPI *EFI_CREATE_EVENT) (
    IN UINT32           Type,
    IN EFI_TPL          NotifyTpl,
    IN EFI_EVENT_NOTIFY NotifyFunction OPTIONAL,
    IN VOID             *NotifyContext OPTIONAL,
    OUT EFI_EVENT       *Event
);

#define TPL_APPLICATION 0x04
#define TPL_CALLBACK    0x08
#define TPL_NOTIFY      0x10
#define TPL_HIGH_LEVEL  0x1f

#define EVT_TIMER                         0x80000000
#define EVT_RUNTIME                       0x40000000
#define EVT_NOTIFY_WAIT                   0x00000100
#define EVT_NOTIFY_SIGNAL                 0x00000200
#define EVT_SIGNAL_EXIT_BOOT_SERVICES     0x00000201
#define EVT_SIGNAL_VIRTUAL_ADDRESS_CHANGE 0x60000202

typedef enum {
    TimerCancel,
    TimerPeriodic,
    TimerRelative
} EFI_TIMER_DELAY;

typedef EFI_STATUS (EFIAPI *EFI_SET_TIMER) (
    IN EFI_EVENT       Event,
    IN EFI_TIMER_DELAY Type,
    IN UINT64          TriggerTime
);

typedef EFI_STATUS (EFIAPI *EFI_CLOSE_EVENT) (
    IN EFI_EVENT Event
);

typedef EFI_STATUS (EFIAPI *EFI_WAIT_FOR_EVENT) (
    IN UINTN     NumberOfEvents,
    IN EFI_EVENT *Event,
    OUT UINTN    *Index
);

// ---

typedef
EFI_STATUS
(EFIAPI *EFI_EXIT_BOOT_SERVICES) (
    IN EFI_HANDLE ImageHandle,
    IN UINTN      MapKey
);

typedef EFI_STATUS
(EFIAPI * 	EFI_STALL) (
    IN UINTN Microseconds
);

/*** END OF PROTOCOLS ***/

typedef struct {
    UINT64 Signature;
    UINT32 Revision;
    UINT32 HeaderSize;
    UINT32 CRC32;
    UINT32 Reserved;
} EFI_TABLE_HEADER;

typedef struct {
    EFI_TABLE_HEADER Hdr;
} EFI_RUNTIME_SERVICES;

typedef struct {
    EFI_TABLE_HEADER Hdr;

    void* RaiseTPL;
    void* RestoreTPL;

    void*         AllocatePages;
    void*         FreePages;
    void*         GetMemoryMap;
    void*         AllocatePool;
    EFI_FREE_POOL FreePool;

    EFI_CREATE_EVENT   CreateEvent;
    EFI_SET_TIMER      SetTimer;
    EFI_WAIT_FOR_EVENT WaitForEvent;
    void*              SignalEvent;
    EFI_CLOSE_EVENT    CloseEvent;
    void*              CheckEvent;

    void* InstallProtocolInterface;
    void* ReinstallProtocolInterface;
    void* UninstallProtocolInterface;
    void* HandleProtocol;
    VOID* Reserved;
    void* RegisterProtocolNotify;
    void* LocateHandle;
    void* LocateDevicePath;
    void* InstallConfigurationTable;

    void*                  LoadImage;
    void*                  StartImage;
    void*                  Exit;
    void*                  UnloadImage;
    EFI_EXIT_BOOT_SERVICES ExitBootServices;

    void*                  GetNextMonotonicCount;
    EFI_STALL              Stall;
} EFI_BOOT_SERVICES;

typedef struct {
    EFI_TABLE_HEADER                Hdr;
    CHAR16                          *FirmwareVendor;
    UINT32                          FirmwareRevision;
    EFI_HANDLE                      ConsoleInHandle;
    EFI_SIMPLE_TEXT_INPUT_PROTOCOL  *ConIn;
    EFI_HANDLE                      ConsoleOutHandle;
    EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *ConOut;
    EFI_HANDLE                      StandardErrorHandle;
    EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL *StdErr;
    EFI_RUNTIME_SERVICES            *RuntimeServices;
    EFI_BOOT_SERVICES               *BootServices;
    void                            *ConfigurationTable;
} EFI_SYSTEM_TABLE;

typedef EFI_STATUS (EFIAPI *EFI_IMAGE_ENTRY_POINT) (
    IN EFI_HANDLE       ImageHandle,
    IN EFI_SYSTEM_TABLE *SystemTable
);
