unit Sigload;

{****************************************************************
 *								*
 * SigLoad.Pas							*
 *								*
 * Copyright (c) 1996 L.M. Mear					*
 *								*
 * Version 1.0							*
 *								*
 * This file is supplied 'as is' and suggests a mechanism for	*
 * loading of functions from SigNET.DLL. It is not guaranteed	*
 * to work, and you use it at your own risk.			*
 *								*
 ****************************************************************}


interface

uses WinTypes, WinProcs, Dialogs;

function Sig1Load : Bool;
procedure Sig1Unload;

type
{ Comms definitions }
pSetNotifyWindow = procedure( newWindow : HWND ; Controller : integer );
	{ Sets window to notify of SigNET messages.
	  If HWND_BROADCAST, then broadcasts to all applications
	  A single PC can support 2 virtual controllers, and
          therefore 2 applications }
   { Sets window for logging software }
pSetLoggingWindow = procedure( newWindow : HWND );
pSigNET_Execute = procedure;
	{ Passes control to SigNET for 1 message; Should be called in
          Idle_Time }
pSend_Query_Message = function( Msg : Pchar; MaxRpyLen : Integer;
  TestReply : Pchar; Controller : Integer ): Integer;
pSend_Buffer_Message = function( Msg, ReplyBuffer : Pchar; MaxRpyLen : Integer;
  TestReply : Pchar; Controller : Integer ): Integer;
{ Other Definitions }
pvDemoMode = function : Bool;
	{ returns True if in Demo mode, or false
	  Otherwise. }
pmChannel = function( MsgID : integer ) : integer;
pvDVAPending = function( Controller : integer ) : integer;
pGzStatus = function( i : integer; var Err, Busy : integer; Controller : integer) : Boolean;
pSigNET_Change_Selected_Channel = function
              ( Newchannel, Controller : integer) : Word;
  { Changes selected channel (from voice to DVA or vice versa) }
pGzoneSelect = function ( Zone : integer; Additive : integer;
             Controller : integer) : boolean;
pSigNET_Go_DVA = function(Msg, Controller : integer) : Word;
	{ Sends DVA go }
pDDVA_Complete = procedure (Controller : integer);
	{ Notifies DLL that DiskDVA is complete }
pvDiskDVAChannel = function : integer;
   { Gets the Disk DVA Channel No }
pResetNodesSelected = procedure ( LockNodes : boolean; Controller : integer );
pGzRegister = procedure (Zone : integer; Controller : integer);
pGzUnregister = procedure (Zone : integer; Controller : integer);

const
  SigNET_MSG        =  $6000;

  LOG_FAULT         =  SigNET_MSG + 1 ;
  SigNET_TO_TOP     =  SigNET_MSG + 2 ;
  GENERAL_CLOSE     =  SigNET_MSG + 3 ;
  SigNET_RESPONDING =  SigNET_MSG + 4 ;
  WM_RESETNODES     =  SigNET_MSG + 5 ;
  WM_SigNET_FAULT   =  SigNET_MSG + 6 ;
  WM_DVA_RESET      =  SigNET_MSG + 7 ;
  WM_NODE_FAULT     =  SigNET_MSG + 8 ;
  WM_NODE_BUSY      =  SigNET_MSG + 9 ;
  WM_GO_BUSY        =  SigNET_MSG + 10;
  WM_GO_CLEAR       =  SigNET_MSG + 11;
  WM_WRONGHARDWARE  =  SigNET_MSG + 12;
  WM_DUPLICATECOPY  =  SigNET_MSG + 13;
  WM_COMMANDOVERFLOW = SigNET_MSG + 14;
  WM_ACFAIL         =  SigNET_MSG + 15;
  WM_CFAIL          =  SigNET_MSG + 16;
  WM_ACCLEAR        =  SigNET_MSG + 17;
  WM_CCLEAR         =  SigNET_MSG + 18;
  WM_RINGOK         =  SigNET_MSG + 19;
  WM_TCMD_RCVD      =  SigNET_MSG + 20;
  WM_GENCMD_RCVD    =  SigNET_MSG + 21;
  WM_GENCMD_ERROR   =  SigNET_MSG + 22;

  IMC_MSG           =  $6F00;

  SigLOG_TO_TOP     =  IMC_MSG + 0;
  PRINT_LOG         =  IMC_MSG + 1;
  CLEAR_LOG         =  IMC_MSG + 2;

  NOT_BUSY          =  0;
  BUSY              =  1;
  VERY_BUSY         =  2;

