table 60004 "NXN Doc. Integration Error Log"
{
    // HBSRP 2015-02-09: Module option "EDI Member Cr Memo" has been added
    // HBSRP 2015-02-09: Module option "EDI Central Invoice" has been added
    // HBSRP 2015-04-14: Module option "EDI Member Remt_Adv" has been added
    // HBSRP 2015-07-13: Module option "EDI Sales Invoice" has been added
    // HBSRP 2015-10-08: Module option "Advance PO XML" has been added
    // HBSRP 2015-11-18: Module option "EDI Sales Cr Memo" has been added
    // #11871 2018-12-05: Module option "Order Confirmation" & "Contract Purch Price"  have been added
    // #CW4.65 NXNRP 2020-07-04: module option added for Subventory functionality (ctn capping and store depot list)
    Caption = 'Document Integration Error Log';


    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(2; Module; Option)
        {
            OptionCaption = ' ,EDI Order,EDI Invoice,EDI Payment,EDI Cr Memo,Raw XML,EDI Member Invoice,WS Order,EDI Member Cr Memo,EDI Central Invoice,EDI Member Remt_adv,EDI Sales Invoice,Advance PO XML,EDI Sales Cr Memo,Member SOH,Order Confirmation,Contract Purch Price,Store Depot List,Carton Capping';
            OptionMembers = " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","Raw XML","EDI Member Invoice","WS Order","EDI Member Cr Memo","EDI Central Invoice","EDI Member Remt_adv","EDI Sales Invoice","Advance PO XML","EDI Sales Cr Memo","Member SOH","Order Confirmation","Contract Purch Price","Store Depot List","Carton Capping";
            DataClassification = CustomerContent;
            Caption = 'Module';
        }
        field(3; "Reference No."; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference No.';
        }
        field(4; "Reference No. 2"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Reference No. 2';
        }
        field(5; "Document Type"; Option)
        {
            OptionCaption = ' ,EDI Order,EDI Invoice,EDI Payment,EDI Cr Memo,EDI Rebate PI,EDI Reason Code';
            OptionMembers = " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code";
            DataClassification = CustomerContent;
            Caption = 'Document Type';
        }
        field(6; Status; Option)
        {
            OptionCaption = ' ,Successful,File Error';
            OptionMembers = " ",Successful,"File Error";
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
        field(30; Direction; Option)
        {
            OptionCaption = ' ,In,Out';
            OptionMembers = " ","In",Out;
            DataClassification = CustomerContent;
            Caption = 'Direction';
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

