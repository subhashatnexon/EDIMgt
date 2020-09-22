page 60015 "NXN Doc. Posting Error Log"
{
    // HBSTG P2CW013 2014-07-02: Page "Document Posting Error Log" to show errors while Auto-Posting of EDI Orders, Credit Memos.

    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NXN Doc. Posting Error Log";
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
                    ToolTip='Specifies the value of the Entry No. field';
                    ApplicationArea=All;
                }
                field("Posting Document Type"; "Posting Document Type")
                {
                    Editable = false;
                    ToolTip='Specifies the value of the Posting Document Type field';
                    ApplicationArea=All;
                }
                field("Document No."; "Document No.")
                {
                    Editable = false;
                    ToolTip='Specifies the value of the Document No. field';
                    ApplicationArea=All;
                }
                field("Reference No."; "Reference No.")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip='Specifies the value of the Reference No. field';
                    ApplicationArea=All;
                }
                field("Template Name"; "Template Name")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip='Specifies the value of the Template Name field';
                    ApplicationArea=All;
                }
                field("Batch Name"; "Batch Name")
                {
                    Editable = false;
                    Visible = false;
                    ToolTip='Specifies the value of the Batch Name field';
                    ApplicationArea=All;
                }
                field("Error Description"; "Error Description")
                {
                    Editable = false;
                    ToolTip='Specifies the value of the Error Description field';
                    ApplicationArea=All;
                }
                field("Error Description 2"; "Error Description 2")
                {
                    Editable = false;
                    ToolTip='Specifies the value of the Error Description 2 field';
                    ApplicationArea=All;
                }
                field("Retry Counter"; "Retry Counter")
                {
                    Editable = false;
                    ToolTip='Specifies the value of the Retry Counter field';
                    ApplicationArea=All;
                }
                field(Closed; Closed)
                {
                    ToolTip='Specifies the value of the Closed field';
                    ApplicationArea=All;
                }
                field("Execution Timestamp"; "Execution Timestamp")
                {
                    Editable = false;
                    ToolTip='Specifies the value of the Execution Timestamp field';
                    ApplicationArea=All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Link; Links)
            {
                ApplicationArea=All;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea=All;
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        SETRANGE(Closed, FALSE);
    end;
}

