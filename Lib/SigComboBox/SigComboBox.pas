unit SigComboBox;

{
  Rather like a FMX combo box, but has a separate property of type
  TListBoxHelperItems<T> which, if assigned to add extra functionality
  with new (non published) properties like EnglishName and ID
}

interface

uses
  System.SysUtils, System.Classes, FMX.Types, FMX.Controls, FMX.ListBox,
  UnitListBoxHelper
  ;

type
  TSigComboBox = class(TComboBox)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
  published
    { Published declarations }
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('SigNET', [TSigComboBox]);
end;

end.
