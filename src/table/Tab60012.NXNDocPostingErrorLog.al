table 60012 "NXN Doc. Posting Error Log"
{
    // HBSTG P2CW013 2014-07-02: Created Table to store the errors while Auto Posting of the EDI Orders and Credit Memos
    // HBSRP 2017-07-03: New options "Sales Invoice" and "Purchase Invoice" added in the field "Posting Document Type"


    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(2; "Posting Document Type"; Option)
        {
            OptionCaption = ' ,Sales Order,Purchase Order,Sales Cr Memo,Purchase Cr Memo,Sales Invoice,Purchase Invoice';
            OptionMembers = " ","Sales Order","Purchase Order","Sales Cr Memo","Purchase Cr Memo","Sales Invoice","Purchase Invoice";
            DataClassification = CustomerContent;
        }
        field(3; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(4; "Reference No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(5; "Template Name"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(6; "Batch Name"; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(8; Closed; Boolean)
        {
            Editable = true;
        }
        field(9; "Retry Counter"; Integer)
        {
            DataClassification = CustomerContent;
        }
        field(10; "Execution Timestamp"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(20; "Error Description"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(21; "Error Description 2"; Text[250])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

