tableextension 60037 "NXN ChangeLog Entries Ext" extends "Change Log Entry" //405
{
    fields
    {
        field(60000; "NXN Synced"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(60001; "NXN Synced Date"; Date)
        {
            DataClassification = CustomerContent;
        }
    }

}