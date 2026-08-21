unit UnitSelectMessage;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  MPlayer, Grids, Outline, DirOutln, StdCtrls, FileCtrl, ComCtrls, Buttons;

type
  TFormSelectMessage = class(TForm)
    MediaPlayer: TMediaPlayer;
    DriveComboBoxSelectMessage: TDriveComboBox;
    DirectoryListBoxSelectMessage: TDirectoryListBox;
    FileListBoxSelectMessage: TFileListBox;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    procedure FileListBoxSelectMessageClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    function Execute : boolean;
  end;

var
  FormSelectMessage: TFormSelectMessage;

implementation

{$R *.DFM}

function TFormSelectMessage.Execute : boolean;
begin
  case ShowModal of
    mrOK : Result := TRUE;
    else Result := FALSE;
  end;
  MediaPlayer.Close;
end;

procedure TFormSelectMessage.FileListBoxSelectMessageClick(
  Sender: TObject);
begin
  MediaPlayer.FileName := FileListBoxSelectMessage.FileName;
  MediaPlayer.Open;
end;

end.
