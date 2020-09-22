pageextension 60004 "NXN EDICompInfo Ext" extends "Company Information" //1
{
    layout
    {
        addafter("IC Inbox Type")
        {
            field("NXN Register Change log"; "NXN Register Change log")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Register Change log field';
            }
            field("NXN Activate Sync"; "NXN Activate Sync")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Activate Sync field';
            }
        }
        addafter("Industrial Classification")
        {

            field("NXN EDI Company Initial"; "NXN EDI Company Initial")
            {
                ApplicationArea = ALL;
                ToolTip = 'Specifies the value of the EDI Company Initial field';
            }

        }

    }
    actions
    {
    }
}