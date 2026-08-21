HTML Help (.chm) Support for Delphi
===================================

This package  contains three Delphi units  that make it possible  to use
.chm  files  for context-sensitive  help  in your  Delphi  applications.
Each of  the three units targets  specific versions of Delphi.   Borland
thought  it necessary  to  modify Delphi's  help  system several  times,
hence the different units.

You may use the units in this  package free of charge in all your Delphi
applications.   Distribution of this  unit or  units derived from  it is
prohibited.   If other  people would  like a copy,  they are  welcome to
download it from: http://www.helpscribble.com/delphi-bcb.html

These units are copyright (c) 2001, 2004, 2005  Jan Goyvaerts.
Any rights not explicitly granted above are reserved.


Delphi 3, 4 and 5
=================

Delphi 3,  4 and 5 normally only  support WinHelp.   Add the UseHTMLHelp
unit to  the uses clause of your  application's .dpr source  file.  This
unit will rout all  help calls from WinHelp to HTML Help.   It does this
via the OnHelp event handler of  the Application object.  This means you
cannot use your own OnHelp event handler with the UseHTMLHelp unit.


Delphi 6 and 7
==============

Delphi  6  introduces a  new  VCL  help  system  that adds  support  for
multiple help  formats.  However, only  WinHelp is supported out  of the
box.    Add  the  HTMLHelpViewer  unit   to  the  uses  clause  of  your
application's .dpr  source  file.  Your  application  then automatically
supports both WinHelp (.hlp) and HTML Help (.chm) help files.


Delphi 2005 (VCL/Win32 and VCL/.NET)
====================================

Delphi  2005 does  not  add  any help  support  to  VCL applications  by
default.    To use  a  help  file  in  WinHelp  (.hlp) format,  add  the
WinHelpViewer unit (included  with Delphi) to the .dpr uses  clause.  To
use a help  file in HTML Help (.chm) format,  add the HTMLHelpViewer2005
unit to the .dpr uses clause.

If you want  your application to support both .hlp  and .chm help files,
you   MUST  add   HTMLHelpViewer  to   the  .dpr   uses  clause   BEFORE
WinHelpViewer.  Due  to a bug in Delphi 2005,  if you list WinHelpViewer
first, WinHelpViewer will  try to open .chm files, which  will result in
an error.


Delphi 2006 and later
=====================

Delphi 2006 and later include their own HTMLHelpViewer unit.  Simply add
it to the uses clause in your .dpr file.


How to Link to The .chm File
============================

After adding the appropriate unit to  the uses clause of your .dpr file,
you can link to the .chm file just  like you'd link to a .hlp file.  Set
the  HelpFile property of  the  Application object, e.g.  by  adding the
following line to the OnCreate  event handler of your application's main
form:

Application.HelpFile := ExtractFilePath(Application.ExeName) + 'helpfile.chm';

Doing it this way  makes sure the help file will be  found.  Setting the
help file in  the Project Options in the IDE  only allows for hard-coded
paths.

If you want  to use a different  help file for different  forms, you can
assign the  form's HelpFile property instead.   Note that this  will not
work with the UseHTMLHelp unit for Delphi 3, 4 and 5.

To implement context-sensitive help, simply  assign the topic numbers to
the HelpContext properties in Delphi.


How to Create .chm Files
========================

If you're  looking for  a tool  to easily create  HLP and/or  CHM files,
take   a   look    at   HelpScribble   at   http://www.helpscribble.com/
HelpScribble includes a  special HelpContext property  editor for Delphi
that makes it very easy to link your help file to your application.
