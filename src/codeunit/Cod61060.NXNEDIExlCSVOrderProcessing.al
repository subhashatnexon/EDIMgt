codeunit 61060 "NXN EDI ExcelCSV Order Process"
{
    TableNo = "NXN BlobList";
    trigger OnRun()
    begin
        if companyinformation.get then;
        if (StrPos(Rec.FileName, companyinformation."NXN EDI Company Initial" + '_ExcelOrder') > 0) then
            ImportShortyfromAzureBlob(Rec.FileName);
        if StrPos(Rec.FileName, companyinformation."NXN EDI Company Initial" + '_RedBalloon') > 0 then
            ImportRedBallonfromAzureBlob(Rec.FileName);
    end;

    procedure ImportShortyfromAzureBlob(FileName: Text[500])
    var
        JsonText: Text;
        I: Integer;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        Headers: HttpHeaders;
        Client: HttpClient;
        myfile: File;
        JToken: JsonToken;
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        DeleteBlobCU: Codeunit "NXN Delete Azure Blob";
        AzureSetup: Record "NXN Azure storage Setup";
        LineCount: Integer;
        TempBlob: Codeunit "Temp Blob";
        PackageOutstream: OutStream;
        DW: Dialog;
        responcemessgae: HttpResponseMessage;
        content: HttpContent;
        Instr: InStream;
        uri: text;
        Buffer: text;
        ImportLabel: label 'Importing the data..';
        ErrorMsg: label 'Unable to download the package : %1';
        fileMgt: Codeunit "File Management";
        LineNum: Integer;
        Column1: Text;
        Column2: Text;
        Column3: Text;
        Column4: Text;
        Column5: Text;
        Column6: Text;
        Column7: Text;
        RemTxt: Text;
        Response: Text;
        VarInstream: InStream;
        VarOutStream: OutStream;
        response2: Text;
        StreamInTest: InStream;
        C4110: Codeunit "Base64 Convert";
        EDIHeader: Record "NXN EDI Order Header";
        EDILine: Record "NXN EDI Order Line";
        Cust: Record Customer;
        EDIHeaderCreated: Boolean;
        ShipTo: Record "Ship-to Address";
        EntryNum: Integer;
        Item: Record Item;
        CustNo: Text;
        CostCentre: Text;
        OrdRef: Text;
        ContNum: Text;
        ContName: Text;
        ExptDelDate: Date;
        ExptDeTime: Time;
        DeliveryInstruction: Text;
        ShipCode: Text;
        ShipName: Text;
        ShipAddr: Text;
        ShipAddr2: Text;
        ShipCity: Text;
        ShipZipCode: Text;
        ShipState: Text;
        ShipCounty: Text;
        ShipContact: Text;
        cold: Text;
        BlobMgmt: Codeunit "NXN Azure Blob Mgt.";

    begin
        if GuiAllowed then
            dw.Open(ImportLabel);
        Clear(TempBlob);
        AzureSetup.Get();
        EDIHeaderCreated := false;
        InitializeURL(AzureSetup.AccountName, AzureSetup.AccountContainer);
        uri := StorageAccountUrl + FileName;

        if not client.Get(uri, responcemessgae) then
            Error(ErrorMsg, GetLastErrorText());
        if not responcemessgae.IsSuccessStatusCode then
            Error(ErrorMsg, responcemessgae.ReasonPhrase);
        responcemessgae.Content.ReadAs(JsonText);

        tempBlob.CreateOutStream(VarOutStream);
        VarOutStream.WriteText(JsonText);
        TempBlob.CreateInStream(VarInstream);

        while not VarInstream.EOS do begin
            LineNum += 1;
            VarInstream.ReadText(Buffer);

            Clear(Column1);
            Column1 := COPYSTR(Buffer, 1, STRPOS(Buffer, ',') - 1);
            RemTxt := DELSTR(Buffer, 1, STRPOS(Buffer, ','));

            Clear(Column2);
            Column2 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
            RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

            Clear(Column3);
            Column3 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
            RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

            Clear(Column4);
            Column4 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
            RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

            Clear(Column5);
            Column5 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
            RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

            Clear(Column6);
            Column6 := COPYSTR(RemTxt, 1, StrLen(RemTxt));
            RemTxt := DELSTR(RemTxt, 1, StrLen(RemTxt));

            if LineNum = 2 then begin
                CustNo := Column2;
                ShipCode := Column4;
            end;
            if LineNum = 3 then begin
                // :=Column2;
                ShipAddr := Column4;
            end;
            if LineNum = 4 then begin
                CostCentre := Column2;
                ShipAddr2 := Column4;
            end;
            if LineNum = 5 then begin
                OrdRef := Column2;
                ShipCity := Column4;
            end;
            if LineNum = 6 then begin
                ContName := Column2;
                ShipZipCode := Column4;
            end;
            if LineNum = 7 then begin
                ContNum := Column2;
                ShipState := Column4;
            end;
            if LineNum = 8 then begin
                if Column2 <> '' then
                    Evaluate(ExptDelDate, Column2);
                ShipCounty := Column4;
            end;
            if LineNum = 9 then begin
                if Column2 <> '' then
                    Evaluate(ExptDeTime, Column2);
                ShipContact := Column4;
            end;
            if LineNum = 10 then begin
                DeliveryInstruction := Column2;
                cold := Column4;
            end;
            if LineNum = 11 then begin
                if not EDIHeaderCreated then begin
                    IF Cust.get(CustNo) then;
                    EDIHeader.Init();
                    EDIHeader."Entry No." := 0;
                    IF Cust.get(CustNo) then begin
                        EDIHeader."Customer No." := Cust."No.";
                        EDIHeader."Customer ID" := Cust."No.";
                    end else
                        EDIHeader."Customer ID" := 'SHORTYSXLORDER';
                    EDIHeader."Order ID" := OrdRef;
                    EDIHeader."Bill-to Address" := CUst.Address;
                    EDIHeader."Bill-to Name" := CUst.Name;
                    EDIHeader."Bill-to City" := CUst.City;
                    EDIHeader."Bill-to State" := CUst.County;
                    EDIHeader."Bill-to Post Code" := CUst."Post Code";
                    EDIHeader."Bill-to Contact" := ContNum;
                    EDIHeader."Cost Centre Code" := CostCentre;
                    EDIHeader."Order Date" := Today;
                    EDIHeader."Order Time" := Time;
                    EDIHeader."Cust Order Received Date" := Today;
                    EDIHeader."Cust Order Received Time" := Time;
                    EDIHeader."Order Method" := EDIHeader."Order Method"::Email;
                    EDIHeader."Ship-to Name" := ShipName;
                    EDIHeader."Ship-to Address" := ShipAddr;
                    EDIHeader."Ship-to City" := ShipCity;
                    EDIHeader."Ship-to State" := ShipState;
                    EDIHeader."Ship-to Post Code" := ShipZipCode;
                    EDIHeader."Ship-to Country/Region Code" := ShipCounty;
                    EDIHeader."Ship-to Contact" := ShipContact;
                    EDIHeader."EDI Delivery Instructions" := copystr(DeliveryInstruction, 1, 80);
                    if (cold = 'yes') OR (cold = 'Yes') OR (cold = 'YES') then
                        EDIHeader.Cold := true
                    else
                        EDIHeader.Cold := false;
                    EDIHeader."Expected Delivery Date" := ExptDelDate;
                    EDIHeader."Preferred Delivery Time" := ExptDeTime;
                    EDIHeader."Email Date" := Today;
                    EDIHeader."Email Time" := Time;
                    EDIHeader."Import File Name" := FileName;
                    EDIHeader.Insert();
                    EDIHeaderCreated := true;
                    EntryNum := EDIHeader."Entry No.";
                end;
            end;
            IF (LineNum > 12) and (Column4 <> '') THEN BEGIN
                if Column1 <> '' then begin
                    if not ItemCategory(Column1) then begin
                        // EDILine.Init();
                        EDILine."Entry No." := EDIHeader."Entry No.";
                        EDILine."Line No." := GetLineNum(EDIHeader."Entry No.");
                        if Item.Get(Column1) then begin
                            EDILine."Item No." := Column1;
                            EDILine.Description := Item.Description;
                            EDILine."Unit Of Measure Code" := Item."Base Unit of Measure";
                            EDILine."Unit Price" := Item."Unit Price";
                        end else begin
                            EDILine."Item No." := Column1;
                            EDILine."Unit Of Measure Code" := Column3;
                            EDILine.Description := Column2;
                            if Column4 <> '' then
                                Evaluate(EDILine."Unit Price", Column5);
                        end;
                        if Column5 <> '' then begin
                            Evaluate(EDILine.Quantity, Column4);
                            EDILine.Insert();
                        end;
                    end;
                end;
            end;
        end;
        DeleteBlobCU.DeleteBlob(AzureSetup.AccountName, AzureSetup.AccountContainer, AzureSetup.AccountAccessKey, uri);
    end;


    procedure ImportRedBallonfromAzureBlob(FileName: Text[500])
    var
        JsonText: Text;
        I: Integer;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        Headers: HttpHeaders;
        Client: HttpClient;
        myfile: File;
        JToken: JsonToken;
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        LineCount: Integer;
        configpackage: Codeunit "Config. Package - Import";
        TempBlob: Codeunit "Temp Blob";
        PackageOutstream: OutStream;
        DW: Dialog;
        responcemessgae: HttpResponseMessage;
        content: HttpContent;
        Instr: InStream;
        uri: text;
        Buffer: text;
        ImportLabel: label 'Importing the data..';
        ErrorMsg: label 'Unable to download the package : %1';
        fileMgt: Codeunit "File Management";
        LineNum: Integer;
        Column1: Text;
        Column2: Text;
        Column3: Text;
        Column4: Text;
        Column5: Text;
        Column6: Text;
        Column7: Text;
        Column8: Text;
        Column9: Text;
        Column10: Text;
        Column11: Text;
        Column12: Text;
        Column13: Text;
        Column14: Text;
        Column15: Text;
        Column16: Text;
        Column17: Text;
        Column18: Text;
        Column19: Text;
        Column20: Text;
        Column21: Text;
        Column22: Text;
        Column23: Text;
        Column24: Text;
        RemTxt: Text;
        Response: Text;
        VarInstream: InStream;
        VarOutStream: OutStream;
        response2: Text;
        StreamInTest: InStream;
        C4110: Codeunit "Base64 Convert";
        EDIHeader: Record "NXN EDI Order Header";
        EDILine: Record "NXN EDI Order Line";
        AzureSetup: Record "NXN Azure storage Setup";
        DeleteBlob: Codeunit "NXN Delete Azure Blob";

    begin
        dw.Open(ImportLabel);
        Clear(TempBlob);
        AzureSetup.Get();
        InitializeURL(AzureSetup.AccountName, AzureSetup.AccountContainer);
        uri := StorageAccountUrl + FileName;

        if not client.Get(uri, responcemessgae) then
            Error(ErrorMsg, GetLastErrorText());
        if not responcemessgae.IsSuccessStatusCode then
            Error(ErrorMsg, responcemessgae.ReasonPhrase);

        responcemessgae.Content.ReadAs(JsonText);

        tempBlob.CreateOutStream(VarOutStream);
        VarOutStream.WriteText(JsonText);
        TempBlob.CreateInStream(VarInstream);
        while not VarInstream.EOS do begin
            LineNum += 1;
            VarInstream.ReadText(Buffer);
            // Do some processing.  
            IF LineNum > 1 THEN BEGIN
                Clear(Column1);
                Column1 := COPYSTR(Buffer, 1, STRPOS(Buffer, ',') - 1);
                RemTxt := DELSTR(Buffer, 1, STRPOS(Buffer, ','));

                Clear(Column2);
                Column2 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column3);
                Column3 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column4);
                Column4 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column5);
                Column5 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column6);
                Column6 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column7);
                Column7 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column8);
                Column8 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column9);
                Column9 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column10);
                Column10 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column11);
                Column11 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column12);
                Column12 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column13);
                Column13 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column14);
                Column14 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column15);
                Column15 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column16);
                Column16 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column17);
                Column17 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column18);
                Column18 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column19);
                Column19 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column20);
                Column20 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column21);
                Column21 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column22);
                Column22 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column23);
                Column23 := COPYSTR(RemTxt, 1, STRPOS(RemTxt, ',') - 1);
                RemTxt := DELSTR(RemTxt, 1, STRPOS(RemTxt, ','));

                Clear(Column24);
                Column24 := COPYSTR(RemTxt, 1, StrLen(RemTxt));
                RemTxt := DELSTR(RemTxt, 1, StrLen(RemTxt));

                // Message('Line Num-%1 & %2', LineNum, Column2);

                EDIHeader.Reset();
                EDIHeader.SetRange("Order ID", Column2);
                EDIHeader.SetRange("Sales Order Created", false);
                if not EDIHeader.FindFirst() then begin
                    EDIHeader.Init();
                    EDIHeader."Entry No." := 0;
                    EDIHeader."Customer ID" := Column6;
                    EDIHeader."Order ID" := Column2;
                    if Column5 <> '' then
                        Evaluate(EDIHeader."Order Date", Column5)
                    else
                        EDIHeader."Order Date" := today;
                    EDIHeader."Cust Order Received Date" := Today;
                    EDIHeader."Cust Order Received Time" := Time;

                    EDIHeader."Order Time" := Time;
                    EDIHeader."Ship-to Name" := Column6 + ' ' + Column7;
                    EDIHeader."Telephone No." := Column8;
                    EDIHeader."Order Method" := EDIHeader."Order Method"::Email;
                    EDIHeader."Ship-to Address" := Column10 + ' ' + Column11 + ' ' + Column12;
                    EDIHeader."Ship-to City" := Column13;
                    EDIHeader."Ship-to State" := Column14;
                    EDIHeader."Ship-to Post Code" := Column15;
                    EDIHeader."Tracking Email" := Column16;
                    EDIHeader."EDI Delivery Instructions" := Column17;
                    EDIHeader."Supplier Question 1" := Column18;
                    EDIHeader."Supplier Question 2" := Column19;
                    EDIHeader."Supplier Question 3" := Column20;
                    EDIHeader."Supplier Question 4" := Column21;
                    EDIHeader."Message To" := Column22;
                    EDIHeader."Message From" := Column23;
                    EDIHeader."Message Text" := Column24;
                    EDIHeader."Order Method" := EDIHeader."Order Method"::Email;
                    EDIHeader."Email Date" := Today;
                    EDIHeader."Email Time" := Time;
                    EDIHeader."Import File Name" := FileName;
                    EDIHeader.Insert();
                end;

                EDILine.Reset();
                EDILine.SetRange("Entry No.", EDIHeader."Entry No.");
                EDILine.SetRange("Item No.", Column3);
                if EDILine.FindFirst() then begin
                    EDILine.Quantity := EDILine.Quantity + 1;
                    EDILine.Modify();
                end else begin
                    EDILine.Init();
                    EDILine."Entry No." := EDIHeader."Entry No.";
                    EDILine."Line No." := GetLineNum(EDIHeader."Entry No.");
                    EDILine."Item No." := Column3;
                    EDILine.Quantity := 1;
                    EDILine.Insert();
                end;
            end;
        end;
        DeleteBlob.DeleteBlob(AzureSetup.AccountName, AzureSetup.AccountContainer, AzureSetup.AccountAccessKey, uri);
    end;

    local procedure ItemCategory(Category: Code[50]): Boolean
    var
        ItemCategry: Record "Item Category";
    begin
        if ItemCategry.Get(Category) then
            exit(true)
        else
            exit(false);

    end;

    procedure GetLineNum(EntryNum: Integer): Integer
    var
        EDILineRec: Record "NXN EDI Order Line";
    begin
        EDILineRec.Reset();
        EDILineRec.SetRange("Entry No.", EntryNum);
        if EDILineRec.FindLast() then
            exit(EDILineRec."Line No." + 10000)
        else
            exit(10000);
    end;

    procedure InitializeURL(AccountName: Text; containername: text[50])
    var
        UTCDateTimeMgt: Codeunit "NXN Blob UTC DateTime Mgt.";
    begin
        NewLine[1] := 10;
        UTCDateTimeText := UTCDateTimeMgt.GetUTCDateTimeText();
        StorageAccountUrl := 'https://' + AccountName + '.blob.core.windows.net/' + containername + '/';
    end;


    var
        DeleteBlobCU: Codeunit "NXN Delete Azure Blob";
        FailedToGetBlobErr: Label 'Failed to download a blob: ';
        UrlIncorrectErr: Label 'Url incorrect.';
        UTCDateTimeText: Text;
        StorageAccountUrl: Text;
        NewLine: Text[1];
        companyinformation: Record "Company Information";
}