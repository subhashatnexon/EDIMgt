tableextension 60033 "NXN HnldICInBoxPurchHdr" extends "Handled IC Inbox Purch. Header" //440
{
    fields
    {
        // Add changes to table fields here
        field(60001; "NXN EDI Order ID"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Order ID';
        }
        field(60015; "NXN IC SRC Order No."; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'IC Source Sales Order No.';
        }
        field(60016; "NXN IC SRC Inv_Cr No."; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'IC Source Sales Inv/Cr No.';
        }
    }
}