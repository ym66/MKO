unit FormSearchResult;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TSearchResultForm = class(TForm)
    pnlBottom: TPanel;
    btnOk: TButton;
    pnlTop: TPanel;
    ListBox: TListBox;
    procedure ListBoxData(Control: TWinControl; Index: Integer; var Data: string);
    procedure btnOkClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FList: TStringList;
    procedure SetList(const Value: TStringList);
  public
    property List: TStringList read FList write SetList;
  end;

var
  SearchResultForm: TSearchResultForm;

implementation

{$R *.dfm}


procedure TSearchResultForm.btnOkClick(Sender: TObject);
begin
  Close;
end;

procedure TSearchResultForm.FormResize(Sender: TObject);
begin
  btnOk.Left := (Self.Width div 2) - (btnOk.Width div 2);
end;

procedure TSearchResultForm.ListBoxData(Control: TWinControl; Index: Integer;
  var Data: string);
begin
  Data:= List[Index];
end;

procedure TSearchResultForm.SetList(const Value: TStringList);
begin
  FList := Value;
end;

end.
