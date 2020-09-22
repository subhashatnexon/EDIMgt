page 60004 "NXN Doc. Creation Error Log"
{
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NXN Doc. Creation Error Log";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Table Name"; "Table Name")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field("Table Entry No"; "Table Entry No")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Entry No field';
                }
                field("Document Type"; "Document Type")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Type field';
                }
                field("Reference No."; "Reference No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Reference No. field';
                }
                field("Error Description"; "Error Description")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Description field';
                }
                field("Error Description 2"; "Error Description 2")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Error Description 2 field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field(Closed; Closed)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Closed field';
                }
                field("Initial Execution Timestamp"; "Initial Execution Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Initial Execution Timestamp field';
                }
                field("Execution Timestamp"; "Execution Timestamp")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Execution Timestamp field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = All;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(creation)
        {
            action(Retry)
            {
                Image = CarryOutActionMessage;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Retry action';

                trigger OnAction()
                begin
                    EDISetup.GET;

                    TESTFIELD(Closed, FALSE);
                    TESTFIELD(Status, Status::"Document Error");
                    //IF ("Retry Counter" >= EDISetup."Max Retry Attempt - Doc Create") THEN
                    //ERROR(Text0001, EDISetup."Max Retry Attempt - Doc Create");
                    //ReTryDocCreationProcess.ReTryDocCreationProcess(Rec);
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        SETRANGE(Closed, FALSE);
    end;

    var
        EDISetup: Record "NXN EDI Setup";
        //ReTryDocCreationProcess: Codeunit "50001";
        Text0001: Label 'Maximum Number of Re-Try Attempts %1 have expired.';
}

