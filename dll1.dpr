library dll1;
uses
  Winapi.Windows,
  System.SysUtils,
  System.Classes,
  System.IOUtils,
  System.Masks,
  Winapi.Messages;

{$R *.res}
type

  TBuffer =  array[0..1024 * 1024] of byte;
  PBuffer = ^TBuffer;

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

function GetFiles(ADir, AMask: PWideChar): PWideChar; stdcall;
var
  S: string;
  Res: string;
  SearchThread: TSearchThread;
  Dir: string;
  Mask: string;
  L: TStringList;
begin
  L:= TStringList.Create;
  try
    L.Delimiter:= ',';
    L.StrictDelimiter:= true;
    L.DelimitedText:= Mask;

    try
      Dir:= ADir;
      Mask:= AMask;
    except

    end;
  finally
    L.Free;
  end;
  SearchThread:= TSearchThread.Create(false, Dir, Mask, 0);
  Result:= '';
end;

// Поиск подстроки в файле
function SearchCharsSequence(const FileName: PChar; const Pattern: Pointer;
                             const PatternLen: Integer; {0- строка, >0- байты}
                             var PositionsStr: PChar): Boolean; stdcall;
const
  BUF_SIZE = 65536; // 64 KB
var
  FS: TFileStream;
  Buffer: array of Byte;
  ReadBytes, i, Overlap: Integer;
  GlobalOffset: Int64;
  TempStr: string;
  SearchData: TBytes;
  ActualLen: Integer;
begin
  Result := False;
  PositionsStr := nil;
  TempStr := '';

  if (FileName = nil) or (Pattern = nil) then Exit;
  if not FileExists(FileName) then Exit;

  // Определяем длину шаблона
  if PatternLen = 0 then
    ActualLen := StrLen(PAnsiChar(Pattern)) // строка
  else
    ActualLen := PatternLen;               // бинарные данные

  if ActualLen <= 0 then Exit;

  // Записываем шаблон в массив байтов
  SetLength(SearchData, ActualLen);
  Move(Pattern^, SearchData[0], ActualLen);

  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone{fmShareDenyWrite});
  try
    SetLength(Buffer, BUF_SIZE + ActualLen - 1);
    GlobalOffset := 0;

    while FS.Position < FS.Size do
    begin
      ReadBytes := FS.Read(Buffer[0], BUF_SIZE);

      // Перекрытие на границах
      if (FS.Position < FS.Size) and (ActualLen > 1) then
      begin
        Overlap := ActualLen - 1;
        FS.Read(Buffer[ReadBytes], Overlap);
        FS.Position := FS.Position - Overlap;
        Inc(ReadBytes, Overlap);
      end;

      for i := 0 to ReadBytes - ActualLen do
      begin
        if CompareMem(@Buffer[i], @SearchData[0], ActualLen) then
        begin
          if TempStr <> '' then TempStr := TempStr + ',';
          TempStr := TempStr + IntToStr(GlobalOffset + i);
        end;
      end;

      Inc(GlobalOffset, ReadBytes - (ActualLen - 1));
    end;

    if TempStr <> '' then
    begin
      PositionsStr := StrAlloc(Length(TempStr) + 1);
      StrPCopy(PositionsStr, TempStr);
    end;

    Result := True;
  finally
    FS.Free;
  end;
end;


exports
  GetInfo,
  GetFiles,
  SearchCharsSequence;

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
  S: string;
  Res: string;
  L: TStringList;
begin
  inherited;
  Res:= '';
  try
    L:= TStringList.Create;
    L.Delimiter:= ',';
    L.StrictDelimiter:= true;
    L.DelimitedText:= Mask;

    try
      for S in TDirectory.GetFiles(Dir, '*.*', TSearchOption.soAllDirectories,
                                   function(const Path: string; const SearchRec: TSearchRec): boolean
                                   var msk: string;
                                   begin
                                     Result:= true;
                                     for msk in L do
                                     begin
                                       if MatchesMask(ExtractFileName(SearchRec.Name), msk) then exit;
                                     end;
                                     Result:= false;
                                   end)
        do
        begin
          if Res= '' then Res:= S else Res:= Res + ',' + S;
        end;
    finally
      L.Free;
    end;
  except
    Res:= 'Ошибка.';
  end;

  CopyData.dwData := 0; // Можно использовать для обозначения типа данных
  CopyData.cbData := (Length(Res) + 1) * SizeOf(WideChar); // Размер данных в байтах
  CopyData.lpData := PWideChar(Res); // Указатель на строку
  SendMessage(FindWindow(nil, 'МКО тестовая программа'), WM_COPYDATA, Handle, Integer(@CopyData));
end;

begin
end.
