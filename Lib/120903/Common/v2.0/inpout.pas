unit Inpout;

interface

function Inp( Address : Word ) : Word ; far;
procedure Out( Address : Word; Value : Word ); far;

implementation

function Inp( Address : Word ) : Word ; external 'InOut';

procedure Out( Address : Word; Value : Word ) ; external 'InOut';

end.
