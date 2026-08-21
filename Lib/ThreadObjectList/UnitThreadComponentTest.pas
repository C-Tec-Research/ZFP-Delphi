unit UnitThreadComponentTest;

interface

{$DEFINE LOCK_VER}

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
  Vcl.ExtCtrls,
  Vcl.StdCtrls
{$IFDEF LOCK_VER}
  ,UnitThreadSafeComponents
{$ENDIF}
  ;


type
  TFormThreadsafeTest = class(TForm)
    MemoTest: TMemo;
    Timer1: TTimer;
    Timer2: TTimer;
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TTestThread = class( TThread )
  private
    fName: string;
  public
    constructor Create( const pName : string );
    procedure Execute; override;
    property Name : string
             read fName;
  end;

var
  FormThreadsafeTest: TFormThreadsafeTest;

implementation

{$R *.dfm}

procedure TFormThreadsafeTest.Timer1Timer(Sender: TObject);
begin
  // deliberately problematic
  with Sender as TTimer do
  begin
    TTestThread.Create( Name );
  end;
end;

{ TTestThread }

constructor TTestThread.Create(const pName: string);
begin
  inherited Create( TRUE );
  fName := pName;
  Suspended := FALSE;
end;

procedure TTestThread.Execute;
var
  i, j : integer;
const
  cLim = 5000000;
begin
  // deliberately problematic
  j := 0;
{$IFDEF LOCK_VER}
  FormThreadsafeTest.MemoTest.Lock;
{$ENDIF}
  FormThreadsafeTest.MemoTest.Lines.Add( 'Sent' );
  for i := 1 to cLim do
  begin
    Application.ProcessMessages;
    if j < 10000 then
    begin
      inc( j ); // waste some time

    end
    else
    begin
      dec( j );
    end;
  end;
  FormThreadsafeTest.MemoTest.Lines[ FormThreadsafeTest.MemoTest.Lines.Count - 1 ] := FormThreadsafeTest.MemoTest.Lines[ FormThreadsafeTest.MemoTest.Lines.Count - 1 ] + ' From ';
  for i := 1 to cLim do
  begin
    Application.ProcessMessages;
    if j < 10000 then
    begin
      inc( j ); // waste some time

    end
    else
    begin
      dec( j );
    end;
  end;
  FormThreadsafeTest.MemoTest.Lines[ FormThreadsafeTest.MemoTest.Lines.Count - 1 ] := FormThreadsafeTest.MemoTest.Lines[ FormThreadsafeTest.MemoTest.Lines.Count - 1 ] + Name;
  for i := 1 to cLim do
  begin
    Application.ProcessMessages;
    if j < 10000 then
    begin
      inc( j ); // waste some time

    end
    else
    begin
      dec( j );
    end;
  end;
{$IFDEF LOCK_VER}
  FormThreadsafeTest.MemoTest.UnLock;
{$ENDIF}

end;

end.
