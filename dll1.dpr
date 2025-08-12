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
  Result:= 'GetFiles,�����  ������  ������  ��  �����;SearchCharsSequence,����� ��������� ������������������ �������� � �����';
end;

function GetFiles(ADir: PWideChar): PWideChar; stdcall;
var
  S: string;
  Res: string;
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

{
function SearchCharsSequence(ASequence: PAnsiChar; AFile: PWideChar): PAnsiChar; stdcall;
var
  FS: TFileStream;
  Buffer: PBuffer;
  N: integer;
  PS: integer;
  M: integer;
  S: string;
  SB: string; // ��������� �����
  SequenceLen: integer;
begin
  Result:= '';
  SequenceLen:= Length(ASequence);
  GetMem(Buffer, 1024 * 1024);
  FS:= TFileStream.Create(AFile, fmOpenRead or fmShareDenyNone);
  try
    repeat
      N:= FS.Read(Buffer^, 1024 * 1024);
      S:= PAnsiChar(AnsiString(Buffer));
      PS:= Pos(ASequence, S);
      M:= PS;
      if PS <> 0 then
        if Result = '' then S:= IntToStr(M) else S:= Result + ',' + IntToStr(M);
      Result:= PAnsiChar(AnsiString(S));
      while PS <> 0 do
      begin
        SB:= PAnsiChar(AnsiString(Buffer));
        SB:= Copy(SB, M + SequenceLen, Length(SB));
        PS:= Pos(ASequence, SB);
        M:= M + PS + 1;
        if PS <> 0 then
        begin
          S:= Result + ',' + IntToStr(M);
          Result:= PAnsiChar(AnsiString(S));
        end;
      end;
    until  N = 0;
  finally
    FS.Free;
    FreeMem(Buffer);
  end;
end;
}
{
function SearchCharsSequence(ASequence: PAnsiChar; AFile: PWideChar): PAnsiChar; stdcall;
begin
  Result:= '�� ������';
end;
}

function SearchCharsSequence(const FileName: PChar; const Pattern: Pointer;
                             const PatternLen: Integer; {0- ������, >0- �����}
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

  // ���������� ����� �������
  if PatternLen = 0 then
    ActualLen := StrLen(PAnsiChar(Pattern)) // ������
  else
    ActualLen := PatternLen;               // �������� ������

  if ActualLen <= 0 then Exit;

  // ���������� ������ � ������ ������
  SetLength(SearchData, ActualLen);
  Move(Pattern^, SearchData[0], ActualLen);

  FS := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone{fmShareDenyWrite});
  try
    SetLength(Buffer, BUF_SIZE + ActualLen - 1);
    GlobalOffset := 0;

    while FS.Position < FS.Size do
    begin
      ReadBytes := FS.Read(Buffer[0], BUF_SIZE);

      // ���������� �� ��������
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
begin
  inherited;
  Res:= '';
  try
    for S in TDirectory.GetFiles(Dir, Mask, TSearchOption.soAllDirectories) do
       if Res= '' then Res:= S else Res:= Res + ',' + S;
  except
    Res:= '������';
  end;

  CopyData.dwData := 0; // ����� ������������ ��� ����������� ���� ������
  CopyData.cbData := (Length(Res) + 1) * SizeOf(WideChar); // ������ ������ � ������
  CopyData.lpData := PWideChar(Res); // ��������� �� ������
  SendMessage(FindWindow(nil, '��� �������� ���������'), WM_COPYDATA, Handle, Integer(@CopyData));
end;

begin
end.
