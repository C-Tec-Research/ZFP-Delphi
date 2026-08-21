unit FMX.UnitFileNotSaved;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Dialogs;

type
  TFormFileNotSaved = class(TForm)
    LabelNotSavedWarning: TLabel;
    ButtonYes: TButton;
    ButtonNo: TButton;
    ButtonCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FormFileNotSaved: TFormFileNotSaved;

implementation

{$R *.fmx}

end.
