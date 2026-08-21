unit UnitSigFile7Test;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, SigFile7,
  Data.Bind.GenData, Data.Bind.EngExt, Fmx.Bind.DBEngExt, System.Rtti,
  System.Bindings.Outputs, Fmx.Bind.Editors, Data.Bind.Components,
  Data.Bind.ObjectScope, FMX.Layouts, FMX.Memo, FMX.StdCtrls, FMX.Edit,
  FMX.Controls.Presentation, FMX.EditBox,
  FMX.SpinBox;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Edit1: TEdit;
    ButtonShowSource: TButton;
    MemoSource: TMemo;
    Label3: TLabel;
    ButtonLoadSource: TButton;
    MemoErrors: TMemo;
    SigFile7IntegerProperty1: TSigFile7IntegerProperty;
    SigFile7TextProperty1: TSigFile7TextProperty;
    SigFile7File1: TSigFile7File;
    SpinBox1: TSpinBox;
    SigFile7SingleProperty1: TSigFile7SingleProperty;
    procedure ButtonShowSourceClick(Sender: TObject);
    procedure SigFile7EditorChange(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonLoadSourceClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.ButtonLoadSourceClick(Sender: TObject);
begin
  SigFile7File1.Load( MemoSource.Lines, MemoErrors.Lines )
end;

procedure TForm1.ButtonShowSourceClick(Sender: TObject);
begin
  MemoSource.Lines.Clear;
  SigFile7File1.Save( MemoSource.Lines );
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  SigFile7SingleProperty1.RegisterEditor( SpinBox1 );
  SigFile7TextProperty1.RegisterEditor( Edit1 );
end;

procedure TForm1.SigFile7EditorChange(Sender: TObject);
begin
  if Sender is TCustomEdit then
  begin
    with Sender as TCustomEdit do
    begin
      // try fast way first
      if assigned( TagObject ) then
      begin
        if TagObject is TSigFile7BaseProperty then
        begin
          (TagObject as TSigFile7BaseProperty).Text := Text;
          exit;
        end;
      end;
      // else
      // do it the slow way
      SigFile7File1.ChangeText( Sender, Text );
    end;
  end;
end;

end.
