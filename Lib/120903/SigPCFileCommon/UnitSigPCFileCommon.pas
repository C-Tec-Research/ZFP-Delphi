unit UnitSigPCFileCommon;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs,
  SigFile,
  UnitEditArea,
  UnitEditUser;

type

  TFormSigArea = class(TForm)
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  tSigAreaFormType = class( tSigIntegerProperty )
  private
    procedure SetFormType(const Value: tSigFormType);
    function GetFormType: tSigFormType;
  public
    property FormType : tSigFormType
             read GetFormType
             write SetFormType;
  end;

  tMacro = class;

  tSigEditableObject = class( tSigCompoundProperty )
  private
  protected
  public
    procedure Edit; virtual; abstract;
  end;

  tSigComponent = class( tSigEditableObject ) // this represents a GUI object
  private
    fTop: tSigIntegerProperty;
    fLeft: tSigIntegerProperty;
    fWidth: tSigIntegerProperty;
    fHeight: tSigIntegerProperty;
    procedure SetTop(const Value: integer);
    function GetOwner: tSigComponent;
    function GetTop: integer;
    function GetLeft: integer;
    procedure SetLeft(const Value: integer);
    function GetControlOwner: tComponent;
    function GetControlParent: tWinControl;
    function GetHeight: integer;
    function GetWidth: integer;
    procedure SetHeight(const Value: integer);
    procedure SetWidth(const Value: integer);
    procedure SetControlParent(const Value: tWinControl);
  protected
    fControl: tControl;
    procedure SetControl(const Value: tControl); virtual;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property OwnerAsSigComponent : tSigComponent
             read GetOwner;
    property Control : tControl
             read fControl
             write SetControl;
    property ControlOwner : tComponent
             read GetControlOwner;
    property ControlParent : tWinControl
             read GetControlParent
             write SetControlParent;
    property Top : integer
             read GetTop
             write SetTop;
    property Left : integer
             read GetLeft
             write SetLeft;
    property Width : integer
             read GetWidth
             write SetWidth;
    property Height : integer
             read GetHeight
             write SetHeight;
  end;

  tSigLink = class( tSigComponent)
  {
    A SigLink is a link to the outside world, usually via a comms port.
    Every Action is associated with at most one SigLink, but, of course
    a macro can handle many
  }
  private
  protected
  public
    function IsSameAs( const Value : tSigLink ) : boolean; virtual; abstract;
  end;

  tSigLinkList = class( tSigObjectArray )
  private
    function GetSigLink( const i : integer ): tSigLink;
  {
    every SigLink Must be unique within the list
  }
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property SigLink[ const i : integer ] : tSigLink
             read GetSigLink;
  end;

  tSigPCAction = class( tSigCompoundProperty )
  private
    fWaitForCompletion : tSigBooleanProperty;
    fSigLink: tSigLink;
    function GetMacro: tMacro;
    function GetWaitForCompletion: boolean;
    procedure SetWaitForCompletion(const Value: boolean);
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property Macro : tMacro
             read GetMacro;
    property WaitForCompletion : boolean
             read GetWaitForCompletion
             write SetWaitForCompletion;
    procedure Click; virtual; abstract;
    property SigLink : tSigLink
             read fSigLink
             write fSigLink;
  end;

  tSigActionList = class( tSigObjectArray )
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
  end;

  tMacro = class( tSigCompoundProperty )
  private
    fName : tSigSimpleProperty;
    fActionList : tSigActionList;
    function GetAction(const i: integer): tSigPCAction;
    function GetName: string;
    procedure SetName(const Value: string);
  protected
    ClickIndex : integer;
    procedure ActionClick;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    procedure Click;
    procedure OnActionComplete( const Sender : tSigPCAction );
    property Action[ const i : integer ] : tSigPCAction
             read GetAction;
    property Name : string
             read GetName
             write SetName;
  end;

  tMacroList = class( tSigObjectList )
  private
    function GetMacro(const i: integer): tMacro;
    function GetMacroByName(const s: string): tMacro;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property MacroByName[ const s : string ] : tMacro
             read GetMacroByName;
    property Macro[ const i : integer ] : tMacro
             read GetMacro;
  end;

  tSigButton = class( tSigComponent )
  private
    fMacroName : tSigSimpleProperty;
    procedure SetMacro(const Value: tMacro);
    function GetMacro: tMacro;
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property Macro : tMacro
             read GetMacro
             write SetMacro;
    procedure Click;
  end;

  tSigButtonSet = class( tSigObjectArray )
  private
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
  end;

  tSigArea = class( tSigComponent )
  private
    fVisible: boolean;
    fFormArea: tFormSigArea;
    fFormType : tSigAreaFormType;
    fName : tSigSimpleProperty;
    fPicture : tSigSimpleProperty;
    procedure SetVisible(const Value: boolean);
    procedure SetFormArea(const Value: tFormSigArea);
    function GetFormType: tSigFormType;
    procedure SetFormType(const Value: tSigFormType);
    function GetName: string;
    procedure SetName(const Value: string);
    function GetPicture: string;
    procedure SetPicture(const Value: string);
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property Visible : boolean
             read fVisible
             write SetVisible;
    property FormArea : tFormSigArea
             read fFormArea
             write SetFormArea;
    property FormType : tSigFormType
             read GetFormType
             write SetFormType;
    procedure Edit; override;
    property Name : string
             read GetName
             write SetName;
    property Picture : string
             read GetPicture
             write SetPicture;
  end;

  tSigAreas = class( tSigObjectArray )
  private
    function GetSigArea(const i: integer): tSigArea;
    function GetAreaWithName(const s: string): tSigArea;
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); overload; override;
    property Area[ const i : integer ] : tSigArea
             read GetSigArea; default;
    property AreaWithName[ const s : string ] : tSigArea
             read GetAreaWithName;
  end;

  tUser = class( tSigEditableObject )
  private
    fName : tSigSimpleProperty;
    fPIN  : tSigSimpleProperty;
    fTimeOut : tSigIntegerProperty;
    fChimeOpts : tSigIntegerProperty;
    fChimeTime : tSigIntegerProperty;
    fUserOptions: tSigObjectArray;
    function GetName: string;
    procedure SetName(const Value: string);
    function GetPIN: string;
    procedure SetPIN(const Value: string);
    function GetTimeout: integer;
    procedure SetTimeout(const Value: integer);
    function GetChimeOpts: tChimeOptions;
    procedure SetChimeOpts(const Value: tChimeOptions);
    function GetChimeTime: integer;
    procedure SetChimeTime(const Value: integer);
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    procedure Edit; override;
    property Name : string
             read GetName
             write SetName;
    property PIN : string
             read GetPIN
             write SetPIN;
    property Timeout : integer
             read GetTimeout
             write SetTimeout;
    property ChimeOptions : tChimeOptions
             read GetChimeOpts
             write SetChimeOpts;
    property ChimeTime : integer
             read GetChimeTime
             write SetChimeTime;
    property UserOptions : tSigObjectArray
             read fUserOptions;
  end;

  tUsers = class( tSigObjectArray )
  private
    function GetUser(const i: integer): tUser;
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property User[ const i : integer ] : tUser
             read GetUser; default;
  end;

  tSigEditableCfg = class( tSigCompoundProperty )  // The common bits lumped together - i.e. Areas, users and SESA
  private
    fUsers: tUsers;
    fSigAreas: tSigAreas;
  protected
  public
    constructor Create( pPropertyName : string; pOwner : tSigCompoundProperty  ); override;
    property Users : tUsers
             read fUsers;
    property Areas : tSigAreas
             read fSigAreas;
  end;

