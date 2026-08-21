unit UnitSerialMasterSlave;

{
  Master/Slave Serial

  Derived from AVRCo original

  v2.1
  Conditional compile on SerSlaveOnly, that removes functions not required
  unless component can be serial master
  use $DEFINE SERSLAVEONLY

  v2.0
  This version does not require the master to attempt to relinquish.

  Time outs are fundamentally different, as are the states.

  CanBeMaster remains, but the destinction between reluctantMaster, etc. are removed.

  Any relinquishing of master status can now only occur after a record checksum fail,
  the assumption being that two units could be attempting to be a master.

  GetNextSerRecord result no longer affects promotion etc. and promotion has
  been removed as a function. Instead it records whether the destination is expected
  to act in a sub-dominant role, i.e. if it expects a response of its own. If it does,
  the result is true.

  A unit can demote from an Active master to a potential master.

  v1.0
  combines the Serial Master and slave functionality

  The master sends a record which may be a sync record. If not, the target device
  has the right of reply. It may reply to any destination, not just the master,
  and indeeed, any device may eavesdrop. In this context the destination, if it
  is not the master (and perhaps if it is) is generally effectively a request
  for the target to change state. The target may or may not comply.

  The unit requires that SetSerDelay is called before a unit tries to become a master.
  The code is structured so that this may be changed dynamically. This controls
  how quickly the unit tries to be master, but the parameter should never be zero.
  Typically it should be 10 * address of unit (or similar). This will give 10 ms steps

  Note that only priorities between zero and 15 are supported.

  Initially the unit is a slave. If there is a time out, a device takes over
  depending on two factors. The unit priority (the smaller the value the higher the priority)
  and whether the unit is or wants to be master.

  In this context there are two time outs; a transmission time out occurs relatively quickly
  at about 100 ms (This applies to the current master only) and is the time within which
  the target slave must respond.

  The master hand over time out should be much longer (about 1 sec).

  These are controlled by constants (or variables)

  SerMasterTimeOut : word = 100;   // time out time in ms for master
  SerSlaveTimeOut  : word = 1000;  // time out time in ms for units that cannot become master
  SerTimeoutDelta  : word = 40;    // see below

  Note that the first of these values is a floor value, the actual value will depend on
  the other priority factors. SerMasterDelta is the delay added to distinguish between various
  mode states. As a guide, this should be 10 * the number of potential masters.

  The function ProcessSerial
   must be called regularly

  A number of call back points are provided

    SerRxFailCallBack may be assigned a procedure of the form
    procedure xxx( FailMode : tSerRxFailMode );

      This procedure is called whenever a failure is detected. The fail mode
      is passed as the parameter;

    SerRxCallBack should be assigned a function of form
    function xxx : boolean;

      This returns TRUE if it is a message to us, i.e. we can reply (in SLAVE mode).
      In master mode the result is effectively ignored, so no distinction between
      master and slave mode is generally required.

      This procedure is called whenever a record is successfully received.
      This may be from the master or any slave.

      Within this procedure SerRxTempBuff should be copied to a permanent location,
      unless it is to be discarded.

    GetNextSerRecord should be assigned a procedure of form
    function xxx : boolean, unless the unit only evesdrops.

      The response should be TRUE if the unit needs to send more records quickly,
      or FALSE if it can wait. This affects whether the unit gains or relinquishes control

      If GetNextSerRecord is not assigned, the unit can never become master.

      The purpose of GetNextSerRecord is to assign a new record to SerTxBuffer. It should
      return TRUE if we have more data to transmit, or FALSE if not. IF TRUE is returned
      the unit will attempt to become, or remain, a master. If FALSE the unit will attempt
      to become, or remain, a slave.

  Two additional function are provided for use in a multi-master environment where a
  potential master may not get the right of reply

    SerPromote allows the unit to become master when it can, i.e. when the current master
    relinquishes

    SerRelinquish allows the unit to relinquish earlier than using the reply to the
    GetNextSerRecord function, although in practice it is unlikely to be required.

}

interface


{ typical serial record type }
{
  type
  tSerRecType = ( tsrSync,
                  tsrOutputCfg,
                  tsrOutputFaultText,
                  tsrNoTypes );
}
{ typical Ser Record format - mapped to Rx or Tx buffers}
{  tDeviceAddress = byte;

  tSerRec        = record
    Sender      : tDeviceAddress;
    Destination : tDeviceAddress;
    RecType     : tSerRecType;
    ParmB1      : byte;
    ParmW1      : word;
    ParmW2      : word;
    ParmW3      : word;
    ParmW4      : word;
    ParmW5      : word;
  end;
  Note that checksum is not required explicitly
}

