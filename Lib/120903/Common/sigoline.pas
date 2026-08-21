unit Sigoline;

{
  The TSigNETOutline component is a specialised outliner for SigNET editors.
  It has a timer built in for use by children with comms ports,
  although it has no comms ports itself.

  It also has properties in common with TSigNETOutline Nodes,
  in particular a test for legal children and a child dialog
  listing legal child types, which automatically creates children.

  v1.0 created 16/9/79 by D.S. Mear

  The following specialised objects are also defined in this
  unit, but are not independant entities.

  TSigNETObject
    TSigNETRing
    TSigNETWCTL
}

interface

uses
  SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
  Forms, Dialogs, Grids, Outline, ExtCtrls, ComPort, OlChild,
  EdRing, Printers, SigParse, EdWCTL, RingChld, PropList,
  WCTLChld;

{------------------ Generic Types ---------}

type
  TParity = ( pOdd, pEven );

type
  TDataBits = ( dbSeven_One );

type
  TPrintMode = ( pmToFile, pmToPrinter );

{------------------ TSigNETOutline -------------}
type
  TSigNETObject = class;
  TSigNETOutline = class(TOutline)
  private
    { Private declarations }
    GlobalTimer : TTimer;

    iHasChanged : Boolean; { if any additions, deletions etc }
    iUndoIndex : LongInt;  { used for undos }

    { The following allow common functions to
      be used for file save and for printing }

    iTextFile : TextFile; {for loading/saving}
    iPrinter : System.Text; {for printing }
    iCanvas : TCanvas; {for printing or text display }
    iPrintMode : TPrintMode; { Say Which }
    iY : Word;
    iPageHeight : Word;

    { The following are for user defined functions }
    fOnCreate : TNotifyEvent;

    { The following is the current control object
      for comms functions. It may itself pass control
      to its children if it wishes, provided that they
      are COMMS children. }
    ControlChild : TSigNETObject; 

    { Map an items Data member to a TSigNETObject }
    function fSigNETLeaf( index : LongInt ) : TSigNETObject ;

    {indent File to correct level }
    procedure WriteIndent( Indent : Word );

  protected
    { Protected declarations }
    { timer actine - poll children }
    procedure fTimerAction (Sender: TObject);

    procedure CommonSave( Child : LongInt ); { common element for both print and file save }
  public
    { Public declarations }
    constructor Create( AOwner: TComponent ) ; override;
    destructor Destroy; override;
    function SigNETAddSibling : LongInt;
             { add a sibling at the current point;
               Returns its index }
    function SigNETAddChild : LongInt;
             { adds a child to the currently selected item;
               Returns its index }
    procedure Edit; { edits currently selected item }

    procedure Save( const FName : string; Child : LongInt ) ;
    procedure Print( Child : LongInt );
    procedure Load( const FName : string; Child : LongInt );
    function LoadChild( Child : LongInt ) : boolean;
    function SaveChild( Index : LongInt) : LongInt;

    function GetNextLineFromFile( var Value : string ) : boolean;
             { returns False at EOF }

    function CreateChildFromFile( iProperty, iIndex,
             iValue, iComment : string ) : boolean;

    procedure SaveLine( iText : string; iIndent : Word );

    property SigNETLeaf[ Index : LongInt ] : TSigNETObject
             read fSigNETLeaf;
    procedure DeleteItem( Index : LongInt ) ;
    procedure DeleteCurrentItem;
    procedure ClearItems;

    { The following entries relate to comms control }
    function GiveChildControl( NewControlChild : TSigNETObject )
             : {OldControlChild} TSigNETObject;

  published
    { Published declarations }
    property OnCreate : TNotifyEvent
             read fOnCreate
             write fOnCreate;
    property HasChanged : Boolean
             read iHasChanged
             write iHasChanged;
  end;

