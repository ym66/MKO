unit FormFileView;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TFileViewForm = class(TForm)
    pnlButtons: TPanel;
    btnOk: TButton;
    pnlCenter: TPanel;
    lblCharsResult: TLabel;
    ListBox: TListBox;
    procedure FormResize(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FileViewForm: TFileViewForm;

implementation

{$R *.dfm}

procedure TFileViewForm.btnOkClick(Sender: TObject);
begin
  Close;
end;

procedure TFileViewForm.FormResize(Sender: TObject);
begin
  btnOk.Left := (Self.Width div 2) - (btnOk.Width div 2);
end;

end.