var
SetNotifyWindow : pSetNotifyWindow;
SigNET_Execute : pSigNET_Execute;
vDemoMode : pvDemoMode;
Send_Query_Message : pSend_Query_Message;
Send_Buffer_Message : pSend_Buffer_Message;
SetLoggingWindow : pSetLoggingWindow;

mChannel : pmChannel;
vDVAPending : pvDVAPending;
GzStatus : pGzStatus;
SigNET_Change_Selected_Channel : pSigNET_Change_Selected_Channel;
GzoneSelect : pGzoneSelect;
SigNET_Go_DVA : pSigNET_Go_DVA;
DDVA_Complete : pDDVA_Complete;
vDiskDVAChannel : pvDiskDVAChannel;
ResetNodesSelected : pResetNodesSelected;
GzRegister : pGzRegister;
GzUnregister : pGzUnregister;

implementation

Var
hSigNET : THandle;
P : Pointer;

{ Import routines from SigNET.dLL. }

function Sig1Load : Bool;
label EndSig1Load;
begin
  Result := true;  {Added by AD to indicate that the default is true unless one
  							of the following functions fail}
  hSigNET := LoadLibrary( 'SigNET.DLL' );
  if ( hSigNET >  HINSTANCE_ERROR ) then
  begin
    { Comms Side }
    P := GetProcAddress( hSigNET, 'SetNotifyWindow') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    SetNotifyWindow := pSetNotifyWindow(P);

    P := GetProcAddress( hSigNET, 'SigNET_Execute') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    SigNET_Execute := pSigNET_Execute(P);

    { General }
    P := GetProcAddress( hSigNET, 'vDemoMode') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    vDemoMode := pvDemoMode(P);

    P := GetProcAddress( hSigNET, 'Send_Query_Message') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    Send_Query_Message := pSend_Query_Message(P);

    P := GetProcAddress( hSigNET, 'Send_Buffer_Message') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    Send_Buffer_Message := pSend_Buffer_Message(P);

    P := GetProcAddress( hSigNET, 'mChannel') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    mChannel := pmChannel(P);

    P := GetProcAddress( hSigNET, 'vDVAPending') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    vDVAPending := pvDVAPending(P);

    P := GetProcAddress( hSigNET, 'GzStatus') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    GzStatus := pGzStatus(P);

    P := GetProcAddress( hSigNET, 'SigNET_Change_Selected_Channel') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    SigNET_Change_Selected_Channel := pSigNET_Change_Selected_Channel(P);

    P := GetProcAddress( hSigNET, 'GzoneSelect') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    GzoneSelect := pGzoneSelect(P);

    P := GetProcAddress( hSigNET, 'SigNET_Go_DVA') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    SigNET_Go_DVA := pSigNET_Go_DVA(P);

    P := GetProcAddress( hSigNET, 'DDVA_Complete') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    DDVA_Complete := pDDVA_Complete(P);

    P := GetProcAddress( hSigNET, 'vDiskDVAChannel') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    vDiskDVAChannel := pvDiskDVAChannel(P);

    P := GetProcAddress( hSigNET, 'ResetNodesSelected') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    ResetNodesSelected := pResetNodesSelected(P);

    P := GetProcAddress( hSigNET, 'SetLoggingWindow') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    SetLoggingWindow := pSetLoggingWindow(P);

    P := GetProcAddress( hSigNET, 'GzRegister') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    GzRegister := pGzRegister(P);

    P := GetProcAddress( hSigNET, 'GzUnregister') ;
    if (P = Nil ) then
    begin
      Result := False;
      goto EndSig1Load;
    end;
    GzUnregister := pGzUnregister(P);
  end;
EndSig1Load:
end;

procedure Sig1Unload;
begin
  if ( hSigNET >  HINSTANCE_ERROR ) then
  begin
    FreeLibrary( hSigNET );
  end;
end;


end.
