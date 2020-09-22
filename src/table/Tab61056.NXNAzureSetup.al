table 61056 "NXN Azure Storage Setup"
{
    DataClassification = CustomerContent;
    Caption = 'NXN Azure Storage Setup';
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(2; AccountName; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(3; AccountContainer; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(4; AccountAccessKey; Text[1000])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
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