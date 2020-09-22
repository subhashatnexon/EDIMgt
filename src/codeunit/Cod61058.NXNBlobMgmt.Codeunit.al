codeunit 61058 "NXN Azure Blob Mgt."
{
    trigger OnRun()
    var
    begin

    end;

    procedure CreateOrdersfromAzure()
    var
        AzureFile: Record "NXN BlobList";
        ListBlobCU: Codeunit "NXN List Azure Blob";
        StorageName: Text[50];
        ContainerName: Text[50];
        AcessKey: Text;
        AzureSetup: Record "NXN Azure storage Setup";
        EDIExcelCSVProcessingCU: Codeunit "NXN EDI ExcelCSV Order Process";

    begin
        AzureSetup.Get();
        ListBlobCU.ListBlob(AzureSetup.AccountName, AzureSetup.AccountContainer, AzureSetup.AccountAccessKey, '');
        AzureFile.SetFilter(FileName, '<>%1', '');
        if AzureFile.FindFirst() then
            repeat
                //if (StrPos(AzureFile.FileName, companyInfo."NXN EDI Company Initial" + '_ExcelOrder') > 0) then
                //EDIExcelCSVProcessingCU.ImportShortyfromAzureBlob(AzureFile.FileName);
                // if StrPos(AzureFile.FileName, companyInfo."NXN EDI Company Initial" + '_RedBalloon') > 0 then
                //EDIExcelCSVProcessingCU.ImportRedBallonfromAzureBlob(AzureFile.FileName);
                if NOT EDIExcelCSVProcessingCU.Run(AzureFile) then begin
                    InsertIntegrationErrLog(TableName::"EDI Order", AzureFile.FileName, 2, CurrentDateTime, GETLASTERRORTEXT);
                    CLEARLASTERROR();
                end else begin
                    InsertIntegrationErrLog(TableName::"EDI Order", AzureFile.FileName, 1, CurrentDateTime, GETLASTERRORTEXT);
                end;
            until AzureFile.Next() = 0;
        if GuiAllowed then
            Message('Finished Processing');
    end;

    procedure GetDocument()
    var
        DocParserList: Record "NXN DocParser List";
        DocParserCU: Codeunit "NXN DocParserProcessing ";
    begin
        CompanyInfo.Get();
        if (CompanyInfo."NXN EDI Company Initial" = 'SL') OR ((StrPos(CompanyInfo.Name, 'Liquor') > 0)) then begin
            if DocParserList.FindFirst() then
                repeat
                    // CallWebService('dyqbkqaysnjs'); //DXC Technologies
                    //CallWebService('nqxoyrdhlghj'); //ORDERIN
                    // CallWebService('naxdgdqftynm'); //SODEXO
                    // CallWebService('nowiqizxbsuv'); //SPOTLESS
                    if NOT DocParserCU.Run(DocParserList) then begin
                        InsertIntegrationErrLog(TableName::"EDI Order", DocParserList.ParserCode, 2, CurrentDateTime, GETLASTERRORTEXT);
                        CLEARLASTERROR();
                    end else
                        InsertIntegrationErrLog(TableName::"EDI Order", DocParserList.ParserCode, 1, CurrentDateTime, GETLASTERRORTEXT);
                Until DocParserList.Next = 0;
            if GuiAllowed then
                Message('Finished Processing');
        end;

    end;

    procedure Initialize()
    begin
        NewLine[1] := 10;
    end;

    procedure GetTextToHash(Verb: Text; ContentType: Text; CanonicalizedHeaders: Text; CanonicalizedResource: Text; ContentLength: Text) TextToHash: Text
    begin
        Initialize();
        exit(
            Verb + NewLine +  //HTTP Verb
            NewLine +  //Content-Encoding
            NewLine +  //Content-Language
            ContentLength + NewLine +  //Content-Length (include value when zero)
            NewLine +  //Content-MD5
            ContentType + NewLine +  //Content-Type
            NewLine +  //Date
            NewLine +  //If-Modified-Since
            NewLine +  //If-Match
            NewLine +  //If-None-Match
            NewLine +  //If-Unmodified-Since
            NewLine +  //Range
            CanonicalizedHeaders + NewLine +  //CanonicalizedHeaders
            CanonicalizedResource);
    end;

    procedure GetAuthorization(AccountName: Text; HashKey: Text; TextToHash: Text) Authorization: Text;
    begin
        Initialize();
        Authorization := 'SharedKey ' + AccountName + ':' + GenerateKeyedHash(TextToHash, HashKey);
    end;

    local procedure GenerateKeyedHash(TextToHash: Text; HashKey: Text) KeyedHash: Text
    var
        EncryptionMgt: Codeunit "Cryptography Management";
        HashAlgorithmType: Option HMACMD5,HMACSHA1,HMACSHA256,HMACSHA384,HMACSHA512;
    begin
        KeyedHash := EncryptionMgt.GenerateBase64KeyedHashAsBase64String(TextToHash, HashKey, HashAlgorithmType::HMACSHA256)
    end;

    procedure InsertIntegrationErrLog(pModule: Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","Raw XML","EDI Member Invoice","WS Order"; "Reference No": text[100]; DocStatus: Option "",Sucessful,Error; ExecutionTimeStamp: DateTime; pErrorDescription: Text[1024])
    var
    begin
        WITH IntegationLog DO BEGIN
            RESET;
            INIT;
            "Entry No." := GetLastEntryNo();
            Module := pModule;
            "Reference No." := "Reference No";
            "Reference No. 2" := '';
            "Document Type" := pModule;
            Status := docStatus;
            Direction := 1;
            "Error Description" := COPYSTR(pErrorDescription, 1, 250);
            "Error Description 2" := COPYSTR(pErrorDescription, 251, 250);
            "Execution Timestamp" := CURRENTDATETIME;
            INSERT();
        END;
        COMMIT;
    end;

    procedure GetLastEntryNo(): Integer
    var
        EntryNo: Integer;
    begin
        WITH IntegationLog DO BEGIN
            RESET;
            IF FINDLAST THEN
                EntryNo := "Entry No." + 1
            ELSE
                EntryNo := 1;
        END;
        EXIT(EntryNo);
    end;

    var
        NewLine: Text[1];
        EntryNo: Integer;
        CompanyInfo: Record "Company Information";
        OrderID: Code[20];
        TableName: Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code","EDI Central Invoicing";
        BatchProcessName: Code[20];
        UniqueOrderID: Code[50];
        IntegationLog: Record "NXN Doc. Integration Error Log";
}