tableextension 60035 "NXN EDIReasonCode Ext" extends "Reason Code" //231
{
    fields
    {
        field(60001; "NXN Allow Auto Posting"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Allow Auto Posting';
        }
        field(60002; "NXN Use WorkDate As PostDate"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Use WorkDate as Posting Date';
        }

    }

}