// global part

uses
  Classes,
  ComPanel;

{ Type Declarations }
type
  tSerRxFailMode = (srfmCS, srfmTimeOut );

type
  tSerRxCallBack     = function : boolean of object;
  tSerTxCallBack     = function : boolean of object;
  tSerRxFailCallBack = procedure( FailMode : tSerRxFailMode ) of object;

type
  tSerPriority = (
                      spActiveMaster,     //     Master Mode
                      spCanBeMaster,      //  )__Slave Modes
                      spMustBeSlave       //  )
                  );

type
  tSerMode = ( smWaitingToSync,
               smTx,
               smRx
             );

type
  tTimers = ( SerTimer, ttMax );

type
  tSerMasterSlave = class
  private
    fGetNextSerRecord: tSerTxCallBack;
    fSerRxFailCallBack: tSerRxFailCallBack;
    fSerRxCallback: tSerRxCallBack;
    fSerModePriority: tSerPriority;
    fSerMode: tSerMode;
    fSerAddressPriority: word;
    fSerCS: byte;
    RxPtr : integer;
    fSerMasterTimeOut: integer;
    fMustSendSync: boolean;
    fSerSlaveTimeout: integer;
    fMightBeSync: boolean;
    fSerTimeOutLatch: boolean;
    fSerTimeout: boolean;
    fSubDomMode: boolean;
    fSerBufferSize: integer;
    fSerSync: boolean;
    fComPanel: TCommsPanel;
    fTimers : array[ SerTimer..ttMax ] of integer;
    fRcvBuffer : string;
    procedure SetSysTimer( const pTimer : tTimers; Value : integer );
    procedure SetComPanel(const Value: TCommsPanel);
    property MightBeSync : boolean
             read fMightBeSync
             write fMightBeSync;
    property MustSendSync : boolean
             read fMustSendSync
             write fMustSendSync;
    procedure SetSync;
    procedure SetXmit;
    procedure CheckMasterStatus;
   procedure fOnRcvChar(Sender: TObject; Character: Char);
  public
    SerRxTempBuff   : string;
    SerTxBuffer   : string;
    SerRxBuffer   : string;
    constructor Create;
    property SerRxFailCallBack : tSerRxFailCallBack
             read fSerRxFailCallBack
             write fSerRxFailCallBack;
    property SerRxCallback     : tSerRxCallBack
             read fSerRxCallback
             write fSerRxCallback;
    property GetNextSerRecord  : tSerTxCallBack
             read fGetNextSerRecord
             write fGetNextSerRecord;
    procedure ProcessSerial;
    procedure ForceSync;
    procedure SetSerPriority( NewVal : word );
    procedure SerDemote;
    property SerMode  : tSerMode
             read fSerMode
             write fSerMode;
    property SerAddressPriority : word
             read fSerAddressPriority
             write fSerAddressPriority;
    property SerModePriority    : tSerPriority
             read fSerModePriority
             write fSerModePriority;
    property SerCS    : byte
             read fSerCS
             write fSerCS;
    procedure SetTimeOut;
    procedure Tick; // decrements timeout
    property SerMasterTimeOut : integer
             read fSerMasterTimeOut
             write fSerMasterTimeOut;
    property SerSlaveTimeout : integer
             read fSerSlaveTimeout
             write fSerSlaveTimeout;
    property SerTimeOut : boolean
             read fSerTimeout;
    property SerTimeOutLatch : boolean
             read fSerTimeOutLatch
             write fSerTimeOutLatch; // Set by class, reset externally
    property SubDomMode : boolean
             read fSubDomMode
             write fSubDomMode;
    procedure RcvChar( const Value : char );
    function SerStat : boolean;
    procedure SendSyncRecord;
    procedure SendSerRecord;
    procedure ReceiveSyncRecord;
    procedure ReceiveSerRecord;
    property SerBuffSize : integer
             read fSerBufferSize
             write fSerBufferSize;
    function SerInp : char;
    procedure SetRcv;
    function IsSysTimerZero( const pTimer : tTimers ) : boolean;
    property SerSync : boolean
             read fSerSync
             write fSerSync;
    property ComPanel : TCommsPanel
             read fComPanel
             write SetComPanel;
  end;

function ExtractWord( const FromString : string; const AtLoc : integer ) : word;

implementation

function ExtractWord( const FromString : string; const AtLoc : integer ) : word;
begin
  Result := Ord( FromString[ AtLoc ] ) + 256 * Ord( FromString[ AtLoc + 1] );
