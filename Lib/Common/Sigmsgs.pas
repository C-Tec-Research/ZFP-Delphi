
{*******************************************************}
{                                                       }
{       Delphi Runtime Library                          }
{       SigNET Messages Interface Unit                  }
{                                                       }
{       Copyright (c) 1996,1997 SigNET (AC) Ltd.        }
{                                                       }
{*******************************************************}

unit Sigmsgs;

interface

const
  SigNET_MSG          = $6000;

  LOG_FAULT           = SigNET_MSG + 1;
  SigNET_TO_TOP       = SigNET_MSG + 2;
  GENERAL_CLOSE       = SigNET_MSG + 3;
  SigNET_RESPONDING   = SigNET_MSG + 4;
  WM_RESETNODES       = SigNET_MSG + 5;
  WM_SigNET_FAULT     = SigNET_MSG + 6;
  WM_DVA_RESET        = SigNET_MSG + 7;
  WM_NODE_FAULT       = SigNET_MSG + 8;
  WM_NODE_BUSY        = SigNET_MSG + 9;
  WM_GO_BUSY          = SigNET_MSG + 10;
  WM_GO_CLEAR         = SigNET_MSG + 11;
  WM_WRONGHARDWARE    = SigNET_MSG + 12;
  WM_DUPLICATECOPY    = SigNET_MSG + 13;
  WM_COMMANDOVERFLOW  = SigNET_MSG + 14;
  WM_ACFAIL           = SigNET_MSG + 15;
  WM_CFAIL            = SigNET_MSG + 16;
  WM_ACCLEAR          = SigNET_MSG + 17;
  WM_CCLEAR           = SigNET_MSG + 18;
  WM_RINGOK           = SigNET_MSG + 19;
  WM_TCMD_RCVD        = SigNET_MSG + 20;
  WM_GENCMD_RCVD      = SigNET_MSG + 21;
  WM_GENCMD_ERROR     = SigNET_MSG + 22;

  IMC_MSG             = $6F00;

  SigLOG_TO_TOP       = IMC_MSG + 0;
  PRINT_LOG           = IMC_MSG + 1;
  CLEAR_LOG           = IMC_MSG + 2;

  SESA_CLIENT_TO_TOP  = IMC_MSG + 16;

  NOT_BUSY            = 0;
  BUSY                = 1;
  VERY_BUSY           = 2;

implementation

end.
