page 60012 "NXN Doc. Int. Error Log"
{
    Caption = 'Document Integration Error Log';
    PageType = List;
    SourceTable = "NXN Doc. Integration Error Log";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Direction; Direction)
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Direction field';
                }
                field(Module; Module)
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Module field';
                }
                field("Reference No."; "Reference No.")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Reference No. field';
                }
                field(Status; Status)
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Status field';
                }
                field("Execution Timestamp"; "Execution Timestamp")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Execution Timestamp field';
                }
                field("Error Description"; "Error Description")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Error Description field';
                }
            }
        }
    }

    actions
    {
    }
}

