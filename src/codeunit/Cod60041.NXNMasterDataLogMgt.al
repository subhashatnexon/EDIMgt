codeunit 60041 "NXN Master Data Log Mgt"
{
    Permissions = TableData 402 = r,
                  TableData 403 = r,
                  TableData 404 = r,
                  TableData 405 = ri;
    SingleInstance = true;


    trigger OnRun()
    begin
    end;

    var
        CompanyInfo: Record "Company Information";
        MasterDataSyncSetup: Record "NXN MasterDataSync Setup_Table";
        RecRef: RecordRef;
        xRecRef: RecordRef;

    procedure InsertLogEntry(var FldRef: FieldRef; var xFldRef: FieldRef; var RecRef: RecordRef; TypeOfChange: Option Insertion,Modification,Deletion; IsReadable: Boolean)
    var
        MasterSyncLogEntry: Record "NXN Master Data Sync Log";
        KeyFldRef: FieldRef;
        KeyRef1: KeyRef;
        i: Integer;
    begin
        //IF RecRef.CURRENTCOMPANY <> MasterSyncLogEntry.CURRENTCOMPANY THEN
        //MasterSyncLogEntry.CHANGECOMPANY(RecRef.CURRENTCOMPANY);
        MasterSyncLogEntry.INIT;
        MasterSyncLogEntry."Date and Time" := CURRENTDATETIME;
        MasterSyncLogEntry.Time := DT2TIME(MasterSyncLogEntry."Date and Time");

        MasterSyncLogEntry."User ID" := USERID;

        MasterSyncLogEntry."Table No." := RecRef.NUMBER;
        MasterSyncLogEntry."Field No." := FldRef.NUMBER;
        MasterSyncLogEntry."Type of Change" := TypeOfChange;
        IF (RecRef.NUMBER = DATABASE::"User Property") AND (FldRef.NUMBER IN [2 .. 5]) THEN BEGIN // Password like
            MasterSyncLogEntry."Old Value" := '*';
            MasterSyncLogEntry."New Value" := '*';
        END ELSE BEGIN
            IF TypeOfChange <> TypeOfChange::Insertion THEN
                IF IsReadable THEN
                    MasterSyncLogEntry."Old Value" := FORMAT(xFldRef.VALUE, 0, 9)
                ELSE
                    MasterSyncLogEntry."Old Value" := '';
            IF TypeOfChange <> TypeOfChange::Deletion THEN
                MasterSyncLogEntry."New Value" := FORMAT(FldRef.VALUE, 0, 9);
        END;
        MasterSyncLogEntry."From Company Name" := MasterDataSyncSetup."From Company Name";
        MasterSyncLogEntry."To Company Name" := MasterDataSyncSetup."To Company Name";
        MasterSyncLogEntry."Record ID" := RecRef.RECORDID;
        MasterSyncLogEntry."Primary Key" := COPYSTR(RecRef.GETPOSITION(FALSE), 1, MAXSTRLEN(MasterSyncLogEntry."Primary Key"));

        KeyRef1 := RecRef.KEYINDEX(1);
        FOR i := 1 TO KeyRef1.FIELDCOUNT DO BEGIN
            KeyFldRef := KeyRef1.FIELDINDEX(i);

            CASE i OF
                1:
                    BEGIN
                        MasterSyncLogEntry."Primary Key Field 1 No." := KeyFldRef.NUMBER;
                        MasterSyncLogEntry."Primary Key Field 1 Value" :=
                          COPYSTR(FORMAT(KeyFldRef.VALUE, 0, 9), 1, MAXSTRLEN(MasterSyncLogEntry."Primary Key Field 1 Value"));
                    END;
                2:
                    BEGIN
                        MasterSyncLogEntry."Primary Key Field 2 No." := KeyFldRef.NUMBER;
                        MasterSyncLogEntry."Primary Key Field 2 Value" :=
                          COPYSTR(FORMAT(KeyFldRef.VALUE, 0, 9), 1, MAXSTRLEN(MasterSyncLogEntry."Primary Key Field 2 Value"));
                    END;
                3:
                    BEGIN
                        MasterSyncLogEntry."Primary Key Field 3 No." := KeyFldRef.NUMBER;
                        MasterSyncLogEntry."Primary Key Field 3 Value" :=
                          COPYSTR(FORMAT(KeyFldRef.VALUE, 0, 9), 1, MAXSTRLEN(MasterSyncLogEntry."Primary Key Field 3 Value"));
                    END;
            END;
        END;
        MasterSyncLogEntry.INSERT;
    end;

    procedure LogInsertion(var RecRef: RecordRef)
    var
        FldRef: FieldRef;
        i: Integer;
    begin
        IF RecRef.ISTEMPORARY THEN
            EXIT;

        //IF NOT IsLogActive(RecRef.NUMBER,0,0) THEN
        //EXIT;
        FOR i := 1 TO RecRef.FIELDCOUNT DO BEGIN
            FldRef := RecRef.FIELDINDEX(i);
            IF HasValue(FldRef) THEN
                IF IsNormalField(FldRef) THEN
                    //IF IsLogActive(RecRef.NUMBER,FldRef.NUMBER,0) THEN
                    IF i = 1 THEN
                        InsertLogEntry(FldRef, FldRef, RecRef, 0, TRUE);
        END;
        //
    end;

    procedure LogModification(var RecRef: RecordRef; var pxRecRef: RecordRef)
    var
        xRecRef: RecordRef;
        FldRef: FieldRef;
        xFldRef: FieldRef;
        i: Integer;
        IsReadable: Boolean;
        MasterDataSyncSetupField: Record "NXN MasterDataSync Setup_Field";
    begin
        IF RecRef.ISTEMPORARY THEN
            EXIT;

        //IF NOT IsLogActive(RecRef.NUMBER,0,1) THEN
        //EXIT;

        // xRecRef.OPEN(RecRef.NUMBER);
        // xRecRef."SECURITYFILTERING" := SECURITYFILTER::Filtered;
        // IF xRecRef.READPERMISSION THEN BEGIN
        //     IsReadable := TRUE;
        //     IF NOT xRecRef.GET(pXRecRef.RECORDID) THEN
        //         EXIT;
        // END;

        FOR i := 1 TO RecRef.FIELDCOUNT DO BEGIN
            FldRef := RecRef.FIELDINDEX(i);
            xFldRef := pxRecRef.FIELDINDEX(i);
            IF IsNormalField(FldRef) THEN
                IF FORMAT(FldRef.VALUE) <> FORMAT(xFldRef.VALUE) THEN
                    //IF IsFieldLogActive(RecRef.NUMBER, FldRef.NUMBER) THEN
                    //IF i = 1 THEN
                    InsertLogEntry(FldRef, xFldRef, RecRef, 1, IsReadable);
        END;
    end;

    procedure IsFieldLogActive(TableNumber: Integer; FieldNumber: Integer): Boolean
    var
        TempMasterDataSyncSetupField: Record "NXN MasterDataSync Setup_Field" temporary;
        MasterDataSyncSetupField: Record "NXN MasterDataSync Setup_Field";
    begin
        CLEAR(TempMasterDataSyncSetupField);
        TempMasterDataSyncSetupField.DELETEALL;
        IF FieldNumber = 0 THEN
            EXIT(TRUE);

        IF NOT TempMasterDataSyncSetupField.GET(COMPANYNAME, TableNumber, FieldNumber) THEN BEGIN
            IF NOT MasterDataSyncSetupField.GET(COMPANYNAME, TableNumber, FieldNumber) THEN BEGIN
                TempMasterDataSyncSetupField.INIT;
                TempMasterDataSyncSetupField."Company Name" := COMPANYNAME;
                TempMasterDataSyncSetupField."Table No." := TableNumber;
                TempMasterDataSyncSetupField."Field No." := FieldNumber;
            END ELSE
                TempMasterDataSyncSetupField := MasterDataSyncSetupField;
            TempMasterDataSyncSetupField.INSERT;
        END;
        EXIT(TempMasterDataSyncSetupField."Enable Sync");
    End;

    procedure LogRename(var RecRef: RecordRef; var xRecRefParam: RecordRef)
    var
        xRecRef: RecordRef;
        FldRef: FieldRef;
        xFldRef: FieldRef;
        i: Integer;
    begin
        IF RecRef.ISTEMPORARY THEN
            EXIT;

        //IF NOT IsLogActive(RecRef.NUMBER,0,1) THEN
        //EXIT;

        xRecRef.OPEN(xRecRefParam.NUMBER, FALSE, RecRef.CURRENTCOMPANY);
        xRecRef.GET(xRecRefParam.RecordId);
        FOR i := 1 TO RecRef.FIELDCOUNT DO BEGIN
            FldRef := RecRef.FIELDINDEX(i);
            xFldRef := xRecRef.FIELDINDEX(i);
            IF IsNormalField(FldRef) THEN
                IF FORMAT(FldRef.VALUE) <> FORMAT(xFldRef.VALUE) THEN
                    //IF IsLogActive(RecRef.NUMBER,FldRef.NUMBER,1) THEN
                    InsertLogEntry(FldRef, xFldRef, RecRef, 1, TRUE);
        END;
    end;

    procedure LogDeletion(var RecRef: RecordRef)
    var
        FldRef: FieldRef;
        i: Integer;
    begin
        IF RecRef.ISTEMPORARY THEN
            EXIT;

        //IF NOT IsLogActive(RecRef.NUMBER,0,2) THEN
        //EXIT;
        FOR i := 1 TO RecRef.FIELDCOUNT DO BEGIN
            FldRef := RecRef.FIELDINDEX(i);
            IF HasValue(FldRef) THEN
                IF IsNormalField(FldRef) THEN
                    //IF IsLogActive(RecRef.NUMBER,FldRef.NUMBER,2) THEN
                    IF i = 1 THEN
                        InsertLogEntry(FldRef, FldRef, RecRef, 2, TRUE);
        END;
    end;

    // [EventSubscriber(ObjectType::Codeunit, 49, 'OnAfterOnDatabaseInsert', '', false, false)]

    // procedure DBInsertSubscriber(RecRef: RecordRef)
    // // begin
    // //     CompanyInfo.GET;
    // //     IF CompanyInfo."NXN Register Change log" THEN BEGIN
    // //         MasterDataSyncSetup.RESET;
    // //         MasterDataSyncSetup.SETRANGE("Table ID", RecRef.NUMBER);
    // //         IF MasterDataSyncSetup.FINDFIRST THEN BEGIN
    // //             LogInsertion(RecRef);
    // //         END;
    // //     END;
    // // end;

    // [EventSubscriber(ObjectType::Codeunit, 49, 'OnAfterOnDatabaseModify', '', false, false)]

    // procedure DBModifySubscriber(RecRef: RecordRef)
    // begin
    //     CompanyInfo.GET;
    //     IF CompanyInfo."NXN Register Change log" THEN BEGIN
    //         MasterDataSyncSetup.RESET;
    //         MasterDataSyncSetup.SETRANGE("Table ID", RecRef.NUMBER);
    //         IF MasterDataSyncSetup.FINDFIRST THEN BEGIN
    //             LogModification(RecRef);
    //         END;
    //     END;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, 49, 'OnAfterOnDatabaseDelete', '', false, false)]

    // procedure DBDeleteSubscriber(RecRef: RecordRef)
    // begin
    //     CompanyInfo.GET;
    //     IF CompanyInfo."NXN Register Change log" THEN BEGIN
    //         MasterDataSyncSetup.RESET;
    //         MasterDataSyncSetup.SETRANGE("Table ID", RecRef.NUMBER);
    //         IF MasterDataSyncSetup.FINDFIRST THEN BEGIN
    //             LogDeletion(RecRef);
    //         END;
    //     END;
    // end;

    // [EventSubscriber(ObjectType::Codeunit, 49, 'OnAfterOnDatabaseRename', '', false, false)]

    // procedure DBRenameSubscriber(RecRef: RecordRef; xRecRef: RecordRef)
    // begin
    //     CompanyInfo.GET;
    //     IF CompanyInfo."NXN Register Change log" THEN BEGIN
    //         MasterDataSyncSetup.RESET;
    //         MasterDataSyncSetup.SETRANGE("Table ID", RecRef.NUMBER);
    //         IF MasterDataSyncSetup.FINDFIRST THEN BEGIN
    //             LogRename(RecRef, xRecRef);
    //         END;
    //     END;
    // end;


    local procedure IsNormalField(FieldRef: FieldRef): Boolean
    begin
        EXIT(FORMAT(FieldRef.CLASS) = 'Normal')
    end;

    local procedure HasValue(FldRef: FieldRef): Boolean
    var
        "Field": Record Field;
        HasValue: Boolean;
        Int: Integer;
        Dec: Decimal;
        D: Date;
        T: Time;
    begin
        EVALUATE(Field.Type, FORMAT(FldRef.TYPE));

        CASE Field.Type OF
            Field.Type::Boolean:
                HasValue := FldRef.VALUE;
            Field.Type::Option:
                HasValue := TRUE;
            Field.Type::Integer:
                BEGIN
                    Int := FldRef.VALUE;
                    HasValue := Int <> 0;
                END;
            Field.Type::Decimal:
                BEGIN
                    Dec := FldRef.VALUE;
                    HasValue := Dec <> 0;
                END;
            Field.Type::Date:
                BEGIN
                    D := FldRef.VALUE;
                    HasValue := D <> 0D;
                END;
            Field.Type::Time:
                BEGIN
                    T := FldRef.VALUE;
                    HasValue := T <> 0T;
                END;
            Field.Type::BLOB:
                HasValue := FALSE;
            ELSE
                HasValue := FORMAT(FldRef.VALUE) <> '';
        END;

        EXIT(HasValue);
    end;

    procedure InitChangeLog()
    begin
        //ChangeLogSetupRead := FALSE;
        //TempChangeLogSetupField.DELETEALL;
        //TempChangeLogSetupTable.DELETEALL;
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

    //9- Country/Region
    // [EventSubscriber(ObjectType::Table, 9, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertCountryRegion(var Rec: Record "Country/Region"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 9, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyCountryRegion(var Rec: Record "Country/Region"; var xRec: Record "Country/Region"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 9, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteCountryRegion(var Rec: Record "Country/Region"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 9, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameCountryRegion(var Rec: Record "Country/Region"; var xRec: Record "Country/Region"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;

    // //27-Item
    // [EventSubscriber(ObjectType::Table, 27, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertItem(var Rec: Record Item; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 27, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyItem(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 27, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteItem(var Rec: Record Item; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 27, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameItem(var Rec: Record "Item"; var xRec: Record "Item"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;
    // //94 Inventory Posting Group
    // [EventSubscriber(ObjectType::Table, 94, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertIPG(var Rec: Record "Inventory Posting Group"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 94, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyIPG(var Rec: Record "Inventory Posting Group"; var xRec: Record "Inventory Posting Group"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 94, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteIPG(var Rec: Record "Inventory Posting Group"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 94, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameIPG(var Rec: Record "Inventory Posting Group"; var xRec: Record "Inventory Posting Group"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;
    // //204-Unit of Measure
    // [EventSubscriber(ObjectType::Table, 204, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertUOM(var Rec: Record "Unit of Measure"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 204, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyUOM(var Rec: Record "Unit of Measure"; var xRec: Record "Unit of Measure"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 204, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteUOM(var Rec: Record "Unit of Measure"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 204, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameUOM(var Rec: Record "Unit of Measure"; var xRec: Record "Unit of Measure"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;
    // //Gen Product Posting Group
    // [EventSubscriber(ObjectType::Table, 251, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertGPPG(var Rec: Record "Gen. Product Posting Group"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 251, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyGPPG(var Rec: Record "Gen. Product Posting Group"; var xRec: Record "Gen. Product Posting Group"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 251, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteGPPG(var Rec: Record "Gen. Product Posting Group"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 251, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameGPPG(var Rec: Record "Gen. Product Posting Group"; var xRec: Record "Gen. Product Posting Group"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;
    // //VAT Product Posting Group
    // [EventSubscriber(ObjectType::Table, 324, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertVPPG(var Rec: Record "VAT Product Posting Group"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 324, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyVPPG(var Rec: Record "VAT Product Posting Group"; var xRec: Record "VAT Product Posting Group"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 324, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteVPPG(var Rec: Record "VAT Product Posting Group"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 324, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameVPPG(var Rec: Record "VAT Product Posting Group"; var xRec: Record "VAT Product Posting Group"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;
    // //Default Dimension
    // [EventSubscriber(ObjectType::Table, 352, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertDefaultDimension(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 352, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyDefaultDimension(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 352, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteDefaultDimension(var Rec: Record "Default Dimension"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 352, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameDefaultDimension(var Rec: Record "Default Dimension"; var xRec: Record "Default Dimension"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;

    // //ItemVariant
    // [EventSubscriber(ObjectType::Table, 5401, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertItemVariant(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 5401, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyItemVariant(var Rec: Record "Item Variant"; var xRec: Record "Item Variant"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 5401, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteItemVariant(var Rec: Record "Item Variant"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 5401, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameItemVariant(var Rec: Record "Item Variant"; var xRec: Record "Item Variant"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;
    // //Item Unit of Measure
    // [EventSubscriber(ObjectType::Table, 5404, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertIUOM(var Rec: Record "Item Unit of Measure"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 5404, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyIUOM(var Rec: Record "Item Unit of Measure"; var xRec: Record "Item Unit of Measure"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 5404, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteIUOM(var Rec: Record "Item Unit of Measure"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 5404, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameItemUOM(var Rec: Record "Item Unit of Measure"; var xRec: Record "Item Unit of Measure"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;
    // //StockKeeping Unit
    // [EventSubscriber(ObjectType::Table, 5700, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertSKU(var Rec: Record "Stockkeeping Unit"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 5700, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifySKU(var Rec: Record "Stockkeeping Unit"; var xRec: Record "Stockkeeping Unit"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 5700, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteSKU(var Rec: Record "Stockkeeping Unit"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 5700, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameSKU(var Rec: Record "Stockkeeping Unit"; var xRec: Record "Stockkeeping Unit"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;
    // //Item Substitution
    // [EventSubscriber(ObjectType::Table, 5715, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertItemSub(var Rec: Record "Item Substitution"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 5715, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyItemSub(var Rec: Record "Item Substitution"; var xRec: Record "Item Substitution"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 5715, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteItemSub(var Rec: Record "Item Substitution"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 5715, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameItemSub(var Rec: Record "Item Substitution"; var xRec: Record "Item Substitution"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;
    // //Item Cross Reference
    // [EventSubscriber(ObjectType::Table, 5717, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertItemCrossRef(var Rec: Record "Item Cross Reference"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 5717, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyItemCrossRef(var Rec: Record "Item Cross Reference"; var xRec: Record "Item Cross Reference"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 5717, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteItemCrossRef(var Rec: Record "Item Cross Reference"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 5717, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameItemCrossRef(var Rec: Record "Item Cross Reference"; var xRec: Record "Item Cross Reference"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;
    // //Item Categories
    // [EventSubscriber(ObjectType::Table, 5722, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertItemCategories(var Rec: Record "Item Category"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 5722, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyItemCategories(var Rec: Record "Item Category"; var xRec: Record "Item Category"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 5722, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteItemCategories(var Rec: Record "Item Category"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 5722, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameItemCategories(var Rec: Record "Item Category"; var xRec: Record "Item Category"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;
    // //Item Attribute
    // //Item Categories
    // [EventSubscriber(ObjectType::Table, 7500, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertItemAttribute(var Rec: Record "Item Attribute"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 7500, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyItemAttribute(var Rec: Record "Item Attribute"; var xRec: Record "Item Attribute"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 7500, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteItemAttribute(var Rec: Record "Item Attribute"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 7500, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameItemAttribute(var Rec: Record "Item Attribute"; var xRec: Record "Item Attribute"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;
    // //Item Attribute Value
    // [EventSubscriber(ObjectType::Table, 7501, 'OnAfterInsertEvent', '', false, false)]
    // procedure InsertItemAttributeValue(var Rec: Record "Item Attribute Value"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'INSERT');
    // end;

    // [EventSubscriber(ObjectType::Table, 7501, 'OnAfterModifyEvent', '', false, false)]
    // procedure ModifyItemAttributeValue(var Rec: Record "Item Attribute Value"; var xRec: Record "Item Attribute Value"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'MODIFY');
    // end;

    // [EventSubscriber(ObjectType::Table, 7501, 'OnAfterDeleteEvent', '', false, false)]
    // procedure DeleteItemAttributeValue(var Rec: Record "Item Attribute Value"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     RecRef.GetTable(Rec);
    //     RegisterLog(RecRef, RecRef, 'DELETE');
    // end;

    // [EventSubscriber(ObjectType::Table, 7501, 'OnAfterRenameEvent', '', false, false)]
    // procedure RenameItemAttributeValue(var Rec: Record "Item Attribute Value"; var xRec: Record "Item Attribute Value"; RunTrigger: Boolean)
    // begin
    //     Clear(RecRef);
    //     clear(xRecRef);
    //     RecRef.GetTable(Rec);
    //     xRecRef.GetTable(xRec);
    //     RegisterLog(RecRef, xRecRef, 'RENAME');
    // end;

    // procedure RegisterLog(RecRef: RecordRef; xRecRef: RecordRef; TypeofChange: Code[10])
    // begin
    //     CompanyInfo.GET;
    //     IF CompanyInfo."NXN Register Change log" THEN BEGIN
    //         MasterDataSyncSetup.RESET;
    //         MasterDataSyncSetup.SETRANGE("Table ID", RecRef.NUMBER);
    //         IF MasterDataSyncSetup.FINDFIRST THEN BEGIN
    //             repeat
    //                 IF TypeofChange = 'INSERT' then
    //                     LogInsertion(RecRef);
    //                 IF TypeofChange = 'MODIFY' then
    //                     LogModification(RecRef, xRecRef);
    //                 IF TypeofChange = 'DELETE' then
    //                     LogDeletion(RecRef);
    //             //IF TypeofChange = 'RENAME' then
    //             //LogRename(RecRef, xRecRef);
    //             until MasterDataSyncSetup.Next = 0;
    //         END;
    //     END;
    // end;
}

