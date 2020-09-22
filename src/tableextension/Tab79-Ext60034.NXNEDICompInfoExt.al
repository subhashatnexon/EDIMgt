tableextension 60034 "NXN EDICompInfo Ext" extends "Company Information" //79
{
    fields
    {
        // Add changes to table fields here
        field(60052; "NXN Activate Sync"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Activate Sync';
            trigger OnValidate()
            var
            begin
                //TestField("NXN Register Change log", false);
            end;
        }
        field(60053; "NXN Register Change log"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Register Change log';
            trigger OnValidate()
            var
            begin
                //TestField("NXN Activate Sync", false);
            end;
        }
        field(60054; "NXN EDI Company Initial"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Company Initial';
            trigger OnValidate()
            var
            begin

            end;
        }


    }

    var
        myInt: Integer;
}