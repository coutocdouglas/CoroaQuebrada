#ifndef AppVersion
  #define AppVersion "0.5.0"
#endif
[Setup]
#ifdef TestInstall
AppId={{DDA24646-38EC-4C07-A44C-6591A5034472}
AppName=Coroa Quebrada - teste de instalador
#else
AppId={{756F69A7-0C6E-4CBC-9F12-48F51838DDC3}
AppName=Coroa Quebrada
#endif
AppVersion={#AppVersion}
AppPublisher=coutocdouglas
AppPublisherURL=https://github.com/coutocdouglas/CoroaQuebrada
DefaultDirName={localappdata}\Programs\CoroaQuebrada
DefaultGroupName=Coroa Quebrada
PrivilegesRequired=lowest
ArchitecturesAllowed=x64compatible
OutputDir=..\outputs
OutputBaseFilename=CoroaQuebrada-Setup-{#AppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
UninstallDisplayIcon={app}\CoroaQuebrada.exe
CloseApplications=yes
RestartApplications=no
SetupLogging=yes

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar um atalho na área de trabalho"; Flags: unchecked

[Files]
Source: "..\outputs\CoroaQuebrada.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "Atualizar.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\outputs\COMO_JOGAR.txt"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\THIRD_PARTY_NOTICES.md"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\Coroa Quebrada"; Filename: "{app}\CoroaQuebrada.exe"
Name: "{group}\Desinstalar Coroa Quebrada"; Filename: "{uninstallexe}"
Name: "{autodesktop}\Coroa Quebrada"; Filename: "{app}\CoroaQuebrada.exe"; Tasks: desktopicon

[Run]
Filename: "{app}\CoroaQuebrada.exe"; Description: "Abrir Coroa Quebrada"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: files; Name: "{app}\atualizacao.log"
Type: files; Name: "{app}\.update.lock"
Type: files; Name: "{app}\versao.txt"
