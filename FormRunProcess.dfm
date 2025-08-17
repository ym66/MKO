object RunProcessForm: TRunProcessForm
  Left = 0
  Top = 0
  Caption = #1047#1072#1087#1091#1089#1082' '#1087#1088#1086#1094#1077#1089#1089#1072
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnResize = FormResize
  TextHeight = 15
  object pnlButtons: TPanel
    Left = 0
    Top = 392
    Width = 624
    Height = 49
    Align = alBottom
    TabOrder = 0
    object btnStop: TButton
      Left = 264
      Top = 16
      Width = 75
      Height = 25
      Caption = #1057#1090#1086#1087
      TabOrder = 0
      OnClick = btnStopClick
    end
    object btnClose: TButton
      Left = 528
      Top = 16
      Width = 75
      Height = 25
      Caption = #1047#1072#1082#1088#1099#1090#1100
      Enabled = False
      TabOrder = 1
      OnClick = btnCloseClick
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
    ExplicitLeft = 272
    ExplicitTop = 192
    ExplicitWidth = 185
    ExplicitHeight = 41
    object memoProcess: TMemo
      Left = 6
      Top = 6
      Width = 612
      Height = 380
      Align = alClient
      TabOrder = 0
      ExplicitLeft = 208
      ExplicitTop = 192
      ExplicitWidth = 185
      ExplicitHeight = 89
    end
  end
end