end;

{ tSerMasterSlave }

procedure tSerMasterSlave.CheckMasterStatus;
begin
  // this occurs on a time out - we can change state
  case SerModePriority of
    spActiveMaster:
    begin
      // Genuine time out
      fSerTimeOut := TRUE;
      SerTimeOutLatch := TRUE;
      if assigned( SerRxFailCallBack ) then
      begin
        SerRxFailCallBack( srfmTimeOut );
      end;
    end;
    spCanBeMaster:
    begin
      SerModePriority := spActiveMaster;
    end;
  end;
  SetSync;
end;

constructor tSerMasterSlave.Create;
begin
  inherited Create;

  SerMode         := smWaitingToSync;
  SerModePriority := spCanBeMaster;

  SetSysTimer( SerTimer, SerSlaveTimeOut );

end;

procedure tSerMasterSlave.fOnRcvChar(Sender: TObject; Character: Char);
begin
  fRcvBuffer := fRcvBuffer + Character;
end;

procedure tSerMasterSlave.ForceSync;
begin
  MustSendSync := TRUE;
end;

function tSerMasterSlave.IsSysTimerZero(const pTimer: tTimers): boolean;
begin
  Result := fTimers[ pTimer ] = 0;
end;

procedure tSerMasterSlave.ProcessSerial;
begin
  case SerMode of
    smWaitingToSync:
    begin
      case SerModePriority of
        spActiveMaster:
        begin
          // I am the current Master
          SendSyncRecord;
        end;
        else
        begin
          // I am a slave
          ReceiveSyncRecord;
        end;
      end;
    end;
    smTx:
    begin
      // if anything is in the input buffer at this stage then we have a problem
      // if we are master, relegate to CanBeMaster, just as if there were a
      // collision
      if SerStat then
      begin
        case SerModePriority of
          spActiveMaster:
          begin
            SerModePriority := spCanBeMaster;
          end;
        end;
        // abort the transmission and wait for sync
        SetSync;
      end
      else
      begin
        SendSerRecord;
      end;
    end;
    smRx:
    begin
      ReceiveSerRecord;
    end;
  end;
end;

procedure tSerMasterSlave.RcvChar(const Value: char);
begin
  SerRxBuffer := SerRxBuffer + Value;
end;

procedure tSerMasterSlave.ReceiveSerRecord;
begin
  // anything waiting in the buffer ?
  if SerStat then
  begin
    // reset time out timer
    SetSysTimer( SerTimer, SerMasterTimeOut ); // after first byte, wait minimum time
    while SerStat do
    begin
      inc( RxPtr );
      if RxPtr > SerBuffSize then // byte recieved was checksum
      begin
        if SerCS = byte(SerInp) then        //  if wrong, we don't care how wrong
        begin
          if not MightBeSync then // is not a sync record. If all prior entries are zero,
          begin                   // and checksums then must be sync record
            // record OK; call back to transfer and check if we can reply
            if assigned( SerRxCallBack ) then
            begin
              if SerRxCallBack() then
              begin
                // can reply
                SetXmit;
                exit; // no need to check if we are master or read more characters
              end;
            end;
          end;
          // if we are a master we must retransmit anyway, unless we are in SubDom Mode
          case SerModePriority of
            spActiveMaster:
            begin
              if SubDomMode then
              begin
                SubDomMode := FALSE;
                SetRcv;
              end
              else
              begin
                SetXmit;
              end;
            end;
            else // reset buffer counter and stay in receive mode
            begin
              SetRcv;
            end;
          end;
        end
        else
        begin
          if assigned( SerRxFailCallBack) then
          begin
            SerRxFailCallBack( srfmCS );
          end;
          // If checksum has failed, it is probably due to a collision.
          // Two possibilies exist here. Either two devices have the same
          // address - nothing we can do about that - or two devices are
          // contending for master status (perhaps one has changed its address
          // from former contention. To cope with this possibility, if we are
          // master we reduce our status to CanBeMaster
          case SerModePriority of
            spActiveMaster:
            begin
              SerModePriority := spCanBeMaster;
            end;
          end;
          SetSync;
        end;
        // record complete or aborted - do not read further characters
        exit;
      end
      else
      begin
        SerRxTempBuff[ RxPtr ] := SerInp;
        Dec( fSerCS, ord( SerRxTempBuff[ RxPtr ]) );
        if SerRxTempBuff[ RxPtr ] <> #0 then
        begin
          MightBeSync := FALSE;
        end;
      end;
    end;
  end
