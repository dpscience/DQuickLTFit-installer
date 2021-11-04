; { ///////////////////////////////////////////////////////////////////////////////////////////////// }
;
; Copyright (C) 2021 Danny Petschke. All rights reserved.
;
; { ///////////////////////////////////////////////////////////////////////////////////////////////// }
;
; Copyright (C) 1997-2019 Jordan Russell. All rights reserved.
; Portions Copyright (C) 2000-2019 Martijn Laan. All rights reserved.
;
; This software is provided "as-is," without any express or implied warranty. In no event shall the
; author be held liable for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any purpose, including commercial
; applications, and to alter and redistribute it, provided that the following conditions are met:
;
; 1. All redistributions of source code files must retain all copyright notices that are currently in
;    place, and this list of conditions without modification.
;
; 2. All redistributions in binary form must retain all occurrences of the above copyright notice and
;    web site addresses that are currently in place (for example, in the About boxes).
;
; 3. The origin of this software must not be misrepresented; you must not claim that you wrote the
;    original software. If you use this software to distribute a product, an acknowledgment in the
;    product documentation would be appreciated but is not required.
;
; 4. Modified versions in source or binary form must be plainly marked as such, and must not be
;    misrepresented as being the original software. }
;
; Jordan Russell
; jr-2010 AT jrsoftware.org
; http://www.jrsoftware.org/
;
; { ///////////////////////////////////////////////////////////////////////////////////////////////// }

#IFDEF UNICODE
#DEFINE AW "W"
#ELSE
#DEFINE AW "A"
#ENDIF

#define MyAppName            "DQuickLTFit"
#define MyAppNameFull        SourcePath + "/exe/" + MyAppName

#define MyAppPublisher       "Dr. Danny Petschke"
#define MyAppURL             "https://dpscience.github.io/DQuickLTFit/"
#define MyAppSupportURL      "https://www.researchgate.net/profile/Danny_Petschke"

#define MyAppVersion         "4.2"
#define MyAppExeName         MyAppName + ".exe" 
#define MyOutputBaseFilename "installer_" + MyAppName + "-v" + MyAppVersion

[Setup]
WizardStyle                 = modern
ChangesAssociations         = yes
UserInfoPage                = yes
UsePreviousUserInfo         = yes
UsePreviousGroup            = yes
UsePreviousLanguage         = yes
UsePreviousPrivileges       = yes
UsePreviousSetupType        = yes
UsePreviousTasks            = yes
EnableDirDoesntExistWarning = yes

; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId={{990AB016-DD9B-4134-8DDF-C22317E2CDAF}

ArchitecturesAllowed            = x64
ArchitecturesInstallIn64BitMode = x64
DisableWelcomePage              = no
AppName                         = {#MyAppName}
AppVersion                      = {#MyAppVersion}
AppVerName                      = {#MyAppName} {#MyAppVersion}
AppPublisher                    = {#MyAppPublisher}
AppPublisherURL                 = {#MyAppURL}
AppSupportURL                   = {#MyAppSupportURL}
AppUpdatesURL                   = {#MyAppURL}
AppContact                      = https://dpscience.github.io/DQuickLTFit/
AppCopyright                    = Copyright (c) 2016-2021 Dr. Danny Petschke
DefaultDirName                  = {pf}\{#MyAppName}
DefaultGroupName                = {#MyAppName}
AllowNoIcons                    = yes
DirExistsWarning                = no 
SetupLogging                    = yes
LicenseFile                     = {#SourcePath}\license\LICENSE.txt
UninstallDisplayIcon            = {#SourcePath}\res\DQuickLTFit.ico
WizardImageFile                 = {#SourcePath}\res\DQuickLTFit.bmp
WizardImageStretch              = no
OutputDir                       = {#SourcePath}
OutputBaseFilename              = {#MyOutputBaseFilename}
SetupIconFile                   = {#SourcePath}\res\DQuickLTFit.ico
Compression                     = lzma
SolidCompression                = yes

[Code]
{ ----------------- /MS requirements: redistributable packages ------------------------ }
type
  INSTALLSTATE = Longint;

  const
  INSTALLSTATE_INVALIDARG = -2;  { An invalid parameter was passed to the function. }
  INSTALLSTATE_UNKNOWN    = -1;  { The product is neither advertised or installed. }
  INSTALLSTATE_ADVERTISED = 1;   { The product is advertised but not installed. }
  INSTALLSTATE_ABSENT     = 2;   { The product is installed for a different user. }
  INSTALLSTATE_DEFAULT    = 5;   { The product is installed for the current user. }

/////////////////////////////////////////////////////////////////////
function VCinstalled(const regKey: string): Boolean;
 { Function for Inno Setup Compiler }
 { Returns True if same or later Microsoft Visual C++ 2017-xxxx Redistributable is installed, otherwise False. }
var
  major: Cardinal;
  minor: Cardinal;
  bld: Cardinal;
  rbld: Cardinal;

begin
  Result := False;

  if RegQueryDWordValue(HKEY_LOCAL_MACHINE, regKey, 'Major', major) then begin
    if RegQueryDWordValue(HKEY_LOCAL_MACHINE, regKey, 'Minor', minor) then begin
      if RegQueryDWordValue(HKEY_LOCAL_MACHINE, regKey, 'Bld', bld) then begin
        if RegQueryDWordValue(HKEY_LOCAL_MACHINE, regKey, 'RBld', rbld) then begin
            { MsgBox('VC 2017-2019 Redist Major is: ' + IntToStr(major) + ' Minor is: ' + IntToStr(minor) + ' Bld is: ' + IntToStr(bld) + ' Rbld is: ' + IntToStr(rbld), mbInformation, MB_OK);
            { Version info was found. Return true if later or equal to our 14.29.30040.0 redistributable }
            { Note brackets required because of weird operator precendence }
            Result := (major >= 14) and (minor >= 29) and (bld >= 30040) and (rbld >= 0)
        end
      end
    end
  end
end;

/////////////////////////////////////////////////////////////////////
function VCRedistNeedsInstall: Boolean;
begin
 if NOT IsWin64 then 
  Result := not (VCinstalled('SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\X86'))
 else if Is64BitInstallMode then
  Result := not (VCinstalled('SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x64'))
 else
  Result := not (VCinstalled('SOFTWARE\WOW6432Node\Microsoft\VisualStudio\14.0\VC\Runtimes\x86'));  
end;

{ ///////////////////////////////////////////////////////////////////// }
/////////////////////////////////////////////////////////////////////
function GetUninstallString: String;
var
  sUnInstPath: String;
  sUnInstallString: String;

begin
  sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{#emit SetupSetting("AppId")}_is1');
  sUnInstallString := '';

  if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then begin
    sUnInstallString := '';
    if not RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString) then begin
      sUnInstallString := '';
    end
  end;
  
  Result := sUnInstallString;
end;

{ ///////////////////////////////////////////////////////////////////// }
function UnInstallOldVersion(): Integer;
var
  sUnInstallString: String;
  iResultCode: Integer;
begin
  { Return Values: }
  { 1 - uninstall string is empty }
  { 2 - error executing the UnInstallString }
  { 3 - successfully executed the UnInstallString }

  { default return value }
  Result := 0;

  { get the uninstall string of the old app }
  sUnInstallString := GetUninstallString();
  if sUnInstallString <> '' then begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    if Exec(sUnInstallString, '/VERYSILENT /NORESTART /SUPPRESSMSGBOXES','', SW_HIDE, ewWaitUntilTerminated, iResultCode) then
      Result := 3
    else
      Result := 2;
  end else
    Result := 1;
end;

{ ///////////////////////////////////////////////////////////////////// }
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep=ssInstall) then begin
      UnInstallOldVersion();
  end;
end;

{ ///////////////////////////////////////////////////////////////////// }
[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[LangOptions]
LanguageName      = English
LanguageID        = $0409
LanguageCodePage  = 0
DialogFontName    = Courier New
DialogFontSize    = 10
WelcomeFontName   = Arial 
WelcomeFontSize   = 12
TitleFontName     = Arial
TitleFontSize     = 29
CopyrightFontName = Arial
CopyrightFontSize = 8
RightToLeft       = no

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: desktopicon\common; Description: "For all users"; GroupDescription: "Additional icons:"; Flags: exclusive
Name: desktopicon\user; Description: "For the current user only"; GroupDescription: "Additional icons:"; Flags: exclusive unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 0,6.1

[Files] 
; NOTE: Don't use "Flags: ignoreversion" on any shared system files
Source: "{#SourcePath}\exe\{#MyAppName}.exe"; DestName: {#MyAppExeName}; DestDir: "{app}"; Flags: ignoreversion; 

Source: "{#SourcePath}\exe\bin\VC_redist.x64.exe"; DestDir: {tmp}; Flags: deleteafterinstall
Source: "{#SourcePath}\license\LICENSE.txt"; DestDir: "{app}"; Flags: ignoreversion;
Source: "{#SourcePath}\license\COPYRIGHT"; DestDir: "{app}"; Flags: ignoreversion;
Source: "{#SourcePath}\license\LICENSE.GPLv3"; DestDir: "{app}"; Flags: ignoreversion;
Source: "{#SourcePath}\license\LICENSE.LGPLv3"; DestDir: "{app}"; Flags: ignoreversion;
Source: "{#SourcePath}\license\MODIFICATIONS"; DestDir: "{app}"; Flags: ignoreversion;
Source: "{#SourcePath}\license\USED-LICENSE.GPLv3"; DestDir: "{app}"; Flags: ignoreversion;

Source: "{#SourcePath}\exe\bin\d3dcompiler_47.dll"; DestDir: {app}; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\icuuc54.dll"; DestDir: {app}; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\icudt54.dll"; DestDir: {app}; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\icuin54.dll"; DestDir: {app}; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\libEGL.dll"; DestDir: {app}; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\libGLESv2.dll"; DestDir: {app}; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\opengl32sw.dll"; DestDir: {app}; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\Qt5Core.dll"; DestDir: {app}; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\Qt5Gui.dll"; DestDir: {app}; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\Qt5Svg.dll"; DestDir: {app}; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\Qt5Widgets.dll"; DestDir: {app}; Flags: ignoreversion

Source: "{#SourcePath}\exe\bin\iconengines\qsvgicon.dll"; DestDir: {app}/iconsengines/; Flags: ignoreversion

Source: "{#SourcePath}\exe\bin\imageformats\qdds.dll"; DestDir: {app}/imageformats/; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\imageformats\qgif.dll"; DestDir: {app}/imageformats/; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\imageformats\qicns.dll"; DestDir: {app}/imageformats/; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\imageformats\qico.dll"; DestDir: {app}/imageformats/; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\imageformats\qjp2.dll"; DestDir: {app}/imageformats/; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\imageformats\qjpeg.dll"; DestDir: {app}/imageformats/; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\imageformats\qmng.dll"; DestDir: {app}/imageformats/; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\imageformats\qsvg.dll"; DestDir: {app}/imageformats/; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\imageformats\qtga.dll"; DestDir: {app}/imageformats/; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\imageformats\qtiff.dll"; DestDir: {app}/imageformats/; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\imageformats\qwbmp.dll"; DestDir: {app}/imageformats/; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\imageformats\qwebp.dll"; DestDir: {app}/imageformats/; Flags: ignoreversion

Source: "{#SourcePath}\exe\bin\platforms\qminimal.dll"; DestDir: {app}/platforms/; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\platforms\qoffscreen.dll"; DestDir: {app}/platforms/; Flags: ignoreversion
Source: "{#SourcePath}\exe\bin\platforms\qwindows.dll"; DestDir: {app}/platforms/; Flags: ignoreversion
        
[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\DQuickLTFit homepage ..."; Filename: "{#MyAppURL}"
Name: "{group}\contact Danny Petschke ..."; Filename: "{#MyAppSupportURL}"
Name: "{group}\LICENSE-DQuickLTFit"; Filename: "{app}\LICENSE.txt"
Name: "{group}\LICENSE-GPLv3"; Filename: "{app}\LICENSE.GPLv3"
Name: "{group}\LICENSE-LGPLv3"; Filename: "{app}\LICENSE.LGPLv3"
Name: "{group}\uninstall {#MyAppName}"; Filename: "{uninstallexe}"                        
Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon
Name: "{userappdata}\Microsoft\Internet Explorer\Quick Launch\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: quicklaunchicon

[UninstallDelete]
Type: files; Name: "{app}\{#MyAppExeName}.exe"
Type: files; Name: "{app}\LICENSE.txt"

Type: files; Name: "{app}\LICENSE.GPLv3"
Type: files; Name: "{app}\LICENSE.LGPLv3"
Type: files; Name: "{app}\MODIFICATIONS"
Type: files; Name: "{app}\COPYRIGHT"
Type: files; Name: "{app}\USED-LICENSE.GPLv3"

[Run]
Filename: "{tmp}\VC_redist.x64.exe"; Check: VCRedistNeedsInstall; StatusMsg: Installing Visual Studio Runtime Libraries ...
Filename: "{app}\{#MyAppExeName}"; Flags: nowait postinstall skipifsilent 64bit; Description: "Lauch {#MyAppName}"; 
Filename: "{#MyAppURL}"; Description: "visit DQuickLTFit homepage ..."; Flags: postinstall shellexec unchecked;
