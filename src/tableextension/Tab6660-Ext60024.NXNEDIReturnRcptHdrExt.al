tableextension 60024 "NXN EDIReturnRcptHdr Ext" extends "Return Receipt Header" //6660
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
        field(60006; "NXN Order Method"; Option)
        {
            OptionMembers = ,Online,"Mobile App",Email,Fax,Phone,Other,Complimentary;
            OptionCaption = ' ,Online,Mobile App,Email,Fax,Phone,Other,Complimentary';
            DataClassification = CustomerContent;
        }
        field(60007; "NXN EDI Header Comments"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Header Comments';
        }
        field(60008; "NXN EDI Del. Instr."; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Delivery Instructions';
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