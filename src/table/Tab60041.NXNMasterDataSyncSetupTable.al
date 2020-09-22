table 60041 "NXN MasterDataSync Setup_Table"
{
    DataPerCompany = false;
    Caption = 'Master Data Sync Setup (Table)';
    fields
    {
        field(1; "Table ID"; Integer)
        {
            DataClassification = ToBeClassified;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(Table));

            trigger OnValidate()
            begin
                IF NOT IsTableExistInSetup("Table ID") THEN
                    ERROR(TableNotSelectErr);
            end;
        }
        field(2; "Table Name"; Text[250])
        {
            CalcFormula = Lookup (AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table ID")));
            FieldClass = FlowField;
        }
        field(3; "To Company Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = Company;
        }
        field(4; "Enable Sync"; Option)
        {
            DataClassification = ToBeClassified;
            OptionCaption = ' ,Select Fields';
            OptionMembers = " ","Select Fields";

            trigger OnValidate()
            begin
                IF (xRec."Enable Sync" = xRec."Enable Sync"::"Select Fields") AND (Rec."Enable Sync" = Rec."Enable Sync"::" ") THEN
                    IF confirm(STRSUBSTNO(Text001, xRec.FIELDCAPTION("Enable Sync"), xRec."Enable Sync"), TRUE)
                    THEN
                        DelMasterDataLogFields()
                    ELSE
                        Rec."Enable Sync" := Rec."Enable Sync"::"Select Fields";
            end;
        }
        field(5; "From Company Name"; Text[100])
        {
            DataClassification = ToBeClassified;
            TableRelation = Company;
        }

    }

    keys
    {
        key(Key1; "From Company Name", "To Company Name", "Table ID")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        MasterDataSyncSetupField.RESET;
        MasterDataSyncSetupField.SETRANGE("Company Name", "From Company Name");
        MasterDataSyncSetupField.SETRANGE("Table No.", "Table ID");
        MasterDataSyncSetupField.DELETEALL;
    end;

    var
        MasterDataSyncSetupField: Record "NXN MasterDataSync Setup_Field";
        ConfirmManagement: Codeunit "Confirm Management";
        Text001: Label 'You have changed the %1 field to no longer be %2. Do you want to remove the field selections?';
        AllObjWithCaption: Record AllObjWithCaption;
        TableNotSelectErr: Label 'You can not select this Table ID as it is not setup in Sync Master Setup.';

    procedure DelMasterDataLogFields()
    begin
        MasterDataSyncSetupField.SETRANGE("Table No.", "Table ID");
        MasterDataSyncSetupField.SETRANGE("Enable Sync", TRUE);
        IF MasterDataSyncSetupField.FINDFIRST THEN BEGIN
            REPEAT
                MasterDataSyncSetupField.DELETE(TRUE);
            UNTIL MasterDataSyncSetupField.NEXT = 0;
        END;
    end;

    procedure IsTableExistInSetup(pTableId: Integer): Boolean
    begin
        IF pTableId IN [7500, 7501, 7502, 7503, 7504, 7505, 5722, 5717, 5715, 5700, 5404, 5401, 352, 349, 341, 324, 323, 270, 260, 204, 99, 94, 27, 9] THEN
            EXIT(TRUE);
        EXIT(FALSE);
    end;

}