var
  FormSigArea: TFormSigArea; // always at least 1 SigArea form so this is OK

  var
  EditMode : boolean; // set globally!
  MacroList : tMacroList; // owned and maintained externally by a SigFile object but stored here to simplfy access


implementation

{$R *.dfm}

{ tSigAreas }

constructor tSigAreas.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigArea );

end;

function tSigAreas.GetAreaWithName(const s: string): tSigArea;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    Result := Area[ i ];
    if SameText( s, Result.Name) then
    begin
      exit;
    end;
  end;
  // else
  Result := nil;
end;

function tSigAreas.GetSigArea(const i: integer): tSigArea;
begin
  Result := Entry[ i ] as tSigArea;
end;

{ tSigArea }

constructor tSigArea.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  fFormType := tSigAreaFormType.Create( 'Form Type', self );
  fName     := tSigSimpleProperty.Create( 'Area Name', self );
  fPicture  := tSigSimpleProperty.Create( 'Picture', self );

end;

procedure tSigArea.Edit;
begin
  with FormEditArea do
  begin
    FormType := self.FormType;
    AreaName := self.Name;
    Picture := self.Picture;
    if Execute then
    begin
      self.Picture := Picture;
      self.Name := AreaName;
      self.FormType := FormType;
    end;
  end;
