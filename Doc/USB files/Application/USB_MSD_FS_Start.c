/*********************************************************************
*  
*   IAR PowerPac - USB Stack
*
*   (c) Copyright IAR Systems 2008.  All rights reserved.
*
**********************************************************************
----------------------------------------------------------------------
File    : USB_MSD_FS_Start.c
Purpose : Sample startup, using the file system driver as MSC storage driver.
--------  END-OF-HEADER  ---------------------------------------------
*/

#include <stdio.h>
#include "USB.h"
#include "USB_MSD.h"
#include "FS.h"
#include "BSP.h"
#include "RTOS.H"

/*********************************************************************
*
*       Static data
*
**********************************************************************
*/
static OS_STACKPTR int _Stack0[512]; // Task stacks
static OS_TASK         _TCB0;        // Task-control-blocks

/*********************************************************************
*
*       Static ccode
*
**********************************************************************
*/

/*********************************************************************
*
*       _FSTest
*/
static void _FSTest(void) {
  FS_FILE    * pFile;
  unsigned     Len;
  const char * sInfo = "This sample based on the Segger emUSB software with MSD component.\r\nFor further information please visit: www.segger.com\r\n";
  
  Len = strlen(sInfo);
  if (FS_IsLLFormatted("") == 0) {
    FS_X_Log("Low level formatting");
    FS_FormatLow("");          /* Erase & Low-level  format the volume */
  }
  if (FS_IsHLFormatted("") == 0) {
    FS_X_Log("High level formatting\n");
    FS_Format("", NULL);       /* High-level format the volume */
  }
  pFile = FS_FOpen("Readme.txt", "w");
  FS_Write(pFile, sInfo, Len);
  FS_FClose(pFile);
  FS_Unmount("");

}

/*********************************************************************
*
*       _AddMSD
*
*  Function description
*    Add mass storage device to USB stack
*
*  Notes:
*   (1)  -   This examples uses the internal driver of the file system.
*            The module intializes the low-level part of the file system if necessary.
*            If FS_Init() was not previously called, none of the high level functions 
*            such as FS_FOpen, FS_Write etc will work.
*            Only functions that are driver related will be called.
*            Initialization, sector read/write, retrieve device information.
*            The following members of the DriverData are used as follows:
*              DriverData.pStart       = Index no. of the volume that shall be used.
*              DriverData.NumSectors   = Number of sectors to be used - 0 means auto-detect.
*              DriverData.StartSector  = The first sector that shall be used.
*              DriverData.SectorSize will not be used.
*/
static void _AddMSD(void) {
  static U8 _abOutBuffer[USB_MAX_PACKET_SIZE];
  USB_MSD_INIT_DATA     InitData;
  USB_MSD_INST_DATA     InstData;

  InitData.EPIn  = USB_AddEP(1, USB_TRANSFER_TYPE_BULK, USB_MAX_PACKET_SIZE, NULL, 0);
  InitData.EPOut = USB_AddEP(0, USB_TRANSFER_TYPE_BULK, USB_MAX_PACKET_SIZE, _abOutBuffer, USB_MAX_PACKET_SIZE);
  USB_MSD_Add(&InitData);
  //
  // Add logical unit 0: 
  //
  memset(&InstData, 0,  sizeof(InstData));
  InstData.pAPI                    = &USB_MSD_StorageByName;    // s. Note (1)
  InstData.DriverData.pStart       = (void *)"";
  USB_MSD_AddUnit(&InstData);
}

/*********************************************************************
*
*       Public code
*
**********************************************************************
*/

/*********************************************************************
*
*       Get information that are used during enumeration
*/

/*********************************************************************
*
*       USB_GetVendorName
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
*    Returns the product Id
*/
U16 USB_GetProductId(void) {
  return 0x1000;
}

/*********************************************************************
*
*       USB_GetVendorName
*
*  Function description
*    Returns vendor name.
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
  return "MSD device";
}

/*********************************************************************
*
*       USB_GetSerialNumber
*
*  Function description
*    Returns serial number
*/
const char * USB_GetSerialNumber(void) {
  return "000013245678";  // Should be 12 character or more for compliance with Mass Storage Device Bootability spec.
}

/*********************************************************************
*
*       String information routines when inquiring the volume
*/
/*********************************************************************
*
*       USB_MSD_GetVendorName
*/
const char * USB_MSD_GetVendorName(U8 Lun) {
  return "Vendor";
}

/*********************************************************************
*
*       USB_MSD_GetProductName
*/
const char * USB_MSD_GetProductName(U8 Lun) {
  return "MSD Volume";
}

/*********************************************************************
*
*       USB_MSD_GetProductVer
*/
const char * USB_MSD_GetProductVer(U8 Lun) {
  return "1.00";
}

/*********************************************************************
*
*       USB_MSD_GetSerialNo
*/
const char * USB_MSD_GetSerialNo(U8 Lun) {
  return "134657890";
}

/*********************************************************************
*
*       MainTask
*
*/
static void MainTask(void) {
  USB_Init();
  FS_Init();
  _FSTest();
  _AddMSD();
  USB_Start();
  while (1) {
    //
    // Wait for configuration
    //
    while ((USB_GetState() & (USB_STAT_CONFIGURED | USB_STAT_SUSPENDED)) != USB_STAT_CONFIGURED) {
      BSP_ToggleLED(0);
      USB_OS_Delay(50);
    }
    BSP_SetLED(0);
    USB_MSD_Task();
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

