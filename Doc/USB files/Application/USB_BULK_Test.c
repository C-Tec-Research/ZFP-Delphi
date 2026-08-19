/*********************************************************************
*  
*   IAR PowerPac - USB Stack
*
*   (c) Copyright IAR Systems 2008.  All rights reserved.
*
**********************************************************************
----------------------------------------------------------------------
File    : USB_BULK_Test.c
Purpose : Modified echo server to test the stack
--------  END-OF-HEADER  ---------------------------------------------
*/

#include "USB.h"
#include "BSP.h"
#include "RTOS.H"

/*********************************************************************
*
*       Static data
*
**********************************************************************
*/
static OS_STACKPTR int _Stack0[512]; // Task stacks
static OS_TASK         _TCB0;         // Task-control-blocks

static U8 _ac[0x400];

/*********************************************************************
*
*       _AddBULK
*
*  Function description
*    Add generic USB BULK interface to USB stack
*/
static void _AddBULK(void) {
  static U8 _abOutBuffer[USB_MAX_PACKET_SIZE];
  USB_BULK_INIT_DATA    InitData;

  InitData.EPIn  = USB_AddEP(1, USB_TRANSFER_TYPE_BULK, USB_MAX_PACKET_SIZE, NULL, 0);
  InitData.EPOut = USB_AddEP(0, USB_TRANSFER_TYPE_BULK, USB_MAX_PACKET_SIZE, _abOutBuffer, USB_MAX_PACKET_SIZE);
  USB_BULK_Add(&InitData);
}

/*********************************************************************
*
*       public code
*
**********************************************************************
*/

/*********************************************************************
*
*       Get information that are used during enumeration
*/

/*********************************************************************
*
*       USB_GetVendorId
*
*  Function description
*    Returns vendor Id
*/
U16 USB_GetVendorId(void) {
  return 0x8765;
}

/*********************************************************************
*
*       USB_GetProductId
*
*  Function description
*    Returns product Id
*/
U16 USB_GetProductId(void) {
  return 0x1234;
}

/*********************************************************************
*
*       USB_GetVendorName
*
*  Function description
*    Returns vendor name
*/
const char * USB_GetVendorName(void) {
  return "Vendor";
}

/*********************************************************************
*
*       USB_GetProductName
*
*  Function description
*    Returns product name
*/
const char * USB_GetProductName(void) {
  return "Bulk device";
}

/*********************************************************************
*
*       USB_GetSerialNumber
*
*  Function description
*    Returns serial number
*/
const char * USB_GetSerialNumber(void) {
  return "13245678";
}

/*********************************************************************
*
*       MainTask
*
* Function description
*   USB handling task.
*   Modify to implement the desired protocol
*/
void MainTask(void);
void MainTask(void) {
  USB_Init();
  _AddBULK();
  USB_Start();
  while (1) {
    unsigned char c;

    //
    // Wait for configuration
    //
    while ((USB_GetState() & (USB_STAT_CONFIGURED | USB_STAT_SUSPENDED)) != USB_STAT_CONFIGURED) {
      BSP_ToggleLED(0); // Toggle LED to indicate configuration
      USB_OS_Delay(50);
    }
    BSP_ClrLED(0);
    //
    // Loop: Receive data byte by byte, send back (data + 1)
    //
    USB_BULK_Read(&c, 1);
    if (c > 0x10) {
      c++;
      USB_BULK_Write(&c, 1);
    } else {
      int NumBytes = c << 8;
      USB_BULK_Read(&c, 1);
      NumBytes |= c;
      if (NumBytes <= sizeof(_ac)) {
        USB_BULK_Read(_ac, NumBytes);
        USB_BULK_Write(_ac, NumBytes);
      } else {
        int i;
        int NumBytesAtOnce;
        for (i = 0; i < NumBytes; i += NumBytesAtOnce) {
          NumBytesAtOnce = NumBytes - i;
          if (NumBytesAtOnce > sizeof(_ac)) {
            NumBytesAtOnce = sizeof(_ac);
          }
          USB_BULK_Read(_ac, NumBytesAtOnce);
          USB_BULK_Write(_ac, NumBytesAtOnce);
        }
      }
    }
  }
}

/*********************************************************************
*
*       main
*/
void main(void) {
  OS_IncDI();                      /* Initially disable interrupts  */
  OS_InitKern();                   /* Initialize OS                 */
  OS_InitHW();                     /* Initialize Hardware for OS    */
  BSP_Init();                      /* Initialize BSP module         */
  BSP_SetLED(0);
  OS_CREATETASK(&_TCB0, "MainTask", MainTask, 100, _Stack0);
  OS_Start();
}

/**************************** end of file ***************************/