end;

function tSigArea.GetFormType: tSigFormType;
begin
  Result := fFormType.FormType;
end;

function tSigArea.GetName: string;
begin
  Result := fName.Value;
end;

function tSigArea.GetPicture: string;
begin
  Result := fPicture.Value;
end;

procedure tSigArea.SetFormArea(const Value: tFormSigArea);
begin
  FFormArea := Value;
end;

procedure tSigArea.SetFormType(const Value: tSigFormType);
begin
  fFormType.FormType := Value;
end;

procedure tSigArea.SetName(const Value: string);
begin
  fName.Value := Value;
end;

procedure tSigArea.SetPicture(const Value: string);
begin
  fPicture.Value := Value;
end;

procedure tSigArea.SetVisible(const Value: boolean);
begin
  fVisible := Value;
  if Value then
  begin
    case FormType of
      ftNormal:
      begin
        if not assigned( fFormArea ) then
        begin
          fFormArea := FormSigArea;
        end
        else if fFormArea <> FormSigArea then
        begin
          fFormArea.Release;
          fFormArea := FormSigArea;
        end;
      end;
      ftFloat:
      begin
        if not assigned( fFormArea ) then
        begin
          fFormArea := tFormSigArea.Create( Application );
        end
        else if fFormArea = FormSigArea then
        begin
          fFormArea := tFormSigArea.Create( Application );
        end;
      end;
    end;
  end
  else
  begin
    if assigned( fFormArea) then
    begin
      fFormArea.Hide;
    end;
  end;
end;

{ tSigAreaFormType }

function tSigAreaFormType.GetFormType: tSigFormType;
begin
  Result := tSigFormType( ValueAsInt );
end;

procedure tSigAreaFormType.SetFormType(const Value: tSigFormType);
begin
  ValueAsInt := Ord(Value);
end;

{ tSigComponent }

constructor tSigComponent.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  fTop := tSigIntegerProperty.Create( 'Top', self );
  fLeft := tSigIntegerProperty.Create( 'Left', self );
  fWidth := tSigIntegerProperty.Create( 'Width', self );
  fHeight := tSigIntegerProperty.Create( 'Height', self );

end;

function tSigComponent.GetControlOwner: tComponent;
begin
  Result := Control.Owner;
end;

function tSigComponent.GetControlParent: tWinControl;
begin
  Result := Control.Parent;
end;

function tSigComponent.GetHeight: integer;
begin
  Result := fHeight.ValueAsInt;
end;

function tSigComponent.GetLeft: integer;
begin
  Result := fLeft.ValueAsInt;
end;

function tSigComponent.GetOwner: tSigComponent;
begin
  Result := fOwner as tSigComponent;
end;

function tSigComponent.GetTop: integer;
begin
  Result := fTop.ValueAsInt;
end;

function tSigComponent.GetWidth: integer;
begin
  Result := fWidth.ValueAsInt;
end;

