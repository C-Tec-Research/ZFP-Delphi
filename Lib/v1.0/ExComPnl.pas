unit ExComPnl;

interface

uses
	Companel;

type
	TExtendedCommsPanel = class (TCommsPanel)
   	private

      protected

   	public
	end;

procedure Register;

implementation

procedure Register;
begin
  	RegisterComponents('SigNET', [TExtendedCommsPanel]);
end;


end.
 