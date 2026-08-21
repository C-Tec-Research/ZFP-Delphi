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

uses WinTypes, WinProcs;

function Sig1Load : Bool;
procedure Sig1Unload;

type
{ Comms definitions }
pSetNotifyWindow = procedure( newWindow : HWND ; Controller : integer );
	{ Sets window to notify of SigNET messages.
	  If HWND_BROADCAST, then broadcasts to all applications
	  A single PC can support 2 virtual controllers, and
          therefore 2 applications }
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

implementation

Var
hSigNET : THandle;
P : Pointer;

{ Import routines from SigNET.dLL. }

function Sig1Load : Bool;
label EndSig1Load;
begin
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
