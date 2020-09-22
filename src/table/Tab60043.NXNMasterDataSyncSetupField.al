table 60043 "NXN MasterDataSync Setup_Field"
{
    Caption = 'Master Data Sync Setup (Field)';
    ReplicateData = false;
    DataPerCompany = false;

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            TableRelation = "NXN MasterDataSync Setup_Table";
        }
        field(2; "Field No."; Integer)
        {
            Caption = 'Field No.';
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."));
        }
        field(3; "Field Caption"; Text[100])
        {
            CalcFormula = Lookup (Field."Field Caption" WHERE(TableNo = FIELD("Table No."),
                                                              "No." = FIELD("Field No.")));
            Caption = 'Field Caption';
            FieldClass = FlowField;
        }
        field(4; "Company Name"; Text[100])
        {
            Caption = 'Company Name';
            TableRelation = Company;
        }
        field(5; "Enable Sync"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(6; "Primary Key"; Boolean)
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Table No.", "Field No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

