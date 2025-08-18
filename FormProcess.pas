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

// thunk-������� ��� DLL
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

  LblCmd.Caption := '�������: ' + Cmd;
  FStartTime := Now;
  LblTime.Caption := '�����: 00:00:00';
  Timer.Enabled := True;

  // ��������� ������� ����� DLL (RunProcess �� FormMain)
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
  Memo.Lines.Add(Format('*** ������� ��������, ���: %d ***', [ExitCode]));
  MainForm.Memo.Lines.Add('������: ������� ' + FCmd + ' ��������');
end;

procedure TProcessForm.BtnStopClick(Sender: TObject);
begin
  if Assigned(FTask) then
  begin
    MainForm.StopProcess(FTask);
    FTask := nil;
    Timer.Enabled := False;
    Memo.Lines.Add('*** ������� ���������� ������������� ***');
    MainForm.Memo.Lines.Add('������� ' + FCmd + ' ���������� �������������');
  end;
end;

procedure TProcessForm.Timer1Timer(Sender: TObject);
var
  Elapsed: TDateTime;
  H, M, S, MS: Word;
begin
  Elapsed := Now - FStartTime;
  DecodeTime(Elapsed, H, M, S, MS);
  LblTime.Caption := Format('�����: %.2d:%.2d:%.2d', [H, M, S]);
end;

{ --- thunk-������� --- }

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

