page 60042 "NXN Master SyncChangeLog Entry"
{

    ApplicationArea = All;
    Caption = 'Master Data Sync Log';
    PageType = List;
    SourceTable = "NXN Master Data Sync Log";
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Date and Time"; "Date and Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date and Time field';
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Caption field';
                }
                field("Field No."; "Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field No. field';
                }
                field("New Value"; "New Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the New Value field';
                }
                field("Old Value"; "Old Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Old Value field';
                }
                field("Primary Key Field 1 Caption"; "Primary Key Field 1 Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key Field 1 Caption field';
                }
                field("Primary Key Field 1 No."; "Primary Key Field 1 No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key Field 1 No. field';
                }
                field("Primary Key Field 1 Value"; "Primary Key Field 1 Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key Field 1 Value field';
                }
                field("Primary Key Field 2 Caption"; "Primary Key Field 2 Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key Field 2 Caption field';
                }
                field("Primary Key Field 2 No."; "Primary Key Field 2 No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key Field 2 No. field';
                }
                field("Primary Key Field 2 Value"; "Primary Key Field 2 Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key Field 2 Value field';
                }
                field("Primary Key Field 3 Caption"; "Primary Key Field 3 Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key Field 3 Caption field';
                }
                field("Primary Key Field 3 No."; "Primary Key Field 3 No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key Field 3 No. field';
                }
                field("Primary Key Field 3 Value"; "Primary Key Field 3 Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key Field 3 Value field';
                }
                field("Primary Key"; "Primary Key")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Primary Key field';
                }
                field("Record ID"; "Record ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Record ID field';
                }
                field("Part of Primary Key"; "Part of Primary Key")
                {
                    ApplicationArea = All;
                }
                field("Synced Date"; "Synced Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Synced Date field';
                }
                field("Synced Time"; "Synced Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Synced Time field';
                }
                field("Table Caption"; "Table Caption")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Caption field';
                }
                field("Table No."; "Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Type of Change"; "Type of Change")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type of Change field';
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field(Synced; Synced)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Synced field';
                }
                field(Time; Time)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Time field';
                }
                field("Error Message"; "Error Message")
                {
                    ApplicationArea = All;
                }
                field("Error Occured"; "Error Occured")
                {
                    ApplicationArea = All;
                }
                field("From Company Name"; "From Company Name")
                {
                    ApplicationArea = All;
                }
                field("To Company Name"; "To Company Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}
