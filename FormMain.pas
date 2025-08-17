unit FormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Actions, Vcl.ActnList, Vcl.ComCtrls, Vcl.Grids, Vcl.WinXCtrls,
  System.ImageList, Vcl.ImgList, Vcl.Mask, Vcl.FileCtrl,
  Vcl.Samples.DirOutln;

type
// Типы функций из DLL
  TStrFunction= function: PWideChar; stdcall;
  TFileSearchFunction= function(ADir, AMask: PWideChar): PWideChar; stdcall;
  TSearchCharsFunction= function(FileName: PChar; SubStr: PByte; SubStrLen: Integer): PChar; stdcall;

// Типы коллбеков
type
  TOutputCallback = procedure(const Line: PChar; UserData: Pointer); stdcall;
  TFinishedCallback = procedure(ExitCode: DWORD; UserData: Pointer); stdcall;

// Типы функций из DLL
type
  TRunProcess = function(const CmdLine: PChar;
                         OutputCB: TOutputCallback;
                         FinishedCB: TFinishedCallback;
                         UserData: Pointer): Pointer; stdcall;
  TTerminateProcessTask = function(TaskPtr: Pointer): BOOL; stdcall;
  TFreeProcessTask = procedure(TaskPtr: Pointer); stdcall;

// Коллбеки
  procedure OnOutput(const Line: PChar; UserData: Pointer); stdcall;
  procedure OnFinished(ExitCode: DWORD; UserData: Pointer); stdcall;

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
    Label3: TLabel;
    lblSubstring: TLabel;
    btnSearchSubstring: TButton;
    actSearchSubstring: TAction;
    btnFile: TButton;
    OpenDialog: TOpenDialog;
    actSetFile: TAction;
    edSubstring: TEdit;
    lblInfo: TLabel;
    TabSheet3: TTabSheet;
    pnlRunProcess: TPanel;
    lblCommand: TLabel;
    edCommand: TEdit;
    btnStart: TButton;
    memoProcess: TMemo;
    actStart: TAction;
    Button1: TButton;
    actStop: TAction;
    procedure actCloseExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure DirectoryListBoxChange(Sender: TObject);
    procedure actMaskSearchExecute(Sender: TObject);
    procedure StringGridClick(Sender: TObject);
    procedure actSetFileExecute(Sender: TObject);
    procedure edSubstringKeyPress(Sender: TObject; var Key: Char);
    procedure actSearchSubstringExecute(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure actStartExecute(Sender: TObject);
    procedure actStopExecute(Sender: TObject);
  private
//       Image: TImage;
    hLib1: HMODULE;
    hLib2: HMODULE;

    FBytes: TBytes;
    InfoFunction1: TStrFunction;
    InfoFunction2: TStrFunction;
    FileSearchFunction: TFileSearchFunction;
    SearchCharsFunction: TSearchCharsFunction;

    RunProcess: TRunProcess;

    FreeProcessTask: TFreeProcessTask;

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
    TerminateProcessTask: TTerminateProcessTask;
    Task: Pointer;
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


procedure OnOutput(const Line: PChar; UserData: Pointer); stdcall;
begin
  MainForm.memoProcess.Lines.Add(string(Line));
end;

procedure OnFinished(ExitCode: DWORD; UserData: Pointer); stdcall;
begin
  MainForm.memoProcess.Lines.Add(Format('*** Процесс завершён, код: %d ***', [ExitCode]));
  MainForm.Memo.Lines.Add('Готово: ' + MainForm.edCommand.Text);
end;

procedure TMainForm.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.actSearchSubstringExecute(Sender: TObject);
var
  PosStr: PChar;
  S: string;
  SubStr: array of Byte; // подстрока для передачи в функцию Dll
  L: TStringList;
  L0: TStringList;
  LAll: TStringList;
  FFV: TFileViewForm;
  i: integer;
  j: integer;
  C: char;
  Sub: Ansistring; // подстрока
begin
   Memo.Lines.Add('Задано: поиск подстроки');
   // Здесь храним подстроки
   L0:= TStringList.Create;
   LAll:= TStringList.Create;
   try
     L0.Duplicates:= dupIgnore;
     L0.Delimiter:= ';';
     L0.StrictDelimiter:= true;
     L0.DelimitedText:= edSubstring.Text;

     FFV:= TFileViewForm.Create(Self);


     for j:= 0  to L0.Count - 1 do
     begin
       Sub:= L0[j];
       SetLength(SubStr, Length(Sub));
       for i:= 0 to Length(Sub) - 1 do
       begin
         SubStr[i]:= Ord(Sub[i + 1]);
       end;
    //   SubStr[0]:= ord('M');
    //   SubStr[1]:= ord('Z');
       PosStr:= SearchCharsFunction(PWideChar(FFileToSearchSubstring), @SubStr[0], 2);
       if Assigned(PosStr) then
       begin
    //     ShowMessage(String(PosStr));
         S:= PosStr;
       end else Exit;
       LocalFree(HLOCAL(PosStr));
       L:= TStringList.Create;
       try
         L.Delimiter:= ',';
         L.StrictDelimiter:= true;
         L.DelimitedText:= S;
         for i:= 0 to L.Count - 1 do
         begin
           L[i]:= L[i] + ' позиция ' + QuotedStr(L0[j]) + ' в ' + FFileToSearchSubstring;
           LAll.Add(L[i]);
         end;
       finally
         L.Free;
       end;

     end;   //for
     FFV.ListBox.Items:= LAll;
   finally
     L0.Free;
     LAll.Free;
   end;
   FFV.lblCharsResult.Caption:= 'Позиции подстрок ' + QuotedStr(edSubstring.Text) + ' в файле ' + FFileToSearchSubstring;
   FFV.Show;
   Memo.Lines.Add('Готово: поиск подстроки');
end;

procedure TMainForm.actSetFileExecute(Sender: TObject);
begin
  OpenDialog.InitialDir := GetCurrentDir;
  if OpenDialog.Execute then
  begin
    FFileToSearchSubstring:= OpenDialog.FileName;
    btnSearchSubstring.Enabled:= true;
    lblInfo.Caption:='Подстроки ' + edSubstring.Text + ' в файле ' + FFileToSearchSubstring;
    lblInfo.Visible:= true;
  end else
  begin
    FFileToSearchSubstring:= '';
    lblSubstring.Caption:= '';
    btnSearchSubstring.Enabled:= false;
  end;
end;

procedure TMainForm.actStartExecute(Sender: TObject);
begin
  if Assigned(RunProcess) then
  begin
    MemoProcess.Clear;
    // запускаем 7z архиватор (или любую CLI-команду)
    Task := RunProcess(PChar(edCommand.Text),{'cmd /c "7z a archive.7z *.txt"',}
                       @OnOutput,
                       @OnFinished,
                       nil);
    Memo.Lines.Add('Задано: ' + edCommand.Text);
  end
  else;
end;

procedure TMainForm.actStopExecute(Sender: TObject);
begin
  if Assigned(TerminateProcessTask) and (Task <> nil) then
  begin
    if MainForm.TerminateProcessTask(Task) then
      MemoProcess.Lines.Add('Процесс принудительно завершён');
  end;
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


procedure TMainForm.actMaskSearchExecute(Sender: TObject);
begin
   FileSearchFunction(PWideChar(MaskSearchDir), PWideChar(edMask.Text));
   Memo.Lines.Add('Задано: поиск файлов по маске ' + edMask.Text);
end;

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
{  Image:= TImage.Create(StatusBar);
  Image.Left:= StatusBar.Width - 16;
  Image.Top:= 2;
  Image.Parent:= StatusBar;
  Image.OnMouseDown:= CheckNew;
  Image.Picture.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'drop.bmp');
  OldBkMode := SetBkMode(Image.Canvas.Handle, Transparent);
  Image.Canvas.TextOut(2, 2, '10');
  SetBkMode(Image.Canvas.Handle, OldBkMode);}

  StringGrid.Cells[0, 0]:= 'Библиотека';
  StringGrid.Cells[1, 0]:= 'Функция';
  StringGrid.Cells[2, 0]:= 'Описание';

  for Page:= 0 to PageControl.PageCount - 1 do
  begin
    PageControl.Pages[Page].TabVisible := false;
  end;
  PageControl.ActivePage:= TabSheet1;

  DirectoryListBoxChange(Self);

  btnSearchSubstring.Enabled:= FFileToSearchSubstring <> '';
  lblInfo.Visible:= false;
  InitDlls;
  ShowInfo;
  btnStart.Enabled:= IsDll2;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
 if Assigned(FreeProcessTask) and (Task <> nil) then
    FreeProcessTask(Task);
  if hLib1 <> 0 then
    FreeLibrary(hLib1);
