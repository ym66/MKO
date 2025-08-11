object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = #1052#1050#1054' '#1090#1077#1089#1090#1086#1074#1072#1103' '#1087#1088#1086#1075#1088#1072#1084#1084#1072
  ClientHeight = 486
  ClientWidth = 668
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  OnCreate = FormCreate
  OnResize = FormResize
  TextHeight = 15
  object pnlButtons: TPanel
    Left = 0
    Top = 429
    Width = 668
    Height = 57
    Align = alBottom
    TabOrder = 0
    DesignSize = (
      668
      57)
    object btnClose: TButton
      Left = 572
      Top = 6
      Width = 75
      Height = 25
      Action = actClose
      Anchors = [akRight, akBottom]
      Caption = #1047#1072#1082#1088#1099#1090#1100
      TabOrder = 0
    end
    object StatusBar: TStatusBar
      Left = 1
      Top = 37
      Width = 666
      Height = 19
      Panels = <
        item
          Width = 50
        end>
    end
  end
  object pnlCenter: TPanel
    Left = 0
    Top = 0
    Width = 668
    Height = 429
    Align = alClient
    TabOrder = 1
    object InfoPanel: TPanel
      Left = 1
      Top = 309
      Width = 666
      Height = 119
      Align = alBottom
      BorderWidth = 5
      TabOrder = 0
      object Memo: TMemo
        Left = 6
        Top = 6
        Width = 654
        Height = 107
        Align = alClient
        TabOrder = 0
      end
    end
    object pnlMain: TPanel
      Left = 1
      Top = 1
      Width = 666
      Height = 308
      Align = alClient
      BorderWidth = 5
      TabOrder = 1
      object Label1: TLabel
        Left = 6
        Top = 6
        Width = 654
        Height = 15
        Align = alTop
        Caption = #1057#1087#1080#1089#1086#1082' '#1079#1072#1076#1072#1095
        ExplicitWidth = 74
      end
      object StringGrid: TStringGrid
        Left = 6
        Top = 21
        Width = 654
        Height = 124
        Align = alTop
        ColCount = 3
        FixedCols = 0
        RowCount = 2
        Options = [goFixedVertLine, goFixedHorzLine, goVertLine, goHorzLine, goRangeSelect, goColSizing, goRowSelect, goFixedRowDefAlign]
        TabOrder = 0
        ColWidths = (
          73
          149
          425)
      end
    end
  end
  object ActionList: TActionList
    Left = 552
    Top = 24
    object actClose: TAction
      Caption = 'actClose'
      OnExecute = actCloseExecute
    end
  end
end
