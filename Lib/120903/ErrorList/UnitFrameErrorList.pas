unit UnitFrameErrorList;

interface

{
  This is a helper frame giving a unified appearance for handling an Error list.
  It does no navigation to the error, just visually represents an error list.
  It uses the translate function of the Error List where required (if present)
}

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  ErrorList, Vcl.Grids, SigGeneralGrid, Vcl.ImgList;

type
  tErrorDblClick = procedure( const Sender : TObject; const pErrorObject : tError ) of object;

type
  TFrameErrorList = class(TFrame)
    SigGeneralGridErrors: TSigGeneralGrid;
    ImageListStatus: TImageList;
    tSigGridEditorStatus: tSigGridEditor;
    tSigGridEditorErrorText: tSigGridEditor;
    procedure SigGeneralGridErrorsMouseDown(Sender: TObject;
      Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FrameResize(Sender: TObject);
  private
    fErrorList: tErrorList;
    fOnErrorDblClick: tErrorDblClick;
    fHighlighted : integer;
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
  end;

implementation

{$R *.dfm}

{ TFrame1 }

procedure TFrameErrorList.FrameResize(Sender: TObject);
begin
  //
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
    if Value > 0 then
    begin
      SigGeneralGridErrors.Error[ 1, fHighLighted ] := TRUE;
    end;
  end;
end;

procedure TFrameErrorList.SigGeneralGridErrorsMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  iRow, iCol : integer;
begin
  if assigned( fOnErrorDblClick ) then
  begin
    if assigned( fErrorList ) then
    begin
      if Shift = [ssDouble, ssLeft] then
      begin
        SigGeneralGridErrors.MouseToCell( X, Y, iCol, iRow );
        if iRow > 0 then
        begin
          Highlighted := iRow;
          {
          if fHighlighted in [1..SigGeneralGridErrors.RowCount] then
          begin
            SigGeneralGridErrors.Error[ 1, fHighlighted ] := FALSE;
          end;
          fHighlighted := iRow;
          SigGeneralGridErrors.Error[ 1, fHighLighted ] := TRUE;
          }
          fOnErrorDblClick( self, fErrorList.Error[ iRow - 1 ] );
        end;
      end;
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

end.
