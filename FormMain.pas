unit FormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.Actions, Vcl.ActnList, Vcl.ComCtrls, Vcl.Grids, Vcl.WinXCtrls,
  System.ImageList, Vcl.ImgList;

type
  TStrFunction= function: PWideChar; stdcall;
  TFileSearchFunction= function(ADir: PWideChar): PWideChar; stdcall;
//  TSearchCharsFunction= function(ASequence: PAnsiChar; AFile: PWideChar):PAnsiChar;  stdcall;
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
    procedure actCloseExecute(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
       Image: TImage;
    hLib1: HMODULE;
    hLib2: HMODULE;

    InfoFunction1: TStrFunction;
    InfoFunction2: TStrFunction;
    FileSearchFunction: TFileSearchFunction;
    SearchCharsFunction: TSearchCharsFunction;
    FIsDll1: boolean;
    FIsDll2: boolean;
    procedure InitDlls;
    procedure ShowInfo;
    procedure SetIsDll1(const Value: boolean);
    procedure SetIsDll2(const Value: boolean);

    procedure CheckNew(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
  protected
    procedure WMCopyData(var Msg: TWMCopyData); message WM_COPYDATA;
  public
    property IsDll1: boolean read FIsDll1 write SetIsDll1;
    property IsDll2: boolean read FIsDll2 write SetIsDll2;
  end;


var
  MainForm: TMainForm;


implementation

{$R *.dfm}
uses FormSearchResult;

procedure TMainForm.actCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.CheckNew(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ShowMessage('Ура!');
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  OldBkMode: integer;
begin
  StatusBar.DoubleBuffered:= true;
  Image:= TImage.Create(StatusBar);
  Image.Left:= StatusBar.Width - 16;
  Image.Top:= 2;
  Image.Parent:= StatusBar;
  Image.OnMouseDown:= CheckNew;
  Image.Picture.LoadFromFile('drop.bmp');
  OldBkMode := SetBkMode(Image.Canvas.Handle, Transparent);
  Image.Canvas.TextOut(2, 2, '10');
  SetBkMode(Image.Canvas.Handle, OldBkMode);

  StringGrid.Cells[0, 0]:= 'Библиотека';
  StringGrid.Cells[1, 0]:= 'Функция';
  StringGrid.Cells[2, 0]:= 'Описание';

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

procedure TMainForm.SetIsDll1(const Value: boolean);
begin
  FIsDll1 := Value;
end;

procedure TMainForm.SetIsDll2(const Value: boolean);
begin
  FIsDll2 := Value;
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
      FileSearchFunction('D:\');
      Memo.Lines.Add('Задано: поиск файлов по маске XXX');

      @SearchCharsFunction:= GetProcAddress(hLib1, 'SearchCharsSequence');

      if SearchCharsFunction('a.bin', PAnsiChar('12'), 0, PosStr) then
      begin
        if PosStr<> nil then
        begin
          S:= PosStr;
//          ShowMessage('Найдено: ' + PosStr);
          StrDispose(PosStr);
          L1.DelimitedText:= S;
          ShowMessage(L1[1]);
        end;
      end;

      //ShowMessage(S);
    finally
      L1.Free;
      L.Free;
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
      F.Show{Modal};
      Memo.Lines.Add('Готово: поиск файлов по маске XXX');
    finally
    //  F.Free;
    end;

  end;
end;

end.
