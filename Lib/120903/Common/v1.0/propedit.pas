unit Propedit;

interface

uses WinTypes, WinProcs, Classes, Graphics, Forms, Controls, Buttons,
  StdCtrls, ExtCtrls, Grids;

type
  TDlgPropertyEditor = class(TForm)
    OKBtn: TBitBtn;
    CancelBtn: TBitBtn;
    HelpBtn: TBitBtn;
    Bevel1: TBevel;
    StringGridProperties: TStringGrid;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DlgPropertyEditor: TDlgPropertyEditor;

implementation

{$R *.DFM}

procedure TDlgPropertyEditor.FormCreate(Sender: TObject);
begin
  StringGridProperties.ColWidths[2] := 180;
  StringGridProperties.Cells[2,0] := 'Comments';
end;

end.
