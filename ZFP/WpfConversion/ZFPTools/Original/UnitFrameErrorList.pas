unit UnitFrameErrorList;

interface

{
  This is a helper frame giving a unified appearance for handling an Error list.
  It does no navigation to the error, just visually represents an error list.
  It uses the translate function of the Error List where required (if present)
}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  ErrorList,
  Vcl.Grids,
  SigGeneralGrid,
  Vcl.ImgList,
  Vcl.Menus,
  System.Contnrs,
  System.UITypes, System.ImageList
  ;

type
  tErrorDblClick = procedure( const Sender : TObject; const pErrorObject : tError ) of object;

type

  TFrameErrorLists = class;

  TFrameErrorList = class(TFrame)
    SigGeneralGridErrors: TSigGeneralGrid;
    ImageListStatus: TImageList;
    tSigGridEditorStatus: tSigGridEditor;
    tSigGridEditorErrorText: tSigGridEditor;
    PopupMenu: TPopupMenu;
    Prev1: TMenuItem;
    Next1: TMenuItem;
    Goto1: TMenuItem;
    Remove1: TMenuItem;
    N1: TMenuItem;
    Close1: TMenuItem;
    procedure SigGeneralGridErrorsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FrameResize(Sender: TObject);
    procedure PopupMenuPopup(Sender: TObject);
    procedure Prev1Click(Sender: TObject);
    procedure Next1Click(Sender: TObject);
    procedure Goto1Click(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);
  private
    fErrorList: TErrorList;
    fOnErrorDblClick: tErrorDblClick;
    fHighlighted : integer;
    fOnClose: tNotifyEvent;
    fRow : integer;
    fFrameList: TFrameErrorLists;
    procedure SetErrorList(const Value: tErrorList);
    procedure SetHighlighted(const Value: integer);
    { Private declarations }
  public
    { Public declarations }
    property ErrorList : tErrorList
             read fErrorList
             write SetErrorList;
    property Highlighted : integer
             read fHighlighted
             write SetHighlighted;
    function Translate( const pString : string ) : string;

  published
    property OnErrorDblClick : tErrorDblClick
             read fOnErrorDblClick
             write fOnErrorDblClick;
    property OnClose : tNotifyEvent
             read fOnClose
             write fOnClose;
    property FrameList : TFrameErrorLists // used to synchronise error lists,
             read fFrameList              // ie share events and highlights
             write fFrameList;
  end;

  TFrameErrorLists = class( tObjectList )
  private
    fOnErrorDblClick: tErrorDblClick;
    fErrorList: tErrorList;
    fHighlighted: integer;
    fOnClose: TNotifyEvent;
    procedure SetErrorList(const Value: tErrorList);
    procedure SetHighlighted(const Value: integer);
    function GetFrame(const i: integer): TFrameErrorList;
    procedure SetOnErrorDblClick(const Value: tErrorDblClick);
    // maintains a list of synchronised error lists
  public
    constructor Create; reintroduce;
    procedure Clear; override;

    procedure PopupMenuPopup(Sender: TFrameErrorList);
    procedure Prev1Click(Sender: TObject);
    procedure Next1Click(Sender: TObject);
    procedure Goto1Click(Sender: TObject);
    procedure Remove1Click(Sender: TObject);
    procedure Close1Click(Sender: TObject);

    function Add( pErrorList : TFrameErrorList ) : integer; reintroduce;
    property ErrorList : tErrorList
             read fErrorList
             write SetErrorList;
    property Highlighted : integer
             read fHighlighted
             write SetHighlighted;
    property Frame[ const i : integer ] : tFrameErrorList
             read GetFrame;

    procedure SyncHighlightWith( const pObject : tFrameErrorList );

    property OnErrorDblClick : tErrorDblClick
             read fOnErrorDblClick
             write SetOnErrorDblClick;
    property OnClose : tNotifyEvent
             read fOnClose
             write fOnClose;
  end;

implementation

{$R *.dfm}

{ TFrame1 }

procedure TFrameErrorList.Close1Click(Sender: TObject);
begin
  if assigned( fFrameList ) then
  begin
    fFrameList.Close1Click( Sender );
  end
  else if assigned( fOnClose ) then
  begin
    fOnClose( self );
  end
  else
  begin
    ErrorList := nil;
  end;
end;

procedure TFrameErrorList.FrameResize(Sender: TObject);
begin
  //
end;

procedure TFrameErrorList.Goto1Click(Sender: TObject);
begin
  if assigned( fFrameList ) then
  begin
    fFrameList.Goto1Click( Sender );
  end
  else
  begin
    if assigned( fOnErrorDblClick ) then
    begin
      fOnErrorDblClick( self, fErrorList.Error[ fRow - 1 ] );
    end;
  end;
end;

