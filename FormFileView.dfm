object FileViewForm: TFileViewForm
  Left = 0
  Top = 0
  Caption = 'FileViewForm'
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poMainFormCenter
  OnResize = FormResize
  TextHeight = 15
  object pnlButtons: TPanel
    Left = 0
    Top = 392
    Width = 624
    Height = 49
    Align = alBottom
    TabOrder = 0
    object btnOk: TButton
      Left = 264
      Top = 16
      Width = 75
      Height = 25
      Caption = 'Ok'
      ModalResult = 1
      TabOrder = 0
    end
  end
  object pnlCenter: TPanel
    Left = 0
    Top = 0
    Width = 624
    Height = 392
    Align = alClient
    BorderWidth = 5
    TabOrder = 1
    ExplicitLeft = 360
    ExplicitTop = 200
    ExplicitWidth = 185
    ExplicitHeight = 41
    object RichEdit: TRichEdit
      Left = 6
      Top = 6
      Width = 612
      Height = 380
      Align = alClient
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'Courier'
      Font.Style = [fsBold]
      ParentFont = False
      TabOrder = 0
      ExplicitLeft = 176
      ExplicitTop = 144
      ExplicitWidth = 185
      ExplicitHeight = 89
    end
  end
end