//    return;
  else if IsSysTimerZero( SerTimer ) then
    // give up - see if we can become master
  begin
    CheckMasterStatus;
  end;
end;

procedure tSerMasterSlave.ReceiveSyncRecord;
begin
  if SerStat then
  begin
    // reset time out timer
    SetSysTimer( SerTimer, SerMasterTimeOut ); // after first char only wait shortest
                                               // timeout regardless of Mode Priority
    fSerTimeOut := FALSE;
    while SerStat do
    begin
      inc( RxPtr );
      if RxPtr > SerBuffSize then // byte recieved was checksum
      begin
        case SerInp of
          #255: // synchronised!
          begin
            SetRcv;
            SerSync := TRUE;
            // must now exit - not read next record!
            exit;
          end;
          #0: // might still be syncing
          begin
            dec( RxPtr );
          end;
          else
          begin
            RxPtr := 0; // abject failure!
          end;
        end;
      end
      else if SerInp <> #$00 then // not a sync record
      begin
        RxPtr := 0;
      end; // zero - still OK as a sync record
    end;
  end
  else if IsSysTimerZero( SerTimer ) then
  begin
    // Timed out. See if my turn to become master
    CheckMasterStatus;
  end;
end;

procedure tSerMasterSlave.SerDemote;
begin
  if SerModePriority = spActiveMaster then
  begin
    SerModePriority    := spCanBeMaster;
  end;
end;

function tSerMasterSlave.SerInp: char;
begin
  Result := fRcvBuffer[ 1 ];
  fRcvBuffer := Copy( fRcvBuffer, 2, Length( fRcvBuffer ));
end;

function tSerMasterSlave.SerStat: boolean;
begin
  Result := Length( fRcvBuffer ) > 0;
end;

procedure tSerMasterSlave.SetComPanel(const Value: TCommsPanel);
begin
  fComPanel := Value;
  fComPanel.OnCharacter := fOnRcvChar;
end;

procedure tSerMasterSlave.SetRcv;
begin
  SerMode := smRx;
  SerCS   := $FF;
  RxPtr   := 0;
  MightBeSync := TRUE;
  SetTimeOut;
end;

procedure tSerMasterSlave.SetSerPriority(NewVal: word);
begin
  SerAddressPriority := NewVal;
  SerModePriority    := spCanBeMaster;
end;


procedure tSerMasterSlave.SetSync;
begin
  SerMode := smWaitingToSync;
  RxPtr := 0;
  SetTimeOut;
end;

procedure tSerMasterSlave.SetSysTimer(const pTimer: tTimers; Value: integer);
begin
  fTimers[ pTimer ] := Value;
end;

procedure tSerMasterSlave.SetTimeOut;
begin
  // set to recieve mode
  case SerModePriority of
    spActiveMaster:
    begin
      SetSysTimer( SerTimer, SerMasterTimeOut );
    end;
    spCanBeMaster:
    begin
      SetSysTimer( SerTimer, SerSlaveTimeout + SerAddressPriority );
      // this time out will be different for each address, allowing one master
      // to take over without risk of collision
    end;
    spMustBeSlave:
    begin
      SetSysTimer( SerTimer, SerSlaveTimeOut );
    end;
  end;
end;

procedure tSerMasterSlave.SetXmit;
begin
  // set to transmit mode
  SerMode := smTx;
end;

procedure tSerMasterSlave.Tick;
var
  i : tTimers;
begin
  for i := SerTimer to ttMax do
  begin
    if fTimers[ i ] > 0 then
    begin
      dec( fTimers[ i ] );
    end;
  end;
end;

procedure tSerMasterSlave.SendSerRecord;
var
  i : byte;
begin
  // check for record to send
  if assigned( GetNextSerRecord ) then
  begin
    SubDomMode := GetNextSerRecord( );
  end
  else
  begin
    exit; // cannot send records - just an evesdropper
  end;
  SerCS := $FF; // Check sum to -1
  for i := 1 to SerBuffSize do
  begin
    Dec( fSerCS, ord(SerTxBuffer[ i ]) );
  end;
  fComPanel.Text := Copy(SerTxBuffer, 1, SerBuffSize ) + char(fSerCS);
  // await reply
  SetRcv;
end;

procedure tSerMasterSlave.SendSyncRecord;
begin
  fComPanel.Text := StringOfChar( #0, SerBuffSize ) + #$FF;
  SerMode   := smTx; // ready to send data
  MustSendSync := FALSE;
end;


end.


