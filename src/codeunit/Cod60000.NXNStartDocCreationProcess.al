codeunit 60000 "NXN Start Doc Creation Process"
{
    // HBSRP 2017-03-30: Code commented because now it will be process manually
    // HBSRP 2017-05-19: New Function has been added "CreateDocFromSupplierRebate"


    trigger OnRun()
    begin
        CreateDocFromEDIOrder();
        //UpdateDocFromEDIInvoice();
        //CreateDocFromEDICrMemo();
        //CreateDocFromEDIPayment();                                                                            //HBSRP 2017-03-30
        //CreateDocFromEDIRebateLine();                                                                         //HBSRP 2017-03-30
        //UpdateDocFromEDIReasonCode();
    end;

    var
        InitDocCreationProcess: Codeunit "NXN Init Doc Creation Process";


    /// <summary> 
    /// Description for CreateDocFromEDIOrder.
    /// </summary>
    procedure CreateDocFromEDIOrder()
    var
        EDIOrderHeader: Record "NXN EDI Order Header";
        EDIOrderheader2: Record "NXN EDI Order Header";
    begin
        EDIOrderHeader.RESET;
        EDIOrderHeader.SETFILTER(Status, '%1|%2', EDIOrderHeader.Status::" ", EDIOrderHeader.Status::"Released (Manual)");
        EDIOrderHeader.SETFILTER("Doc Process Status", '%1|%2', EDIOrderHeader."Doc Process Status"::" ", EDIOrderHeader."Doc Process Status"::"Document Error");
        IF EDIOrderHeader.FINDSET THEN BEGIN
            REPEAT
                EDIOrderheader2.RESET;
                EDIOrderheader2.SETRANGE("Order ID", EDIOrderHeader."Order ID");
                EDIOrderheader2.SetRange("Entry No.", EDIOrderHeader."Entry No.");//NXNRP
                //EDIOrderheader2.SETRANGE("Multiple Invoice ID", EDIOrderHeader."Multiple Invoice ID");
                IF EDIOrderheader2.FINDSET THEN BEGIN
                    InitDocCreationProcess.InitOrderCreationBatch(EDIOrderheader2);
                    COMMIT;
                END;
            UNTIL EDIOrderHeader.NEXT = 0;
        END;
    end;


    // procedure UpdateDocFromEDIInvoice()
    // var
    //     EDIInvoiceHeader: Record "50005";
    //     EDIInvoiceHeader2: Record "50005";
    // begin
    //     EDIInvoiceHeader.RESET;
    //     EDIInvoiceHeader.SETFILTER("Doc Process Status", '%1|%2', EDIInvoiceHeader."Doc Process Status"::" ", EDIInvoiceHeader."Doc Process Status"::"Document Error");
    //     IF EDIInvoiceHeader.FINDSET THEN BEGIN
    //         REPEAT
    //             EDIInvoiceHeader2.RESET;
    //             EDIInvoiceHeader2.SETRANGE("Order ID", EDIInvoiceHeader."Order ID");
    //             EDIInvoiceHeader2.SETRANGE("Invoice ID", EDIInvoiceHeader."Invoice ID");
    //             IF EDIInvoiceHeader2.FINDSET THEN BEGIN
    //                 InitDocCreationProcess.InitOrderUpdationBatch(EDIInvoiceHeader2);
    //                 COMMIT;
    //             END;
    //         UNTIL EDIInvoiceHeader.NEXT = 0;
    //     END;
    // end;


    // procedure CreateDocFromEDIPayment()
    // var
    //     EDIPaymentLine: Record "50007";
    //     EDIPaymentLine2: Record "50007";
    // begin
    //     EDIPaymentLine.RESET;
    //     EDIPaymentLine.SETFILTER("Doc Process Status", '%1|%2', EDIPaymentLine."Doc Process Status"::" ", EDIPaymentLine."Doc Process Status"::"Document Error");
    //     IF EDIPaymentLine.FINDSET THEN
    //         REPEAT
    //             EDIPaymentLine2.RESET;
    //             EDIPaymentLine2.SETRANGE("Invoice ID", EDIPaymentLine."Invoice ID");
    //             IF EDIPaymentLine2.FINDSET THEN BEGIN
    //                 InitDocCreationProcess.InitPaymentBatch(EDIPaymentLine2);
    //                 COMMIT;
    //             END;
    //         UNTIL EDIPaymentLine.NEXT = 0;
    // end;


    // procedure CreateDocFromEDICrMemo()
    // var
    //     EDICrMemoLine: Record "50008";
    //     EDICrMemoLine2: Record "50008";
    // begin
    //     EDICrMemoLine.RESET;
    //     EDICrMemoLine.SETFILTER("Doc Process Status", '%1|%2', EDICrMemoLine."Doc Process Status"::" ", EDICrMemoLine."Doc Process Status"::"Document Error");
    //     IF EDICrMemoLine.FINDSET THEN
    //         REPEAT
    //             EDICrMemoLine2.RESET;
    //             EDICrMemoLine2.SETRANGE("Credit Memo ID", EDICrMemoLine."Credit Memo ID");
    //             IF EDICrMemoLine2.FINDSET THEN BEGIN
    //                 InitDocCreationProcess.InitCrMemoCreationBatch(EDICrMemoLine2);
    //                 COMMIT;
    //             END;
    //         UNTIL EDICrMemoLine.NEXT = 0;
    // end;


    // procedure CreateDocFromEDIRebateLine()
    // var
    //     EDIRebateLine: Record "50009";
    //     EDIRebateLine2: Record "50009";
    // begin
    //     EDIRebateLine.RESET;
    //     EDIRebateLine.SETFILTER("Doc Process Status", '%1|%2', EDIRebateLine."Doc Process Status"::" ", EDIRebateLine."Doc Process Status"::"Document Error");
    //     EDIRebateLine.SETRANGE("Rebate Purch Invoice Created", FALSE);
    //     EDIRebateLine2.SETRANGE("Payment Doc Process Status", EDIRebateLine2."Payment Doc Process Status"::Successful);
    //     IF EDIRebateLine.FINDSET THEN
    //         REPEAT
    //             EDIRebateLine2.RESET;
    //             EDIRebateLine2.SETRANGE("Customer ID", EDIRebateLine."Customer ID");
    //             IF EDIRebateLine2.FINDSET THEN BEGIN
    //                 InitDocCreationProcess.InitRebatePICreationBatch(EDIRebateLine2);
    //                 COMMIT;
    //             END;
    //         UNTIL EDIRebateLine.NEXT = 0;
    // end;


    // procedure UpdateDocFromEDIReasonCode()
    // var
    //     EDIReasonCodeLine: Record "50010";
    //     EDIReasonCodeLine2: Record "50010";
    // begin
    //     EDIReasonCodeLine.RESET;
    //     EDIReasonCodeLine.SETFILTER("Doc Process Status", '%1|%2', EDIReasonCodeLine."Doc Process Status"::" ", EDIReasonCodeLine."Doc Process Status"::"Document Error");
    //     IF EDIReasonCodeLine.FINDSET THEN
    //         REPEAT
    //             EDIReasonCodeLine2.RESET;
    //             EDIReasonCodeLine2.SETRANGE("Invoice ID", EDIReasonCodeLine."Invoice ID");
    //             IF EDIReasonCodeLine2.FINDSET THEN BEGIN
    //                 InitDocCreationProcess.InitReasonCodeUpdationBatch(EDIReasonCodeLine2);
    //                 COMMIT;
    //             END;
    //         UNTIL EDIReasonCodeLine.NEXT = 0;
    // end;


    // procedure CreateDocFromEDICentralInv()
    // var
    //     EDICentralInvLine: Record "50053";
    //     EDICentralInvLine2: Record "50053";
    // begin
    //     EDICentralInvLine.RESET;
    //     EDICentralInvLine.SETFILTER("Doc Process Status", '%1|%2', EDICentralInvLine."Doc Process Status"::" ", EDICentralInvLine."Doc Process Status"::"Document Error");
    //     IF EDICentralInvLine.FINDSET THEN
    //         REPEAT
    //             EDICentralInvLine2.RESET;
    //             EDICentralInvLine2.SETRANGE("Invoice / Cr Memo No.", EDICentralInvLine."Invoice / Cr Memo No.");
    //             IF EDICentralInvLine2.FINDSET THEN BEGIN
    //                 InitDocCreationProcess.InitCentralInvBatch(EDICentralInvLine2);
    //                 COMMIT;
    //             END;
    //         UNTIL EDICentralInvLine.NEXT = 0;
    // end;
}

