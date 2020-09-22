page 60043 "NXN Data Sync Log Setup(Field)"
{
    Caption = 'Data Sync Log Setup (Field) List';
    DataCaptionExpression = PageCaption;
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = Field;
    //UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(general)
            {
                field("No."; "No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'No.';
                    Editable = false;
                    Lookup = false;
                    ToolTip = 'Specifies the number of the field.';
                }
                field("Field Caption"; "Field Caption")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Field Caption';
                    DrillDown = false;
                    Editable = false;
                    ToolTip = 'Specifies the caption of the field, that is, the name that will be shown in the user interface.';
                }
                field(Sync; Sync)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sync';
                    ToolTip = 'Specifies whether to log the insertion for the selected line on the change log.';

                    trigger OnValidate()
                    begin
                        UpdateRec;
                    end;
                }
                field(IsPartOfPrimaryKey; IsPartOfPrimaryKey)
                {
                    ApplicationArea = All;
                    Caption = 'Part of Primary key';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        GetRec;
        TransFromRec;
    end;

    trigger OnAfterGetRecord()
    begin
        GetRec;
        TransFromRec;
    end;

    trigger OnOpenPage()
    begin
        FILTERGROUP(2);
        SETRANGE(Class, Class::Normal);
        FILTERGROUP(0);
        PageCaption := FORMAT(TableNo) + ' ' + TableName;
    end;

    var
        MasterDataSyncFields: Record "NXN MasterDataSync Setup_Field";
        CannotChangeColumnErr: Label 'You cannot change this column.';
        Sync: Boolean;
        PageCaption: Text[250];
        gvFromCompanyName: Text[100];
        gvToCompanyName: Text[100];
        gvTableNo: Integer;

    procedure SelectColumn(NewInsVisible: Boolean; NewModVisible: Boolean; NewDelVisible: Boolean)
    begin
    end;

    local procedure UpdateRec()
    begin
        GetRec;
        TransToRec;
        WITH MasterDataSyncFields DO
            IF NOT "Enable Sync" THEN BEGIN
                IF DELETE THEN;
            END ELSE
                IF NOT MODIFY THEN
                    INSERT;
    end;

    local procedure GetRec()
    begin
        IF NOT MasterDataSyncFields.GET(TableNo, "No.") THEN BEGIN
            MasterDataSyncFields.INIT;
            //MasterDataSyncFields."Company Name" := gvCompanyName;
            MasterDataSyncFields."Table No." := TableNo;
            MasterDataSyncFields."Field No." := "No.";
            MasterDataSyncFields."Primary Key" := IsPartOfPrimaryKey;
            //MasterDataSyncFields."Enable Sync" := TRUE;
        END;
    end;

    local procedure TransFromRec()
    begin
        Sync := MasterDataSyncFields."Enable Sync";
    end;

    local procedure TransToRec()
    begin
        MasterDataSyncFields."Enable Sync" := Sync;
    end;


    procedure SetCompanyNameTableNo(pCompanyName: Text; pTableNo: Integer)
    begin
        //gvfromCompanyName:= pFromCompanyName;

        //gvToCompanyName := pToCompanyName;
        gvTableNo := pTableNo;
    end;
}

