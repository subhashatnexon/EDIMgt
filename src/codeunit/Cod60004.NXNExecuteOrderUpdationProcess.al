// codeunit 60004 "NXN Execute Order Updation Process"
// {
//     // Execute batch jobs for Document Updation for Invoice - SALES and PURCHASE

//     TableNo = 50005;

//     trigger OnRun()
//     begin
//         EDIInvoiceHeader2.COPY(Rec);
//         ExecuteOrderUpdateBatch();
//     end;

//     var
//         EDIInvoiceHeader2: Record "50005";
//         EntryNo: Integer;
//         PayloadID: Code[20];
//         OrderID: Code[20];
//         BatchName: Code[20];
//         InvoiceID: Code[35];

//     [Scope('Internal')]
//     procedure ExecuteOrderUpdateBatch()
//     var
//         BatchOrderUpdate: Report "50001";
//     begin
//         IF EDIInvoiceHeader2.FINDFIRST THEN BEGIN
//             BatchName := 'INVOICE';
//             EntryNo := EDIInvoiceHeader2."Entry No.";
//             OrderID := EDIInvoiceHeader2."Order ID";
//             InvoiceID := EDIInvoiceHeader2."Invoice ID";

//             BatchOrderUpdate.USEREQUESTPAGE(FALSE);
//             BatchOrderUpdate.SETTABLEVIEW(EDIInvoiceHeader2);
//             BatchOrderUpdate.RUN();
//         END;
//     end;

//     [Scope('Internal')]
//     procedure GetBatchName(var pBatchName: Code[20])
//     begin
//         pBatchName := BatchName;
//     end;

//     [Scope('Internal')]
//     procedure GetEntryNo(var pEntryNo: Integer)
//     begin
//         pEntryNo := EntryNo;
//     end;

//     [Scope('Internal')]
//     procedure GetOrderID(var pOrderID: Code[20])
//     begin
//         pOrderID := OrderID;
//     end;

//     [Scope('Internal')]
//     procedure GetInvoiceID(var pInvoiceID: Code[35])
//     begin
//         pInvoiceID := InvoiceID;
//     end;
// }

