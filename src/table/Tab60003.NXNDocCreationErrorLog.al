table 60003 "NXN Doc. Creation Error Log"
{
    // HBSTG P2CW016 2014-07-03:  Added option Cancelled in "Status" field
    // ReSRP #11694 2018-10-03: Field added "Initial Execution Timestamp"
    Caption = 'Document Creation Error Log';


    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(2; "Table Name"; Option)
        {
            OptionCaption = ' ,EDI Order,EDI Invoice,EDI Payment,EDI Cr Memo,EDI Rebate PI,EDI Reason Code,EDI Central Invoicing';
            OptionMembers = " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code","EDI Central Invoicing";
            DataClassification = CustomerContent;
            Caption = 'Table Name';
        }
        field(3; "Table Entry No"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table Entry No.';
            TableRelation = IF ("Table Name" = FILTER("EDI Order")) "NXN EDI Order Header"."Entry No." WHERE("Entry No." = FIELD("Table Entry No"))
            ELSE
            IF ("Table Name" = FILTER("EDI Invoice")) "NXN EDI Invoice Header"."Entry No." WHERE("Entry No." = FIELD("Table Entry No"))
                            //ELSE IF ("Table Name"=FILTER("EDI Payment")) "NXN EDI Payment Line"."Entry No." WHERE ("Entry No."=FIELD("Table Entry No"))
                            //ELSE IF ("Table Name"=FILTER("EDI Cr Memo")) "NXN EDI Credit Memo Line"."Entry No." WHERE ("Entry No."=FIELD("Table Entry No"))
                            //ELSE IF ("Table Name"=FILTER("EDI Rebate PI")) "EDI Rebate Line"."Entry No." WHERE ("Entry No."=FIELD("Table Entry No"))
                            //ELSE IF ("Table Name"=FILTER("EDI Reason Code")) "EDI Reason Code Line"."Entry No." WHERE ("Entry No."=FIELD("Table Entry No"))
                            //ELSE IF ("Table Name"=FILTER("EDI Central Invoicing")) "EDI Central Invoicing Line"."Entry No." WHERE ("Entry No."=FIELD("Table Entry No"))
                            ;
        }
        field(4; "Reference No."; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference No.';
        }
        field(5; "Document Type"; Option)
        {
            OptionCaption = ' ,EDI Order,EDI Invoice,EDI Payment,EDI Cr Memo,EDI Rebate PI,EDI Reason Code,EDI Central Invoicing';
            OptionMembers = " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code","EDI Central Invoicing";
            DataClassification = CustomerContent;
            Caption = 'Document Type';
        }
        field(6; Status; Option)
        {
            OptionCaption = ' ,Document Error,Successful,File Error,Cancelled';
            OptionMembers = " ","Document Error",Successful,"File Error",Cancelled;
            DataClassification = CustomerContent;
            Caption = 'Status';

            trigger OnValidate()
            var
            //BLine: Record "50000";
            //CLine: Record "50001";
            begin
            end;
        }
        field(8; Closed; Boolean)
        {
            Editable = true;
            DataClassification = CustomerContent;
            Caption = 'Closed';
        }
        field(10; "Execution Timestamp"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Execution Timestamp';
        }
        field(20; "Error Description"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Description';
        }
        field(21; "Error Description 2"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Description 2';
        }
        field(25; "Initial Execution Timestamp"; DateTime)
        {
            Description = '11694';
            DataClassification = CustomerContent;
            Caption = 'Initial Execution Timestamp';
        }
        field(35; "Retry Counter"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Retry Counter';
        }

    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Table Name", "Table Entry No", Status, Closed, "Reference No.")
        {
        }
    }

    fieldgroups
    {
    }
}

