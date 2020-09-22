codeunit 61059 "NXN DocParserProcessing "
{
    TableNo = "NXN DocParser List";

    trigger OnRun()
    begin
        CallWebService(rec.parserid);
    end;

    procedure CallWebService(ParserID: Text)
    var
        JsonText: Text;
        I: Integer;
        ResponseMessage: HttpResponseMessage;
        RequestMessage: HttpRequestMessage;
        Headers: HttpHeaders;
        Client: HttpClient;
        JToken: JsonToken;
        JsonArray: JsonArray;
        JsonObject: JsonObject;
        RecParsedData: Record "NXN EDI Order Header";
        RecParsedDataLine: Record "NXN EDI Order Line";
        J: Integer;
        Key1: Text;
        Key2: Text;
        Key3: Text;
        Key4: Text;
        Key5: Text;
        Key0: Text;
        Key6: Text;
        Key7: Text;
        Key8: Text;
        LineCount: Integer;
        EDISetup: Record "NXN EDI Setup";
        Desc: Text[50];
        BilltoCount: Integer;
        Shiptocount: Integer;
        LineExitsIndex: Integer;
    begin
        EDISetup.Get();
        RequestMessage.Method := 'GET';
        RequestMessage.SetRequestUri('https://api.docparser.com/v1/results/' + ParserID + '/');
        RequestMessage.GetHeaders(Headers);
        Headers.Add('api_key', '3a72c77f3c559f18cf94e993e2148c7588b8ed0c');
        // Headers.Add('api_key', EDISetup."DocParser API Key");
        Client.Send(RequestMessage, ResponseMessage);
        ResponseMessage.Content.ReadAs(JsonText);

        if not JsonArray.ReadFrom(JsonText) then
            Error('Invalid Response');

        //get the line item in the JSON
        LineCount := 0;
        for I := 0 to JsonArray.Count - 1 do begin
            JsonArray.Get(I, JToken);
            JsonObject := JToken.AsObject();
            if GetJsonToken(JsonObject, 'line_items').IsArray then
                LineCount := GetJsonToken(JsonObject, 'line_items').AsArray().Count
            else
                LineCount := 0;
            if not JsonObject.Get('id', JToken) then
                Error('Could not find the token with the key %1');

            if ParserID = 'dyqbkqaysnjs' then begin //DXC Technologies
                RecParsedData.Reset();
                RecParsedData.SetRange("Document Parser ID", GetJsonToken(JsonObject, 'document_id').AsValue().AsText());
                if not RecParsedData.FindFirst() then begin
                    RecParsedData."Entry No." := 0;
                    // RecParsedData."Document Parser ID" := ParserID;
                    if not GetJsonToken(JsonObject, 'po_number').AsValue.IsNull then
                        RecParsedData."Order ID" := GetJsonToken(JsonObject, 'po_number').AsValue.AsText();
                    //ValidateCustomerDetails('10000', RecParsedData);
                    RecParsedData."Order Method" := RecParsedData."Order Method"::Email;
                    if not SelectJsonToken(JsonObject, '$.po_date.podate2').AsValue().IsNull then
                        RecParsedData."Order Date" := SelectJsonToken(JsonObject, '$.po_date.podate2').AsValue().AsDate()
                    else
                        RecParsedData."Order Date" := Today;
                    RecParsedData."Order Time" := Time;
                    RecParsedData."Cust Order Received Date" := Today;
                    RecParsedData."Cust Order Received Time" := Time;
                    if not GetJsonToken(JsonObject, 'document_id').AsValue().IsNull then
                        RecParsedData."Document Parser ID" := GetJsonToken(JsonObject, 'document_id').AsValue().AsText();
                    RecParsedData."Document Parser Name" := 'DXC';
                    RecParsedData."Customer ID" := 'DXC';
                    if not GetJsonToken(JsonObject, 'forpurchaseorderqueries').AsValue().IsNull then
                        RecParsedData."Bill-to Contact" := GetJsonToken(JsonObject, 'forpurchaseorderqueries').AsValue().AsText(); //CV_PS070920
                    if not GetJsonToken(JsonObject, 'termsofpayment').AsValue().IsNull then
                        RecParsedData."EDI Header Comments" := GetJsonToken(JsonObject, 'termsofpayment').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'billtoname').AsValue().IsNull then
                        RecParsedData."Bill-to Name" := GetJsonToken(JsonObject, 'billtoname').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'billtoaddr').AsValue().IsNull then
                        RecParsedData."Bill-to Address" := GetJsonToken(JsonObject, 'billtoaddr').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'billtocity').AsValue().IsNull then
                        RecParsedData."Bill-to City" := GetJsonToken(JsonObject, 'billtocity').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'billtostate').AsValue().IsNull then
                        RecParsedData."Bill-to State" := GetJsonToken(JsonObject, 'billtostate').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'billtozip').AsValue().IsNull then
                        RecParsedData."Bill-to Post Code" := GetJsonToken(JsonObject, 'billtozip').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptoname').AsValue().IsNull then
                        RecParsedData."Ship-to Name" := GetJsonToken(JsonObject, 'shiptoname').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptostreet').AsValue().IsNull then
                        RecParsedData."Ship-to Street" := GetJsonToken(JsonObject, 'shiptostreet').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptocity').AsValue().IsNull then
                        RecParsedData."Ship-to City" := GetJsonToken(JsonObject, 'shiptocity').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptocity').AsValue().IsNull then
                        RecParsedData."Ship-to State" := GetJsonToken(JsonObject, 'shiptocity').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptozipcode').AsValue().IsNull then
                        RecParsedData."Ship-to Post Code" := GetJsonToken(JsonObject, 'shiptozipcode').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'file_name').AsValue().IsNull then
                        RecParsedData."Import File Name" := GetJsonToken(JsonObject, 'file_name').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'uploaded_at').AsValue().IsNull then begin
                        RecParsedData."Email Date" := Variant2Date(GetJsonToken(JsonObject, 'uploaded_at').AsValue().AsDateTime());
                        RecParsedData."Email Time" := Variant2Time(GetJsonToken(JsonObject, 'uploaded_at').AsValue().AsDateTime());
                    end;
                    RecParsedData.Insert();

                    for J := 0 to LineCount - 1 do begin
                        Key0 := '$.line_items[' + format(J) + '].key_0';
                        Key1 := '$.line_items[' + format(J) + '].key_1';
                        Key2 := '$.line_items[' + format(J) + '].key_2';
                        Key3 := '$.line_items[' + format(J) + '].key_3';
                        Key4 := '$.line_items[' + format(J) + '].key_4';
                        Key5 := '$.line_items[' + format(J) + '].key_5';
                        Key6 := '$.line_items[' + format(J) + '].key_6';
                        Key7 := '$.line_items[' + format(J) + '].key_7';
                        Key8 := '$.line_items[' + format(J) + '].key_8';

                        if Evaluate(RecParsedDataLine.Quantity, SelectJsonToken(JsonObject, Key2).AsValue().AsText()) then begin
                            RecParsedDataLine."Entry No." := RecParsedData."Entry No.";
                            RecParsedDataLine."Line No." := FindLastLineNum(RecParsedData."Entry No.") + 10000;
                            if not SelectJsonToken(JsonObject, Key5).AsValue().IsNull then
                                RecParsedDataLine."Item No." := SelectJsonToken(JsonObject, Key5).AsValue().AsText();
                            if not SelectJsonToken(JsonObject, Key4).AsValue().IsNull then
                                RecParsedDataLine.Description := copystr(SelectJsonToken(JsonObject, Key4).AsValue().AsText(), 1, 50);
                            if not SelectJsonToken(JsonObject, Key3).AsValue().IsNull then
                                RecParsedDataLine."Unit Of Measure Code" := SelectJsonToken(JsonObject, Key3).AsValue().AsText();
                            if not SelectJsonToken(JsonObject, Key2).AsValue().IsNull then
                                Evaluate(RecParsedDataLine.Quantity, SelectJsonToken(JsonObject, Key2).AsValue().AsText());
                            RecParsedDataLine.Insert();
                        end;
                    end;
                end;
            end;
            if ParserID = 'nowiqizxbsuv' then begin //SPOTLESS
                RecParsedData.Reset();
                RecParsedData.SetRange("Document Parser ID", GetJsonToken(JsonObject, 'document_id').AsValue().AsText());
                if not RecParsedData.FindFirst() then begin
                    RecParsedData."Entry No." := 0;
                    // RecParsedData."Document Parser ID" := ParserID;
                    if not GetJsonToken(JsonObject, 'po_number').AsValue.IsNull then
                        RecParsedData."Order ID" := GetJsonToken(JsonObject, 'po_number').AsValue.AsText();
                    if not SelectJsonToken(JsonObject, '$.po_date.iso8601').AsValue().IsNull then
                        RecParsedData."Order Date" := SelectJsonToken(JsonObject, '$.po_date.iso8601').AsValue().AsDate()
                    else
                        RecParsedData."Order Date" := today;
                    RecParsedData."Order Time" := Time;
                    RecParsedData."Cust Order Received Date" := Today;
                    RecParsedData."Cust Order Received Time" := Time;
                    RecParsedData."Order Method" := RecParsedData."Order Method"::Email;
                    // ValidateCustomerDetails('20000', RecParsedData);
                    if not GetJsonToken(JsonObject, 'cust_no').AsValue().IsNull then
                        RecParsedData."Customer ID" := GetJsonToken(JsonObject, 'cust_no').AsValue().AsText()
                    else
                        RecParsedData."Customer ID" := 'SPOTLESS';

                    if not GetJsonToken(JsonObject, 'shiptoname').AsValue().IsNull then
                        RecParsedData."Ship-to Name" := GetJsonToken(JsonObject, 'shiptoname').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptoaddr').AsValue().IsNull then
                        RecParsedData."Ship-to Address" := GetJsonToken(JsonObject, 'shiptoaddr').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptocity').AsValue().IsNull then
                        RecParsedData."Ship-to City" := GetJsonToken(JsonObject, 'shiptocity').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptopostcode').AsValue().IsNull then
                        RecParsedData."Ship-to Post Code" := GetJsonToken(JsonObject, 'shiptopostcode').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptocountry').AsValue().IsNull then
                        RecParsedData."Ship-to Country/Region Code" := GetJsonToken(JsonObject, 'shiptocountry').AsValue().AsText();

                    if not SelectJsonToken(JsonObject, '$.email.email').AsValue().IsNull then
                        RecParsedData."Tracking Email" := SelectJsonToken(JsonObject, '$.email.email').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'teli').AsValue().IsNull then
                        RecParsedData."Telephone No." := SelectJsonToken(JsonObject, 'teli').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'deliveryinstructions').AsValue().IsNull then
                        RecParsedData."EDI Delivery Instructions" := GetJsonToken(JsonObject, 'deliveryinstructions').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'document_id').AsValue().IsNull then
                        RecParsedData."Document Parser ID" := GetJsonToken(JsonObject, 'document_id').AsValue().AsText();
                    RecParsedData."Document Parser Name" := 'SPOTLESS';
                    if not GetJsonToken(JsonObject, 'file_name').AsValue().IsNull then
                        RecParsedData."Import File Name" := GetJsonToken(JsonObject, 'file_name').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'uploaded_at').AsValue().IsNull then begin
                        RecParsedData."Email Date" := Variant2Date(GetJsonToken(JsonObject, 'uploaded_at').AsValue().AsDateTime());
                        RecParsedData."Email Time" := Variant2Time(GetJsonToken(JsonObject, 'uploaded_at').AsValue().AsDateTime());
                    end;
                    RecParsedData.Insert();
                    for J := 0 to LineCount - 1 do begin
                        Key0 := '$.line_items[' + format(J) + '].key_0';
                        Key1 := '$.line_items[' + format(J) + '].key_1';
                        Key2 := '$.line_items[' + format(J) + '].key_2';
                        Key3 := '$.line_items[' + format(J) + '].key_3';
                        Key4 := '$.line_items[' + format(J) + '].key_4';
                        Key5 := '$.line_items[' + format(J) + '].key_5';
                        Key6 := '$.line_items[' + format(J) + '].key_6';

                        if Evaluate(RecParsedDataLine.Quantity, SelectJsonToken(JsonObject, Key5).AsValue().AsText()) then begin
                            RecParsedDataLine."Entry No." := RecParsedData."Entry No.";
                            RecParsedDataLine."Line No." := FindLastLineNum(RecParsedData."Entry No.") + 10000;
                            if not SelectJsonToken(JsonObject, Key3).AsValue().IsNull then
                                RecParsedDataLine."Item No." := SelectJsonToken(JsonObject, Key3).AsValue().AsText();
                            if not SelectJsonToken(JsonObject, Key2).AsValue().IsNull then
                                RecParsedDataLine.Description := SelectJsonToken(JsonObject, Key2).AsValue().AsText();
                            if not SelectJsonToken(JsonObject, Key6).AsValue().IsNull then
                                RecParsedDataLine."Unit Of Measure Code" := SelectJsonToken(JsonObject, Key6).AsValue().AsText();
                            if not SelectJsonToken(JsonObject, Key5).AsValue().IsNull then
                                Evaluate(RecParsedDataLine.Quantity, SelectJsonToken(JsonObject, Key5).AsValue().AsText());
                            RecParsedDataLine.Insert();
                        end;
                    end;
                end;
            end;
            if ParserID = 'naxdgdqftynm' then begin //SODEXO
                RecParsedData.Reset();
                RecParsedData.SetRange("Document Parser ID", GetJsonToken(JsonObject, 'document_id').AsValue().AsText());
                if not RecParsedData.FindFirst() then begin
                    RecParsedData."Entry No." := 0;
                    RecParsedData."Document Parser ID" := ParserID;
                    if not GetJsonToken(JsonObject, 'po_number').AsValue.IsNull then
                        RecParsedData."Order ID" := GetJsonToken(JsonObject, 'po_number').AsValue.AsText();

                    RecParsedData."Order Method" := RecParsedData."Order Method"::Email;
                    RecParsedData."Order Date" := Today;
                    RecParsedData."Order Time" := Time;
                    RecParsedData."Cust Order Received Date" := Today;
                    RecParsedData."Cust Order Received Time" := Time;
                    if not GetJsonToken(JsonObject, 'po_number').AsValue.IsNull then
                        RecParsedData."Order ID" := GetJsonToken(JsonObject, 'po_number').AsValue.AsText();
                    RecParsedData."Order Method" := RecParsedData."Order Method"::Email;

                    if not GetJsonToken(JsonObject, 'customer_no').AsValue().IsNull then
                        RecParsedData."Customer ID" := GetJsonToken(JsonObject, 'customer_no').AsValue().AsText()
                    else
                        RecParsedData."Customer ID" := 'SODEXO';
                    if not GetJsonToken(JsonObject, 'orderdby').AsValue().IsNull then
                        RecParsedData."EDI Delivery Instructions" := GetJsonToken(JsonObject, 'orderdby').AsValue().AsText();

                    if not GetJsonToken(JsonObject, 'billtoname').AsValue().IsNull then
                        RecParsedData."Bill-to Name" := GetJsonToken(JsonObject, 'billtoname').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'billtoaddr').AsValue().IsNull then
                        RecParsedData."Bill-to Address" := GetJsonToken(JsonObject, 'billtoaddr').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'billtocity').AsValue().IsNull then
                        RecParsedData."Bill-to City" := GetJsonToken(JsonObject, 'billtocity').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'billtozip').AsValue().IsNull then
                        RecParsedData."Bill-to Post Code" := GetJsonToken(JsonObject, 'billtozip').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptoaddr').AsValue().IsNull then
                        RecParsedData."Ship-to Address" := GetJsonToken(JsonObject, 'shiptoaddr').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptostreet').AsValue().IsNull then
                        RecParsedData."Ship-to Street" := GetJsonToken(JsonObject, 'shiptostreet').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptocity').AsValue().IsNull then
                        RecParsedData."Ship-to City" := GetJsonToken(JsonObject, 'shiptocity').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptozip').AsValue().IsNull then
                        RecParsedData."Ship-to Post Code" := GetJsonToken(JsonObject, 'shiptozip').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'phonenum').AsValue().IsNull then
                        RecParsedData."Telephone No." := GetJsonToken(JsonObject, 'phonenum').AsValue().AsText();
                    if not SelectJsonToken(JsonObject, '$.requested_delivery_date.formatted').AsValue().IsNull then
                        Evaluate(RecParsedData."Expected Delivery Date", SelectJsonToken(JsonObject, '$.requested_delivery_date.formatted').AsValue().AsText());

                    if not GetJsonToken(JsonObject, 'document_id').AsValue().IsNull then
                        RecParsedData."Document Parser ID" := GetJsonToken(JsonObject, 'document_id').AsValue().AsText();
                    RecParsedData."Document Parser Name" := 'SODEXO';

                    // ValidateCustomerDetails('30000', RecParsedData);
                    if not GetJsonToken(JsonObject, 'file_name').AsValue().IsNull then
                        RecParsedData."Import File Name" := GetJsonToken(JsonObject, 'file_name').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'uploaded_at').AsValue().IsNull then begin
                        RecParsedData."Email Date" := Variant2Date(GetJsonToken(JsonObject, 'uploaded_at').AsValue().AsDateTime());
                        RecParsedData."Email Time" := Variant2Time(GetJsonToken(JsonObject, 'uploaded_at').AsValue().AsDateTime());
                    end;
                    RecParsedData.Insert();

                    for J := 0 to LineCount - 1 do begin
                        Key0 := '$.line_items[' + format(J) + '].key_0';
                        Key1 := '$.line_items[' + format(J) + '].key_1';
                        Key2 := '$.line_items[' + format(J) + '].key_2';
                        Key3 := '$.line_items[' + format(J) + '].key_3';
                        Key4 := '$.line_items[' + format(J) + '].key_4';
                        Key5 := '$.line_items[' + format(J) + '].key_5';
                        Key6 := '$.line_items[' + format(J) + '].key_6';

                        if Evaluate(RecParsedDataLine.Quantity, SelectJsonToken(JsonObject, Key3).AsValue().AsText()) then begin
                            RecParsedDataLine."Entry No." := RecParsedData."Entry No.";
                            RecParsedDataLine."Line No." := FindLastLineNum(RecParsedData."Entry No.") + 10000;
                            if not SelectJsonToken(JsonObject, Key0).AsValue().IsNull then
                                RecParsedDataLine."Item No." := SelectJsonToken(JsonObject, Key0).AsValue().AsText();
                            if not SelectJsonToken(JsonObject, Key1).AsValue().IsNull then
                                RecParsedDataLine.Description := SelectJsonToken(JsonObject, Key1).AsValue().AsText();
                            if not SelectJsonToken(JsonObject, Key2).AsValue().IsNull then
                                RecParsedDataLine."Unit Of Measure Code" := SelectJsonToken(JsonObject, Key2).AsValue().AsText();
                            if not SelectJsonToken(JsonObject, Key3).AsValue().IsNull then
                                Evaluate(RecParsedDataLine.Quantity, SelectJsonToken(JsonObject, Key3).AsValue().AsText());
                            RecParsedDataLine.Insert();
                        end;
                    end;
                end;
            end;
            if ParserID = 'nqxoyrdhlghj' then begin //ORDERIN
                RecParsedData.Reset();
                RecParsedData.SetRange("Document Parser ID", GetJsonToken(JsonObject, 'document_id').AsValue().AsText());
                if not RecParsedData.FindFirst() then begin
                    RecParsedData."Entry No." := 0;
                    RecParsedData."Document Parser ID" := ParserID;
                    if not GetJsonToken(JsonObject, 'po_number').AsValue.IsNull then
                        RecParsedData."Order ID" := GetJsonToken(JsonObject, 'po_number').AsValue.AsText();
                    RecParsedData."Order Method" := RecParsedData."Order Method"::Email;
                    RecParsedData."Order Date" := Today;
                    RecParsedData."Order Time" := Time;
                    RecParsedData."Cust Order Received Date" := Today;
                    RecParsedData."Cust Order Received Time" := Time;
                    RecParsedData."Customer ID" := 'ORDERIN';
                    // ValidateCustomerDetails('40000', RecParsedData);
                    if not GetJsonToken(JsonObject, 'shiptoname').AsValue().IsNull then
                        RecParsedData."Ship-to Name" := GetJsonToken(JsonObject, 'shiptoname').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptoaddr').AsValue.IsNull then
                        RecParsedData."Ship-to Address" := GetJsonToken(JsonObject, 'shiptoaddr').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'shiptocity').AsValue().IsNull then
                        RecParsedData."Ship-to City" := GetJsonToken(JsonObject, 'shiptocity').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'document_id').AsValue().IsNull then
                        RecParsedData."Document Parser ID" := GetJsonToken(JsonObject, 'document_id').AsValue().AsText();
                    RecParsedData."Document Parser Name" := 'ORDERIN';
                    if not GetJsonToken(JsonObject, 'file_name').AsValue().IsNull then
                        RecParsedData."Import File Name" := GetJsonToken(JsonObject, 'file_name').AsValue().AsText();
                    if not GetJsonToken(JsonObject, 'uploaded_at').AsValue().IsNull then begin
                        RecParsedData."Email Date" := Variant2Date(GetJsonToken(JsonObject, 'uploaded_at').AsValue().AsDateTime());
                        RecParsedData."Email Time" := Variant2Time(GetJsonToken(JsonObject, 'uploaded_at').AsValue().AsDateTime());
                    end;
                    RecParsedData.Insert();
                    for J := 0 to LineCount - 1 do begin
                        Key0 := '$.line_items[' + format(J) + '].key_0';
                        Key1 := '$.line_items[' + format(J) + '].key_1';
                        Key2 := '$.line_items[' + format(J) + '].key_2';
                        Key3 := '$.line_items[' + format(J) + '].key_3';
                        Key4 := '$.line_items[' + format(J) + '].key_4';
                        Key5 := '$.line_items[' + format(J) + '].key_5';
                        Key6 := '$.line_items[' + format(J) + '].key_6';

                        if Evaluate(RecParsedDataLine.Quantity, SelectJsonToken(JsonObject, Key1).AsValue().AsText()) then begin
                            RecParsedDataLine."Entry No." := RecParsedData."Entry No.";
                            RecParsedDataLine."Line No." := FindLastLineNum(RecParsedData."Entry No.") + 10000;
                            if not SelectJsonToken(JsonObject, Key3).AsValue().IsNull then
                                RecParsedDataLine."Item No." := SelectJsonToken(JsonObject, Key3).AsValue().AsText();
                            if not SelectJsonToken(JsonObject, Key2).AsValue().IsNull then
                                RecParsedDataLine.Description := SelectJsonToken(JsonObject, Key2).AsValue().AsText();
                            if not SelectJsonToken(JsonObject, Key6).AsValue().IsNull then
                                RecParsedDataLine."Unit Of Measure Code" := SelectJsonToken(JsonObject, Key6).AsValue().AsText();
                            if not SelectJsonToken(JsonObject, Key1).AsValue().IsNull then
                                Evaluate(RecParsedDataLine.Quantity, SelectJsonToken(JsonObject, Key1).AsValue().AsText());
                            RecParsedDataLine.Insert();
                        end;
                    end;
                end;
            end;
            /*
            if ParserID = 'iauyzflpxcbn' then begin  //YORDER
                RecParsedData.Reset();
                RecParsedData.SetRange("Document Parser ID", GetJsonToken(JsonObject, 'document_id').AsValue().AsText());
                if not RecParsedData.FindFirst() then begin
                    for J := 0 to LineCount do begin
                        Key0 := '$.line_items[' + format(J) + '].key_0';
                        Key1 := '$.line_items[' + format(J) + '].key_1';
                        Key2 := '$.line_items[' + format(J) + '].key_2';
                        Key3 := '$.line_items[' + format(J) + '].key_3';
                        Key4 := '$.line_items[' + format(J) + '].key_4';
                        Key5 := '$.line_items[' + format(J) + '].key_5';
                        Key6 := '$.line_items[' + format(J) + '].key_6';
                        if J = 0 then begin
                            RecParsedData."Entry No." := 0;
                            RecParsedData."Document Parser ID" := ParserID;
                            if not GetJsonToken(JsonObject, 'po_number').AsValue.IsNull then
                                RecParsedData."Order ID" := GetJsonToken(JsonObject, 'po_number').AsValue.AsText();
                            RecParsedData."Order Method" := RecParsedData."Order Method"::Email;
                            RecParsedData."Document Parser ID" := GetJsonToken(JsonObject, 'document_id').AsValue().AsText();
                            RecParsedData.Insert();
                        end;
                        RecParsedDataLine."Entry No." := RecParsedData."Entry No.";
                        RecParsedDataLine."Line No." := FindLastLineNum(RecParsedData."Entry No.") + 10000;
                        RecParsedDataLine."Item No." := SelectJsonToken(JsonObject, Key0).AsValue().AsText();
                        RecParsedDataLine.Description := SelectJsonToken(JsonObject, Key1).AsValue().AsText();
                        // RecParsedData."Item UOM" := SelectJsonToken(JsonObject, Key2).AsValue().AsText();
                        Evaluate(RecParsedDataLine.Quantity, SelectJsonToken(JsonObject, Key3).AsValue().AsText());
                        RecParsedDataLine.Insert();
                    end;
                end;
            end;
            */
        end;

    end;

    procedure CheckJsonToken(JsonObject: JsonObject; TokenKey: text): Boolean
    var
        JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            exit(true);

    end;

    procedure GetJsonToken(JsonObject: JsonObject; TokenKey: text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

    procedure SelectJsonToken(JsonObject: JsonObject; Path: text) JsonToken: JsonToken;
    begin
        if not JsonObject.SelectToken(Path, JsonToken) then
            Error('Could not find a token with path %1', Path);
    end;

    procedure FindLastLineNum(EntryNum: Integer): Integer
    var
        RecNxnLine: Record "NXN EDI Order Line";
    begin
        RecNxnLine.Reset();
        RecNxnLine.SetRange("Entry No.", EntryNum);
        if RecNxnLine.FindLast() then
            exit(RecNxnLine."Line No.")
        else
            exit(0);
    end;

    var
        NoLinesFound: Boolean;
        FailedToGetBlobErr: Label 'Failed to download a blob: ';
        UrlIncorrectErr: Label 'Url incorrect.';
        UTCDateTimeText: Text;
}