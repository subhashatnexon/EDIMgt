table 60008 "NXN EDI CrMemo Line"
{
    // HBSRP 2015-03-18: New field Item No has been added
    // HBSRP 2015-05-01: New field "Import file name"
    // HBSRP 2016-05-11: New Field "Unit Of Measure Code" added

    DataCaptionFields = "Entry No.", "Credit Memo ID", "Invoice ID", "Invoice Line No.";
    Caption = 'EDI Cr Memo Line';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            NotBlank = true;
        }
        field(2; "Credit Memo ID"; Code[35])
        {
            Description = 'Customer''s Cr.Memo No.';
        }
        field(3; "Invoice ID"; Code[35])
        {
        }
        field(4; "Invoice Line No."; Integer)
        {
        }
        field(5; "Customer ID"; Code[20])
        {
            Description = 'Not Used';
        }
        field(6; "Credit Memo Date"; Date)
        {
            Description = 'Cr. Memo Date';
        }
        field(7; Quantity; Decimal)
        {
        }
        field(8; "Marked-down Unit Price"; Decimal)
        {
        }
        field(9; Description; Text[50])
        {
        }
        field(10; "Currency Code"; Code[10])
        {
            Description = 'As Per NAV Currency Code - Not Used';
            TableRelation = Currency;
        }
        field(11; "Reason Code"; Code[10])
        {
            TableRelation = "Return Reason".Code;

            trigger OnValidate()
            var
                RetReason: Record "Return Reason";
            begin
                RetReason.RESET;
                RetReason.SETRANGE(RetReason.Code, "Reason Code");
                IF RetReason.FINDFIRST THEN
                    "Reason Description" := RetReason.Description;
            end;
        }
        field(12; "Reason Description"; Text[50])
        {
        }
        field(13; "Unit Of Measure Code"; Code[20])
        {
        }
        field(100; "Manufacturer Code"; Code[10])
        {
            Caption = 'Manufacturer Code';
            Description = 'HBSTG P2CW014 2014-07-07';
            TableRelation = Manufacturer;
        }
        field(101; Brand; Code[20])
        {
            Description = 'HBSTG P2CW014 2014-07-07';
            //TableRelation = Brand;
        }
        field(102; "Member ID"; Code[20])
        {
            Description = 'Member/Depot ID';
        }
        field(215; "Item No."; Code[20])
        {
            Description = 'HBSRP';
        }
        field(216; "Import File Name"; Text[150])
        {
            Description = 'HBSRP';
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
        fieldgroup(DropDown; "Entry No.", "Credit Memo ID", "Invoice ID", "Invoice Line No.", "Credit Memo Date", Quantity, "Marked-down Unit Price")
        {
        }
    }

    var

}

