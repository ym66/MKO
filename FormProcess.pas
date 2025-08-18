unit FormProcess;

interface

uses
  Windows, SysUtils, Classes, Forms, StdCtrls, Controls, ExtCtrls, FormMain;

type
  TProcessForm = class(TForm)
    Memo: TMemo;
    BtnStop: TButton;
    LblCmd: TLabel;
    LblTime: TLabel;
    Timer: TTimer;
    procedure BtnStopClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    FTask: Pointer;
    FCmd: string;
    FStartTime: TDateTime;
    procedure DoOutput(const Line: PChar);
    procedure DoFinished(ExitCode: DWORD);
  public
    constructor CreateWithProcess(const Cmd: string);
    destructor Destroy; override;
  end;

// thunk-функции для DLL
procedure OutputThunk(const Line: PChar; UserData: Pointer); stdcall;
procedure FinishedThunk(ExitCode: DWORD; UserData: Pointer); stdcall;

var
  ProcessForm: TProcessForm;

implementation

{$R *.dfm}

constructor TProcessForm.CreateWithProcess(const Cmd: string);
begin
  inherited Create(nil);
  FCmd := Cmd;
  Caption := 'Process Window';
  Memo.Clear;

  LblCmd.Caption := 'Команда: ' + Cmd;
  FStartTime := Now;
  LblTime.Caption := 'Время: 00:00:00';
  Timer.Enabled := True;

  // запускаем процесс через DLL (RunProcess из FormMain)
  FTask := MainForm.RunProcess(PChar(Cmd),
                      @OutputThunk,
                      @FinishedThunk,
                      Self);
end;

destructor TProcessForm.Destroy;
begin
  Timer.Enabled := False;
  if Assigned(FTask) then
    MainForm.StopProcess(FTask);
  inherited;
end;

procedure TProcessForm.DoOutput(const Line: PChar);
begin
  Memo.Lines.Add(string(Line));
end;

procedure TProcessForm.DoFinished(ExitCode: DWORD);
begin
  Timer.Enabled := False;
  Memo.Lines.Add(Format('*** Процесс завершён, код: %d ***', [ExitCode]));
  MainForm.Memo.Lines.Add('Готово: Процесс ' + FCmd + ' завершен');
end;

procedure TProcessForm.BtnStopClick(Sender: TObject);
begin
  if Assigned(FTask) then
  begin
    MainForm.StopProcess(FTask);
    FTask := nil;
    Timer.Enabled := False;
    Memo.Lines.Add('*** Процесс остановлен пользователем ***');
    MainForm.Memo.Lines.Add('Процесс ' + FCmd + ' остановлен пользователем');
  end;
end;

procedure TProcessForm.Timer1Timer(Sender: TObject);
var
  Elapsed: TDateTime;
  H, M, S, MS: Word;
begin
  Elapsed := Now - FStartTime;
  DecodeTime(Elapsed, H, M, S, MS);
  LblTime.Caption := Format('Время: %.2d:%.2d:%.2d', [H, M, S]);
end;

{ --- thunk-функции --- }

procedure OutputThunk(const Line: PChar; UserData: Pointer); stdcall;
begin
  if Assigned(UserData) then
    TProcessForm(UserData).DoOutput(Line);
end;

procedure FinishedThunk(ExitCode: DWORD; UserData: Pointer); stdcall;
begin
  if Assigned(UserData) then
    TProcessForm(UserData).DoFinished(ExitCode);
end;

end.

