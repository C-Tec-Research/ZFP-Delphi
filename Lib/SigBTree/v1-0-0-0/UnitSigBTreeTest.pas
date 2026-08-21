unit UnitSigBTreeTest;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  SigBTree, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons;

type

  tBTreeNode = class( tSigBTreeNodeMemory )
  private
    fName: string;
  protected
  public

    property Name : string
             read fName
             write fName;

    function NodeText : string; override;  // returns the text to be displayed visually
  end;

type
  TFormBTreeTest = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    BitBtn1: TBitBtn;
    PaintBoxBinaryTree: TPaintBox;
    EditAdd: TEdit;
    SpeedButtonAdd: TSpeedButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButtonAddClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditAddKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
    BTRoot : tSigDBTreeRoot;
  public
    { Public declarations }
  end;

var
  FormBTreeTest: TFormBTreeTest;

implementation

{$R *.dfm}

procedure TFormBTreeTest.BitBtn1Click(Sender: TObject);
begin
  Close;
end;

{ tBTreeNode }

function tBTreeNode.NodeText: string;
begin
  Result := fName + '(' + IntToStr( TreeDepth ) + ')';
end;

procedure TFormBTreeTest.EditAddKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    SpeedButtonAddClick( Sender );
  end;
end;

procedure TFormBTreeTest.FormDestroy(Sender: TObject);
begin
  BTRoot.Free;
end;

procedure TFormBTreeTest.FormShow(Sender: TObject);
begin
  BTRoot := tSigDBTreeRoot.Create;
  BTRoot.PaintBox := PaintBoxBinaryTree;
end;

procedure TFormBTreeTest.SpeedButtonAddClick(Sender: TObject);
var
  iNewVal : tBTreeNode;
begin
  iNewVal := tBTreeNode.Create;
  iNewVal.Name := EditAdd.Text;
  EditAdd.Text := '';
  BTRoot.Add( iNewVal );
end;

end.
