codeunit 60042 "NXN Master Sync Mgt"
{


    TableNo = "NXN Master Data Sync Log";


    trigger OnRun()
    begin
        CompanyInformation.GET;
        IF NOT CompanyInformation."NXN Activate Sync" THEN
            EXIT;
        MasterSyncLogEntry := Rec;

        //Insertion
        IF MasterSyncLogEntry."Type of Change" = MasterSyncLogEntry."Type of Change"::Insertion THEN BEGIN
            InsertDESMasters();
        END;
        //Modification
        IF MasterSyncLogEntry."Type of Change" = MasterSyncLogEntry."Type of Change"::Modification THEN BEGIN
            CLEAR(DESRecRef);
            ModifyDESMasters();
        END;

        //Deletion
        IF MasterSyncLogEntry."Type of Change" = MasterSyncLogEntry."Type of Change"::Deletion THEN BEGIN
            CLEAR(DESRecRef);
            DeleteDESMasters();
        END;
    end;

    var
        MasterChangeLogMgt: Codeunit "NXN Master Data Log Mgt";
        CompanyInfo: Record "Company Information";
        MasterDataSyncSetup: Record "NXN MasterDataSync Setup_Table";
        CompanyInformation: Record "Company Information";
        MasterSyncLogEntry: Record "NXN Master Data Sync Log";
        DESItem: Record Item;
        SRCItem: Record Item;
        SRCRecRef: RecordRef;
        DESRecRef: RecordRef;
        SRCFieldRef: FieldRef;
        DESFieldRef: FieldRef;
        SRCCountryRegion: Record "Country/Region";
        SRCInventoryPostingGroup: Record "Inventory Posting Group";
        SRCUnitofMeasure: Record "Unit of Measure";
        SRCGenProductPostingGroup: Record "Gen. Product Posting Group";
        SRCTariffNumber: Record "Tariff Number";
        SRCNoSeries: Record "No. Series";
        SRCTaxGroup: Record "Tax Group";
        SRCVATBusinessPostingGroup: Record "VAT Business Posting Group";
        SRCVATProductPostingGroup: Record "VAT Product Posting Group";
        SRCItemDiscountGroup: Record "Item Discount Group";
        SRCDimensionValue: Record "Dimension Value";
        SRCItemCategory: Record "Item Category";
        SRCItemUnitofMeasure: Record "Item Unit of Measure";
        SRCItemCrossRef: Record "Item Cross Reference";
        SRCItemVariants: Record "Item Variant";
        SRCSKU: Record "Stockkeeping Unit";
        DESCountryRegion: Record "Country/Region";
        DESInventoryPostingGroup: Record "Inventory Posting Group";
        DESUnitofMeasure: Record "Unit of Measure";
        DESGenProductPostingGroup: Record "Gen. Product Posting Group";
        DESTariffNumber: Record "Tariff Number";
        DESNoSeries: Record "No. Series";
        DESTaxGroup: Record "Tax Group";
        DESVATBusinessPostingGroup: Record "VAT Business Posting Group";
        DESVATProductPostingGroup: Record "VAT Product Posting Group";
        DESItemDiscountGroup: Record "Item Discount Group";
        DESDimensionValue: Record "Dimension Value";
        DESItemCategory: Record "Item Category";
        DESItemUnitofMeasure: Record "Item Unit of Measure";
        DESItemCrossRef: Record "Item Cross Reference";
        DESItemVariants: Record "Item Variant";
        DESSKU: Record "Stockkeeping Unit";
        DESDateTime: DateTime;
        DESDate: Date;
        DESTime: Time;
        MasterDataSyncSetupField: Record "NXN MasterDataSync Setup_Field";


    local procedure UpdateMasterSyncLogEntry()
    begin
        MasterSyncLogEntry.Synced := TRUE;
        MasterSyncLogEntry."Synced Date" := WORKDATE;
        MasterSyncLogEntry."Synced Time" := TIME;
        MasterSyncLogEntry.MODIFY;
    end;

    local procedure InsertDESMasters()
    var
        SRCKeyFldRef: FieldRef;
        SRCKeyRef1: KeyRef;
        i: Integer;
        DESKeyFldRef: FieldRef;
        DESKeyRef1: KeyRef;
        InputText: Text;
    begin
        CLEAR(SRCRecRef);
        CLEAR(DESRecRef);
        SRCRecRef.OPEN(MasterSyncLogEntry."Table No.");
        SRCRecRef.CHANGECOMPANY(MasterSyncLogEntry."From Company Name");
        IF SRCRecRef.GET(MasterSyncLogEntry."Record ID") THEN BEGIN
            DESRecRef.OPEN(MasterSyncLogEntry."Table No.");
            IF NOT DESRecRef.GET(MasterSyncLogEntry."Record ID") THEN BEGIN
                MasterDataSyncSetupField.RESET;
                //MasterDataSyncSetupField.SETRANGE("Company Name", COMPANYNAME);
                MasterDataSyncSetupField.SETRANGE("Table No.", MasterSyncLogEntry."Table No.");
                MasterDataSyncSetupField.SETRANGE("Enable Sync", TRUE);
                IF MasterDataSyncSetupField.FINDSET THEN BEGIN
                    REPEAT
                        SRCFieldRef := SRCRecRef.FIELD(MasterDataSyncSetupField."Field No.");
                        DESFieldRef := DESRecRef.FIELD(MasterDataSyncSetupField."Field No.");
                        DESFieldRef.VALUE := SRCFieldRef.VALUE;
                    //DESFieldRef.VALIDATE;

                    UNTIL MasterDataSyncSetupField.NEXT = 0;
                    DESRecRef.INSERT(TRUE)
                END;
                Clear(DESRecRef);
                DESRecRef.OPEN(MasterSyncLogEntry."Table No.");
                IF DESRecRef.GET(MasterSyncLogEntry."Record ID") then begin
                    MasterDataSyncSetupField.RESET;
                    //MasterDataSyncSetupField.SETRANGE("Company Name", COMPANYNAME);
                    MasterDataSyncSetupField.SETRANGE("Table No.", MasterSyncLogEntry."Table No.");
                    MasterDataSyncSetupField.SETRANGE("Enable Sync", TRUE);
                    IF MasterDataSyncSetupField.FINDSET THEN BEGIN
                        REPEAT
                            DESFieldRef := DESRecRef.FIELD(MasterDataSyncSetupField."Field No.");
                            DESFieldRef.VALIDATE;
                        UNTIL MasterDataSyncSetupField.NEXT = 0;
                        DESRecRef.Modify(True);
                    END;
                end;
            END;
        END;
    end;

    local procedure ModifyDESMasters()
    begin
        IF MasterDataSyncSetupField.GET(MasterSyncLogEntry."Table No.", MasterSyncLogEntry."Field No.") THEN BEGIN
            DESRecRef.OPEN(MasterSyncLogEntry."Table No.");
            DESRecRef.GET(MasterSyncLogEntry."Record ID");
            DESFieldRef := DESRecRef.FIELD(MasterSyncLogEntry."Field No.");
            EvaluateTextToFieldRef(MasterSyncLogEntry."New Value", DESFieldRef);
            DESFieldRef.VALIDATE;
            DESRecRef.MODIFY(TRUE);
        END;
    end;

    local procedure DeleteDESMasters()
    begin
        DESRecRef.OPEN(MasterSyncLogEntry."Table No.");
        DESRecRef.GET(MasterSyncLogEntry."Record ID");
        DESRecRef.DELETE(TRUE);
    end;

    local procedure RenameDESMasters()
    begin
        // IF MasterDataSyncSetupField.GET(COMPANYNAME, MasterSyncLogEntry."Table No.", MasterSyncLogEntry."Field No.") THEN BEGIN
        //     DESRecRef.OPEN(MasterSyncLogEntry."Table No.");
        //     DESRecRef.GET(MasterSyncLogEntry."Record ID");
        //     DESFieldRef := DESRecRef.FIELD(MasterSyncLogEntry."Field No.");
        //     EvaluateTextToFieldRef(MasterSyncLogEntry."New Value", DESFieldRef);
        //     DESFieldRef.VALIDATE;
        //     DESRecRef.MODIFY(TRUE);
        // END;
    end;

    procedure EvaluateTextToFieldRef(InputText: Text; var FieldRef: FieldRef): Boolean
    var
        IntVar: Integer;
        DecimalVar: Decimal;
        DateVar: Date;
        TimeVar: Time;
        DateTimeVar: DateTime;
        BoolVar: Boolean;
        DurationVar: Duration;
        BigIntVar: BigInteger;
        GUIDVar: Guid;
        DateFormulaVar: DateFormula;
    begin
        IF (FORMAT(FieldRef.CLASS) = 'FlowField') OR (FORMAT(FieldRef.CLASS) = 'FlowFilter') THEN
            EXIT(TRUE);

        CASE FORMAT(FieldRef.TYPE) OF
            'Integer', 'Option':
                IF EVALUATE(IntVar, InputText) THEN BEGIN
                    FieldRef.VALUE := IntVar;
                    EXIT(TRUE);
                END;
            'Decimal':
                IF EVALUATE(DecimalVar, InputText, 9) THEN BEGIN
                    FieldRef.VALUE := DecimalVar;
                    EXIT(TRUE);
                END;
            'Date':
                IF EVALUATE(DateVar, InputText, 9) THEN BEGIN
                    FieldRef.VALUE := DateVar;
                    EXIT(TRUE);
                END;
            'Time':
                IF EVALUATE(TimeVar, InputText, 9) THEN BEGIN
                    FieldRef.VALUE := TimeVar;
                    EXIT(TRUE);
                END;
            'DateTime':
                IF EVALUATE(DateTimeVar, InputText, 9) THEN BEGIN
                    FieldRef.VALUE := DateTimeVar;
                    EXIT(TRUE);
                END;
            'Boolean':
                IF EVALUATE(BoolVar, InputText, 9) THEN BEGIN
                    FieldRef.VALUE := BoolVar;
                    EXIT(TRUE);
                END;
            'Duration':
                IF EVALUATE(DurationVar, InputText, 9) THEN BEGIN
                    FieldRef.VALUE := DurationVar;
                    EXIT(TRUE);
                END;
            'BigInteger':
                IF EVALUATE(BigIntVar, InputText) THEN BEGIN
                    FieldRef.VALUE := BigIntVar;
                    EXIT(TRUE);
                END;
            'GUID':
                IF EVALUATE(GUIDVar, InputText, 9) THEN BEGIN
                    FieldRef.VALUE := GUIDVar;
                    EXIT(TRUE);
                END;
            'Code', 'Text':
                BEGIN
                    IF STRLEN(InputText) > FieldRef.LENGTH THEN BEGIN
                        FieldRef.VALUE := PADSTR(InputText, FieldRef.LENGTH);
                        EXIT(FALSE);
                    END;
                    FieldRef.VALUE := InputText;
                    EXIT(TRUE);
                END;
            'DateFormula':
                IF EVALUATE(DateFormulaVar, InputText, 9) THEN BEGIN
                    FieldRef.VALUE := DateFormulaVar;
                    EXIT(TRUE);
                END;
        END;

        EXIT(FALSE);
    end;


}

