codeunit 60002 "NXN Init Doc Creation Process"
{

    trigger OnRun()
    begin
    end;

    var
        DocCreationErrorLog: Record "NXN Doc. Creation Error Log";
        EDISetup: Record "NXN EDI Setup";
        ExecOrderCreationProcess: Codeunit "NXN Exe. Ord. Creation Process";
        //ExecOrderUpdationProcess: Codeunit "50004";
        //ExecReceiptJVProcess: Codeunit "50005";
        //ExecCrMemoCreateProcess: Codeunit "50006";
        //ExecRebatePIProcess: Codeunit "50007";
        //ExecReasonCodeProcess: Codeunit "50008";
        //ExecCentralInvJVProcess: Codeunit "50053";
        OldErrDesc: Text;
        CreateMsgQue: Boolean;
        CreditLimitAmt: Decimal;
        CreditLimitPmtPlanAmt: Decimal;
        CreditLimitErr: Label 'This is to inform you that your Account is put On-Hold. Your Account No.-%1, Credit Limit-%2, Payment Plan-%3, Current Balance-%4, Open Sales Amout -%5, Current Order Amount- %6.';
        BlockCustomer: Boolean;
        Cust: Record Customer;


    /// <summary> 
    /// Description for InitOrderCreationBatch.
    /// </summary>
    /// <param name="EDIOrderHeader">Parameter of type Record "NXN EDI Order Header".</param>
    procedure InitOrderCreationBatch(var EDIOrderHeader: Record "NXN EDI Order Header")
    var
        EDIOrderHeader2: Record "NXN EDI Order Header";
        EntryNo: Integer;
        OrderID: Code[20];
        TableName: Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code","EDI Central Invoicing";
        BatchProcessName: Code[20];
        UniqueOrderID: Code[50];
    begin
        EDIOrderHeader2.COPY(EDIOrderHeader);
        IF EDIOrderHeader2.FINDSET THEN BEGIN
            IF ExecOrderCreationProcess.RUN(EDIOrderHeader2) THEN BEGIN
                ExecOrderCreationProcess.GetEntryNo(EntryNo);
                CloseErrorLog(EntryNo, DocCreationErrorLog."Table Name"::"EDI Order");
                COMMIT;
            END ELSE BEGIN
                ExecOrderCreationProcess.GetBatchName(BatchProcessName);
                ExecOrderCreationProcess.GetEntryNo(EntryNo);
                ExecOrderCreationProcess.GetOrderID(OrderID);
                ExecOrderCreationProcess.GetUniqueOrderID(UniqueOrderID);  //HBSTG CW 2013-09-11
                EDIOrderHeader2.MODIFYALL("Doc Process Status", EDIOrderHeader2."Doc Process Status"::"Document Error");
                InsertErrorLog(TableName::"EDI Order", BatchProcessName, EntryNo, UniqueOrderID, GETLASTERRORTEXT);  //HBSTG CW 2013-09-11
                CLEARLASTERROR();
            END;
        END;
        EDIOrderHeader := EDIOrderHeader2;
    end;


    // procedure InitOrderUpdationBatch(var EDIInvoiceHeader: Record "50005")
    // var
    //     EDIInvoiceHeader2: Record "50005";
    //     EntryNo: Integer;
    //     OrderID: Code[20];
    //     InvoiceID: Code[35];
    //     TableName: Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code","EDI Central Invoicing";
    //     BatchProcessName: Code[20];
    // begin
    //     EDIInvoiceHeader2.COPY(EDIInvoiceHeader);
    //     IF EDIInvoiceHeader2.FINDSET THEN BEGIN
    //         IF ExecOrderUpdationProcess.RUN(EDIInvoiceHeader2) THEN BEGIN
    //             ExecOrderUpdationProcess.GetEntryNo(EntryNo);
    //             CloseErrorLog(EntryNo, DocCreationErrorLog."Table Name"::"EDI Invoice");
    //             COMMIT;
    //         END ELSE BEGIN
    //             ExecOrderUpdationProcess.GetBatchName(BatchProcessName);
    //             ExecOrderUpdationProcess.GetEntryNo(EntryNo);
    //             ExecOrderUpdationProcess.GetOrderID(OrderID);
    //             ExecOrderUpdationProcess.GetInvoiceID(InvoiceID);
    //             EDIInvoiceHeader2.MODIFYALL("Doc Process Status", EDIInvoiceHeader2."Doc Process Status"::"Document Error");
    //             InsertErrorLog(TableName::"EDI Invoice", BatchProcessName, EntryNo, InvoiceID, GETLASTERRORTEXT);
    //             CLEARLASTERROR();
    //         END;
    //     END;
    //     EDIInvoiceHeader := EDIInvoiceHeader2;
    // end;


    // procedure InitPaymentBatch(var EDIPaymentLine: Record "50007")
    // var
    //     EDIPaymentLine2: Record "50007";
    //     TableName: Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code","EDI Central Invoicing";
    //     BatchProcessName: Code[20];
    //     EntryNo: Integer;
    //     InvoiceID: Code[35];
    // begin
    //     EDIPaymentLine2.COPY(EDIPaymentLine);
    //     IF EDIPaymentLine2.FINDSET THEN BEGIN
    //         IF ExecReceiptJVProcess.RUN(EDIPaymentLine2) THEN BEGIN
    //             ExecReceiptJVProcess.GetEntryNo(EntryNo);
    //             CloseErrorLog(EntryNo, DocCreationErrorLog."Table Name"::"EDI Payment");
    //             COMMIT;
    //         END ELSE BEGIN
    //             ExecReceiptJVProcess.GetBatchName(BatchProcessName);
    //             ExecReceiptJVProcess.GetEntryNo(EntryNo);
    //             ExecReceiptJVProcess.GetInvoiceID(InvoiceID);
    //             EDIPaymentLine2.MODIFYALL("Doc Process Status", EDIPaymentLine2."Doc Process Status"::"Document Error");
    //             InsertErrorLog(TableName::"EDI Payment", BatchProcessName, EntryNo, InvoiceID, GETLASTERRORTEXT);
    //             CLEARLASTERROR();
    //         END;
    //     END;

    //     EDIPaymentLine := EDIPaymentLine2;
    // end;


    // procedure InitCrMemoCreationBatch(var EDICrMemoLine: Record "50008")
    // var
    //     EDICrMemoLine2: Record "50008";
    //     EntryNo: Integer;
    //     CrMemoID: Code[35];
    //     InvoiceID: Code[35];
    //     TableName: Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code","EDI Central Invoicing";
    //     BatchProcessName: Code[20];
    // begin
    //     EDICrMemoLine2.COPY(EDICrMemoLine);
    //     IF EDICrMemoLine2.FINDSET THEN BEGIN
    //         IF ExecCrMemoCreateProcess.RUN(EDICrMemoLine2) THEN BEGIN
    //             ExecCrMemoCreateProcess.GetEntryNo(EntryNo);
    //             CloseErrorLog(EntryNo, DocCreationErrorLog."Table Name"::"EDI Cr Memo");
    //             COMMIT;
    //         END ELSE BEGIN
    //             ExecCrMemoCreateProcess.GetBatchName(BatchProcessName);
    //             ExecCrMemoCreateProcess.GetEntryNo(EntryNo);
    //             ExecCrMemoCreateProcess.GetCrMemoID(CrMemoID);
    //             ExecCrMemoCreateProcess.GetInvoiceID(InvoiceID);
    //             EDICrMemoLine2.MODIFYALL("Doc Process Status", EDICrMemoLine2."Doc Process Status"::"Document Error");
    //             InsertErrorLog(TableName::"EDI Cr Memo", BatchProcessName, EntryNo, CrMemoID, GETLASTERRORTEXT);
    //             CLEARLASTERROR();
    //         END;
    //     END;
    //     EDICrMemoLine := EDICrMemoLine2;
    // end;


    // procedure InitRebatePICreationBatch(var EDIRebateLine: Record "50009")
    // var
    //     EDIRebateLine2: Record "50009";
    //     EntryNo: Integer;
    //     RebateRefID: Code[20];
    //     InvoiceID: Code[35];
    //     TableName: Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code","EDI Central Invoicing";
    //     BatchProcessName: Code[20];
    //     CustID: Code[20];
    // begin
    //     EDIRebateLine2.COPY(EDIRebateLine);
    //     IF EDIRebateLine2.FINDSET THEN BEGIN
    //         IF ExecRebatePIProcess.RUN(EDIRebateLine2) THEN BEGIN
    //             ExecRebatePIProcess.GetEntryNo(EntryNo);
    //             CloseErrorLog(EntryNo, DocCreationErrorLog."Table Name"::"EDI Rebate PI");
    //             COMMIT;
    //         END ELSE BEGIN
    //             ExecRebatePIProcess.GetBatchName(BatchProcessName);
    //             ExecRebatePIProcess.GetEntryNo(EntryNo);
    //             //ExecRebatePIProcess.GetRebateRefID(RebateRefID);
    //             ExecRebatePIProcess.GetCustID(CustID);
    //             ExecRebatePIProcess.GetInvoiceID(InvoiceID);
    //             EDIRebateLine2.MODIFYALL("Doc Process Status", EDIRebateLine2."Doc Process Status"::"Document Error");
    //             //InsertErrorLog(TableName::"EDI Rebate PI",BatchProcessName,EntryNo,RebateRefID,GETLASTERRORTEXT);
    //             InsertErrorLog(TableName::"EDI Rebate PI", BatchProcessName, EntryNo, CustID, GETLASTERRORTEXT);
    //             CLEARLASTERROR();
    //         END;
    //     END;
    //     EDIRebateLine := EDIRebateLine2;
    // end;


    // procedure InitReasonCodeUpdationBatch(var EDIReasonCodeLine: Record "50010")
    // var
    //     EDIReasonCodeLine2: Record "50010";
    //     EntryNo: Integer;
    //     CustRefID: Code[20];
    //     InvoiceID: Code[35];
    //     TableName: Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code","EDI Central Invoicing";
    //     BatchProcessName: Code[20];
    // begin
    //     EDIReasonCodeLine2.COPY(EDIReasonCodeLine);
    //     IF EDIReasonCodeLine2.FINDSET THEN BEGIN
    //         IF ExecReasonCodeProcess.RUN(EDIReasonCodeLine2) THEN BEGIN
    //             ExecReasonCodeProcess.GetEntryNo(EntryNo);
    //             CloseErrorLog(EntryNo, DocCreationErrorLog."Table Name"::"EDI Reason Code");
    //             COMMIT;
    //         END ELSE BEGIN
    //             ExecReasonCodeProcess.GetBatchName(BatchProcessName);
    //             ExecReasonCodeProcess.GetEntryNo(EntryNo);
    //             ExecReasonCodeProcess.GetCustRefID(CustRefID);
    //             ExecReasonCodeProcess.GetInvoiceID(InvoiceID);
    //             EDIReasonCodeLine2.MODIFYALL("Doc Process Status", EDIReasonCodeLine2."Doc Process Status"::"Document Error");
    //             InsertErrorLog(TableName::"EDI Reason Code", BatchProcessName, EntryNo, InvoiceID, GETLASTERRORTEXT);
    //             CLEARLASTERROR();
    //         END;
    //     END;
    //     EDIReasonCodeLine := EDIReasonCodeLine2;
    // end;


    // procedure InitCentralInvBatch(var EDICentralInvLine: Record "50053")
    // var
    //     EDICentralInvLine2: Record "50053";
    //     TableName: Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code","EDI Central Invoicing";
    //     BatchProcessName: Code[20];
    //     EntryNo: Integer;
    //     InvoiceID: Code[35];
    // begin
    //     EDICentralInvLine2.COPY(EDICentralInvLine);
    //     IF EDICentralInvLine2.FINDSET THEN BEGIN
    //         IF ExecCentralInvJVProcess.RUN(EDICentralInvLine2) THEN BEGIN
    //             ExecCentralInvJVProcess.GetEntryNo(EntryNo);
    //             CloseErrorLog(EntryNo, DocCreationErrorLog."Table Name"::"EDI Central Invoicing");
    //             COMMIT;
    //         END ELSE BEGIN
    //             ExecCentralInvJVProcess.GetBatchName(BatchProcessName);
    //             ExecCentralInvJVProcess.GetEntryNo(EntryNo);
    //             ExecCentralInvJVProcess.GetInvoiceID(InvoiceID);
    //             EDICentralInvLine2.MODIFYALL("Doc Process Status", EDICentralInvLine2."Doc Process Status"::"Document Error");
    //             InsertErrorLog(TableName::"EDI Central Invoicing", BatchProcessName, EntryNo, InvoiceID, GETLASTERRORTEXT);
    //             CLEARLASTERROR();
    //         END;
    //     END;

    //     EDICentralInvLine := EDICentralInvLine2;
    // end;


    /// <summary> 
    /// Description for InsertErrorLog.
    /// </summary>
    /// <param name="pTableName">Parameter of type Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code","EDI Central Invoicing".</param>
    /// <param name="pBatchProcessName">Parameter of type Code[20].</param>
    /// <param name="pEntryNo">Parameter of type Integer.</param>
    /// <param name="pDocNo">Parameter of type Code[50].</param>
    /// <param name="pErrorDescription">Parameter of type Text[1024].</param>
    procedure InsertErrorLog(pTableName: Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code","EDI Central Invoicing"; pBatchProcessName: Code[20]; pEntryNo: Integer; pDocNo: Code[50]; pErrorDescription: Text[1024])
    var
        CounterValue: Integer;
        InsertErrorLog: Boolean;
    begin
        CounterValue := 0;
        OldErrDesc := '';
        InsertErrorLog := TRUE;                                                                            //#11694
        //Close Previous Error Log having Status "Document Error"
        WITH DocCreationErrorLog DO BEGIN
            RESET;
            SETRANGE("Table Name", pTableName);
            //SETRANGE("Reference No.", pDocNo);
            SETRANGE("Table Entry No", pEntryNo);
            SETRANGE(Status, Status::"Document Error");
            SETRANGE(Closed, FALSE);
            IF FINDLAST THEN BEGIN
                IF "Error Description" <> pErrorDescription THEN BEGIN
                    Closed := TRUE;
                    CounterValue := 0;
                    MODIFY();
                END ELSE BEGIN
                    InsertErrorLog := FALSE;
                    "Retry Counter" := "Retry Counter" + 1;
                    "Execution Timestamp" := CURRENTDATETIME;
                    MODIFY();
                END;
                OldErrDesc := "Error Description";
            END;
        END;

        //Insert Error Log with Status "Document Error"
        IF InsertErrorLog THEN BEGIN                                                                       //#11694
            WITH DocCreationErrorLog DO BEGIN
                RESET;
                INIT;
                "Entry No." := GetLastEntryNo();
                "Table Entry No" := pEntryNo;
                TESTFIELD("Table Entry No");
                "Reference No." := pDocNo;
                "Table Name" := pTableName;
                CASE TRUE OF
                    pBatchProcessName = 'ORDER':
                        "Document Type" := "Document Type"::"EDI Order";
                    pBatchProcessName = 'INVOICE':
                        "Document Type" := "Document Type"::"EDI Invoice";
                    pBatchProcessName = 'PAYMENT':
                        "Document Type" := "Document Type"::"EDI Payment";
                    pBatchProcessName = 'CREDITMEMO':
                        "Document Type" := "Document Type"::"EDI Cr Memo";
                    pBatchProcessName = 'REBATE-PI':
                        "Document Type" := "Document Type"::"EDI Rebate PI";
                    pBatchProcessName = 'REASONCODE':
                        "Document Type" := "Document Type"::"EDI Reason Code";
                    pBatchProcessName = 'CENTRALINVOICE':
                        "Document Type" := "Document Type"::"EDI Central Invoicing";
                END;
                VALIDATE(Status, Status::"Document Error");
                "Error Description" := COPYSTR(pErrorDescription, 1, 250);
                "Error Description 2" := COPYSTR(pErrorDescription, 251, 250);
                "Execution Timestamp" := CURRENTDATETIME;
                "Initial Execution Timestamp" := CURRENTDATETIME;                                              //#11694
                //"Retry Counter" := CounterValue;
                INSERT();
                //HBSTG  2015-04-30: Start >>
                EDISetup.GET();
                //IF (("Retry Counter" = 0) OR ("Error Description" <> OldErrDesc)) AND (EDISetup."Email Error Logs") THEN BEGIN    //#11694
                IF EDISetup."Email Error Logs" THEN BEGIN
                    CreateMsgLog('Document Creation Error: ' + pBatchProcessName + ' ' + pDocNo, "Error Description", EDISetup."Email Address Error Logs", '', '', 'EDI ' + pBatchProcessName, pDocNo); //HBSTG  2015-08-14
                    //EmailErrortoOtherEntities(pTableName, pBatchProcessName, pEntryNo, pDocNo, pErrorDescription);
                END;
                //HBSTG  2015-04-30: End <<
                COMMIT;
            END;
        END;                                                                                               //#11694
    end;


    /// <summary> 
    /// Description for GetLastEntryNo.
    /// </summary>
    /// <returns>Return variable "Integer".</returns>
    procedure GetLastEntryNo(): Integer
    var
        DocCreationErrLog: Record "NXN Doc. Creation Error Log";
        EntryNo: Integer;
    begin
        WITH DocCreationErrLog DO BEGIN
            RESET;
            IF FINDLAST THEN
                EntryNo := "Entry No." + 1
            ELSE
                EntryNo := 1;
        END;
        EXIT(EntryNo);
    end;


    /// <summary> 
    /// Description for CloseErrorLog.
    /// </summary>
    /// <param name="TableEntryNo">Parameter of type Integer.</param>
    /// <param name="TableName">Parameter of type Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code".</param>
    procedure CloseErrorLog(TableEntryNo: Integer; TableName: Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code")
    begin
        DocCreationErrorLog.RESET;
        DocCreationErrorLog.SETRANGE("Table Name", TableName);
        DocCreationErrorLog.SETRANGE("Table Entry No", TableEntryNo);
        DocCreationErrorLog.SETRANGE(Status, DocCreationErrorLog.Status::"Document Error");
        DocCreationErrorLog.SETRANGE(Closed, FALSE);
        IF DocCreationErrorLog.FINDSET(TRUE, FALSE) THEN
            REPEAT
                DocCreationErrorLog.Closed := TRUE;
                DocCreationErrorLog.Status := DocCreationErrorLog.Status::Successful;
                DocCreationErrorLog.MODIFY;
            UNTIL DocCreationErrorLog.NEXT = 0;
    end;


    /// <summary> 
    /// Description for CreateMsgLog.
    /// </summary>
    /// <param name="EmailSubject">Parameter of type Text[250].</param>
    /// <param name="EmailBody">Parameter of type Text[250].</param>
    /// <param name="EmailTo">Parameter of type Text[100].</param>
    /// <param name="EmailCC">Parameter of type Text[100].</param>
    /// <param name="EmailBCC">Parameter of type Text[100].</param>
    /// <param name="SourceType">Parameter of type Code[50].</param>
    /// <param name="SourceNo">Parameter of type Code[100].</param>
    procedure CreateMsgLog(EmailSubject: Text[250]; EmailBody: Text[250]; EmailTo: Text[100]; EmailCC: Text[100]; EmailBCC: Text[100]; SourceType: Code[50]; SourceNo: Code[100])
    var
        MessageLog: Record "NXN E-Mail Queue";
    begin
        MessageLog.RESET;
        MessageLog.INIT;
        MessageLog."Subject Line" := EmailSubject;
        MessageLog."Body Line" := EmailBody;
        MessageLog."To Address" := EmailTo;
        MessageLog."CC Address" := EmailCC;            //HBSTG  2015-08-14
        MessageLog."BCC Address" := EmailBCC;          //HBSTG  2015-08-14
        MessageLog."Source Type" := SourceType;
        MessageLog."Source No." := SourceNo;
        MessageLog."Logging DateTime" := CURRENTDATETIME;
        MessageLog.INSERT(TRUE);
    end;


    // procedure EmailErrortoOtherEntities(pTableName: Option " ","EDI Order","EDI Invoice","EDI Payment","EDI Cr Memo","EDI Rebate PI","EDI Reason Code","EDI Central Invoicing"; pBatchProcessName: Code[20]; pEntryNo: Integer; pDocNo: Code[50]; pErrorDescription: Text[1024])
    // var
    //     EDIInvHeader: Record "50005";
    //     EDIOrdHeader: Record "50001";
    //     Vend: Record "23";
    //     HumePDF: Codeunit "70000";
    //     ToEmailAddr: Text[100];
    //     CCEmailAddr: Text[100];
    //     BCCEmailAddr: Text[100];
    //     Entity: Option Customer,Vendor,Location,Company;
    //     VendNo: Code[20];
    //     ContractDimVal: Record "349";
    //     EDICreditMemoLine: Record "50008";
    //     ContractDimValCode: Code[20];
    //     ErrorLogDocCode: Code[20];
    //     EDIOrderAmount: Decimal;
    //     DocEntryNo: Code[20];
    // begin
    //     //HBSTG  2015-08-14: New Function
    //     EDISetup.GET();
    //     //HumePDFSetup.GET();
    //     ErrorLogDocCode := '';
    //     Cust.RESET;
    //     CASE TRUE OF
    //         //#14273 Start:
    //         pBatchProcessName = 'ORDER':
    //             BEGIN
    //                 IF EDIOrdHeader.GET(pEntryNo) THEN BEGIN
    //                     EDIOrdHeader."Amount Including VAT" := 0;
    //                     EDIOrdHeader."Credit Limit Error" := FALSE;
    //                     EDIOrdHeader."Customer Block Error" := FALSE;
    //                     EDIOrdHeader.MODIFY(TRUE);
    //                 END;
    //                 IF (STRPOS(pErrorDescription, 'is blocked with type Ship') > 0) THEN BEGIN
    //                     EDIOrdHeader."Customer Block Error" := TRUE;
    //                     EDIOrdHeader.MODIFY(TRUE);
    //                 END;
    //                 IF (STRPOS(pErrorDescription, 'Hold because the Total Credit Limit ') > 0) THEN BEGIN
    //                     EDIOrdHeader."Amount Including VAT" := GetOrderAmt(pErrorDescription);
    //                     EDIOrdHeader."Credit Limit Error" := TRUE;
    //                     EDIOrdHeader."Customer Block Error" := TRUE;
    //                     Cust.RESET;
    //                     Cust.SETRANGE("EDI Customer ID", EDIOrdHeader."Customer ID");
    //                     IF Cust.FINDFIRST THEN BEGIN
    //                         Cust.Blocked := Cust.Blocked::Ship;
    //                         Cust.MODIFY(TRUE);
    //                     END;
    //                     EDIOrdHeader.MODIFY(TRUE);
    //                     //Get Customer Block Alert Doc Code
    //                     IF ContractDimVal.GET(EDISetup."Cost Centre Dimension Code", EDIOrdHeader."Cost Centre Code") THEN
    //                         ErrorLogDocCode := ContractDimVal."Customer Block Alert Code"
    //                     ELSE
    //                         ErrorLogDocCode := '';

    //                     HumePDF.SetContractDimValues(TRUE, ContractDimVal.Code);
    //                     HumePDF.SetBatchProcessName('ORDER');
    //                     IF HumePDF.DocEnabledforEntity(ErrorLogDocCode, Cust."No.") THEN BEGIN
    //                         HumePDF.GetEmailAddresses(ToEmailAddr, CCEmailAddr, BCCEmailAddr, ErrorLogDocCode, Cust."No.");
    //                         CreateMsgLog(
    //                             'Account ' + Cust."EDI Customer ID" + ' is put on-hold because of insufficent balance. Order ID ' + pDocNo + ' is not processed.',
    //                             COPYSTR(pErrorDescription, 1, 250), ToEmailAddr, CCEmailAddr, BCCEmailAddr, 'EDI Order Customer', pDocNo);
    //                     END;
    //                 END;
    //             END;
    //         //#14273 End:
    //         pBatchProcessName = 'INVOICE':
    //             BEGIN
    //                 CreateMsgQue := FALSE;
    //                 IF EDIInvHeader.GET(pEntryNo) THEN BEGIN
    //                     //get error log Doc Code
    //                     IF ContractDimVal.GET(EDISetup."Cost Centre Dimension Code", EDIInvHeader."Cost Centre Code") THEN
    //                         ErrorLogDocCode := ContractDimVal."Error Log to Member Alert Code"
    //                     ELSE
    //                         ErrorLogDocCode := HumePDFSetup."Err Log to Member w/o CC";

    //                     IF ErrorLogDocCode <> '' THEN BEGIN
    //                         //NXNRP 2020-03-18: START
    //                         IF (STRPOS(pErrorDescription, 'There is nothing to release for the document of type ') > 0) THEN BEGIN
    //                             pErrorDescription := 'The invoice submitted is for zero value. This invoice and the pertaining order will be cancelled by CW.';
    //                             CreateMsgQue := TRUE;
    //                         END ELSE
    //                             //NXNRP 2020-03-18: End
    //                             IF (STRPOS(pErrorDescription, 'does not match original Order Item') > 0) OR
    //                               (STRPOS(pErrorDescription, 'Cannot find Order Line for Item') > 0) OR
    //                               (STRPOS(pErrorDescription, 'has been invoiced OR cancelled') > 0) OR
    //                               (STRPOS(pErrorDescription, 'does not exist in Navision') > 0) OR
    //                               (STRPOS(pErrorDescription, 'Quantity variation is more than permitted for Item') > 0) OR
    //                               (STRPOS(pErrorDescription, 'Reason Code is not a valid substitute reason for') > 0) OR
    //                               (STRPOS(pErrorDescription, 'New Invoice Line cannot be added for the item') > 0) OR
    //                               (STRPOS(pErrorDescription, 'Contract Purchase Price cannot be found for Contract') > 0) OR
    //                               (STRPOS(pErrorDescription, 'is missing from the invoice. It cannot be zero or empty') > 0) OR
    //                               (STRPOS(pErrorDescription, 'Replace By Item No. does not match with EDI Invoice') > 0) OR
    //                               (STRPOS(pErrorDescription, 'There is no Item Cross Reference within the filter') > 0) THEN BEGIN
    //                                 CreateMsgQue := TRUE;
    //                             END;
    //                         IF CreateMsgQue THEN BEGIN
    //                             HumePDF.SetContractDimValues(TRUE, ContractDimVal.Code);
    //                             //Using EntryNo to find out the unique InvoiceID because InvoiceID could be same for different vendor
    //                             DocEntryNo := FORMAT(pEntryNo);
    //                             HumePDF.SetBatchProcessName('INVOICE');
    //                             IF HumePDF.DocEnabledforEntity(ErrorLogDocCode, DocEntryNo) THEN BEGIN
    //                                 HumePDF.GetEmailAddresses(ToEmailAddr, CCEmailAddr, BCCEmailAddr, ErrorLogDocCode, DocEntryNo);
    //                                 CreateMsgLog('Invoice Creation Error: ' + 'Invoice ID' + ' ' + pDocNo, pErrorDescription, ToEmailAddr, CCEmailAddr, BCCEmailAddr, 'EDI Invoice Member', pDocNo);
    //                             END;
    //                         END;
    //                     END;
    //                 END;
    //             END;
    //         pBatchProcessName = 'CREDITMEMO':
    //             BEGIN
    //                 IF EDICreditMemoLine.GET(pEntryNo) THEN BEGIN
    //                     //get error log Doc Code
    //                     IF ContractDimVal.GET(EDISetup."Cost Centre Dimension Code", EDICreditMemoLine."CC Code") THEN
    //                         ErrorLogDocCode := ContractDimVal."Error Log to Member Alert Code"
    //                     ELSE
    //                         ErrorLogDocCode := HumePDFSetup."Err Log to Member w/o CC";

    //                     IF ErrorLogDocCode <> '' THEN BEGIN
    //                         IF (STRPOS(pErrorDescription, 'do not match original Order Item') > 0) OR
    //                              (STRPOS(pErrorDescription, 'Cannot find Order Line for Item') > 0) OR
    //                              (STRPOS(pErrorDescription, 'is not found in the EDI Invoice') > 0) OR
    //                              (STRPOS(pErrorDescription, 'Invoice Line No. must have a value in EDI Credit Memo Line') > 0) OR
    //                              (STRPOS(pErrorDescription, 'The field Return Reason Code of table Sales Line contains a value') > 0) OR
    //                              (STRPOS(pErrorDescription, 'Reason Code must have a value in EDI Credit Memo Line') > 0) OR
    //                              (STRPOS(pErrorDescription, 'Invoice ID must have a value in EDI Credit Memo Line') > 0) OR
    //                              (STRPOS(pErrorDescription, 'from the Credit Memo line is different  in applied') > 0) OR
    //                              (STRPOS(pErrorDescription, 'There is no Purch. Inv. Header within the filter') > 0) OR
    //                              (STRPOS(pErrorDescription, 'cannot be found in system.') > 0) THEN BEGIN
    //                             HumePDF.SetContractDimValues(TRUE, ContractDimVal.Code);
    //                             //Using EntryNo to find out the unique InvoiceID because InvoiceID could be same for different vendor
    //                             DocEntryNo := FORMAT(pEntryNo);
    //                             HumePDF.SetBatchProcessName('CREDITMEMO');
    //                             IF HumePDF.DocEnabledforEntity(ErrorLogDocCode, DocEntryNo) THEN BEGIN
    //                                 HumePDF.GetEmailAddresses(ToEmailAddr, CCEmailAddr, BCCEmailAddr, ErrorLogDocCode, DocEntryNo);
    //                                 CreateMsgLog('Credit Memo Creation Error: ' + 'Credit Memo ID' + ' ' + pDocNo, pErrorDescription, ToEmailAddr, CCEmailAddr, BCCEmailAddr, 'EDI Credit Memo Member', pDocNo);
    //                             END;
    //                         END;
    //                     END;
    //                 END;
    //             END;
    //     END;
    /*
    HumePDFSetup.GET();
    CASE TRUE OF
      pBatchProcessName = 'INVOICE':
        BEGIN
          IF HumePDFSetup."Err Log to Member w/o CC" <> '' THEN
            IF HumePDFDocSetup.GET(HumePDFSetup."Err Log to Member w/o CC") THEN
              IF HumePDFDocSetup.Enable THEN
                IF (STRPOS(pErrorDescription,'do not match original Order Item') > 0) OR
                     (STRPOS(pErrorDescription,'Cannot find Order Line for Item') > 0)  OR
                     (STRPOS(pErrorDescription,'does not exist in Sales Orders') > 0)  OR
                     (STRPOS(pErrorDescription,'does not exist in Purchase Orders') > 0) THEN
                  IF HumePDF.DocEnabledforEntity(HumePDFSetup."Err Log to Member w/o CC",pDocNo) THEN BEGIN
                    HumePDF.GetEmailAddresses(ToEmailAddr,CCEmailAddr,BCCEmailAddr,HumePDFSetup."Err Log to Member w/o CC",pDocNo);
                    CreateMsgLog('Invoice Creation Error: ' + 'Invoice ID' + ' ' + pDocNo,pErrorDescription,ToEmailAddr,CCEmailAddr,BCCEmailAddr,'EDI Invoice Member',pDocNo);
                  END;
        END;
    END;
    */

    //end;


    /// <summary> 
    /// Description for GetOrderAmt.
    /// </summary>
    /// <param name="pErrDesc">Parameter of type Text[1024].</param>
    /// <returns>Return variable "Decimal".</returns>
    procedure GetOrderAmt(pErrDesc: Text[1024]): Decimal
    var
        lvEDIOrderAmt: Decimal;
        lvEDIOrderAmttxt: Text;
        StartPos: Integer;
        EndPos: Integer;
    begin
        //#14273 Start:
        IF pErrDesc <> '' THEN BEGIN
            lvEDIOrderAmt := 0;
            StartPos := STRPOS(pErrDesc, 'Current Order');
            StartPos += 14;
            EndPos := STRLEN(pErrDesc);
            lvEDIOrderAmttxt := COPYSTR(pErrDesc, StartPos, EndPos - StartPos - 1);
            IF lvEDIOrderAmttxt <> '' THEN
                EVALUATE(lvEDIOrderAmt, lvEDIOrderAmttxt);
            EXIT(lvEDIOrderAmt);
        END;
        //#14273 End:
    end;
}

