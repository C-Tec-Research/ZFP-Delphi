unit Imsg;

{ Encapsulates the I and i SCL commands }

interface

Uses
  SS2NMsg, SS2NComm, SysUtils;

type
  TIMessage = class( TSS2NMessage )
    { issues cyclic I messages. }
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
	 constructor Create; {virtual;}

end;

type
  TextIMessage = class( TSS2NMessage )
    { issues one shot i message. }
  private
    { Private declarations }
    iNode : integer;
  protected
    { Protected declarations }
  public
    { Public declarations }
	 constructor Create( pNode : integer );
    property Node : integer
             read iNode;

end;


implementation

{---------------------- I ------------------}

constructor TIMessage.Create;
begin
  inherited Create('I');
  iTestString := '00'; { No errors }
  iResubmitCount := 0;
  iResubmitPeriodCount := 10; { Panel is usually 10 ticks per second.
                                This is only a default. User may change. }
end;

{------------------------ i -----------------}

constructor TextIMessage.Create( pNode : integer );
begin
  inherited Create(Format('i%.3X', [pNode ]));
  iTestString := '00000000000000000000';
              { no errors }
  iNode := pNode;
end;

end.
