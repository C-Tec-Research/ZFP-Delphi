unit UnitBiDiMonitor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, ComCtrls, StdCtrls, Grids, SigNETStringGrid, Buttons;

type
  tDisplayFormat = ( dfASCII, dfHex, dfAFP );

type
  tAFPRecState = ( rsEmpty, rsSOHRcvd, rsRecTypeRcvd, rsDataLengthRcvd, rsDataRcvd, rsComplete, rsErr );

type
  tDisplay = class;

  tAFPRec = class
  private
    fRecordState: tAFPRecState;
    fRecordType: byte;
    fAFPHexgrid: tSigNETStringGrid;
    fRecLen: integer;
    fAFPASCIIgrid: tSigNETStringGrid;
    iX : integer; // used to keep track of rows
    fCharsRcvd : integer;
    fChecksumRcvd: byte;
    fChecksum: byte;
    fData: string;
    fHexData: string;
    fOwner: tDisplay;
    fUsesSOH: boolean;
    procedure SetAFPHexGrid(const Value: tSigNETStringGrid);
    procedure SetRecordState(const Value: tAFPRecState);
    procedure SetAFPASCIIGrid(const Value: tSigNETStringGrid);
    procedure SetChecksum(const Value: byte);
    procedure SetChecksumRcvd(const Value: byte);
  public
    constructor Create( const pOwner : tDisplay );
    property RecordState : tAFPRecState
             read fRecordState
             write SetRecordState;
    procedure AddByte( const NewVal : byte );
    property RecordType : byte
             read fRecordType;
    property AFPHexGrid : tSigNETStringGrid
             read fAFPHexgrid
             write SetAFPHexGrid;
    property AFPASCIIGrid : tSigNETStringGrid
             read fAFPASCIIgrid
             write SetAFPASCIIGrid;
    property RecLen : integer
             read fRecLen;
    property Checksum : byte
             read fChecksum
             write SetChecksum;
    property ChecksumRcvd : byte
             read fChecksumRcvd
             write SetChecksumRcvd;
    function ChecksumOK : boolean;
    property Data : string
             read fData;
    property HexData : string
             read fHexData;
    procedure Clear;
    procedure AddData( NewVal : byte );
    property Owner : tDisplay
             read fOwner;
    procedure AddBlankLine;
    procedure AddBlankLineForced;
    property UsesSOH : boolean
             read fUsesSOH
             write fUsesSOH;
  end;

  TFormBiDiMonitor = class;

  tDisplay = class
  private
    fDisplayFormat: tDisplayFormat;
    fCaption: string;
    fAFPRec: tAFPRec;
    fOwner: TFormBiDiMonitor;
    function GetAFPHexgrid: tSigNETStringGrid;
    procedure SetAFPHexGrid(const Value: tSigNETStringGrid);
    function GetAFPASCIIgrid: tSigNETStringGrid;
    procedure SetAFPASCIIGrid(const Value: tSigNETStringGrid);
    function GetUsesSOH: boolean;
    procedure SetUsesSOH(const Value: boolean);
  public
    constructor Create( const pOwner : TFormBiDiMonitor );
    destructor Destroy; override;
    property DisplayFormat : tDisplayFormat
             read fDisplayFormat
             write fDisplayFormat;
    property Caption : string
             read fCaption
             write fCaption;
    property AFPHexGrid : tSigNETStringGrid
             read GetAFPHexgrid
             write SetAFPHexGrid;
    property AFPASCIIGrid : tSigNETStringGrid
             read GetAFPASCIIgrid
             write SetAFPASCIIGrid;
    procedure AddChar( const NewVal : char );
    property AFPRec : tAFPRec
             read fAFPRec;
    property Owner : TFormBiDiMonitor
             read fOwner;
    procedure AddBlankLine;
    procedure AddBlankLineForced;
    property UsesSOH : boolean
             read GetUsesSOH
             write SetUsesSOH;
  end;

  TFormBiDiMonitor = class(TForm)
    PanelOptions: TPanel;
    PanelTx: TPanel;
    PanelRcv: TPanel;
    CheckBoxLinkFormats: TCheckBox;
    PageControlTx: TPageControl;
    TabSheetTxASCII: TTabSheet;
    TabSheetTxHex: TTabSheet;
    PageControlRx: TPageControl;
    TabSheetRxASCII: TTabSheet;
    TabSheetRxHex: TTabSheet;
    TabSheetTxAFP: TTabSheet;
    TabSheetRxAFP: TTabSheet;
    PageControlTxAFP: TPageControl;
    TabSheetRxAFPHex: TTabSheet;
    TabSheetTxAFPASCII: TTabSheet;
    PanelTransmissionCaption: TPanel;
    PanelReceptionCaption: TPanel;
    SigNETStringGridTxAFPHex: TSigNETStringGrid;
    SigNETStringGridTxAFPASCII: TSigNETStringGrid;
    PageControlRxAFP: TPageControl;
    TabSheet1: TTabSheet;
    SigNETStringGridRxAFPHex: TSigNETStringGrid;
    TabSheet2: TTabSheet;
    SigNETStringGridRxAFPASCII: TSigNETStringGrid;
    SpeedButton1: TSpeedButton;
    procedure FormResize(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    fTx: tDisplay;
    fRx: tDisplay;
    fNonClientWidthRxAFP : integer;
    fNonClientWidthTxAFP : integer;
    function GetTxCaption: string;
    procedure SetTxCaption(const Value: string);
    function GetRxCaption: string;
    procedure SetRxCaption(const Value: string);
    function GetRxDisplayFormat: tDisplayFormat;
    function GetTxDisplayFormat: tDisplayFormat;
    procedure SetRxDisplayFormat(const Value: tDisplayFormat);
    procedure SetTxDisplayFormat(const Value: tDisplayFormat);
    function GetLinkFormats: boolean;
    procedure SetLinkFormats(const Value: boolean);
    { Private declarations }
  public
    { Public declarations }
    property Tx : tDisplay
             read fTx;
    property Rx : tDisplay
             read fRx;
    property TxCaption : string
             read GetTxCaption
             write SetTxCaption;
    property RxCaption : string
             read GetRxCaption
             write SetRxCaption;
    property TxDisplayFormat : tDisplayFormat
             read GetTxDisplayFormat
             write SetTxDisplayFormat;
    property RxDisplayFormat : tDisplayFormat
             read GetRxDisplayFormat
             write SetRxDisplayFormat;
    property LinkFormats : boolean
             read GetLinkFormats
             write SetLinkFormats;
    constructor Create( AOwner: TComponent); override;
    destructor Destroy; override;
    procedure AddBlankLine;
    procedure AddTxChar( const NewVal : char );
    procedure AddRxChar( const NewVal : char );
    procedure AddTxString( const NewVal : string );
    procedure AddRxString( const NewVal : string );
    procedure Clear;
  end;

var
  FormBiDiMonitor: TFormBiDiMonitor;

implementation

{$R *.dfm}

const
  _AFPDataCol : integer = 5;
  _AFPRecTypeCol : integer = 1;
  _AFPRecLenCol : integer = 2;
  _AFPChecksumCol : integer = 3;
  _AFPCSRcvdCol : integer = 4;

{ TFormBiDiMonitor }

procedure TFormBiDiMonitor.AddBlankLine;
begin
  // Force add a blank line to all record based tables
  fTx.AddBlankLineForced;
  fRx.AddBlankLineForced;
end;

procedure TFormBiDiMonitor.AddRxChar(const NewVal: char);
begin
  fRx.AddChar( NewVal );
end;

procedure TFormBiDiMonitor.AddRxString(const NewVal: string);
var
  i: Integer;
begin
  for i := 1 to Length( NewVal ) do
  begin
    AddRxChar( NewVal[ i ] );
  end;
end;

procedure TFormBiDiMonitor.AddTxChar( const NewVal: char );
begin
  fTx.AddChar( NewVal );
end;

procedure TFormBiDiMonitor.AddTxString(const NewVal: string);
var
  i: Integer;
begin
  for i := 1 to Length( NewVal ) do
  begin
    AddTxChar( NewVal[ i ] );
  end;
end;

procedure TFormBiDiMonitor.Clear;
begin
  SigNETStringGridTxAFPHex.RowCount := 1;
  SigNETStringGridTxAFPASCII.RowCount := 1;
  SigNETStringGridRxAFPHex.RowCount := 1;
  SigNETStringGridRxAFPASCII.RowCount := 1;
  AddBlankLine;
end;

constructor TFormBiDiMonitor.Create(AOwner: TComponent);
begin
  inherited;
  fTx := tDisplay.Create( self );
  fRx := tDisplay.Create( self );
  TxCaption := 'Transmission';
  RxCaption := 'Reception';
  LinkFormats := TRUE;
  fNonClientWidthRxAFP := SigNETStringGridRxAFPASCII.ClientWidth - SigNETStringGridRxAFPASCII.ColWidths[ _AFPDataCol ];
  fNonClientWidthTxAFP := SigNETStringGridTxAFPASCII.ClientWidth - SigNETStringGridTxAFPASCII.ColWidths[ _AFPDataCol ];
  fTx.AFPASCIIGrid := SigNETStringGridTxAFPASCII;
  fRx.AFPASCIIGrid := SigNETStringGridRxAFPASCII;
  fTx.AFPHexGrid := SigNETStringGridTxAFPHex;
  fRx.AFPHexGrid := SigNETStringGridRxAFPHex;
  fTx.UsesSOH := TRUE;  // default states
  fRx.UsesSOH := FALSE;
end;

destructor TFormBiDiMonitor.Destroy;
begin
  fTx.Free;
  fRx.Free;
  inherited;
end;

procedure TFormBiDiMonitor.FormResize(Sender: TObject);
begin
  PanelTx.Width := ClientWidth div 2;
  SigNETStringGridRxAFPASCII.ColWidths[ _AFPDataCol ] := SigNETStringGridRxAFPASCII.ClientWidth - fNonClientWidthRxAFP;
  SigNETStringGridTxAFPASCII.ColWidths[ _AFPDataCol ] := SigNETStringGridTxAFPASCII.ClientWidth - fNonClientWidthTxAFP;
  SigNETStringGridRxAFPHex.ColWidths[ _AFPDataCol ] := SigNETStringGridRxAFPHex.ClientWidth - fNonClientWidthRxAFP;
  SigNETStringGridTxAFPHex.ColWidths[ _AFPDataCol ] := SigNETStringGridTxAFPHex.ClientWidth - fNonClientWidthTxAFP;
end;

function TFormBiDiMonitor.GetLinkFormats: boolean;
begin
  Result := CheckBoxLinkFormats.Checked;
end;

function TFormBiDiMonitor.GetRxCaption: string;
begin
  Result := Rx.Caption;
end;

function TFormBiDiMonitor.GetRxDisplayFormat: tDisplayFormat;
begin
  Result := Rx.DisplayFormat;
end;

function TFormBiDiMonitor.GetTxCaption: string;
begin
  Result := Tx.Caption;
end;

function TFormBiDiMonitor.GetTxDisplayFormat: tDisplayFormat;
begin
  Result := Tx.DisplayFormat;
end;

procedure TFormBiDiMonitor.SetLinkFormats(const Value: boolean);
begin
  CheckBoxLinkFormats.Checked := Value;
end;

procedure TFormBiDiMonitor.SetRxCaption(const Value: string);
begin
  Rx.Caption := Value;
  // update screens
  PanelReceptionCaption.Caption := Value;
end;

procedure TFormBiDiMonitor.SetRxDisplayFormat(const Value: tDisplayFormat);
begin
  Rx.DisplayFormat := Value;
  // set visual display
end;

procedure TFormBiDiMonitor.SetTxCaption(const Value: string);
begin
  Tx.Caption := Value;
  // update screens
  PanelTransmissionCaption.Caption := Value;
end;

procedure TFormBiDiMonitor.SetTxDisplayFormat(const Value: tDisplayFormat);
begin
  Tx.DisplayFormat := Value;
  // set visual display
end;

procedure TFormBiDiMonitor.SpeedButton1Click(Sender: TObject);
begin
  Clear;
end;

{ tAFPRec }

procedure tAFPRec.AddBlankLine;
begin
  if fAFPHexgrid.Cells[ 0, iX ] <> '' then
  begin
    fOwner.AddBlankLine;
  end
  else
  begin
    Clear;
  end;
end;

procedure tAFPRec.AddBlankLineForced;
var
  i : integer;
begin
  Clear;
  iX := fAFPHexgrid.RowCount;
  fAFPHexgrid.RowCount := iX + 1;
  fAFPASCIIgrid.RowCount := iX + 1;
  for i := 0 to _AFPDataCol do
  begin
    fAFPHexgrid.Cells[ i, iX ] := '';
    fAFPASCIIgrid.Cells[ i, iX ] := '';
  end;
end;

procedure tAFPRec.AddByte(const NewVal: byte);
begin
  case RecordState of
    rsEmpty:
    begin
      AddBlankLine;
      fAFPHexgrid.Cells[ 0, iX ] := IntToStr( iX );
      fAFPASCIIgrid.Cells[ 0, iX ] := IntToStr( iX );
      case NewVal of
        1:
        begin
          RecordState := rsSOHRcvd;
        end;
        6:
        begin
          fAFPHexgrid.Cells[ _AFPDataCol, iX ] := '<ACK>';
          fAFPASCIIgrid.Cells[ _AFPDataCol, iX ] := '<ACK>';
          RecordState := rsComplete;
        end;
        21:
        begin
          fAFPHexgrid.Cells[ _AFPDataCol, iX ] := '<NAK>';
          fAFPASCIIgrid.Cells[ _AFPDataCol, iX ] := '<NAK>';
          RecordState := rsComplete;
        end;
        else
        begin
          if UsesSOH then
          begin
            fAFPHexgrid.Cells[ _AFPRecTypeCol, iX ] := '<ERR>';
            fAFPASCIIgrid.Cells[ _AFPRecTypeCol, iX ] := '<ERR>';
            AddData( NewVal );
            RecordState := rsErr;
          end
          else
          begin
            // treat as if SOH implicitly rcvd
            RecordState := rsSOHRcvd;
            AddByte( NewVal );
          end;
        end;
      end;
    end;
    rsErr:
    begin
      case NewVal of
        1, 6, 21:
        begin
          RecordState := rsEmpty;
          AddByte( NewVal );
        end;
        else
        begin
          AddData( NewVal );
        end;
      end;
    end;
    rsSOHRcvd:
    begin
      fAFPHexgrid.Cells[ _AFPRecTypeCol, iX ] := IntToHex( NewVal, 2 );
      fAFPASCIIgrid.Cells[ _AFPRecTypeCol, iX ] := IntToHex( NewVal, 2 );
      RecordState := rsRecTypeRcvd;
      Checksum := NewVal;
    end;
    rsRecTypeRcvd:
    begin
      fRecLen := NewVal;
      fCharsRcvd := 0;
      fAFPHexgrid.Cells[ _AFPRecLenCol, iX ] := IntToStr( NewVal );
      fAFPASCIIgrid.Cells[ _AFPRecLenCol, iX ] := IntToStr( NewVal );
      Checksum := Checksum + NewVal;
      if NewVal = 0 then
      begin
        // no data
        RecordState := rsDataRcvd;
      end
      else
      begin
        RecordState := rsDataLengthRcvd;
      end;
    end;
    rsDataLengthRcvd:
    begin
      AddData( NewVal );
      if fCharsRcvd = self.fRecLen then
      begin
        RecordState := rsDataRcvd;
      end;
    end;
    rsDataRcvd:
    begin
      ChecksumRcvd := NewVal;
      RecordState := rsComplete;
    end;
    rsComplete:
    begin
      RecordState := rsEmpty;
      AddByte( NewVal );
    end;
  end;
end;

procedure tAFPRec.AddData(NewVal: byte);
begin
  fCharsRcvd := fCharsRcvd + 1;
  fHexData := fHexData + intToHex( NewVal, 2 ) + ' ';
  fData := fData + chr( NewVal );
  fAFPHexgrid.Cells[ _AFPDataCol, iX ] := fHexData;
  fAFPASCIIgrid.Cells[ _AFPDataCol, iX ] := fData;
  if RecordState <> rsErr then
  begin
    Checksum := Checksum + NewVal;
  end;
end;

function tAFPRec.ChecksumOK: boolean;
begin
  Result := fChecksumRcvd = fChecksum;
end;

procedure tAFPRec.Clear;
begin
  fData := '';
  fHexData := '';
  RecordState := rsEmpty;
end;

constructor tAFPRec.Create( const pOwner : tDisplay );
begin
  inherited Create;
  fRecordState := rsEmpty;
  fOwner := pOwner;
end;

procedure tAFPRec.SetAFPASCIIGrid(const Value: tSigNETStringGrid);
begin
  fAFPASCIIgrid := Value;
  with fAFPASCIIGrid do
  begin
    RowCount := 1;
    Cells[ 0, 0 ] := 'Rec';
    Cells[ _AFPRecTypeCol, 0 ] := 'Type';
    Cells[ _AFPRecLenCol, 0 ] := 'Len';
    Cells[ _AFPDataCol, 0 ] := 'Data';
    Cells[ _AFPChecksumCol, 0 ] := 'CS';
    Cells[ _AFPCSRcvdCol, 0 ] := 'CS Rcvd';
  end;
end;

procedure tAFPRec.SetAFPHexGrid(const Value: tSigNETStringGrid);
begin
  fAFPHexgrid := Value;
  with fAFPHexgrid do
  begin
    ColCount := _AFPDataCol + 1;
    RowCount := 1;
    Cells[ 0, 0 ] := 'Rec';
    Cells[ _AFPRecTypeCol, 0 ] := 'Type';
    Cells[ _AFPRecLenCol, 0 ] := 'Len';
    Cells[ _AFPDataCol, 0 ] := 'Data';
    Cells[ _AFPChecksumCol, 0 ] := 'CS';
    Cells[ _AFPCSRcvdCol, 0 ] := 'CS Rcvd';
  end;
end;

procedure tAFPRec.SetChecksum(const Value: byte);
begin
  fChecksum := Value;
  fAFPHexgrid.Cells[ _AFPChecksumCol, iX ] := IntToHex( Value, 2 );
  fAFPASCIIgrid.Cells[ _AFPChecksumCol, iX ] := IntToHex( Value, 2 );
end;

procedure tAFPRec.SetChecksumRcvd(const Value: byte);
begin
  fChecksumRcvd := Value;
  fAFPHexgrid.Cells[ _AFPCSRcvdCol, iX ] := IntToHex( Value, 2 );
  fAFPASCIIgrid.Cells[ _AFPCSRcvdCol, iX ] := IntToHex( Value, 2 );
end;

procedure tAFPRec.SetRecordState(const Value: tAFPRecState);
begin
  fRecordState := Value;
end;

{ tDisplay }

procedure tDisplay.AddBlankLine;
begin
  fOwner.AddBlankLine;
end;

procedure tDisplay.AddBlankLineForced;
begin
  AFPRec.AddBlankLineForced;
end;

procedure tDisplay.AddChar(const NewVal: char);
begin
  //
  AFPRec.AddByte( ord( NewVal ));
end;

constructor tDisplay.Create( const pOwner : TFormBiDiMonitor );
begin
  inherited Create;
  fOwner := pOwner;
  fAFPRec := tAFPRec.Create( self );
end;

destructor tDisplay.Destroy;
begin
  fAFPRec.Free;
  inherited;
end;

function tDisplay.GetAFPASCIIgrid: tSigNETStringGrid;
begin
  Result := AFPRec.AFPASCIIGrid;
end;

function tDisplay.GetAFPHexgrid: tSigNETStringGrid;
begin
  Result := AFPRec.AFPHexGrid;
end;

function tDisplay.GetUsesSOH: boolean;
begin
  Result := AFPRec.UsesSOH;
end;

procedure tDisplay.SetAFPASCIIGrid(const Value: tSigNETStringGrid);
begin
  AFPRec.AFPASCIIGrid := Value;
end;

procedure tDisplay.SetAFPHexGrid(const Value: tSigNETStringGrid);
begin
  AFPRec.AFPHexGrid := Value;
end;

procedure tDisplay.SetUsesSOH(const Value: boolean);
begin
  AFPRec.UsesSOH := Value;
end;

end.