procedure TFrameErrorList.Next1Click(Sender: TObject);
begin
  if assigned( fFrameList ) then
  begin
    fFrameList.Next1Click( Sender );
  end
  else
  begin
    inc( fRow );
    Highlighted := fRow;
    Goto1Click( Sender );
  end;
end;

procedure TFrameErrorList.PopupMenuPopup(Sender: TObject);
begin
  if assigned( fFrameList ) then
  begin
    fFrameList.PopupMenuPopup( Self );
  end
  else
  begin
    Prev1.Enabled := fRow > 1;
    Next1.Enabled := (fRow >= 1) and (fRow < SigGeneralGridErrors.RowCount - 1);
    Goto1.Enabled := assigned( OnErrorDblClick ) and (fRow >= 1);
    Remove1.Enabled := (fRow >= 1) and (fRow < SigGeneralGridErrors.RowCount);
  end;
end;

procedure TFrameErrorList.Prev1Click(Sender: TObject);
begin
  if assigned( fFrameList ) then
  begin
    fFrameList.Prev1Click( Sender );
  end
  else
  begin
    if fRow > 1 then
    begin
      dec( fRow );
    end;
    Highlighted := fRow;
    Goto1Click( Sender );
  end;
end;

procedure TFrameErrorList.Remove1Click(Sender: TObject);
begin
  if assigned( fFrameList ) then
  begin
    fFrameList.Remove1Click( Sender );
  end
  else
  begin
    fErrorList.Delete( fRow - 1);
    if fErrorList.Count = 0 then
    begin
      Close1Click( Sender );
    end
    else
    begin
      ErrorList := fErrorList;  // force redisplay
      if fRow >= SigGeneralGridErrors.RowCount then
      begin
        Prev1Click( Sender );
      end
      else
      begin
        Goto1Click( Sender );
      end;
    end;
  end;
end;

procedure TFrameErrorList.SetErrorList(const Value: tErrorList);
var
  i : integer;
  iWidth, iTestWidth : integer;
  iText : string;
  iSaveStyle : TFontStyles;
begin
  iWidth := 60;
  fErrorList := Value;
  if assigned( fErrorList ) then
  begin
    if fErrorList.Count > 0 then
    begin
      Visible := TRUE;
      with SigGeneralGridErrors do
      begin
        iSaveStyle := Canvas.Font.Style;
        Canvas.Font.Style := [fsBold ];
        RowCount := fErrorList.Count + 1;
        for i := 1 to RowCount-1 do
        begin
          iText := fErrorList.Error[ i - 1 ].DetailedErrorText;
          Cell[ 0, i ] := IntToStr( Ord( fErrorList.Error[ i - 1 ].Severity ));
          Cell[ 1, i ] := iText;
          iTestWidth := Canvas.TextWidth( iText + 'W' );
          if iTestWidth > iWidth then
          begin
            iWidth := iTestWidth;
          end;
        end;
        Canvas.Font.Style := iSaveStyle;
      end;
      tSigGridEditorErrorText.ColWidth := iWidth;
    end
    else
    begin
      Visible := FALSE;
    end;
  end
  else
  begin
    Visible := FALSE;
  end;
end;

procedure TFrameErrorList.SetHighlighted(const Value: integer);
begin
  if fHighlighted <> Value then
  begin
    if fHighlighted in [1..SigGeneralGridErrors.RowCount] then
    begin
      SigGeneralGridErrors.Error[ 1, fHighlighted ] := FALSE;
    end;
    fHighlighted := Value;
    if fHighlighted in [1..SigGeneralGridErrors.RowCount - 1] then
    begin
      SigGeneralGridErrors.Error[ 1, fHighLighted ] := TRUE;
      SigGeneralGridErrors.RowVisible[ fHighlighted ] := TRUE;
    end;
  end;
end;

procedure TFrameErrorList.SigGeneralGridErrorsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  iCol : integer;
begin
  if assigned( fOnErrorDblClick ) then
  begin
    if assigned( fErrorList ) then
    begin
      if Shift = [ssDouble, ssLeft] then
      begin
        SigGeneralGridErrors.MouseToCell( X, Y, iCol, fRow );
        if fRow > 0 then
        begin
          Highlighted := fRow;
          {
          if fHighlighted in [1..SigGeneralGridErrors.RowCount] then
          begin
            SigGeneralGridErrors.Error[ 1, fHighlighted ] := FALSE;
          end;
          fHighlighted := iRow;
          SigGeneralGridErrors.Error[ 1, fHighLighted ] := TRUE;
          }
          fOnErrorDblClick( self, fErrorList.Error[ fRow - 1 ] );
        end;
      end
      else if Shift = [ssLeft] then
      begin
        SigGeneralGridErrors.MouseToCell( X, Y, iCol, fRow );
        if fRow > 0 then
        begin
          Highlighted := fRow;
        end;
      end
    end;
  end;
