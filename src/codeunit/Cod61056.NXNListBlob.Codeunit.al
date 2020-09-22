codeunit 61056 "NXN List Azure Blob"
{
    procedure ListBlob(AccountName: Text; AccountContainer: Text; AccountAccessKey: Text; Marker: Text) Xml: XmlDocument
    var
        HMACSHA256Mgt: Codeunit "NXN Azure Blob Mgt.";
        WebRequest: HttpRequestMessage;
        WebResponse: HttpResponseMessage;
        WebContent: HttpContent;
        WebHeaders: HttpHeaders;
        WebClient: HttpClient;
        InStr: InStream;
        CanonicalizedHeaders: Text;
        CanonicalizedResource: Text;
        Authorization: Text;
        ResponseXml: Text;
        lXmlDocument: XmlDocument;
        lPersonXmlNode: XmlNode;
        lText: Text;
        lXmlNode: XMLNode;
        lXmlNodeList: XMLNodeList;
        I: Integer;
        BlobList: Record "NXN BlobList";
    begin
        Initialize(AccountName);

        CanonicalizedHeaders := 'x-ms-date:' + UTCDateTimeText + NewLine + 'x-ms-version:2015-02-21';
        CanonicalizedResource := StrSubstNo('/%1/%2', AccountName, AccountContainer) + NewLine + 'comp:list' + NewLine + 'marker:' + Marker + NewLine + 'restype:container';
        Authorization := HMACSHA256Mgt.GetAuthorization(AccountName, AccountAccessKey, HMACSHA256Mgt.GetTextToHash('GET', '', CanonicalizedHeaders, CanonicalizedResource, ''));

        WebRequest.SetRequestUri(StorageAccountUrl + AccountContainer + StrSubstNo('?restype=container&comp=list&marker=%1', Marker));
        WebRequest.Method('GET');
        WebRequest.GetHeaders(WebHeaders);
        WebHeaders.Add('Authorization', Authorization);
        WebHeaders.Add('x-ms-date', UTCDateTimeText);
        WebHeaders.Add('x-ms-version', '2015-02-21');
        WebClient.Send(WebRequest, WebResponse);
        if not WebResponse.IsSuccessStatusCode then
            error(FailedToGetBlobErr + WebResponse.ReasonPhrase);
        WebContent := WebResponse.Content;
        CreateResponseStream(InStr);
        WebContent.ReadAs(ResponseXml);
        XmlDocument.ReadFrom(ResponseXml, Xml);

        ClearBlobList();
        I := 1;
        IF Xml.SelectNodes('//Blobs/Blob', lXmlNodeList) then begin
            If lXmlNodeList.Count > 0 then begin
                foreach lPersonXmlNode in lXmlNodeList do begin
                    IF lPersonXmlNode.SelectSingleNode('Name', lXmlNode) then begin
                        BlobList.Init();
                        BlobList.entrynumber := I;
                        BlobList.FileName := DELCHR(lXmlNode.AsXmlElement.InnerText, '=', ' ');
                        BlobList.NXNUserID := UserId;
                        BlobList."NXN Company Name" := CompanyName;
                        BlobList.Insert();
                    end;
                    I := I + 1;
                END;
                Commit();
            END;
        END;
    end;

    local procedure ClearBlobList()
    var
        Bloblist: Record "NXN BlobList";
    begin
        Bloblist.Reset();
        Bloblist.SetRange(NXNUserID, UserId);
        Bloblist.SetRange("NXN Company Name", CompanyName);
        if Bloblist.FindSet() then
            Bloblist.DeleteAll();
    end;

    local procedure CreateResponseStream(var InStr: Instream)
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob.CreateInStream(InStr);
    end;

    local procedure Initialize(AccountName: Text)
    var
        UTCDateTimeMgt: Codeunit "NXN Blob UTC DateTime Mgt.";
    begin
        NewLine[1] := 10;
        UTCDateTimeText := UTCDateTimeMgt.GetUTCDateTimeText();
        StorageAccountUrl := 'https://' + AccountName + '.blob.core.windows.net/';
    end;

    var
        FailedToGetBlobErr: Label 'Failed to download a blob: ';
        UrlIncorrectErr: Label 'Url incorrect.';
        UTCDateTimeText: Text;
        StorageAccountUrl: Text;
        NewLine: Text[1];
}