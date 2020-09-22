page 60008 NXNEmailQueue
{

    ApplicationArea = All;
    Caption = 'Email Queue Log';
    PageType = List;
    SourceTable = "NXN E-Mail Queue";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Source No."; "Source No.")
                {
                    ApplicationArea = All;
                }
                field("Source Type"; "Source Type")
                {
                    ApplicationArea = All;
                }
                field("Subject Line"; "Subject Line")
                {
                    ApplicationArea = All;
                }
                field("Body Line"; "Body Line")
                {
                    ApplicationArea = All;
                }
                field("To Address"; "To Address")
                {
                    ApplicationArea = All;
                }
                field("CC Address"; "CC Address")
                {
                    ApplicationArea = All;
                }
                field("BCC Address"; "BCC Address")
                {
                    ApplicationArea = All;
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                }
                field("Logging DateTime"; "Logging DateTime")
                {
                    ApplicationArea = All;
                }
                field("Sending DateTime"; "Sending DateTime")
                {
                    ApplicationArea = All;
                }
                field("Error while Sending Email"; "Error while Sending Email")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
