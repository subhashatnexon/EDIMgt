// codeunit 60006 "NXN Execute Cr Memo Create Process"
// {
//     // Execute batch jobs for Document Creation for Credit Memo - SALES and PURCHASE

//     TableNo = 50008;

//     trigger OnRun()
//     begin
//         EDICrMemoLine2.COPY(Rec);
//         ExecuteCrMemoCreateBatch();
//     end;

//     var
//         EDICrMemoLine2: Record "50008";
//         EntryNo: Integer;
//         CrMemoID: Code[35];
//         BatchName: Code[20];
//         InvoiceID: Code[35];

//     [Scope('Internal')]
//     procedure ExecuteCrMemoCreateBatch()
//     var
//         BatchCrMemoCreate: Report "50003";
//     begin
//         IF EDICrMemoLine2.FINDFIRST THEN BEGIN
//             BatchName := 'CREDITMEMO';
//             EntryNo := EDICrMemoLine2."Entry No.";
//             CrMemoID := EDICrMemoLine2."Credit Memo ID";
//             InvoiceID := EDICrMemoLine2."Invoice ID";

//             BatchCrMemoCreate.USEREQUESTPAGE(FALSE);
//             BatchCrMemoCreate.SETTABLEVIEW(EDICrMemoLine2);
//             BatchCrMemoCreate.RUN();
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
//     procedure GetCrMemoID(var pCrMemoID: Code[35])
//     begin
//         pCrMemoID := CrMemoID;
//     end;

//     [Scope('Internal')]
//     procedure GetInvoiceID(var pInvoiceID: Code[35])
//     begin
//         pInvoiceID := InvoiceID;
//     end;
// }

