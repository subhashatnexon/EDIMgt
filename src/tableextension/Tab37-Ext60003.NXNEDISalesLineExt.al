tableextension 60003 "NXN EDISales Line Ext" extends "Sales Line" //37
{
    fields
    {
        field(60000; "NXN EDI Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Entry No.';
        }
        field(60001; "NXN EDI Order ID"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Order ID';
        }
        field(60002; "NXN EDI Invoice ID"; code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Invoice ID';
        }
        field(60004; "NXN EDI CrMemo ID"; code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Cr. Memo ID';
        }
        field(60005; "NXN EDI Invoice Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Invoice Date';
        }
        field(60006; "NXN EDI Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Line No.';
        }
        field(60007; "NXN EDI Invoice Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Invoice Line No.';
        }
        field(60008; "NXN Order Item No."; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Order Item No.';
        }
        field(60009; "NXN Order Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Quantity';
        }
        field(60010; "NXN Order UOM"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Order UOM';
        }
    }

}