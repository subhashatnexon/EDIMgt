table 60011 "NXN E-Mail Queue"
{
    // HBSTG  2015-08-14: Added Functionality for CC and BCC
    Caption = 'E-Mail Queue';


    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Subject Line"; Text[250])
        {
        }
        field(3; "Body Line"; Text[250])
        {
        }
        field(4; "To Address"; Text[250])
        {
        }
        field(5; "Source Type"; Code[50])
        {
        }
        field(6; "Source No."; Code[100])
        {
        }
        field(7; "CC Address"; Text[250])
        {
            Description = 'HBSTG  2015-08-14';
        }
        field(8; "BCC Address"; Text[250])
        {
            Description = 'HBSTG  2015-08-14';
        }
        field(10; "Logging DateTime"; DateTime)
        {
        }
        field(11; Status; Option)
        {
            OptionCaption = ' ,Processed,Error';
            OptionMembers = " ",Processed,Error;
        }
        field(12; "Sending DateTime"; DateTime)
        {
        }
        field(14; "Error while Sending Email"; Text[250])
        {
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

