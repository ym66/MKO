unit FormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Actions, Vcl.ActnList, Vcl.ComCtrls, Vcl.Grids, Vcl.WinXCtrls,
  System.ImageList, Vcl.ImgList, Vcl.Mask, Vcl.FileCtrl,
  Vcl.Samples.DirOutln;

type
  TStrFunction= function: PWideChar; stdcall;
  TFileSearchFunction= function(ADir, AMask: PWideChar): PWideChar; stdcall;
  TSearchCharsFunction= function(const FileName: PChar; const Pattern: Pointer;
                                 const PatternLen: Integer; {0- строка, >0- байты}
                                 var PositionsStr: PChar): boolean; stdcall;
type
  TMainForm = class(TForm)
    pnlButtons: TPanel;
    btnClose: TButton;
    ActionList: TActionList;
    actClose: TAction;
    pnlCenter: TPanel;
    StatusBar: TStatusBar;
    InfoPanel: TPanel;
    Memo: TMemo;
    pnlMain: TPanel;
    StringGrid: TStringGrid;
    Label1: TLabel;
    pnlFileSearch: TPanel;
    PageControl: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    pnlMaskSearch: TPanel;
    lblSearchMask: TLabel;
    edMask: TEdit;
    btnMaskSearch: TButton;
    actMaskSearch: TAction;
    DirectoryListBox: TDirectoryListBox;
    DriveComboBox: TDriveComboBox;
    Label2: TLabel;
    lblMask: TLabel;
    lblSelected: TLabel;
    pnlSubstring: TPanel;
    rgSearchSubstring: TRadioGroup;
    Label3: TLabel;
    edSubstring: TEdit;
    lblSubstring: TLabel;
    lblBytes: TLabel;
    btnSearchSubstring: TButton;
    actSearchSubstring: TAction;
    btnFile: TButton;
    OpenDialog: TOpenDialog;
    actSetFile: TAction;
    actAddByte: TAction;
    btnConvert: TButton;
    actConvertToBytes: TAction;
    edByteStr: TEdit;
    procedure actCloseExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DirectoryListBoxChange(Sender: TObject);
    procedure actMaskSearchExecute(Sender: TObject);
    procedure StringGridClick(Sender: TObject);
    procedure rgSearchSubstringClick(Sender: TObject);
    procedure actSearchSubstringExecute(Sender: TObject);
    procedure actSetFileExecute(Sender: TObject);
    procedure actConvertToBytesExecute(Sender: TObject);
    procedure edSubstringKeyPress(Sender: TObject; var Key: Char);
  private
       Image: TImage;
    hLib1: HMODULE;
    hLib2: HMODULE;

    FBytes: TBytes;
    InfoFunction1: TStrFunction;
    InfoFunction2: TStrFunction;
    FileSearchFunction: TFileSearchFunction;
    SearchCharsFunction: TSearchCharsFunction;
    FIsDll1: boolean;
    FIsDll2: boolean;
    FMaskSearchDir: string;
    FFileToSearchSubstring: string;
    procedure InitDlls;
    procedure ShowInfo;
    procedure SetIsDll1(const Value: boolean);
    procedure SetIsDll2(const Value: boolean);

    procedure CheckNew(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure ShowNew(ANumber: integer);
    procedure SetMaskSearchDir(const Value: string);
    procedure SetFileToSearchSubstring(const Value: string);
    function HexToBytes(const S: string): TBytes;
  protected
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
  public
    property IsDll1: boolean read FIsDll1 write SetIsDll1;
    property IsDll2: boolean read FIsDll2 write SetIsDll2;
    property MaskSearchDir: string read FMaskSearchDir write SetMaskSearchDir;
    property FileToSearchSubstring: string read FFileToSearchSubstring write SetFileToSearchSubstring;
  end;


var
  MainForm: TMainForm;


implementation

{$R *.dfm}
uses FormSearchResult, FormFileView;
{
function TMainForm.HexPairToByte(const S: string): Byte;
var
  Value: Integer;
begin
  if not TryStrToInt('$' + S, Value) then
    raise Exception.CreateFmt('"%s" не является байтом', [S]);
  Result := Byte(Value);
end;
}

procedure TMainForm.actCloseExecute(Sender: TObject);
begin
  Close;
end;

(*
procedure TMainForm.actSearchSubstringExecute(Sender: TObject);
var
  FFV: TFileViewForm;
  FS: TFileStream;
  ReadBytes, i: Integer;
  Buffer: array[0..7] of Byte;
  PosStr: PChar;
  S: string;
  L:TStringList;
begin
  OpenDialog.InitialDir := GetCurrentDir;
  if OpenDialog.Execute then
  begin
    FS:= TFileStream.Create(OpenDialog.FileName, fmOpenRead or fmShareDenyNone);
    FFV:= TFileViewForm.Create(Self);
    FFV.RichEdit.Lines.BeginUpdate;
    try
      L:= TStringList.Create;
      while FS.Position < FS.Size do
      begin
        S:= '';
        ReadBytes := FS.Read(Buffer, SizeOf(Buffer));
        for i:= 0 to ReadBytes - 1 do
        begin
          S:= S + ' ' + IntToHex(Buffer[i], 2);
        end;
//        FFV.RichEdit.Lines.Add(S);
        L.Add(S);
        S:= '';
      end;
      FFV.RichEdit.MaxLength:= 2147483645;
      FFV.RichEdit.Lines.Text:= L.Text;
      FFV.Show{Modal};
      FFV.RichEdit.SetFocus;
      FFV.RichEdit.Selstart:= FFV.RichEdit.Perform(EM_LineIndex, 0, 0) + 0;
      FFV.RichEdit.Perform(EM_ScrollCaret, 0, 0);

  if SearchCharsFunction(PWideChar(OpenDialog.FileName), PAnsiChar(edSubstring.Text), 0, PosStr) then
   begin
     ShowMessage(PosStr);
     S:= PosStr;
   end;
   LocalFree(HLOCAL(PosStr));

    finally
      FFV.RichEdit.Lines.EndUpdate;
      FS.Free;
    end;
  end;
end;
*)

procedure TMainForm.actSearchSubstringExecute(Sender: TObject);
var
  FFV: TFileViewForm;
  FS: TFileStream;
  ReadBytes, i: Integer;
  Buffer: array[0..7] of Byte;
  PosStr: PChar;
  S: string;
  L:TStringList;
begin
//  FS:= TFileStream.Create(OpenDialog.FileName, fmOpenRead or fmShareDenyNone);
//  FFV:= TFileViewForm.Create(Self);
//  FFV.RichEdit.Lines.BeginUpdate;
  try
{    L:= TStringList.Create;
    while FS.Position < FS.Size do
    begin
      S:= '';
      ReadBytes := FS.Read(Buffer, SizeOf(Buffer));
      for i:= 0 to ReadBytes - 1 do
      begin
        S:= S + ' ' + IntToHex(Buffer[i], 2);
      end;
//        FFV.RichEdit.Lines.Add(S);
      L.Add(S);
      S:= '';
    end;
    FFV.RichEdit.Lines.Text:= L.Text;
    FFV.Show{Modal};
{    FFV.RichEdit.SetFocus;
    FFV.RichEdit.Selstart:= FFV.RichEdit.Perform(EM_LineIndex, 0, 0) + 0;
    FFV.RichEdit.Perform(EM_ScrollCaret, 0, 0);
 }

 if SearchCharsFunction(PWideChar(FFileToSearchSubstring), {PAnsiChar('MZ')}PAnsiChar(edByteStr.Text), 0, PosStr) then
 begin
   S:= PosStr;
   ShowMessage(S);
 end;
 LocalFree(HLOCAL(PosStr));

  finally
//    FFV.RichEdit.Lines.EndUpdate;
//    FS.Free;
  end;
end;


procedure TMainForm.actSetFileExecute(Sender: TObject);
begin
  OpenDialog.InitialDir := GetCurrentDir;
  if OpenDialog.Execute then
  begin
    FFileToSearchSubstring:= OpenDialog.FileName;
  end else
  begin
    FFileToSearchSubstring:= '';
    lblSubstring.Caption:= '';
  end;
  rgSearchSubstringClick(Self);
  btnSearchSubstring.Enabled:= (edByteStr.Text <> '') and (FileToSearchSubstring <> '')
end;

function TMainForm.HexToBytes(const S: string): TBytes;
var
  Parts: TStringList;
  i: Integer;
  B: Integer;
begin
  Parts := TStringList.Create;
  try
    Parts.Delimiter := ' ';
    Parts.StrictDelimiter := True;
    Parts.DelimitedText := Trim(S);

    SetLength(Result, Parts.Count);
    for i := 0 to Parts.Count - 1 do
    begin
      if not TryStrToInt('$' + Parts[i], B) then
        raise Exception.CreateFmt('"%s" не является hex-байтом', [Parts[i]]);
      if (B < 0) or (B > 255) then
        raise Exception.CreateFmt('"%s" вне диапазона байта', [Parts[i]]);
      Result[i] := Byte(B);
    end;
  finally
    Parts.Free;
  end;
end;

procedure TMainForm.actConvertToBytesExecute(Sender: TObject);
var
  Bytes: TBytes;
  i: Integer;
begin
  edByteStr.Clear;
  Bytes := HexToBytes(edSubstring.Text);
  for i := 0 to High(Bytes) do
//    edByteStr.Text:= edByteStr.Text + HexToStr(Bytes[i]);
    edByteStr.Text:= edByteStr.Text + Chr(Bytes[i]);
end;

procedure TMainForm.actMaskSearchExecute(Sender: TObject);
begin
   FileSearchFunction(PWideChar(MaskSearchDir), PWideChar(edMask.Text));
   Memo.Lines.Add('Задано: поиск файлов по маске ' + edMask.Text);
end;

{
procedure TMainForm.btnSearchSubstringClick(Sender: TObject);
var
  PosStr: PChar;
  S: string;
begin
  if SearchCharsFunction('mko.exe', PAnsiChar('MZ'), 0, PosStr) then
   begin
//     ShowMessage(String(PosStr));
     S:= PosStr;
     ShowViewer(S);
   end;
   LocalFree(HLOCAL(PosStr));
end;
}
procedure TMainForm.CheckNew(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ShowMessage('Ура!');
end;

procedure TMainForm.DirectoryListBoxChange(Sender: TObject);
begin
  MaskSearchDir:= DirectoryListBox.Directory;
  lblSelected.Caption:= MaskSearchDir;
end;

procedure TMainForm.edSubstringKeyPress(Sender: TObject; var Key: Char);
begin
  // Разрешаем только HEX и пробел
  if not (Key in ['0'..'9', 'A'..'F', 'a'..'f', ' ', #8]) then
    Key := #0;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  OldBkMode: integer;
  Page: integer;
begin
  StatusBar.DoubleBuffered:= true;
  Image:= TImage.Create(StatusBar);
  Image.Left:= StatusBar.Width - 16;
  Image.Top:= 2;
  Image.Parent:= StatusBar;
  Image.OnMouseDown:= CheckNew;
  Image.Picture.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'drop.bmp');
  OldBkMode := SetBkMode(Image.Canvas.Handle, Transparent);
  Image.Canvas.TextOut(2, 2, '10');
  SetBkMode(Image.Canvas.Handle, OldBkMode);

  StringGrid.Cells[0, 0]:= 'Библиотека';
  StringGrid.Cells[1, 0]:= 'Функция';
  StringGrid.Cells[2, 0]:= 'Описание';

  for Page:= 0 to PageControl.PageCount - 1 do
  begin
    PageControl.Pages[Page].TabVisible := false;
  end;
  PageControl.ActivePage:= TabSheet1;

  DirectoryListBoxChange(Self);
  rgSearchSubstringClick(Self);
//  edSubstring.Text := 'DE AD BE EF';
  btnSearchSubstring.Enabled:= FFileToSearchSubstring <> '';
  InitDlls;
  ShowInfo;
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
  Image.Left:= StatusBar.Width - 16;
  Image.Top:= 2;
end;

procedure TMainForm.InitDlls;
begin
  hLib1:= LoadLibrary('dll1.dll');
  if hLib1 <> 0 then
  begin
    @InfoFunction1:= GetProcAddress(hLib1, 'GetInfo');
    IsDll1:= @InfoFunction1 <> nil;
    if not IsDll1 then
    begin
      StatusBar.Panels[0].Text:= 'Ошибка: Не найдена функция GetInfo в dll1.dll';
      Memo.Lines.Add('Ошибка: Не найдена функция GetInfo в dll1.dll');
    end;
  end else
  begin
    StatusBar.Panels[0].Text:= 'Ошибка: Не загружена dll1.dll';
    Memo.Lines.Add('Ошибка: Не загружена dll1.dll');
  end;

  hLib2:= LoadLibrary('dll2.dll');
  if hLib2 <> 0 then
  begin
    @InfoFunction2:= GetProcAddress(hLib2, 'GetInfo');
    IsDll2:= @InfoFunction2 <> nil;
    if not IsDll2 then
    begin
      StatusBar.Panels[0].Text:= 'Ошибка: Не найдена функция GetInfo в dll2.dll';
      Memo.Lines.Add('Ошибка: Не найдена функция GetInfo в dll2.dll');
    end;
  end else
  begin
    StatusBar.Panels[0].Text:= 'Ошибка: Не загружена dll2.dll';
    Memo.Lines.Add('Ошибка: Не загружена dll2.dll');
  end;

end;

procedure TMainForm.rgSearchSubstringClick(Sender: TObject);
begin
  lblBytes.Visible:= rgSearchSubstring.ItemIndex > 0;
  if rgSearchSubstring.ItemIndex = 0 then
  begin
    lblSubstring.Caption:= 'Подстрока ' + QuotedStr(edByteStr.Text) + ' в файле ' + FFileToSearchSubstring;
    lblBytes.Visible:= false;
    lblSubstring.Visible:= true;
    edSubstring.Visible:= false;
    btnConvert.Visible:= false;
    btnSearchSubstring.Enabled:= (edByteStr.Text <> '') and (FFileToSearchSubstring <> '');
  end else
  begin
    lblSubstring.Caption:= 'Набор байт ' +
                           QuotedStr(edByteStr.Text) +
                           ' в файле ' +
                           FFileToSearchSubstring;
    lblBytes.Visible:= true;
    lblSubstring.Visible:= true;
    edSubstring.Visible:= true;
    btnConvert.Visible:= true;
    btnSearchSubstring.Enabled:= (edByteStr.Text <> '') and (FFileToSearchSubstring <> '');
  end;
end;

procedure TMainForm.SetFileToSearchSubstring(const Value: string);
begin
  FFileToSearchSubstring := Value;
end;

procedure TMainForm.SetIsDll1(const Value: boolean);
begin
  FIsDll1 := Value;
end;

procedure TMainForm.SetIsDll2(const Value: boolean);
begin
  FIsDll2 := Value;
end;

procedure TMainForm.SetMaskSearchDir(const Value: string);
begin
  FMaskSearchDir := Value;
end;

procedure TMainForm.ShowInfo;
var
  L: TStringList;
  L1: TStringList;
  S: string;
  i: integer;
//  PosStr: PChar;
begin
  if IsDll1 then
  begin
    L:= TStringList.Create;
    L1:= TStringList.Create;
    try
      L.Delimiter:= ';';
      L.StrictDelimiter:= true;
      L.DelimitedText:= InfoFunction1;
      StringGrid.RowCount:= L.Count + 1;
      L1.Delimiter:= ',';
      L1.StrictDelimiter:= true;
      i:= 1;
      for S in L do
      begin
        L1.DelimitedText:= S;
        StringGrid.Cells[0, i]:= 'dll1.dll';
        StringGrid.Cells[1, i]:= L1[0];
        StringGrid.Cells[2, i]:= L1[1];
        Inc(i);
      end;

      L.DelimitedText:= InfoFunction2;
      StringGrid.RowCount:= StringGrid.RowCount + L.Count;
      for S in L do
      begin
        L1.DelimitedText:= S;
        StringGrid.Cells[0, i]:= 'dll2.dll';
        StringGrid.Cells[1, i]:= L1[0];
        StringGrid.Cells[2, i]:= L1[1];
        Inc(i);
      end;

      @FileSearchFunction:= GetProcAddress(hLib1, 'GetFiles');

      @SearchCharsFunction:= GetProcAddress(hLib1, 'SearchCharsSequence');
{
      if SearchCharsFunction('mko.exe', PAnsiChar('MZ'), 0, PosStr) then
      begin
        if PosStr<> nil then
        begin
          S:= PosStr;
          L1.DelimitedText:= S;
//          ShowMessage(S);
        end;
      end;
}
    finally
      L1.Free;
      L.Free;
    end;
  end;
end;

procedure TMainForm.ShowNew(ANumber: integer);
var
  OldBkMode: integer;
begin
  Image.OnMouseDown:= CheckNew;
  Image.Picture.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'drop.bmp');
  OldBkMode := SetBkMode(Image.Canvas.Handle, Transparent);
  Image.Canvas.TextOut(2, 2, IntToStr(ANumber));
  SetBkMode(Image.Canvas.Handle, OldBkMode);
end;

procedure TMainForm.StringGridClick(Sender: TObject);
begin
  case StringGrid.Row of
  1:
  begin
    PageControl.ActivePageIndex:= 0;
  end;
  2:
  begin
    PageControl.ActivePageIndex:= 1;
  end;
  end;

end;

procedure TMainForm.WMCopyData(var Msg: TWMCopyData);
var
  ReceivedStr: string;
  L: TStringList;
  F: TSearchResultForm;
begin
  if Msg.CopyDataStruct <> nil then
  begin
    ReceivedStr := PWideChar(Msg.CopyDataStruct.lpData);
    L:= TStringList.Create;
    L.Delimiter:= ',';
    L.StrictDelimiter:= true;
    L.DelimitedText:= ReceivedStr;
    F:= TSearchResultForm.Create(Self);
    try
      F.ListBox.ScrollWidth:= 800;
      F.ListBox.Style:= lbVirtual;
      F.List:= L;
      F.ListBox.Count:= L.Count;
      ShowNew(1);
      F.Show{Modal};
      Memo.Lines.Add('Готово: поиск файлов по маске ' + edMask.Text);
    finally
    //  F.Free;
    end;

  end;
end;

end.
