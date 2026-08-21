unit UnitGroups;

{
  Split into physical and logical groups. Logical groups
  are part of the file structure and stored in
  UnitFiles.
}

interface

uses
  Contnrs,
  SigExpandableBlocks,
  UnitImageSelector;

type
  tGroupStyle = (gsInput, gsOutput, gsSpecial );

  tPhysicalGroup = class( tObjectList )
    {
      a group is a (possibly empty) collection of devices passed to panel.
      Note that the list is created dynamically and not stored in a file.
      We keep two copies; the panel copy (if known) and the cfg copy.
    }
  private
  public
    function FileLine : string; virtual; abstract;
  end;

  tPhysicalInputGroup = class( tPhysicalGroup )
    // can only contain input devices
  end;

  tPhysicalOutputGroup = class( tPhysicalGroup )
    // can only contain output devices
  end;

  tPhysicalIntermediateGroup = class( tPhysicalGroup )
    // cannot contain any devices
  end;

  tSuperGroup = class( tObjectList )
    {
      A group of output groups - used for class change. We might not use this
    }
  end;

  tPhysicalGroups = class( tObjectList )
    {
      All the groups, input, output and integmediary
    }
  private
    function GetPhysicalGroup(const i: integer): tPhysicalGroup;
  public
    property PhysicalGroup[ const i : integer ] : tPhysicalGroup
             read GetPhysicalGroup;
  end;

  tGroupSubDevice = class

  end;

  tGroupSubDevices = class( tObjectList )

  end;

implementation

{ tPhysicalGroups }

function tPhysicalGroups.GetPhysicalGroup(const i: integer): tPhysicalGroup;
begin
  Result := Items[ i ] as tPhysicalGroup;
end;

end.