end;

procedure TMainForm.FormResize(Sender: TObject);
begin
{  Image.Left:= StatusBar.Width - 16;
  Image.Top:= 2;}
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
  PosStr: PChar;
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

      @SearchCharsFunction:= GetProcAddress(hLib1, 'FindSubstringInFile');


      @RunProcess:= GetProcAddress(hLib2, 'RunProcess');
      @TerminateProcessTask := GetProcAddress(hLib2, 'TerminateProcessTask');
      @FreeProcessTask := GetProcAddress(hLib2, 'FreeProcessTask');
    finally
      L1.Free;
      L.Free;
    end;
  end;
end;

procedure TMainForm.ShowNew(ANumber: integer);
{var
  OldBkMode: integer;}
begin
{  Image.OnMouseDown:= CheckNew;
  Image.Picture.LoadFromFile(ExtractFilePath(ParamStr(0)) + 'drop.bmp');
  OldBkMode := SetBkMode(Image.Canvas.Handle, Transparent);
  Image.Canvas.TextOut(2, 2, IntToStr(ANumber));
  SetBkMode(Image.Canvas.Handle, OldBkMode);}
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
  3:
  begin
    PageControl.ActivePageIndex:= 2;
  end;
  end;

end;

// Вывод результата поиска файлов
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
      F.Show;
      Memo.Lines.Add('Готово: поиск файлов по маске ' + edMask.Text);
    finally
    end;

  end;
end;

end.
