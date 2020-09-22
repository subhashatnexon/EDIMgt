table 60006 "NXN EDI Invoice Line"
{
    // HBSTG  2013-10-25: Added field for changing Invoice Line No. in posted invoices.
    // HBSRP 2016-12-06: Name of the filed Approved Quantity tolerance to Approved

    DataCaptionFields = "Entry No.", "Line No.", "Invoice Line No.", "Item No.";
    Caption = 'EDI Invoice Line';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            TableRelation = "NXN EDI Invoice Header";
        }
        field(2; "Line No."; Integer)
        {
            Description = 'NAV Generated Line No.';
        }
        field(3; "Item No."; Code[20])
        {
        }
        field(4; Description; Text[50])
        {
        }
        field(5; Quantity; Decimal)
        {
        }
        field(6; "Unit Of Measure Code"; Code[20])
        {
        }
        field(7; "Unit Price"; Decimal)
        {
        }
        field(8; "GST Amount"; Decimal)
        {
            Description = 'Not used';
        }
        field(9; "Order ID"; Code[20])
        {
            Description = 'Not used';
        }
        field(10; "Payload ID"; Code[20])
        {
            Description = 'Not used';
        }
        field(11; "Invoice ID"; Code[35])
        {
            Description = 'Not used';
        }
        field(12; "Reference Line No."; Integer)
        {
            Description = 'Not used';
        }
        field(13; "Line Amount"; Decimal)
        {
            Description = 'Not used';
        }
        field(14; "Net Amount"; Decimal)
        {
            Description = 'Not used';
        }
        field(15; "Gross Amount"; Decimal)
        {
            Description = 'Not used';
        }
        field(16; "Invoice Line No."; Integer)
        {
            BlankZero = true;
            Description = 'XML Invoice Line No.';
        }
        field(17; "GST %"; Decimal)
        {
        }
        field(18; "Changed Invoice Line No."; Integer)
        {
            BlankZero = true;
            Description = 'HBSTG  2013-10-25';
        }
        field(50; "Duplicate Item"; Boolean)
        {
        }
        field(51; Approved; Boolean)
        {
            Description = 'HBSTG 2015-08-19';
        }
        field(52; "Size (Gm/Ml)"; Decimal)
        {
            Description = 'RSTG 2017-09-05';
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
        field(102; "Reason Code"; Code[10])
        {
        }
        field(103; "Reason Description"; Text[50])
        {
        }
        field(110; "Substitute Line No."; Integer)
        {
        }
        field(111; "Manufacturer Name"; Text[50])
        {
        }
        field(112; "Brand Description"; Text[50])
        {
        }
    }

    keys
    {
        key(Key1; "Entry No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