{------------- Base class, virtual - never used directly -------}

  TSigNETObject = class(TObject)
  private
    { Private declarations }
    iDescription : String;
    iComments : TStringList;
    { The above are so common that they are included
      in the base class. Howevere, the base class does
      not actually use them. They are for the benefit
      of the derived classes }

    iPropertyList : TSigPropertyList;

    iSaveControl : TSigNETObject;

    function fReadLevel : Word;
    function fReadIndex : LongInt;
    function fGetSigNETParent : TSigNETObject;
  protected
    { Protected declarations }
    iRequiresPeriodicSupport : Boolean;
    iOwner : TOutlineNode;
    iVisualOwner : TSigNETOutline;

    iProperties : TSigPropertyList;

    iCurrentControlChild : LongInt;

    iDownloadOverhead : integer;

    function fType : string ; virtual; abstract;

    procedure SaveMyData; virtual; abstract;
    procedure EndMySave; virtual; abstract;

    procedure SaveLine( iText : string; iIndent : Word );
    procedure LoadPropertiesFromFile;

    procedure SendCommsString( iText : string ); virtual;

  public
    { Public declarations }
    constructor Create( AOwner: TOutlineNode;
            VisualOwner : TSigNETOutline  ) ;
    destructor Destroy; override;

    procedure EditProperties;
    procedure SaveProperties;

    procedure DoTick; virtual;{ services comms, etc }
    procedure DoAck; virtual;
    procedure DoNack; virtual;
    procedure DoEnter; virtual;
    procedure DoTimeOut; virtual;

    procedure Edit; virtual; abstract;
    function SigNETAddChild : LongInt; virtual;
     { adds a child to this item }

    function Save : LongInt; virtual;
    function CreateChildFromFile( Child : LongInt;
             iProperty, iIndex, iValue, iComment : string) :
             boolean;
    function LoadFromFile( iIndex, iValue, iComment : string ) : boolean; virtual;
    function LoadFromDevice : boolean; virtual;
    function CreateDefaultChild( AOwner: TOutlineNode;
            VisualOwner : TSigNETOutline ;
            iProperty, iValue, iComment : string ) : TSigNETObject;
             virtual;

    { The following functions allow child based
      navigation, for example for passing control }
    function GetFirstChild : TSigNETObject;
    function GetNextChild : TSigNETObject;

    { The following are used for passing Comms control }
    procedure PassControlToFirstChild;
    procedure PassControlToNextChild;
    procedure RelinquishControl;

    { The following are used to download }
    function GetDownLoadCount : integer ;
      { this gets the number of statements to be
        downloaded via serial comms. It is not
        a virtual function, but uses a property
        GetDownloadOverhead, for its own contribution
        which may be overriden, being a property }
    procedure DownLoad; virtual;
    procedure SendTString;

    procedure SetOwnerText;

    property Description : String
             read iDescription
             write iDescription;

    property Comments : TStringList
             read iComments
             write iComments;

    property RequiresPeriodicSupport : Boolean
      read iRequiresPeriodicSupport;

    property Level : Word
             read fReadLevel;

    property Index : LongInt
             read fReadIndex;

    property DownloadOverhead : integer
             read iDownloadOverhead;

    property SigNETParent : TSigNETObject
             read fGetSigNETParent;

    property TypeAsText : string
             read fType;
  end;

{----- TSigNETRing - used as Comms report ---------}

type
  TSigNETRing = class(TSigNETObject)
  private
    { Private declarations }
    ComPort : TComPort; { Comms }

    iTimeOut : LongInt ; { in Ticks }
    iTimeOutValue : LongInt ; {current Value }

    iCommsPort : integer;
    iBaudRate : String;
    iParity : TParity;
    iBits : TDataBits;

  protected
    { Protected declarations }
    procedure SaveMyData; override;
    procedure EndMySave; override;

    function fType : string ; override;

  public
    { Public declarations }
    constructor Create( AOwner: TOutlineNode;
            VisualOwner : TSigNETOutline ) ; virtual;
    destructor Destroy; override;

    procedure DoTick; override ; { services comms, etc }

    procedure Edit; override;

    function SigNETAddChild : LongInt; override;
     { adds a child to this item }

    function LoadFromFile( iIndex, iValue, iComment : string ) : boolean; override;

    function CreateDefaultChild( AOwner: TOutlineNode;
            VisualOwner : TSigNETOutline ;
            iProperty, iValue, iComment : string ) : TSigNETObject;
             override;

    procedure SendCommsString( iText : string ); override;

    property TimeOutValue : LongInt
             read iTimeOutValue;
    property Parity : TParity
             read iParity
             write iParity;
    property DataBits : TDataBits
             read iBits
             write iBits;
    property CommsPort : integer
             read iCommsPort
             write iCommsPort;
    property BaudRate : String
             read iBaudRate
             write iBaudRate;
  end;

{----- TSigNETRing - used as Comms report ---------}

type
  TSigNETWCTL = class(TSigNETObject)
{ This is the WCTL object. Its only properties are
  SigNET Node ID (which might be defaulted by parent)
  and description, which is inherited }
  private
    iNodeNo : integer;
    iCurrentState : ( csInactive,
                      csWaitingToLogOn,
                      csWaitingForLogOnReply,
                      csProcessingChildren,
                      csWaitingToLogOff,
                      csWaitingForLogOffReply );
  protected
    { Protected declarations }
    procedure SaveMyData; override;
    procedure EndMySave; override;

    function fType : string ; override;

  public
    { Public declarations }

    constructor Create( AOwner: TOutlineNode;
            VisualOwner : TSigNETOutline ) ; virtual;
    destructor Destroy; override;

    procedure Edit; override;

    function SigNETAddChild : LongInt; override;
     { adds a child to this item }

    function LoadFromFile( iIndex, iValue, iComment : string ) : boolean; override;

    procedure SendCommsString( iText : string ); override;

    procedure DoTick; override;{ services comms, etc }

    procedure DoAck; override;
    procedure DoNack; override;
    procedure DoEnter; override;
    procedure DoTimeOut; override;


    property NodeNo : integer
             read iNodeNo
             write iNodeNo;
end;

{------------------- End of Class definitions ------------}

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigNETOutline]);
end;

{----------- TSigNETOutline ---------------}

{$I pOline}

{--------------- TSigNETObject --------------------}

{$I chObject}

{--------------- TSigNETRing ---------------------}

{$I chRing}

{--------------- TSigNETWCTL ---------------------}

{$I chWCTL}

end.
