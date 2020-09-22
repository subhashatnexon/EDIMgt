table 61055 "NXN BlobList"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; entrynumber; Integer)
        {
            DataClassification = ToBeClassified;

        }
        field(2; FileName; Text[200])
        {
            DataClassification = ToBeClassified;

        }
        field(3; NXNUserID; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "NXN Company Name"; Text[100])
        {
            DataClassification = ToBeClassified;
        }
    }
    keys
    {
        key(PK; entrynumber)
        {
            Clustered = true;
        }
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}