procedure tSigComponent.SetControl(const Value: tControl);
begin
  fControl := Value;
  if OwnerAsSigComponent.Control is tWinControl then
  begin
    fControl.Parent := (OwnerAsSigComponent.Control as tWinControl);
  end
  else
  begin
    fControl.Parent := OwnerAsSigComponent.ControlParent;
  end;

end;

procedure tSigComponent.SetControlParent(const Value: tWinControl);
begin
  fControl.Parent := Value;
end;

procedure tSigComponent.SetHeight(const Value: integer);
begin
  fHeight.ValueAsInt := Value;
end;

procedure tSigComponent.SetLeft(const Value: integer);
begin
  fLeft.ValueAsInt := Value;
  Control.Left := Value;
end;

procedure tSigComponent.SetTop(const Value: Integer);
begin
  fTop.ValueAsInt := Value;
  Control.Top := Value;
end;

procedure tSigComponent.SetWidth(const Value: integer);
begin
  fWidth.ValueAsInt := Value;
end;

{ tUsers }

constructor tUsers.Create(pPropertyName: string; pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tUser );
  // add the 8 default users
  Max := 7;

  with User[ 0 ] do
  begin
    Name := 'Unregulated';
    Pin  := '';  // unregulated has no pin by default
  end;

  with User[ 1 ] do
  begin
    Name := 'Fire Officer';
    Pin  := '3333';  // unregulated has no pin
  end;

  with User[ 2 ] do
  begin
    Name := 'Supervisor';
    Pin  := '2222';  // unregulated has no pin
  end;

  with User[ 3 ] do
  begin
    Name := 'Engineer';
    Pin  := '4444';  // unregulated has no pin
  end;

  with User[ 4 ] do
  begin
    Name := 'User 1';
    Pin  := '0001';  // unregulated has no pin
  end;

  with User[ 5 ] do
  begin
    Name := 'User 2';
    Pin  := '0002';  // unregulated has no pin
  end;

  with User[ 6 ] do
  begin
    Name := 'User 3';
    Pin  := '0003';  // unregulated has no pin
  end;

  with User[ 7 ] do
  begin
    Name := 'User 4';
    Pin  := '0004';  // unregulated has no pin
  end;

end;

function tUsers.GetUser(const i: integer): tUser;
begin
  result := Entry[ i ] as tUser;
end;

{ tUser }

constructor tUser.Create(pPropertyName: string; pOwner: tSigCompoundProperty);
begin
  inherited;
  fName := tSigSimpleProperty.Create( 'Name', self );
  fPIN  := tSigSimpleProperty.Create( 'PIN', self );
  fTimeOut := tSigIntegerProperty.Create( 'Timeout', self );
  fChimeOpts := tSigIntegerProperty.Create( 'Chime Count', self );
  fChimeTime := tSigIntegerProperty.Create( 'Chime Time', self );
  fUserOptions := tSigObjectArray.Create( 'User options', self, tSigBooleanProperty ); // populated, at least in part by host

  ChimeOptions := coAsUnregulated;

end;

procedure tUser.Edit;
begin
  // to do
end;

function tUser.GetChimeOpts: tChimeOptions;
begin
  Result := tChimeOptions( fChimeOpts.ValueAsInt );
end;

function tUser.GetChimeTime: integer;
begin
  Result := fChimeTime.ValueAsInt;
end;

function tUser.GetName: string;
begin
  Result := fName.Value;
end;

function tUser.GetPIN: string;
begin
  Result := fPIN.Value;
end;

function tUser.GetTimeout: integer;
begin
  Result := fTimeOut.ValueAsInt;
end;

procedure tUser.SetChimeOpts(const Value: tChimeOptions);
begin
  fChimeOpts.ValueAsInt := Ord( Value );
{
  case Value of
    co0Chimes: ChimeTime := dc0chimes;
    co1Chime:  ChimeTime := dc1chime;
    co2Chimes: ChimeTime := dc2chimes;
    co3Chimes: ChimeTime := dc3Chimes;
    coAsUnregulated:  ChimeTime := dc0chimes; // but don't really care
  end;
}
end;

