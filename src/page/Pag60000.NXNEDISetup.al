page 60000 "NXN EDI Setup"
{

    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "NXN EDI Setup";
    Caption = 'EDI Setup';
    UsageCategory = Administration;
    ApplicationArea = all;

    layout
    {
        area(content)
        {
            group(General)
            {
                group(EDI)
                {
                    field("Sender Email ID"; "Sender Email ID")
                    {
                        ApplicationArea = All;
                    }
                    field("Sender Name"; "Sender Name")
                    {
                        ApplicationArea = All;
                    }
                    field("CC To Sender Email ID"; "CC To Sender Email ID")
                    {
                        ApplicationArea = All;
                    }
                    field("Email Error Logs"; "Email Error Logs")
                    {
                        ApplicationArea = All;
                    }
                    field("Email Address Error Logs"; "Email Address Error Logs")
                    {
                        ApplicationArea = All;
                    }
                    field("Archive Doc in EDI Process"; "Archive Doc in EDI Process")
                    {
                        ApplicationArea = All;
                    }
                    // field("Errors Email Address"; "Errors Email Address")
                    // {
                    //     ApplicationArea = All;
                    //     ToolTip = 'Specifies the value of the Errors Email Address field';
                    // }
                    field("Reason Code EDI Order"; "Reason Code EDI Order")
                    {
                        ApplicationArea = All;
                    }
                    // field("Company Name"; "Company Name")
                    // {
                    //     ApplicationArea = All;
                    //     ToolTip = 'Specifies the value of the Company Name field';
                    // }
                    field("Enable IC Transaction"; "Enable IC Transaction")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Enable Intercompany Transactions field';
                    }
                    field("Inbox Folder"; "Inbox Folder")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Inbox Folder field';
                    }
                    field("Outbox Folder"; "Outbox Folder")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Outbox Folder field';
                    }
                    field("History Folder"; "History Folder")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the History Folder field';
                    }
                    field("Errors Folder"; "Errors Folder")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Errors Folder field';
                    }
                    field("Raw XML Folder"; "Raw XML Folder")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Raw XML Folder field';
                    }
                }
            }
        }
    }
    actions
    {
    }

    trigger OnOpenPage()
    begin
        RESET;
        IF NOT GET THEN BEGIN
            INIT;
            INSERT;
        END;
    end;

    var
        Text001: Label 'Do you want to run the Import and Document Creation Process?';
        Text002: Label 'Do you want to start the Order/ Invoice CSV Import Process?';
        Text003: Label 'Do you want to run the Document Posting Process? This will try to post all Sales Orders, Purchase Orders, Sales Cr Memos and Purchase Cr Memos created through EDI Process.';
        Text004: Label 'Do you want to run the Document Export Process?';
}

