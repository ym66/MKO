library dll2;
uses
  System.SysUtils,
  System.Classes;

{$R *.res}

function GetInfo: PWideChar; stdcall;
begin
   Result:= 'ArchivingFiles,Архивирование файлов/папки';
end;


exports
  GetInfo;

begin
end.
