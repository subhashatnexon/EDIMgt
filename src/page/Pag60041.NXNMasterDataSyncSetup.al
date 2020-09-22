page 60041 "NXN MasterDataSyncSetup"
{

    ApplicationArea = All;
    Caption = 'Master Data Sync Setup (Table)';
    PageType = List;
    SourceTable = "NXN MasterDataSync Setup_Table";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("From Company Name"; "From Company Name")
                {
                    ApplicationArea = All;
                }
                field("To Company Name"; "To Company Name")
                {
                    ApplicationArea = All;
                }
                field("Table ID"; "Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; "Table Name")
                {
                    ApplicationArea = All;
                }
                field("Enable Sync"; MasterDataSyncSetup."Enable Sync")
                {
                    ApplicationArea = All;

                    trigger OnAssistEdit()
                    begin
                        WITH MasterDataSyncSetup DO
                            TESTFIELD("Enable Sync", "Enable Sync"::"Select Fields");
                        AssistEdit;
                    end;

                    trigger OnValidate()
                    var
                        //ConfirmManagement: Codeunit "27";
                        NewValue: Option;
                    begin
                        IF MasterDataSyncSetup."Table ID" <> "Table ID" THEN BEGIN
                            NewValue := MasterDataSyncSetup."Enable Sync";
                            GetRec;
                            MasterDataSyncSetup."Enable Sync" := NewValue;
                        END;

                        IF xMasterDataSyncSetup.GET(MasterDataSyncSetup."From Company Name", MasterDataSyncSetup."To Company Name", MasterDataSyncSetup."Table ID") THEN BEGIN
                            IF (xMasterDataSyncSetup."Enable Sync" = xMasterDataSyncSetup."Enable Sync"::"Select Fields") AND
                                (xMasterDataSyncSetup."Enable Sync" <> MasterDataSyncSetup."Enable Sync")
                            THEN
                                IF Confirm(
                                      STRSUBSTNO(Text002, xMasterDataSyncSetup.FIELDCAPTION("Enable Sync"), xMasterDataSyncSetup."Enable Sync"), TRUE)
                                THEN
                                    MasterDataSyncSetup.DelMasterDataLogFields;
                        END;
                        MasterDataSyncTableLogInsertio;
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        GetRec
    end;

    var
        MasterDataSyncSetup: Record "NXN MasterDataSync Setup_Table";
        xMasterDataSyncSetup: Record "NXN MasterDataSync Setup_Table";
        Text002: Label 'You have changed the %1 field to no longer be %2. Do you want to remove the field selections?';

    local procedure AssistEdit()
    var
        "Field": Record Field;
        DataSyncLogSetupFieldList: Page "NXN Data Sync Log Setup(Field)";
    begin
        Field.FILTERGROUP(2);
        Field.SETRANGE(TableNo, "Table ID");
        Field.SETFILTER(ObsoleteState, '<>%1', Field.ObsoleteState::Removed);
        Field.FILTERGROUP(0);
        WITH MasterDataSyncSetup DO
            DataSyncLogSetupFieldList.SetCompanyNameTableNo(Rec."To Company Name", Rec."Table ID");
        DataSyncLogSetupFieldList.SelectColumn(
           "Enable Sync" = "Enable Sync"::"Select Fields",
          FALSE,
          FALSE);
        DataSyncLogSetupFieldList.SETTABLEVIEW(Field);
        DataSyncLogSetupFieldList.RUN;
    end;

    local procedure UpdateRec()
    begin
        WITH MasterDataSyncSetup DO
            //IF ("Enable Sync" <> "Enable Sync"::" ") THEN
            IF NOT MODIFY THEN
                INSERT;
    end;

    local procedure GetRec()
    begin
        IF NOT MasterDataSyncSetup.GET("From Company Name", "To Company Name", "Table ID") THEN BEGIN
            MasterDataSyncSetup.INIT;
            MasterDataSyncSetup."From Company Name" := "From Company Name";
            MasterDataSyncSetup."To Company Name" := "To Company Name";
            MasterDataSyncSetup."Table ID" := "Table ID";
        END;
    end;

    local procedure MasterDataSyncTableLogInsertio()
    begin
        UpdateRec;
    end;

}