procedure tUser.SetChimeTime(const Value: integer);
begin
  fChimeTime.ValueAsInt := Value;
end;

procedure tUser.SetName(const Value: string);
begin
  fName.Value := Value;
end;

procedure tUser.SetPIN(const Value: string);
begin
  fPIN.Value := Value;
end;

procedure tUser.SetTimeout(const Value: integer);
begin
  fTimeout.ValueAsInt := Value;
end;

{ tSigEditableCfg }

constructor tSigEditableCfg.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  fUsers := tUsers.Create( 'Users', self );
  fSigAreas := tSigAreas.Create( 'Users', self );
end;

{ tSigButton }

procedure tSigButton.Click;
begin
  Macro.Click;
end;

constructor tSigButton.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  fMacroName := tSigSimpleProperty.Create( 'Macro', self);

end;

function tSigButton.GetMacro: tMacro;
begin
  Result := MacroList.MacroByName[ fMacroName.Value ];
end;

procedure tSigButton.SetMacro(const Value: tMacro);
begin
  fMacroName.Value := Value.Name; // confusing but....
end;

{ tSigButtonSet }

constructor tSigButtonSet.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigButton );

end;

{ tMacro }

procedure tMacro.ActionClick;
begin
  if ClickIndex < Count then
  begin
    Action[ ClickIndex ].Click;
    if not Action[ ClickIndex ].WaitForCompletion then
    begin
      OnActionComplete( Action[ ClickIndex ] );
    end;
  end;
end;

procedure tMacro.Click;
begin
  ClickIndex := 0;
  ActionClick;
end;

constructor tMacro.Create(pPropertyName: string; pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner );
  fName := tSigSimpleProperty.Create( 'Name', self );
  fActionList := tSigActionList.Create( 'Action List', self );

end;

function tMacro.GetAction(const i: integer): tSigPCAction;
begin
  Result := fActionList.Entry[ i ] as tSigPCAction;
end;

function tMacro.GetName: string;
begin
  Result := fName.Value;
end;

procedure tMacro.OnActionComplete( const Sender : tSigPCAction );
begin
  if ClickIndex < Count then
  begin
    if Sender = Action[ ClickIndex ] then
    begin
      // saftey first in case a non-wait for object issues a completion action
      inc( ClickIndex );
      ActionClick;
    end;
  end;
end;

procedure tMacro.SetName(const Value: string);
begin
  fName.Value := Value;
end;

{ tSigPCAction }

constructor tSigPCAction.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited;
  fWaitForCompletion := tSigBooleanProperty.Create( 'Wait for Completion', self );
  WaitForCompletion := FALSE;

end;

function tSigPCAction.GetMacro: tMacro;
begin
  Result := Owner as tMacro;
end;

function tSigPCAction.GetWaitForCompletion: boolean;
begin
  Result := fWaitForCompletion.ValueAsBool;
end;

procedure tSigPCAction.SetWaitForCompletion(const Value: boolean);
begin
  fWaitForCompletion.ValueAsBool := Value;
end;

{ tSigActionList }

constructor tSigActionList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigPCAction );
end;

{ tMacroList }

constructor tMacroList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tMacro );

end;

function tMacroList.GetMacro(const i: integer): tMacro;
begin
  Result := Entry[ i ] as tMacro;
end;

function tMacroList.GetMacroByName(const s: string): tMacro;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    if SameText( s, Macro[ i ].Name) then
    begin
      Result := Macro[ i ];
      exit;
    end;
  end;
  // else
  Result := nil;
end;

{ tSigLinkList }

constructor tSigLinkList.Create(pPropertyName: string;
  pOwner: tSigCompoundProperty);
begin
  inherited Create( pPropertyName, pOwner, tSigLink );

end;

function tSigLinkList.GetSigLink( const i : integer ) : tSigLink;
begin
  Result := Entry[ i ] as tSigLink;
end;

end.