end;

function TFrameErrorList.Translate(const pString: string): string;
begin
  if assigned( ErrorList ) then
  begin
    Result := ErrorList.Translate( pString );
  end
  else
  begin
    Result := pString;
  end;
end;

{ TFrameErrorLists }

function TFrameErrorLists.Add(pErrorList: tFrameErrorList): integer;
begin
  Result := inherited Add( pErrorList );
  pErrorList.OnErrorDblClick := fOnErrorDblClick;
  pErrorList.ErrorList := fErrorList;
  pErrorList.FrameList := self;
  if assigned( fErrorList ) then
  begin
    pErrorList.Highlighted := fHighlighted;
  end;
end;

procedure TFrameErrorLists.Clear;
begin
  inherited;
  fHighlighted := 1;
end;

procedure TFrameErrorLists.Close1Click(Sender: TObject);
begin
  if assigned( fOnClose ) then
  begin
    fOnClose( self );
  end
  else
  begin
    ErrorList := nil;
  end;
end;

constructor TFrameErrorLists.Create;
begin
  inherited Create( FALSE ); // we don't own these objects
  fHighlighted := 1;
end;

function TFrameErrorLists.GetFrame(const i: integer): tFrameErrorList;
begin
  Result := Items[ i ] as tFrameErrorList;
end;

procedure TFrameErrorLists.Goto1Click(Sender: TObject);
begin
  if assigned( fErrorList ) then
  begin
    if assigned( fOnErrorDblClick ) and (Highlighted in [1.. fErrorList.Count] ) then
    begin
      fOnErrorDblClick( Sender, fErrorList.Error[ Highlighted - 1 ] );
    end;
  end;
end;

procedure TFrameErrorLists.Next1Click(Sender: TObject);
begin
  if Highlighted < (fErrorList.Count - 1) then
  begin
    Highlighted := Highlighted + 1;
    Goto1Click( Sender );
  end;
end;

procedure TFrameErrorLists.PopupMenuPopup(Sender: TFrameErrorList);
begin
  if assigned( fErrorList ) then
  begin
    Sender.Prev1.Enabled := Highlighted > 1;
    Sender.Next1.Enabled := (Highlighted >= 1) and (Highlighted < fErrorList.Count - 2);
    Sender.Goto1.Enabled := assigned( OnErrorDblClick ) and (Highlighted >= 1);
    Sender.Remove1.Enabled := (Highlighted >= 1) and (Highlighted < fErrorList.Count - 1);
  end;
end;

procedure TFrameErrorLists.Prev1Click(Sender: TObject);
begin
  if Highlighted > 1 then
  begin
    Highlighted := Highlighted - 1;
  end;
  Goto1Click( Sender );
end;

procedure TFrameErrorLists.Remove1Click(Sender: TObject);
var
  iSaveLine : integer;
begin
  if (Highlighted > 0) and (Highlighted <= fErrorList.Count ) then
  begin
    iSaveLine := Highlighted;
    fErrorList.Delete( Highlighted - 1);
    if fErrorList.Count = 0 then
    begin
      Close1Click( Sender );
    end
    else
    begin
      ErrorList := fErrorList;  // force redisplay
      if iSaveLine > fErrorList.Count then
      begin
        Prev1Click( Sender );
      end
      else
      begin
        Goto1Click( Sender );
      end;
    end;
  end;
end;

procedure TFrameErrorLists.SetErrorList(const Value: tErrorList);
var
  i: Integer;
begin
  fErrorList := Value;
  Highlighted := 1;
  for i := 0 to Count - 1 do
  begin
    Frame[ i ].ErrorList := Value;
  end;
  Goto1Click( self );
end;

procedure TFrameErrorLists.SetHighlighted(const Value: integer);
var
  i: Integer;
begin
  fHighlighted := Value;
  for i := 0 to Count - 1 do
  begin
    Frame[ i ].Highlighted := fHighlighted;
  end;
end;

procedure TFrameErrorLists.SetOnErrorDblClick(const Value: tErrorDblClick);
var
  i: Integer;
begin
  fOnErrorDblClick := Value;
  for i := 0 to Count - 1 do
  begin
    Frame[ i ].OnErrorDblClick := Value;
  end;
end;

procedure TFrameErrorLists.SyncHighlightWith(const pObject: tFrameErrorList);
//var
//  i: Integer;
begin
  {
  for i := 0 to Count - 1 do
  begin
    if Frame[ i ] <> pObject then
    begin
      Frame[ i ].Highlighted := pObject.Highlighted;
    end;
  end;
  }
  if assigned( pObject ) then
  begin
    Highlighted := pObject.Highlighted;
  end;
end;

end.
