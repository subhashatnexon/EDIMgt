codeunit 60009 "NXN Start Doc Posting Process"
{

    trigger OnRun()
    begin
        GLSetup.GET;
        EDISetup.GET;

        ReasonCode.RESET;
        ReasonCode.SETRANGE("NXN Allow Auto Posting", TRUE);
        ReasonCodeFilterText := GetSelectionFilterForReasoncode(ReasonCode);

        WITH SalesHeader DO BEGIN
            RESET;
            SETRANGE("Document Type", "Document Type"::Order);
            SETRANGE(Status, Status::Released);
            SETFILTER("Posting Date", '..%1', WORKDATE);
            //SETFILTER("External Document No.", '<>%1', '');
            SETFILTER("NXN IC SRC Inv_Cr No.", '<>%1', '');
            IF ReasonCodeFilterText <> '' THEN
                SETFILTER("Reason Code", ReasonCodeFilterText);
            IF FINDSET THEN BEGIN
                REPEAT
                    Invoice := TRUE;
                    Ship := TRUE;
                    OnBeforeSalesOrderPosting(SalesHeader);
                    IF Cust.GET(SalesHeader."Bill-to Customer No.") then begin
                        IF Cust."NXN Cons. Inv." then begin
                            Invoice := false;
                        end;
                    end;
                    CLEARLASTERROR;
                    CLEAR(SalesPost);
                    IF SalesPost.RUN(SalesHeader) THEN BEGIN
                        CloseErrorLog(DocPostErrorLog."Posting Document Type"::"Sales Order", "No.");
                        COMMIT;
                    END ELSE BEGIN
                        InsertErrorLog(DocPostErrorLog."Posting Document Type"::"Sales Order", "No.", GETLASTERRORTEXT);
                        CLEARLASTERROR();
                    END;
                UNTIL NEXT = 0;
            END;
        END;

        WITH SalesHeader DO BEGIN
            RESET;
            SETRANGE("Document Type", "Document Type"::Invoice);
            SETRANGE(Status, Status::Released);
            SETFILTER("Posting Date", '..%1', WORKDATE);
            IF ReasonCodeFilterText <> '' THEN
                SETFILTER("Reason Code", ReasonCodeFilterText);
            IF FINDSET THEN BEGIN
                REPEAT
                    Ship := TRUE;
                    Invoice := TRUE;
                    CLEARLASTERROR;
                    CLEAR(SalesPost);
                    OnBeforeSalesInvoicePosting(SalesHeader);
                    IF SalesPost.RUN(SalesHeader) THEN BEGIN
                        CloseErrorLog(DocPostErrorLog."Posting Document Type"::"Sales Invoice", "No.");
                        COMMIT;
                    END ELSE BEGIN
                        InsertErrorLog(DocPostErrorLog."Posting Document Type"::"Sales Invoice", "No.", GETLASTERRORTEXT);
                        CLEARLASTERROR();
                    END;
                UNTIL NEXT = 0;
            END;
        END;

        WITH SalesHeader DO BEGIN
            RESET;
            SETRANGE("Document Type", "Document Type"::"Credit Memo");
            SETRANGE(Status, Status::Released);
            SETFILTER("Posting Date", '..%1', WORKDATE);
            IF ReasonCodeFilterText <> '' THEN
                SETFILTER("Reason Code", ReasonCodeFilterText);

            IF FINDSET THEN BEGIN
                REPEAT
                    Receive := TRUE;
                    Invoice := TRUE;
                    CLEARLASTERROR;
                    CLEAR(SalesPost);
                    IF SalesPost.RUN(SalesHeader) THEN BEGIN
                        CloseErrorLog(DocPostErrorLog."Posting Document Type"::"Sales Cr Memo", "No.");
                        COMMIT;
                    END ELSE BEGIN
                        InsertErrorLog(DocPostErrorLog."Posting Document Type"::"Sales Cr Memo", "No.", GETLASTERRORTEXT);
                        CLEARLASTERROR();
                    END;
                UNTIL NEXT = 0;
            END;
        END;

        WITH PurchHeader DO BEGIN
            RESET;
            SETRANGE("Document Type", "Document Type"::Order);
            SETRANGE(Status, Status::Released);
            SETFILTER("Posting Date", '..%1', WORKDATE);
            //SETFILTER("Vendor Invoice No.", '<>%1', '');
            SETFILTER("NXN IC SRC Inv_Cr No.", '<>%1', '');
            IF ReasonCodeFilterText <> '' THEN
                SETFILTER("Reason Code", ReasonCodeFilterText);
            IF FINDSET THEN BEGIN
                REPEAT
                    Receive := TRUE;
                    Invoice := TRUE;
                    OnBeforePurchaseOrderPosting(PurchHeader);
                    CLEARLASTERROR;
                    CLEAR(PurchPost);
                    IF PurchPost.RUN(PurchHeader) THEN BEGIN
                        CloseErrorLog(DocPostErrorLog."Posting Document Type"::"Purchase Order", "No.");
                        COMMIT;
                    END ELSE BEGIN
                        InsertErrorLog(DocPostErrorLog."Posting Document Type"::"Purchase Order", "No.", GETLASTERRORTEXT);
                        CLEARLASTERROR();
                    END;
                UNTIL NEXT = 0;
            END;
        END;

        WITH PurchHeader DO BEGIN
            RESET;
            SETRANGE("Document Type", "Document Type"::Invoice);
            SETRANGE(Status, Status::Released);
            SETFILTER("Posting Date", '..%1', WORKDATE);
            IF ReasonCodeFilterText <> '' THEN
                SETFILTER("Reason Code", ReasonCodeFilterText);
            IF FINDSET THEN BEGIN
                REPEAT
                    Receive := TRUE;
                    Invoice := TRUE;
                    CLEARLASTERROR;
                    OnBeforePurchaseInvoicePosting(PurchHeader);
                    CLEAR(PurchPost);
                    IF PurchPost.RUN(PurchHeader) THEN BEGIN
                        CloseErrorLog(DocPostErrorLog."Posting Document Type"::"Purchase Invoice", "No.");
                        COMMIT;
                    END ELSE BEGIN
                        InsertErrorLog(DocPostErrorLog."Posting Document Type"::"Purchase Invoice", "No.", GETLASTERRORTEXT);
                        CLEARLASTERROR();
                    END;
                UNTIL NEXT = 0;
            END;
        END;

        WITH PurchHeader DO BEGIN
            RESET;
            SETRANGE("Document Type", "Document Type"::"Credit Memo");
            SETRANGE(Status, Status::Released);
            SETFILTER("Posting Date", '..%1', WORKDATE);
            IF ReasonCodeFilterText <> '' THEN
                SETFILTER("Reason Code", ReasonCodeFilterText);
            IF FINDSET THEN BEGIN
                REPEAT
                    Ship := TRUE;
                    Invoice := TRUE;
                    CLEARLASTERROR;
                    CLEAR(PurchPost);
                    IF PurchPost.RUN(PurchHeader) THEN BEGIN
                        CloseErrorLog(DocPostErrorLog."Posting Document Type"::"Purchase Cr Memo", "No.");
                        COMMIT;
                    END ELSE BEGIN
                        InsertErrorLog(DocPostErrorLog."Posting Document Type"::"Purchase Cr Memo", "No.", GETLASTERRORTEXT);
                        CLEARLASTERROR();
                    END;
                UNTIL NEXT = 0;
            END;
        END;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        Cust: Record Customer;
        GenJnlLine: Record "Gen. Journal Line";
        EDISetup: Record "NXN EDI Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        ReasonCode: Record "Reason Code";
        BatchPostSalesInv: Report "Batch Post Sales Invoices";
        BatchPostSalesCrMemo: Report "Batch Post Sales Credit Memos";
        BatchPostPurchInv: Report "Batch Post Purchase Invoices";
        BatchPostPurchCrMemo: Report "Batch Post Purch. Credit Memos";
        DocPostErrorLog: Record "NXN Doc. Posting Error Log";
        SalesPost: Codeunit "Sales-Post";
        PurchPost: Codeunit "Purch.-Post";
        docno: Code[20];
        ReasonCodeFilterText: Text[1024];

    procedure GetSelectionFilterForReasoncode(VAR ReasonCode: Record "Reason Code"): Text
    var
        RecRef: RecordRef;
    begin
        RecRef.GETTABLE(ReasonCode);
        EXIT(GetSelectionFilter(RecRef, ReasonCode.FIELDNO(Code)));
    end;

    procedure GetSelectionFilter(VAR TempRecRef: RecordRef; SelectionFieldID: Integer): Text
    var
        RecRef: RecordRef;
        TempRecRefCount: Integer;
        FieldRef: FieldRef;
        FirstRecRef: Text;
        LastRecRef: Text;
        SelectionFilter: Text;
        SavePos: text;
        more: Boolean;
    begin
        IF TempRecRef.ISTEMPORARY THEN BEGIN
            RecRef := TempRecRef.DUPLICATE;
            RecRef.RESET;
        END ELSE
            RecRef.OPEN(TempRecRef.NUMBER);

        TempRecRefCount := TempRecRef.COUNT;
        IF TempRecRefCount > 0 THEN BEGIN
            TempRecRef.ASCENDING(TRUE);
            TempRecRef.FIND('-');
            WHILE TempRecRefCount > 0 DO BEGIN
                TempRecRefCount := TempRecRefCount - 1;
                RecRef.SETPOSITION(TempRecRef.GETPOSITION);
                RecRef.FIND;
                FieldRef := RecRef.FIELD(SelectionFieldID);
                FirstRecRef := FORMAT(FieldRef.VALUE);
                LastRecRef := FirstRecRef;
                More := TempRecRefCount > 0;
                WHILE More DO
                    IF RecRef.NEXT = 0 THEN
                        More := FALSE
                    ELSE BEGIN
                        SavePos := TempRecRef.GETPOSITION;
                        TempRecRef.SETPOSITION(RecRef.GETPOSITION);
                        IF NOT TempRecRef.FIND THEN BEGIN
                            More := FALSE;
                            TempRecRef.SETPOSITION(SavePos);
                        END ELSE BEGIN
                            FieldRef := RecRef.FIELD(SelectionFieldID);
                            LastRecRef := FORMAT(FieldRef.VALUE);
                            TempRecRefCount := TempRecRefCount - 1;
                            IF TempRecRefCount = 0 THEN
                                More := FALSE;
                        END;
                    END;
                IF SelectionFilter <> '' THEN
                    SelectionFilter := SelectionFilter + '|';
                IF FirstRecRef = LastRecRef THEN
                    SelectionFilter := SelectionFilter + AddQuotes(FirstRecRef)
                ELSE
                    SelectionFilter := SelectionFilter + AddQuotes(FirstRecRef) + '..' + AddQuotes(LastRecRef);
                IF TempRecRefCount > 0 THEN
                    TempRecRef.NEXT;
            END;
            EXIT(SelectionFilter);
        END;
    end;

    Procedure AddQuotes(inString: Text[1024]): Text
    var
    begin
        IF DELCHR(inString, '=', ' &|()*') = inString THEN
            EXIT(inString);
        EXIT('''' + inString + '''');
    end;

    procedure InsertErrorLog(pPostDocType: Option " ","Sales Order","Purchase Order","Sales Cr Memo","Purchase Cr Memo","Sales Invoice","Purchase Invoice"; pDocNo: Code[20]; pErrorDescription: Text[1024])
    var
        CounterValue: Integer;
    begin
        CounterValue := 0;

        //Close Previous Open Error Logs
        WITH DocPostErrorLog DO BEGIN
            RESET;
            SETRANGE("Posting Document Type", pPostDocType);
            SETRANGE("Document No.", pDocNo);
            SETRANGE(Closed, FALSE);
            IF FINDLAST THEN BEGIN
                Closed := TRUE;
                MODIFY();
                CounterValue := "Retry Counter" + 1;
            END;
        END;

        //Insert Error Log
        WITH DocPostErrorLog DO BEGIN
            RESET;
            INIT;
            "Entry No." := GetLastEntryNo();
            "Posting Document Type" := pPostDocType;
            "Document No." := pDocNo;
            "Error Description" := COPYSTR(pErrorDescription, 1, 250);
            "Error Description 2" := COPYSTR(pErrorDescription, 251, 250);
            "Execution Timestamp" := CURRENTDATETIME;
            "Retry Counter" := CounterValue;
            Closed := FALSE;
            INSERT();
            IF ("Retry Counter" = 0) AND (EDISetup."Email Error Logs") THEN
                CreateMsgLog('Document Posting Error: ' + FORMAT(pPostDocType) + ' ' + pDocNo, "Error Description", EDISetup."Email Address Error Logs", FORMAT(pPostDocType), pDocNo);
            COMMIT;
        END;
    end;

    procedure GetLastEntryNo(): Integer
    var
        DocCreationErrLog: Record "NXN Doc. Creation Error Log";
        EntryNo: Integer;
    begin
        WITH DocPostErrorLog DO BEGIN
            RESET;
            IF FINDLAST THEN
                EntryNo := "Entry No." + 1
            ELSE
                EntryNo := 1;
        END;
        EXIT(EntryNo);
    end;

    procedure CloseErrorLog(pPostDocType: Option " ","Sales Order","Purchase Order","Sales Cr Memo","Purchase Cr Memo","Sales Invoice","Purchase Invoice"; pDocNo: Code[20])
    begin
        WITH DocPostErrorLog DO BEGIN
            RESET;
            SETRANGE("Posting Document Type", pPostDocType);
            SETRANGE("Document No.", pDocNo);
            SETRANGE(Closed, FALSE);
            IF FINDSET(TRUE, FALSE) THEN
                REPEAT
                    Closed := TRUE;
                    MODIFY;
                UNTIL DocPostErrorLog.NEXT = 0;
        END;
    end;

    procedure PostJournal(TemplateName: Code[20]; BatchName: Code[20]; DocumentType: Option)
    var
        GenJnlPost: Codeunit "Gen. Jnl.-Post";
    begin
        //Not used
        GenJnlLine.RESET;
        GenJnlLine.SETRANGE("Journal Template Name", TemplateName);
        GenJnlLine.SETRANGE("Journal Batch Name", BatchName);
        GenJnlLine.SETFILTER(Amount, '<>%1', 0);
        IF GenJnlLine.FINDFIRST THEN BEGIN
            //GenJnlPost.AutoPostGenJnl(TRUE);
            docno := GenJnlLine."Document No.";
            IF GenJnlPost.RUN(GenJnlLine) THEN
                CloseErrorLogJournal(TemplateName, BatchName)
            ELSE BEGIN
                CloseErrorLogJournal(TemplateName, BatchName);
                InsertErrorLogJournal(GETLASTERRORTEXT, DocumentType);
                CLEARLASTERROR;
            END;
        END;
    end;

    procedure InsertErrorLogJournal(LastErrorText: Text[1024]; DocType: Option)
    var
        lvDocPostErrorLog: Record "NXN Doc. Posting Error Log";
        EntryNo: Integer;
    begin
        //Not used
        WITH lvDocPostErrorLog DO BEGIN
            RESET;
            IF FINDLAST THEN
                EntryNo := "Entry No." + 1
            ELSE
                EntryNo := 1;

            INIT;
            "Entry No." := EntryNo;
            "Posting Document Type" := DocType;
            "Document No." := GenJnlLine."Document No.";
            "Template Name" := GenJnlLine."Journal Template Name";
            "Batch Name" := GenJnlLine."Journal Batch Name";
            "Execution Timestamp" := CURRENTDATETIME;
            "Error Description" := COPYSTR(LastErrorText, 1, 250);
            INSERT;
        END;
        COMMIT;
    end;

    procedure CloseErrorLogJournal(TemplateName: Code[20]; BatchName: Code[20])
    var
        lvDocPostErrorLog: Record "NXN Doc. Posting Error Log";
    begin
        //Not used
        lvDocPostErrorLog.RESET;
        lvDocPostErrorLog.SETRANGE("Template Name", TemplateName);
        lvDocPostErrorLog.SETRANGE("Batch Name", BatchName);
        IF lvDocPostErrorLog.FINDFIRST THEN
            REPEAT
                lvDocPostErrorLog.Closed := TRUE;
                lvDocPostErrorLog.MODIFY;
            UNTIL lvDocPostErrorLog.NEXT = 0;
    end;

    procedure CreateMsgLog(EmailSubject: Text[250]; EmailBody: Text[250]; EmailTo: Text[250]; SourceType: Code[50]; SourceNo: Code[100])
    var
        MessageLog: Record "NXN E-Mail Queue";
    begin
        MessageLog.RESET;
        MessageLog.INIT;
        MessageLog."Subject Line" := EmailSubject;
        MessageLog."Body Line" := EmailBody;
        MessageLog."To Address" := EmailTo;
        MessageLog."Source Type" := SourceType;
        MessageLog."Source No." := SourceNo;
        MessageLog."Logging DateTime" := CURRENTDATETIME;
        MessageLog.INSERT(TRUE);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesOrderPosting(var SalesHdr: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSalesInvoicePosting(var SalesHdr: Record "Sales Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePurchaseOrderPosting(var PurchHdr: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePurchaseInvoicePosting(var PurchHdr: Record "Purchase Header")
    begin
    end;
}

