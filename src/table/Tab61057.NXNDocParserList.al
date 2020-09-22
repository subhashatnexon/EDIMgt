table 61057 "NXN DocParser List"
{
    DataClassification = CustomerContent;
    Caption = 'NXN DocParser List';
    fields
    {
        field(1; "ParserCode"; Code[20])
        {
            DataClassification = CustomerContent;

        }
        field(2; ParserID; Text[100])
        {
            DataClassification = CustomerContent;
        }
        field(3; Description; Text[1000])
        {
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; ParserCode)
        {
            Clustered = true;
        }
    }


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