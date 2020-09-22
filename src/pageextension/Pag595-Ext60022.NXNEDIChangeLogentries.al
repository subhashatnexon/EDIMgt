pageextension 60022 "NXN EDIChangeLog Entries" extends "Change Log Entries" //595
{
    layout
    {
        addafter("Date and Time")
        {

            field("NXN Synced"; "NXN Synced")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("NXN Synced Date"; "NXN Synced Date")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
    }

    actions
    {
    }
}