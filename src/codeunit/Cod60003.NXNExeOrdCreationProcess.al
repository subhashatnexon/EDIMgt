codeunit 60003 "NXN Exe. Ord. Creation Process"
{
    // Execute batch jobs for Document Creation for Order - SALES and PURCHASE
    // 
    // HBSTG CW 2013-09-11: Changes done to handle the multiple Invoice scenario where we can have multiple records for with OrderID in EDI Order Header. Thus,
    //                      we are copying combination of "Order ID + Multiple Invoice ID" in Error Log Reference No.

    TableNo = 60001;

    trigger OnRun()
    begin
        EDIOrderHeader2.COPY(Rec);
        ExecuteOrderCreateBatch();
    end;

    var
        EDIOrderHeader2: Record "NXN EDI Order Header";
        EntryNo: Integer;
        PayloadID: Code[20];
        OrderID: Code[20];
        BatchName: Code[20];
        MultipleInvoiceID: Code[20];


    /// <summary> 
    /// Description for ExecuteOrderCreateBatch.
    /// </summary>
    procedure ExecuteOrderCreateBatch()
    var
        BatchOrderCreate: Report "NXN Batch - Order Creation";
    begin
        IF EDIOrderHeader2.FINDFIRST THEN BEGIN
            BatchName := 'ORDER';
            EntryNo := EDIOrderHeader2."Entry No.";
            OrderID := EDIOrderHeader2."Order ID";
            //MultipleInvoiceID := EDIOrderHeader2."Multiple Invoice ID";  //HBSTG CW 2013-09-11

            BatchOrderCreate.USEREQUESTPAGE(FALSE);
            BatchOrderCreate.SETTABLEVIEW(EDIOrderHeader2);
            BatchOrderCreate.RUN();
        END;
    end;


    /// <summary> 
    /// Description for GetBatchName.
    /// </summary>
    /// <param name="pBatchName">Parameter of type Code[20].</param>
    procedure GetBatchName(var pBatchName: Code[20])
    begin
        pBatchName := BatchName;
    end;


    /// <summary> 
    /// Description for GetEntryNo.
    /// </summary>
    /// <param name="pEntryNo">Parameter of type Integer.</param>
    procedure GetEntryNo(var pEntryNo: Integer)
    begin
        pEntryNo := EntryNo;
    end;


    /// <summary> 
    /// Description for GetPayloadID.
    /// </summary>
    /// <param name="pPayloadID">Parameter of type Code[20].</param>
    procedure GetPayloadID(var pPayloadID: Code[20])
    begin
        pPayloadID := PayloadID;
    end;


    /// <summary> 
    /// Description for GetOrderID.
    /// </summary>
    /// <param name="pOrderID">Parameter of type Code[20].</param>
    procedure GetOrderID(var pOrderID: Code[20])
    begin
        pOrderID := OrderID;
    end;


    /// <summary> 
    /// Description for GetUniqueOrderID.
    /// </summary>
    /// <param name="pUniqueOrderID">Parameter of type Code[50].</param>
    procedure GetUniqueOrderID(var pUniqueOrderID: Code[50])
    begin
        //HBSTG CW 2013-09-11
        pUniqueOrderID := OrderID + ' ' + MultipleInvoiceID;
    end;
}

