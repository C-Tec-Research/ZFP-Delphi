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
    function Find( const pName : string ) : tBTreeNode;
    function LessThan( const SigTreeNode : tSigBTreeNode ) : boolean; override; // by default compares the NodeText
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
    SpeedButtonTimerTest: TSpeedButton;
    TimerRandomTest: TTimer;
    SpeedButtonClear: TSpeedButton;
    SpeedButtonRemove: TSpeedButton;
    procedure BitBtn1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure SpeedButtonAddClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure EditAddKeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButtonTimerTestClick(Sender: TObject);
    procedure TimerRandomTestTimer(Sender: TObject);
    procedure SpeedButtonClearClick(Sender: TObject);
    procedure SpeedButtonRemoveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
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

function tBTreeNode.Find(const pName: string): tBTreeNode;
begin
  if Name = pName then
  begin
    Result := self;
  end
  else if pName < Name then
  begin
    if assigned( LeftChild ) then
    begin
      Result := (LeftChild as tBTreeNode).Find( pName );
    end
    else
    begin
      Result := nil;
    end;
  end
  else
  begin
    if assigned( RightChild ) then
    begin
      Result := (RightChild as tBTreeNode).Find( pName );
    end
    else
    begin
      Result := nil;
    end;
  end;
end;

function tBTreeNode.LessThan(const SigTreeNode: tSigBTreeNode): boolean;
begin
  Result := Name < (SigTreeNode as tBTreeNode).Name;
end;

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

procedure TFormBTreeTest.FormCreate(Sender: TObject);
begin
  WindowState := wsMaximized;
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

procedure TFormBTreeTest.SpeedButtonClearClick(Sender: TObject);
begin
  BTRoot.Free;
  BTRoot := tSigDBTreeRoot.Create;
  BTRoot.PaintBox := PaintBoxBinaryTree;
end;

procedure TFormBTreeTest.SpeedButtonRemoveClick(Sender: TObject);
var
  iNewVal : tBTreeNode;
begin
  if assigned( BTRoot.LeftChild ) then
  begin
    iNewVal := (BTRoot.LeftChild as tBTreeNode ).Find( EditAdd.Text );
    if assigned( iNewVal ) then
    begin
      BTRoot.Remove( iNewVal );
    end;
  end;
end;

procedure TFormBTreeTest.SpeedButtonTimerTestClick(Sender: TObject);
begin
  if TimerRandomTest.Enabled then
  begin
    TimerRandomTest.Enabled := FALSE;
  end
  else
  begin
    TimerRandomTest.Enabled := TRUE;
  end;
end;

procedure TFormBTreeTest.TimerRandomTestTimer(Sender: TObject);
var
  iRandomString : string;
  i : integer;
  iChar : char;
  iNewVal : tBTreeNode;
begin
  iRandomString := '';
  for i := 1 to 4 do
  begin
    iChar := char( Ord('a') + Random( 26 ));
    iRandomString := iRandomString + iChar;
  end;
  iNewVal := tBTreeNode.Create;
  iNewVal.Name := iRandomString;
  BTRoot.Add( iNewVal );
end;

end.
