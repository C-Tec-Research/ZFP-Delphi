unit SigFileEx;

{********************************************************************************
 *                                                                              *
 * This should really be in SigFile but was written during the transition from  *
 * XE2 to XE7 so was written as a separate unit to deal with TSigObjectArray    *
 * and TSigObjectList in generic format to aid Live Bindings.                   *
 *                                                                              *
 * Also introduces TSigListBindSourceAdapter based on TListBindSourceAdapter    *
 * which give LB links to an array or a tree.                                   *
 *                                                                              *
 ********************************************************************************}

interface

uses
{$IFDEF FMX_SIGFILE}
  FMX.SigFile;
{$ELSIFDEF VCL_SIGFILE}
  VCL.SigFile;
{$ELSE}
  SigFile;
{$ENDIF}

type
  TSigObjectArray< T: class > = class( TSigObjectArray )
  private
  protected
  public
  end;

implementation

end.
