unit FormRunProcess;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TRunProcessForm = class(TForm)
    pnlButtons: TPanel;
    btnStop: TButton;
    pnlCenter: TPanel;
    memoProcess: TMemo;
    btnClose: TButton;
    procedure FormResize(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    FTask: pointer;
    procedure SetTask(const Value: pointer);

  public
    property Task: pointer read FTask write SetTask;
  end;

var
  RunProcessForm: TRunProcessForm;

implementation
uses FormMain;

{$R *.dfm}

procedure TRunProcessForm.btnCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TRunProcessForm.btnStopClick(Sender: TObject);
begin
  if Assigned(MainForm.StopProcess) and (Task <> nil) then
  begin
    if MainForm.StopProcess(Task) then
      MemoProcess.Lines.Add('Процесс принудительно завершён');
    btnClose.Enabled:= true;
  end;
end;

procedure TRunProcessForm.FormResize(Sender: TObject);
begin
  btnStop.Left := (Self.Width div 2) - (btnStop.Width div 2);
end;

procedure TRunProcessForm.SetTask(const Value: pointer);
begin
  FTask := Value;
end;

end.
