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

  // Поиск файлов по маске
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

  TSearchSubstringThread = class(TThread)
  private
    FFile: string;
    FSubstring: string;
  protected
    procedure Execute; override;
  public
    constructor Create(CreateSuspended: Boolean; AFile, ASubstring: string);
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
{  L:= TStringList.Create;
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
  end;  }
  SearchThread:= TSearchThread.Create(false, ADir, AMask, 0);
  Result:= '';
end;




// Поиск подстроки в файле
function FindSubstring(FileName, SubStr: string; Encoding: Integer): string;
const
  BUFFER_SIZE = 65536; // 64 КБ
var
  Stream: TFileStream;
  Positions: TStringList;
  ResultStr: string;

  function SearchWithEncoding(Enc: TEncoding): string;
  var
    I, J: Integer;
    SubStrLen: Integer;
    SubStrBytes: TBytes;
    Found: Boolean;
    SearchPos: Int64;
    Buffer: array of Byte;
    ReadBytes, ValidBytes, Tail: Integer;
  begin
    Result := '';
    Positions.Clear;

    // подстрока в байты
    SubStrBytes := Enc.GetBytes(SubStr);
    SubStrLen := Length(SubStrBytes);
    if SubStrLen = 0 then Exit;

    Stream.Position := 0;
    Tail := SubStrLen - 1;
    SetLength(Buffer, BUFFER_SIZE + Tail);
    SearchPos := 0;

    // читаем первую порцию
    ReadBytes := Stream.Read(Buffer[0], BUFFER_SIZE);

    while ReadBytes > 0 do
    begin
      ValidBytes := ReadBytes + Tail;

      // ищем только в реально доступных байтах
      for I := 0 to ValidBytes - SubStrLen do
      begin
        Found := True;
        for J := 0 to SubStrLen - 1 do
          if Buffer[I + J] <> SubStrBytes[J] then
          begin
            Found := False;
            Break;
          end;
        if Found then
          Positions.Add(IntToStr(SearchPos + I));
      end;

      // переносим хвост
      if Tail > 0 then
        Move(Buffer[ReadBytes], Buffer[0], Tail);

      // увеличиваем позицию
      Inc(SearchPos, ReadBytes);

      // читаем следующую порцию сразу за хвостом
      ReadBytes := Stream.Read(Buffer[Tail], BUFFER_SIZE);
    end;

    if Positions.Count > 0 then
      Result := Positions.CommaText
    else
      Result := '';
  end;

begin
  Result := '';
  Positions := TStringList.Create;
  try
    try
{      if (SubStr = nil) or (FileName = nil) then
      begin
        Result := StrAlloc(1);
        Result[0] := #0;
        Exit;
      end;}

      Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
      try
        case Encoding of
          0: ResultStr := SearchWithEncoding(TEncoding.ANSI);
          1: ResultStr := SearchWithEncoding(TEncoding.UTF8);
          2: begin
               ResultStr := SearchWithEncoding(TEncoding.ANSI);
               if ResultStr = '' then
                 ResultStr := SearchWithEncoding(TEncoding.UTF8);
             end;
        else
          ResultStr := 'Error: Unknown encoding';
        end;

        if ResultStr = '' then
          ResultStr := 'Not found';

{        Result := StrAlloc(Length(ResultStr) + 1);
        StrPCopy(Result, ResultStr);}
        Result:= ResultStr;
      finally
        Stream.Free;
      end;
    except
      on E: Exception do
      begin
{        Result := StrAlloc(64);
        StrPCopy(Result, 'Error: ' + E.Message);}
        Result:= 'Error: ' + E.Message;
      end;
    end;
  finally
    Positions.Free;
  end;
end;

function FindSubstringInFile(FileName: PChar; SubStr: PChar; Encoding: Integer): PChar; stdcall;
var
  SearchSubstringThread: TSearchSubstringThread;
begin
  SearchSubstringThread:= TSearchSubstringThread.Create(false, FileName, Substr);
  Result:= 'Ok';
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

{ TSearchSubstringThread }

constructor TSearchSubstringThread.Create(CreateSuspended: Boolean; AFile, ASubstring: string);
begin
  inherited Create(false);
  FFile:= AFile;
  FSubstring:= ASubstring;
end;

procedure TSearchSubstringThread.Execute;
var
  CopyData: TCopyDataStruct;
  S: string;
  Res: string;
  L: TStringList;
  L0: TStringList;
  LAll: TStringList;
  PosStr: string;
  Sub: string; // подстрока
  i: integer;
  j: integer;

begin
  inherited;
   L0:= TStringList.Create;
   LAll:= TStringList.Create;
   try
     LAll.Delimiter:= ',';
     LAll.StrictDelimiter:= true;

     L0.Duplicates:= dupIgnore;
     L0.Delimiter:= ';';
     L0.StrictDelimiter:= true;
     L0.DelimitedText:= FSubstring;
     for j:= 0  to L0.Count - 1 do
     begin
       Sub:= L0[j];
       PosStr:= FindSubString(FFile, Sub, 2);
//       if Assigned(PosStr) then
//       begin
         S:= PosStr;
//       end else Exit;
//       LocalFree(HLOCAL(PosStr));
       L:= TStringList.Create;
       try
         L.Delimiter:= ',';
         L.StrictDelimiter:= true;
         L.DelimitedText:= S;
         for i:= 0 to L.Count - 1 do
         begin
           L[i]:= L[i] + ' позиция ' + QuotedStr(L0[j]) + ' в ' + FFile;
           LAll.Add(L[i]);
         end;
       finally
         L.Free;
       end;

     end;   //for
     Res:= LAll.DelimitedText;
   finally
     L0.Free;
     LAll.Free;
   end;
//   Res:= LAll.Text;

  CopyData.dwData := 1; // Можно использовать для обозначения типа данных
  CopyData.cbData := (Length(Res) + 1) * SizeOf(WideChar); // Размер данных в байтах
  CopyData.lpData := PWideChar(Res); // Указатель на строку
  SendMessage(FindWindow(nil, 'МКО тестовая программа'), WM_COPYDATA, Handle, Integer(@CopyData));
end;

begin
end.
