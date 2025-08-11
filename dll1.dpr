library dll1;
uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  Winapi.Messages;

{$R *.res}
const
  WM_READY = WM_USER + 1;


type
  TSearchThread = class(TThread)
  private
    Options: word;
    Dir: string;
    Mask: string;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean; ADir, AMask: string; AOptions: word);
  end;

function GetInfo: PWideChar; stdcall;
begin
  Result:= 'GetFiles,Поиск  списка  файлов  по  маске;SearchCharsSequence,Поиск вхождений последовательности символов в файле';
end;

function GetFiles(ADir: PWideChar): PWideChar; stdcall;
var
  S: string;
  Res: string;
  CDS: TCopyDataStruct;
  SearchThread: TSearchThread;
begin
{
  Res:= '';
  for S in TDirectory.GetFiles(ADir, '*', TSearchOption.soAllDirectories) do
     if Res= '' then Res:= S else Res:= Res + ',' + S;
  Result:= PWideChar(Res);
}
  SearchThread:= TSearchThread.Create(false, ADir, '*.pas', 0);
end;

exports
  GetInfo,
  GetFiles;

{ TSearchThread }

constructor TSearchThread.Create(CreateSuspended: Boolean; ADir, AMask: string; AOptions: word);
begin
  inherited Create(false);
  Options:= AOptions;
  Dir:= ADir;
  Mask:= AMask;
end;

procedure TSearchThread.Execute;
var
  CopyData: TCopyDataStruct;
  hTargetWnd: HWND;
  S: string;
  Res: string;
begin
  inherited;
  Res:= '';
  try
    for S in TDirectory.GetFiles(Dir, Mask, TSearchOption.soAllDirectories) do
       if Res= '' then Res:= S else Res:= Res + ',' + S;
  except
    Res:= 'Ошибка';
  end;

  CopyData.dwData := 0; // Можно использовать для обозначения типа данных
  CopyData.cbData := (Length(Res) + 1) * SizeOf(WideChar); // Размер данных в байтах
  CopyData.lpData := PWideChar(Res); // Указатель на строку
  SendMessage(FindWindow(nil, 'МКО тестовая программа'), WM_COPYDATA, Handle, Integer(@CopyData));
end;

begin
end.
