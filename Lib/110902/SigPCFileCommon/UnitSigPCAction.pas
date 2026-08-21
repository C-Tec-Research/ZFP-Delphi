unit UnitSigPCAction;

{
  Every button performas an action when clicked, as does every SESA
  macro line - often the same action is performed by both.

  To this end - and to give huge button flexibility, each button
  will execute a macro, which in turn will execute a (possibly 1)
  series of actions. Also buttons can be linked in a button
  list, and an area contains a list of button lists.

  This is all fairly transparent to the user (editor)
}

interface

uses
  SysUtils,
  Classes,
  Controls,
  SigFile;


implementation

end.
