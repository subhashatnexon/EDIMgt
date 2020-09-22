// This table is related to NXN EDI Setup
table 60000 "NXN EDI Setup"
{
    Caption = 'EDI Setup';
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[50])
        {
            DataClassification = CustomerContent;
        }
        field(10; "Email Error Logs"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(15; "Errors Email Address"; Text[80])
        {
            DataClassification = CustomerContent;
        }
        field(25; "Email Address Error Logs"; Text[80])
        {
            DataClassification = CustomerContent;
        }
        field(28; "Sender Name"; text[80])
        {
            DataClassification = CustomerContent;
        }
        field(30; "Sender Email ID"; text[80])
        {
            DataClassification = CustomerContent;
        }


        field(35; "CC To Sender Email ID"; Boolean)
        {
            DataClassification = CustomerContent;
        }

        field(50; "Reason Code EDI Order"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(55; "Archive Doc in EDI Process"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Archive Document in EDI Process';
        }

        field(200; "Inbox Folder"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(201; "Outbox Folder"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(202; "History Folder"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(203; "Errors Folder"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(204; "Raw XML Folder"; Text[250])
        {
            DataClassification = CustomerContent;
        }
        field(300; "Company Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Company Name';
            TableRelation = Company.Name;
        }
        field(501; "Enable IC Transaction"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Enable Intercompany Transactions';

        }

    }
    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
}

