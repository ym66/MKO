library dll2;
uses
  System.SysUtils,
  System.Classes;

{$R *.res}

function GetInfo: PWideChar; stdcall;
begin
   Result:= 'ArchivingFiles,������������� ������/�����';
end;


exports
  GetInfo;

begin
end.
