unit popup;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, LCLType;

type

  { TfrmPopup }

  TfrmPopup = class(TForm)
    btnCancel: TButton;
    btnOK: TButton;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    procedure btnOKClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private

  public
    Edit1Text, Edit2Text: string;

  end;

var
  frmPopup: TfrmPopup;

implementation

{$R *.lfm}

{ TfrmPopup }

procedure TfrmPopup.btnOKClick(Sender: TObject);
begin
  Edit1Text:=LabeledEdit1.Text;
  Edit2Text:=LabeledEdit2.Text;
end;

procedure TfrmPopup.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Edit1Text:=LabeledEdit1.Text;
  Edit2Text:=LabeledEdit2.Text;
end;
end.

