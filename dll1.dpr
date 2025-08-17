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
  Result:= 'GetFiles,Поиск  списка  файлов  по  маске;FindSubstringInFile,Поиск вхождений последовательности символов в файле';
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
function FindSubstringInFile(FileName: PChar; SubStr: PByte; SubStrLen: Integer): PChar; stdcall;
const
  BUFFER_SIZE = 65536; // 64 КБ
var
  Stream: TFileStream;
  Buffer: array of Byte;
  BytesRead, I: Integer;
  Found: Boolean;
  Positions: TStringList;
  ResultStr: string;
  SearchPos: Int64;
begin
  Result := nil;
  Positions := TStringList.Create;
  try
    try
      // Проверка входных параметров
      if (SubStrLen <= 0) or (SubStr = nil) or (FileName = nil) then
      begin
        Result := StrAlloc(1);
        Result[0] := #0;
        Exit;
      end;

      // Открываем файл
      Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      try
        SetLength(Buffer, BUFFER_SIZE + SubStrLen - 1);
        SearchPos := 0;

        // Первоначальное чтение
        BytesRead := Stream.Read(Buffer[0], BUFFER_SIZE);
        if BytesRead < SubStrLen then
        begin
          // Файл слишком маленький
          Result := StrAlloc(10);
          StrPCopy(Result, 'Not found');
          Exit;
        end;

        while BytesRead >= SubStrLen do
        begin
          // Поиск в текущем буфере
          for I := 0 to BytesRead - SubStrLen do
          begin
            Found := True;
            for var J := 0 to SubStrLen - 1 do
              if Buffer[I + J] <> SubStr[J] then
              begin
                Found := False;
                Break;
              end;

            if Found then
              Positions.Add(IntToStr(SearchPos + I));
          end;

          // Сохраняем конец буфера для перекрытия
          if BytesRead >= SubStrLen - 1 then
          begin
            Move(Buffer[BytesRead - (SubStrLen - 1)], Buffer[0], SubStrLen - 1);
            SearchPos := SearchPos + BytesRead - (SubStrLen - 1);
          end;

          // Читаем следующую порцию
          BytesRead := Stream.Read(Buffer[SubStrLen - 1], BUFFER_SIZE);
          if BytesRead > 0 then
            BytesRead := BytesRead + (SubStrLen - 1);
        end;

        // Формируем результат
        if Positions.Count > 0 then
          ResultStr := Positions.CommaText
        else
          ResultStr := 'Not found';

        Result := StrAlloc(Length(ResultStr) + 1);
        StrPCopy(Result, ResultStr);
      finally
        Stream.Free;
      end;
    except
      on E: Exception do
      begin
        Result := StrAlloc(64);
        StrPCopy(Result, 'Error: ' + E.Message);
      end;
    end;
  finally
    Positions.Free;
  end;
end;

exports
  GetInfo,
  GetFiles,
  FindSubstringInFile;

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
