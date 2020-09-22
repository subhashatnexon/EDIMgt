// report 60002 "Batch - Credit Memo Creation"
// {
//     // HBSRP 2015-01-19: Changes done to populate the Cost Center dimension in Purchase Credit Memo document
//     // HBSRP 2015-01-20: Changes done to populate the GST Business posting group from the customer to Purchase documents.
//     // HBSRP 2015-01-21: Code added to check GST Business Posting Group
//     // HBSRP 2015-03-19: Coded added to create Fee and incentive lines
//     // HBSRP 2015-03-24: Coded added to test the reason code
//     // HBSRP 2015-07-13: Code added for adding line type for unsheduled weekday and weekend delivery
//     // HBSRP 2015-07-14: Code added for checking return reason code as per contract dimension
//     // HBSRP 2016-05-06: Code added for item cross reference
//     // HBSRP 2016-05-12: Code added for checking invoice id and credit memo id to allow multiple credits
//     // HBSRP 2017-02-23: Code added for copy for sales invoice description
//     // HBSRP 2018-06-15: Code Commented for the Spotless credit price
//     // #12352 ReSRP 2019-05-03: text added for quantity is zero in text constant Text0023.
//     // #12460 ReSRP 2019-06-06: CC Code in the EDI Credit memo line is updated
//     // #CW4.55 ReSRP 2019-09-10: Code added for Pizza Hut and Fees and incentives.

//     ProcessingOnly = true;

//     dataset
//     {
//         dataitem(EDICrMemoHeader; Table50008)
//         {
//             DataItemTableView = SORTING (Entry No.)
//                                 WHERE (Doc Process Status=FILTER(' '|Document Error));
//             RequestFilterFields = "Credit Memo ID";
//             dataitem(EDICrMemoLine;Table50008)
//             {
//                 DataItemLink = Credit Memo ID=FIELD(Credit Memo ID);
//                 DataItemTableView = SORTING(Entry No.)
//                                     WHERE(Doc Process Status=FILTER(' '|Document Error));

//                 trigger OnAfterGetRecord()
//                 begin
//                     TESTFIELD("Credit Memo ID");
//                     TESTFIELD("Invoice ID");
//                     TESTFIELD("Credit Memo Date");
//                     //TESTFIELD("Invoice Line No.");
//                     TESTFIELD("Reason Code");

//                     IF SCMHeaderCreated THEN BEGIN
//                       LineNo += 10000;
//                       CreateSalesCrMemoLine;
//                       CreatePurchCrMemoLine;

//                       "Sales Cr. Memo Created" := TRUE;
//                       "Sales Cr. Memo No." := SalesHeader."No.";
//                       "Purchase Cr. Memo Created" := TRUE;
//                       "Purchase Cr. Memo No." := PurchHeader."No.";
//                       "Doc Process Status" := "Doc Process Status"::Successful;
//                       "CC Code":= CostCentre;                                                                          //#12460
//                       MODIFY(TRUE);
//                     END ELSE IF SIHeaderCreated THEN BEGIN
//                       //HBSTG 2017-03-02: Commented code after approval from helen to stop the old Spotless business logic
//                       /*
//                       IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN BEGIN
//                         LineNo += 10000;
//                         CreateSalesInvoiceLine;
//                         CreatePurchInvoiceLine;

//                         "Sales Invoice Created" := TRUE;
//                         "Sales Invoice No." := SalesHeader."No.";
//                         "Purchase Invoice Created" := TRUE;
//                         "Purchase Invoice No." := PurchHeader."No.";
//                         "Doc Process Status" := "Doc Process Status"::Successful;
//                         MODIFY(TRUE);
//                       END;
//                       */
//                     END;

//                 end;

//                 trigger OnPostDataItem()
//                 begin
//                     UpdateOrderLineForFeeAndIncentives();
//                     IF ContractDimVal."Archive Docs in EDI Process" THEN
//                       ArchiveManagement.StoreSalesDocument(SalesHeader,FALSE);
//                     ReleaseSalesDoc.RUN(SalesHeader);
//                     IF ContractDimVal."Archive Docs in EDI Process" THEN
//                       ArchiveManagement.StorePurchDocument(PurchHeader,FALSE);
//                     ReleasePurchDoc.RUN(PurchHeader);
//                 end;
//             }

//             trigger OnAfterGetRecord()
//             begin
//                 TESTFIELD("Credit Memo ID");
//                 TESTFIELD("Invoice ID");
//                 TESTFIELD("Member ID");
//                 TESTFIELD("Credit Memo Date");

//                 Vend.RESET;
//                 Vend.SETRANGE("Member ID","Member ID");
//                 Vend.FINDFIRST;

//                 PurchInvHeader.RESET;
//                 PurchInvHeader.SETRANGE("Buy-from Vendor No.",Vend."No.");
//                 PurchInvHeader.SETRANGE("Vendor Invoice No.","Invoice ID");
//                 PurchInvHeader.FINDLAST;

//                 EDIInvHeader.RESET;
//                 EDIInvHeader.SETRANGE("Invoice ID","Invoice ID");
//                 EDIInvHeader.SETRANGE("Doc Process Status",EDIInvHeader."Doc Process Status"::Successful);
//                 EDIInvHeader.FINDLAST;

//                 IF Vend."No." <> PurchInvHeader."Buy-from Vendor No." THEN
//                   ERROR(Text0012,Vend."No.",PurchInvHeader."Buy-from Vendor No.");

//                 PayToVend.GET(PurchInvHeader."Pay-to Vendor No.");
//                 Loc.GET(PurchInvHeader."Location Code");

//                 SalesHeader.RESET;
//                 SalesHeader.SETRANGE("Document Type",SalesHeader."Document Type"::"Credit Memo");
//                 SalesHeader.SETRANGE("Sell-to Customer No.",PurchInvHeader."Sell-to Customer No.");
//                 SalesHeader.SETRANGE("EDI Cr Memo ID","Credit Memo ID");
//                 IF SalesHeader.FINDFIRST THEN
//                   ERROR(Text0004,"Credit Memo ID",SalesHeader."No.");                                      // Rajesh

//                 LineNo := 0;
//                 SCMHeaderCreated := FALSE;
//                 SIHeaderCreated := FALSE;

//                 SalesInvHeader.RESET;
//                 SalesInvHeader.SETRANGE("Sell-to Customer No.",PurchInvHeader."Sell-to Customer No.");
//                 SalesInvHeader.SETRANGE("External Document No.","Invoice ID");
//                 SalesInvHeader.FINDLAST;
//                 Cust.GET(SalesInvHeader."Sell-to Customer No.");
//                 BillToCust.GET(SalesInvHeader."Bill-to Customer No.");
//                 Cust.TESTFIELD("VAT Bus. Posting Group");
//                 BillToCust.TESTFIELD("VAT Bus. Posting Group");


//                 CostCentre := '';
//                 IF Cust."Bill-to Customer No." <> '' THEN BEGIN
//                   DefaultDimension.GET(DATABASE::Customer,Cust."Bill-to Customer No.",EDISetup."Cost Centre Dimension Code");
//                   CostCentre := DefaultDimension."Dimension Value Code";
//                 END ELSE BEGIN
//                   DefaultDimension.GET(DATABASE::Customer,Cust."No.",EDISetup."Cost Centre Dimension Code");
//                   CostCentre := DefaultDimension."Dimension Value Code";
//                 END;

//                 ContractDimVal.GET(EDISetup."Cost Centre Dimension Code",CostCentre);

//                 IF ContractDimVal."Allow EDI Credit Application" THEN BEGIN
//                   VendorLedgerEntry.RESET;
//                   VendorLedgerEntry.SETRANGE("Vendor No.",PayToVend."No.");
//                   VendorLedgerEntry.SETRANGE("Document Type",VendorLedgerEntry."Document Type"::Invoice);
//                   VendorLedgerEntry.SETRANGE("External Document No.","Invoice ID");
//                   IF VendorLedgerEntry.FINDFIRST THEN
//                     IF NOT VendorLedgerEntry.Open THEN
//                       VLEClosed := TRUE;

//                   CustLedgerEntry.RESET;
//                   CustLedgerEntry.SETRANGE("Customer No.",BillToCust."No.");
//                   CustLedgerEntry.SETRANGE("Document Type",CustLedgerEntry."Document Type"::Invoice);
//                   CustLedgerEntry.SETRANGE("External Document No.","Invoice ID");
//                   IF CustLedgerEntry.FINDFIRST THEN
//                     IF NOT CustLedgerEntry.Open THEN
//                       CLEClosed := TRUE;
//                 END;

//                 CustLedgerEntry.RESET;
//                 CustLedgerEntry.SETRANGE("Customer No.",BillToCust."No.");
//                 CustLedgerEntry.SETRANGE("Document Type",CustLedgerEntry."Document Type"::"Credit Memo");
//                 CustLedgerEntry.SETRANGE("External Document No.","Credit Memo ID");
//                 IF CustLedgerEntry.FINDFIRST THEN
//                   ERROR(CreditMemoExistErr,"Credit Memo ID",CustLedgerEntry."Customer No.");

//                 IF EDICrMemoHeader."Marked-down Unit Price" >= 0 THEN BEGIN
//                   CreateSalesCrMemoHeader;
//                   CreatePurchCrMemoHeader;
//                   SCMHeaderCreated := TRUE;
//                 END ELSE BEGIN
//                   //HBSTG 2017-03-02: Commented code after approval from helen to stop the old Spotless business logic
//                   /*
//                   IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN BEGIN
//                     CreateSalesInvoiceHeader;
//                     CreatePurchInvoiceHeader;
//                     SIHeaderCreated := TRUE;
//                   END;
//                   */
//                 END;

//             end;

//             trigger OnPreDataItem()
//             begin
//                 GLSetup.GET;
//                 SalesSetup.GET;
//                 PurchSetup.GET;
//                 InvtSetup.GET;
//                 EDISetup.GET;
//                 EDISetup.TESTFIELD("EDI Sales Cr Memo G/L Acc No.");
//                 EDISetup.TESTFIELD("EDI Purch Cr Memo G/L Acc No.");
//             end;
//         }
//     }

//     requestpage
//     {

//         layout
//         {
//         }

//         actions
//         {
//         }
//     }

//     labels
//     {
//     }

//     var
//         GLSetup: Record "98";
//         SalesSetup: Record "311";
//         PurchSetup: Record "312";
//         InvtSetup: Record "313";
//         EDISetup: Record "50000";
//         SalesHeader: Record "36";
//         SalesLine: Record "37";
//         PurchHeader: Record "38";
//         PurchLine: Record "39";
//         SalesInvHeader: Record "112";
//         PurchInvHeader: Record "122";
//         Cust: Record "18";
//         BillToCustm: Record "18";
//         Vend: Record "23";
//         PayToVend: Record "23";
//         Loc: Record "14";
//         ContractDimVal: Record "349";
//         ReleaseSalesDoc: Codeunit "414";
//         ReleasePurchDoc: Codeunit "415";
//         NoSeriesMgmt: Codeunit "396";
//         ArchiveManagement: Codeunit "5063";
//         SCMHeaderCreated: Boolean;
//         SIHeaderCreated: Boolean;
//         LineNo: Integer;
//         Text0004: Label 'Credit Memo ID %1 is already created with Credit Memo No. %2 .';
//         CostCentre: Code[20];
//         DefaultDimension: Record "352";
//         NewDimSetID: Integer;
//         OldDimSetID: Integer;
//         ChangeDimSetID: Integer;
//         StoreAllocationEntry: Record "50052";
//         FeesAndIncentives: Record "50021";
//         gvType: Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
//         LineType: Option " ","Case Rate","Broken Case Rate","Carton Freight","MOQ Incentive","Direct Debit Incentive","Online Order Incentive","Credit Card Surcharge","Store Allocation","Carton Case Income","Direct Debit Income","Online Order Income","Unsch Weekday Delivery","Unsch Weekend Delivery","Minimum Order Value Charge","CW User Pay","CW Bad Debt",MU1,MU2,MU3,"Bag Rate","Bag Freight","Bag Income",LOF,MOQNA,FrghtAnclry;
//         PurchUnitPrice: Decimal;
//         PurchPriceCalcMgt: Codeunit "7010";
//         EDIOrderHeader: Record "50001";
//         EDIOrderLine: Record "50002";
//         EDIOrderLine2: Record "50002";
//         Text0001: Label 'Could not find Sales Lines for Payload ID %1 and Order ID %2.';
//         Text0002: Label 'The %1 for %2 %3 has changed from %4 to %5 since the Sales Order was created. Adjust the %6 on the Sales Order or the %1.';
//         Text0003: Label 'There were no lines to be retrieved from sales order %1.';
//         Text0004A: Label 'Order ID %1 is already created with Order No. %2 .';
//         Text0005: Label 'Cost Center Dimension does not exist for the Customer No.=%1 ';
//         Text0006: Label 'Item %1 cannot be found in system.';
//         Text0007: Label 'Item Price cannot be found for Item %1';
//         Text0008: Label 'Order ID %1 is already posted with Invoice No. %2 .';
//         Text0009: Label 'Item Price cannot be found for Item %1 for Line Type %2';
//         Text0010: Label 'Item Cost cannot be found for Item %1 for Line Type %2';
//         recItem: Record "27";
//         BillToCust: Record "18";
//         ItemCrossRef: Record "5717";
//         ItemCrossRef2: Record "5717";
//         UOM: Record "204";
//         ItemUOM: Record "5404";
//         PurchCode: Record "5721";
//         GSTPostingSetup: Record "325";
//         CopyDocMgt: Codeunit "6620";
//         ItemTrackingMgt: Codeunit "6500";
//         TransferExtendedText: Codeunit "378";
//         BASManagement: Codeunit "11601";
//         Text0011: Label 'EDI Invoice Line No. %1  is not found in the EDI Invoice.';
//         Text0012: Label 'Member %1 from the Credit Memo line is different  in applied puchase invoice vendor %2.';
//         Text0017: Label 'Item %1 cannot be found in system.';
//         Text0018: Label 'Item %1 do not match original Order Item %2.';
//         Text0019: Label 'Invoice ID %1 already exist in Customer Ledger Entry. ';
//         ReturnReason: Record "6635";
//         Text0020: Label 'Reason Code %1 is not defined for the Contract %2';
//         Text0021: Label 'UOM %1 for Item %2 could not be found in NAV UOM or Member UOM.';
//         Text0022: Label 'UOM %1 for Item %2 is not allowed. UOM can either be same as Invoice or a broken case (Inner) UOM.';
//         PartialCreditLine: Boolean;
//         SIItemUOM: Record "5404";
//         SalesInvLineFound: Boolean;
//         PurchInvLineFound: Boolean;
//         CLEClosed: Boolean;
//         VLEClosed: Boolean;
//         VendorLedgerEntry: Record "25";
//         CustLedgerEntry: Record "21";
//         EDIInvHeader: Record "50005";
//         EDIInvLine: Record "50006";
//         CreditMemoExistErr: Label 'Credit Memo ID %1 is already exist in the ledger entries for the Customer No. %2 .';
//         Text0023: Label 'Quantity should not be zero in Invoice Line No. = %1 of Credit Memo ID %2.';

//     [Scope('Internal')]
//     procedure CreateSalesCrMemoHeader()
//     begin
//         CLEAR(SalesHeader);
//         WITH SalesHeader DO BEGIN
//           RESET;
//           INIT;
//           VALIDATE("Document Type",SalesHeader."Document Type"::"Credit Memo");
//           VALIDATE("No.",NoSeriesMgmt.GetNextNo(SalesSetup."Credit Memo Nos.",EDICrMemoHeader."Credit Memo Date",TRUE));
//           INSERT(TRUE);
//           VALIDATE("Sell-to Customer No.",Cust."No.");
//           VALIDATE("Bill-to Customer No.",BillToCust."No.");
//           VALIDATE("Order Date",EDICrMemoHeader."Credit Memo Date");
//           VALIDATE("Posting Date",EDICrMemoHeader."Credit Memo Date");
//           VALIDATE("Document Date",EDICrMemoHeader."Credit Memo Date");
//           VALIDATE("External Document No.",EDICrMemoHeader."Credit Memo ID");
//           VALIDATE("Location Code",Loc.Code);
//           VALIDATE("No. Series",SalesSetup."Credit Memo Nos.");
//           VALIDATE("Posting Description",'Credit Memo ' + EDICrMemoHeader."Credit Memo ID");
//           VALIDATE("Reason Code",EDISetup."Reason Code EDI Cr Memo");

//           IF SalesInvHeader."Bill-to Name" <> '' THEN
//             //VALIDATE("Bill-to Name",SalesInvHeader."Bill-to Name");
//             "Bill-to Name":= SalesInvHeader."Bill-to Name";
//           IF SalesInvHeader."Bill-to Name 2" <> '' THEN
//             VALIDATE("Bill-to Name 2",SalesInvHeader."Bill-to Name 2");
//           IF SalesInvHeader."Bill-to Address" <> '' THEN
//             VALIDATE("Bill-to Address",SalesInvHeader."Bill-to Address");
//           IF SalesInvHeader."Bill-to Address 2" <> '' THEN
//             VALIDATE("Bill-to Address 2",SalesInvHeader."Bill-to Address 2");
//           IF SalesInvHeader."Bill-to City" <> '' THEN
//             VALIDATE("Bill-to City",SalesInvHeader."Bill-to City");
//           IF SalesInvHeader."Bill-to Contact" <> '' THEN
//             VALIDATE("Bill-to Contact",SalesInvHeader."Bill-to Contact");
//           IF SalesInvHeader."Bill-to Post Code" <> '' THEN
//             VALIDATE("Bill-to Post Code",SalesInvHeader."Bill-to Post Code");
//           IF SalesInvHeader."Bill-to County" <> '' THEN
//             VALIDATE("Bill-to County",SalesInvHeader."Bill-to County");
//           IF SalesInvHeader."Bill-to Country/Region Code" <> '' THEN
//             VALIDATE("Bill-to Country/Region Code",SalesInvHeader."Bill-to Country/Region Code");

//           IF SalesInvHeader."Ship-to Code" <> '' THEN
//             VALIDATE("Ship-to Code",SalesInvHeader."Ship-to Code");
//           IF SalesInvHeader."Ship-to Name" <> '' THEN
//             VALIDATE("Ship-to Name",SalesInvHeader."Ship-to Name");
//           IF SalesInvHeader."Ship-to Name 2" <> '' THEN
//             VALIDATE("Ship-to Name 2",SalesInvHeader."Ship-to Name 2");
//           IF SalesInvHeader."Ship-to Address" <> '' THEN
//             VALIDATE("Ship-to Address",SalesInvHeader."Ship-to Address");
//           IF SalesInvHeader."Ship-to Address 2" <> '' THEN
//             VALIDATE("Ship-to Address 2",SalesInvHeader."Ship-to Address 2");
//           IF SalesInvHeader."Ship-to City" <> '' THEN
//             VALIDATE("Ship-to City",SalesInvHeader."Ship-to City");
//           IF SalesInvHeader."Ship-to Contact" <> '' THEN
//             VALIDATE("Ship-to Contact",SalesInvHeader."Ship-to Contact");
//           IF SalesInvHeader."Ship-to Post Code" <> '' THEN
//             VALIDATE("Ship-to Post Code",SalesInvHeader."Ship-to Post Code");
//           IF SalesInvHeader."Ship-to County" <> '' THEN
//             VALIDATE("Ship-to County",SalesInvHeader."Ship-to County");
//           IF SalesInvHeader."Ship-to Country/Region Code" <> '' THEN
//             VALIDATE("Ship-to Country/Region Code",SalesInvHeader."Ship-to Country/Region Code");

//           "Responsibility Center" := SalesInvHeader."Responsibility Center";
//           VALIDATE("EDI Entry No.",EDICrMemoHeader."Entry No.");
//           VALIDATE("EDI Cr Memo ID",EDICrMemoHeader."Credit Memo ID");
//           VALIDATE("Applies-to Ext.Doc.No.",EDICrMemoHeader."Invoice ID");
//           //IF CostCentre <> EDISetup."CC Dimension Code for Spotless" THEN BEGIN
//           IF ContractDimVal."Allow EDI Credit Application" THEN BEGIN
//             IF NOT CLEClosed THEN BEGIN
//               "Applies-to Doc. Type" := "Applies-to Doc. Type"::Invoice;
//               "Applies-to Doc. No." := SalesInvHeader."No.";
//             END;
//           END;
//           MODIFY(TRUE);
//         END;
//         SCMHeaderCreated := TRUE;
//     end;

//     [Scope('Internal')]
//     procedure CreateSalesCrMemoLine()
//     var
//         SalesInvLine: Record "113";
//     begin
//         PartialCreditLine := FALSE;
//         CLEAR(SalesLine);
//         WITH SalesLine DO BEGIN
//           INIT;
//           VALIDATE("Document Type",SalesHeader."Document Type");
//           VALIDATE("Document No.",SalesHeader."No.");
//           "Line No." := LineNo;
//           INSERT(TRUE);
//           IF NOT recItem.GET(EDICrMemoLine."Item No.") THEN BEGIN
//             ItemCrossRef.RESET;
//             ItemCrossRef.SETRANGE("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::Vendor);
//             ItemCrossRef.SETFILTER("Cross-Reference Type No.",'%1|%2',PurchInvHeader."Buy-from Vendor No.",PurchInvHeader."Pay-to Vendor No.");
//             ItemCrossRef.SETRANGE("Cross-Reference No.",EDICrMemoLine."Item No.");
//             IF ItemCrossRef.FINDFIRST THEN BEGIN
//               recItem.GET(ItemCrossRef."Item No.");
//             END ELSE BEGIN
//               ItemCrossRef.RESET;
//               ItemCrossRef.SETRANGE("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::Contract);
//               ItemCrossRef.SETRANGE("Cross-Reference Type No.",CostCentre);
//               ItemCrossRef.SETRANGE("Cross-Reference No.",EDICrMemoLine."Item No.");
//               IF ItemCrossRef.FINDFIRST THEN BEGIN
//                 recItem.GET(ItemCrossRef."Item No.");
//               END ELSE BEGIN
//                 //IF CostCentre <> EDISetup."CC Dimension Code for Spotless" THEN
//                 ERROR(Text0017,EDICrMemoLine."Item No.");
//               END;
//             END;
//           END;

//           SalesInvLineFound := FALSE;
//           SalesInvLine.RESET;
//           SalesInvLine.SETRANGE("Document No.",SalesInvHeader."No.");
//           SalesInvLine.SETRANGE(Type,SalesInvLine.Type::Item);
//           IF EDICrMemoLine."Invoice Line No." <> 0 THEN
//             SalesInvLine.SETRANGE("EDI Line No.",EDICrMemoLine."Invoice Line No.")
//           ELSE
//             SalesInvLine.SETRANGE("No.",recItem."No.");
//           IF SalesInvLine.FINDFIRST THEN BEGIN
//             SalesInvLineFound := TRUE;
//           END ELSE BEGIN
//             SalesInvLine.SETRANGE("EDI Line No.");
//             SalesInvLine.SETRANGE("No.");
//             SalesInvLine.SETRANGE("EDI Inv PK Line No.",EDICrMemoLine."Invoice Line No.");
//             IF SalesInvLine.FINDFIRST THEN BEGIN
//               SalesInvLineFound := TRUE;
//             END ELSE BEGIN
//               IF NOT (recItem."No." IN [EDISetup."Unsch. Weekday Delivery Code",EDISetup."Unsch. Weekend Delivery Code",EDISetup."Min. Order Value Charge Code",
//                                           EDISetup."Min. Order Qty Charge Code",EDISetup."Late Order Fee Code"]) THEN BEGIN          //#CW4.55
//                 EDIInvLine.RESET;
//                 EDIInvLine.SETRANGE("Entry No.",EDIInvHeader."Entry No.");
//                 EDIInvLine.SETRANGE("Item No.",EDICrMemoLine."Item No.");
//                 IF EDIInvLine.FINDFIRST THEN
//                   IF EDIInvLine.Approved THEN BEGIN
//                     SalesInvLine.SETRANGE("No.",recItem."No.");
//                     IF SalesInvLine.FINDFIRST THEN
//                       SalesInvLineFound := TRUE;
//                   END;
//               END;
//             END;
//           END;

//           IF SalesInvLineFound AND (EDICrMemoLine.Quantity <> 0) THEN BEGIN
//             IF recItem."No." <> SalesInvLine."No." THEN
//               ERROR(Text0018,recItem."No.",SalesInvLine."No.");
//             VALIDATE(Type,SalesInvLine.Type);
//             VALIDATE("No.",SalesInvLine."No.");
//             //VALIDATE(Description,SalesInvLine.Description);
//             Description :=SalesInvLine.Description;
//             VALIDATE("VAT Prod. Posting Group",SalesInvLine."VAT Prod. Posting Group");
//             "Random Weight Item" := SalesInvLine."Random Weight Item";                                            //HBSTG 20160902
//             VALIDATE(Quantity,EDICrMemoLine.Quantity);
//             SIItemUOM.RESET;
//             SIItemUOM.GET("No.",SalesInvLine."Unit of Measure Code");
//             ItemUOM.RESET;
//             IF SalesInvLine."EDI Invoice UOM" = EDICrMemoLine."Unit Of Measure Code" THEN BEGIN
//               ItemUOM.GET("No.",SalesInvLine."Unit of Measure Code");
//             END ELSE BEGIN
//               IF NOT ItemUOM.GET("No.",EDICrMemoLine."Unit Of Measure Code") THEN BEGIN
//                 ItemCrossRef.RESET;
//                 ItemCrossRef.SETRANGE(ItemCrossRef."Item No.","No.");
//                 ItemCrossRef.SETRANGE("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::Vendor);
//                 ItemCrossRef.SETFILTER("Cross-Reference Type No.",'%1',PurchInvHeader."Buy-from Vendor No.");
//                 ItemCrossRef.SETRANGE("Member Unit of Measure",EDICrMemoLine."Unit Of Measure Code");
//                 IF ItemCrossRef.FINDFIRST THEN BEGIN
//                   ItemUOM.RESET;
//                   IF NOT ItemUOM.GET("No.",ItemCrossRef."Unit of Measure") THEN
//                     ERROR(Text0021,EDICrMemoLine."Unit Of Measure Code",EDICrMemoLine."Item No.");
//                 END;
//               END;
//               IF SIItemUOM.Code <> ItemUOM.Code THEN BEGIN
//                 IF (SIItemUOM."UOM Type" = SIItemUOM."UOM Type"::Outer) AND (ItemUOM."UOM Type" = ItemUOM."UOM Type"::Inner) THEN
//                   PartialCreditLine := TRUE
//                 ELSE
//                   ERROR(Text0022,EDICrMemoLine."Unit Of Measure Code",EDICrMemoLine."Item No.");
//               END;
//             END;
//             VALIDATE("Unit of Measure Code",ItemUOM.Code);
//             VALIDATE("EDI Invoice UOM",SalesInvLine."EDI Invoice UOM");
//           END ELSE BEGIN
//             //HBSTG 2017-03-02: Commented code after approval from helen to stop the old Spotless business logic
//             /*
//             IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN BEGIN
//               VALIDATE(Type,Type::"G/L Account");
//               VALIDATE("No.",EDISetup."EDI Sales Cr Memo G/L Acc No.");
//               IF EDICrMemoLine.Quantity <> 0 THEN
//                 VALIDATE(Quantity,EDICrMemoLine.Quantity)
//               ELSE
//                 VALIDATE(Quantity,1);
//               VALIDATE(Description,EDICrMemoHeader.Description);
//             END ELSE
//             */
//             //#12352 Start:
//             IF NOT SalesInvLineFound THEN
//               ERROR(Text0011,EDICrMemoLine."Invoice Line No.")
//             ELSE
//               ERROR(Text0023,EDICrMemoLine."Invoice Line No.",EDICrMemoLine."Credit Memo ID");
//             //#12352 End:
//           END;
//           VALIDATE("Return Reason Code",EDICrMemoLine."Reason Code");
//           VALIDATE("Reason Description",EDICrMemoLine."Reason Description");
//           CheckCreditQtyWithInvQty(SalesInvLine);                                                          //#CW4.55
//           IF PartialCreditLine THEN BEGIN
//             //HBSRP 2018-06-15:
//             //IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN
//               //VALIDATE("Unit Price",ROUND(EDICrMemoLine."Marked-down Unit Price" * (100 + BillToCust."Mark Up Percentage") / 100 * (SalesInvLine.Quantity / SalesInvLine."Quantity (Base)"),0.01))
//             //ELSE
//             VALIDATE("Unit Price",ROUND(SalesInvLine."Unit Price" * SalesInvLine.Quantity / SalesInvLine."Quantity (Base)",0.01));
//             VALIDATE("EDI Partial Credit",TRUE);
//           END ELSE BEGIN
//             //HBSRP 2018-06-15:
//             //IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN
//               //VALIDATE("Unit Price",ROUND(EDICrMemoLine."Marked-down Unit Price" * (100 + BillToCust."Mark Up Percentage") / 100,0.01))
//             //ELSE
//             VALIDATE("Unit Price",SalesInvLine."Unit Price");
//           END;
//           //VALIDATE(Description,SalesInvLine.Description);                                                       //Copy becuase of Auto created item
//           Description := SalesInvLine.Description;
//           //ReSRP 2017-10-14 Start:
//           "Markup Level-1 Amount" := SalesInvLine."Markup Level-1 Amount";
//           "Markup Level-2 Amount" := SalesInvLine."Markup Level-2 Amount";
//           "Markup Level-3 Amount" := SalesInvLine."Markup Level-3 Amount";
//           VALIDATE("Customer End Unit Price",SalesInvLine."Customer End Unit Price");
//           //ReSRP 2017-10-14 End:
//           IF recItem."No." = EDISetup."Unsch. Weekday Delivery Code" THEN
//             "Line Type" := "Line Type"::"Unsch Weekday Delivery";
//           IF recItem."No." = EDISetup."Unsch. Weekend Delivery Code" THEN
//             "Line Type" := "Line Type"::"Unsch Weekend Delivery";
//           IF recItem."No." = EDISetup."Min. Order Value Charge Code" THEN
//             "Line Type" := "Line Type"::"Minimum Order Value Charge";
//           //#CW4.55 Start:
//           IF recItem."No." = EDISetup."Min. Order Qty Charge Code" THEN
//             "Line Type" := "Line Type"::MOQNA;
//           IF recItem."No." = EDISetup."Late Order Fee Code" THEN
//             "Line Type" := "Line Type"::LOF;
//           //#CW4.55 End:
//           VALIDATE("EDI Entry No.",EDICrMemoLine."Entry No.");
//           VALIDATE("EDI Line No.",EDICrMemoLine."Invoice Line No.");
//           VALIDATE("EDI Cr Memo ID",EDICrMemoLine."Credit Memo ID");
//           VALIDATE("EDI Invoice Line No.",EDICrMemoLine."Invoice Line No.");
//           MODIFY(TRUE);
//         END;

//     end;

//     [Scope('Internal')]
//     procedure CreatePurchCrMemoHeader()
//     begin
//         CLEAR(PurchHeader);
//         WITH PurchHeader DO BEGIN
//           INIT;
//           VALIDATE("Document Type",PurchHeader."Document Type"::"Credit Memo");
//           VALIDATE("No.",NoSeriesMgmt.GetNextNo(PurchSetup."Credit Memo Nos.",EDICrMemoHeader."Credit Memo Date",TRUE));
//           INSERT(TRUE);
//           VALIDATE("Buy-from Vendor No.",Vend."No.");
//           VALIDATE("Pay-to Vendor No.",PayToVend."No.");
//           VALIDATE("Order Date",EDICrMemoHeader."Credit Memo Date");
//           VALIDATE("Posting Date",EDICrMemoHeader."Credit Memo Date");
//           VALIDATE("Document Date",EDICrMemoHeader."Credit Memo Date");
//           VALIDATE("Vendor Cr. Memo No.",EDICrMemoHeader."Credit Memo ID");
//           VALIDATE("Location Code",Loc.Code);
//           VALIDATE("No. Series",PurchSetup."Credit Memo Nos.");
//           VALIDATE("Posting Description",'Credit Memo ' + EDICrMemoHeader."Credit Memo ID");
//           VALIDATE("Reason Code",EDISetup."Reason Code EDI Cr Memo");

//           VALIDATE("Sell-to Customer No.",Cust."No.");
//           VALIDATE("Ship-to Code",PurchInvHeader."Ship-to Code");
//           IF PurchInvHeader."Ship-to Name" <> '' THEN
//             VALIDATE("Ship-to Name",PurchInvHeader."Ship-to Name");
//           IF PurchInvHeader."Ship-to Name 2" <> '' THEN
//             VALIDATE("Ship-to Name 2",PurchInvHeader."Ship-to Name 2");
//           IF PurchInvHeader."Ship-to Address" <> '' THEN
//             VALIDATE("Ship-to Address",PurchInvHeader."Ship-to Address");
//           IF PurchInvHeader."Ship-to Address 2" <> '' THEN
//             VALIDATE("Ship-to Address 2",PurchInvHeader."Ship-to Address 2");
//           IF PurchInvHeader."Ship-to City" <> '' THEN
//             VALIDATE("Ship-to City",PurchInvHeader."Ship-to City");
//           IF PurchInvHeader."Ship-to Contact" <> '' THEN
//             VALIDATE("Ship-to Contact",PurchInvHeader."Ship-to Contact");
//           IF PurchInvHeader."Ship-to Post Code" <> '' THEN
//             VALIDATE("Ship-to Post Code",PurchInvHeader."Ship-to Post Code");
//           IF PurchInvHeader."Ship-to County" <> '' THEN
//             VALIDATE("Ship-to County",PurchInvHeader."Ship-to County");
//           IF PurchInvHeader."Ship-to Country/Region Code" <> '' THEN
//             VALIDATE("Ship-to Country/Region Code",PurchInvHeader."Ship-to Country/Region Code");

//           "Responsibility Center" := PurchInvHeader."Responsibility Center";
//           VALIDATE("EDI Entry No.",EDICrMemoHeader."Entry No.");
//           VALIDATE("EDI Cr Memo ID",EDICrMemoHeader."Credit Memo ID");
//           VALIDATE("Shortcut Dimension 1 Code",CostCentre);
//           IF BillToCust."No." <>'' THEN
//             VALIDATE("VAT Bus. Posting Group",BillToCust."VAT Bus. Posting Group")
//           ELSE
//             VALIDATE("VAT Bus. Posting Group",Cust."VAT Bus. Posting Group");
//           VALIDATE("Applies-to Ext.Doc.No.",EDICrMemoHeader."Invoice ID");
//           //IF CostCentre <> EDISetup."CC Dimension Code for Spotless" THEN BEGIN
//           IF ContractDimVal."Allow EDI Credit Application" THEN BEGIN
//             IF NOT VLEClosed THEN BEGIN
//               "Applies-to Doc. Type" := "Applies-to Doc. Type"::Invoice;
//               "Applies-to Doc. No." := PurchInvHeader."No.";
//             END;
//           END;
//           MODIFY(TRUE);
//         END;
//     end;

//     [Scope('Internal')]
//     procedure CreatePurchCrMemoLine()
//     var
//         PurchInvLine: Record "123";
//     begin
//         CLEAR(PurchLine);
//         WITH PurchLine DO BEGIN
//           INIT;
//           VALIDATE("Document Type",PurchHeader."Document Type");
//           VALIDATE("Document No.",PurchHeader."No.");
//           "Line No." := LineNo;
//           INSERT(TRUE);
//           PurchInvLineFound := FALSE;
//           PurchInvLine.RESET;
//           PurchInvLine.SETRANGE("Document No.",PurchInvHeader."No.");
//           PurchInvLine.SETRANGE(Type,PurchInvLine.Type::Item);
//           IF EDICrMemoLine."Invoice Line No." <> 0 THEN
//             PurchInvLine.SETRANGE("EDI Line No.",EDICrMemoLine."Invoice Line No.")
//           ELSE
//             PurchInvLine.SETRANGE("No.",recItem."No.");
//           IF PurchInvLine.FINDFIRST THEN BEGIN
//             PurchInvLineFound := TRUE;
//           END ELSE BEGIN
//             PurchInvLine.SETRANGE("EDI Line No.");
//             PurchInvLine.SETRANGE("No.");
//             PurchInvLine.SETRANGE("EDI Inv PK Line No.",EDICrMemoLine."Invoice Line No.");
//             IF PurchInvLine.FINDFIRST THEN BEGIN
//               PurchInvLineFound := TRUE;
//             END ELSE BEGIN
//               IF NOT (recItem."No." IN [EDISetup."Unsch. Weekday Delivery Code",EDISetup."Unsch. Weekend Delivery Code",EDISetup."Min. Order Value Charge Code",
//                                           EDISetup."Min. Order Qty Charge Code",EDISetup."Late Order Fee Code"]) THEN BEGIN  //#CW4.55
//                 EDIInvLine.RESET;
//                 EDIInvLine.SETRANGE("Entry No.",EDIInvHeader."Entry No.");
//                 EDIInvLine.SETRANGE("Item No.",EDICrMemoLine."Item No.");
//                 IF EDIInvLine.FINDFIRST THEN
//                   IF EDIInvLine.Approved THEN BEGIN
//                     PurchInvLine.SETRANGE("No.",recItem."No.");
//                     IF PurchInvLine.FINDFIRST THEN
//                       PurchInvLineFound := TRUE;
//                   END;
//               END;
//             END;
//           END;
//           IF PurchInvLineFound AND (EDICrMemoLine.Quantity <> 0) THEN BEGIN
//             IF recItem."No." <> PurchInvLine."No." THEN
//               ERROR(Text0018,recItem."No.",PurchInvLine."No.");
//             VALIDATE(Type,PurchInvLine.Type);
//             VALIDATE("No.",PurchInvLine."No.");
//             //VALIDATE(Description,PurchInvLine.Description);
//             Description :=PurchInvLine.Description;
//             VALIDATE("VAT Prod. Posting Group",PurchInvLine."VAT Prod. Posting Group");
//             "Random Weight Item" := PurchInvLine."Random Weight Item";                                            //HBSTG 20160902
//             VALIDATE(Quantity,EDICrMemoLine.Quantity);
//             VALIDATE("Unit of Measure Code",ItemUOM.Code);
//             VALIDATE("EDI Invoice UOM",PurchInvLine."EDI Invoice UOM");
//           END ELSE BEGIN
//             //HBSTG 2017-03-02: Commented code after approval from helen to stop the old Spotless business logic
//             /*
//             IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN BEGIN
//               VALIDATE(Type,Type::"G/L Account");
//               VALIDATE("No.",EDISetup."EDI Purch Cr Memo G/L Acc No.");
//               IF EDICrMemoLine.Quantity <> 0 THEN
//                 VALIDATE(Quantity,EDICrMemoLine.Quantity)
//               ELSE
//                 VALIDATE(Quantity,1);
//               VALIDATE(Description,EDICrMemoHeader.Description);
//             END ELSE
//             */
//             ERROR(Text0011,EDICrMemoLine."Invoice Line No.");
//           END;
//           VALIDATE("Return Reason Code",EDICrMemoLine."Reason Code");
//           VALIDATE("Reason Description",EDICrMemoLine."Reason Description");
//           IF PartialCreditLine THEN BEGIN
//             //HBSRP 2018-06-15:
//             //IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN
//               //VALIDATE("Direct Unit Cost",ROUND(EDICrMemoLine."Marked-down Unit Price" * (PurchInvLine.Quantity / PurchInvLine."Quantity (Base)"),0.01))
//             //ELSE
//             VALIDATE("Direct Unit Cost",ROUND(PurchInvLine."Direct Unit Cost" * (PurchInvLine.Quantity / PurchInvLine."Quantity (Base)"),0.01));
//             VALIDATE("EDI Partial Credit",TRUE);
//           END ELSE BEGIN
//             //HBSRP 2018-06-15:
//             //IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN BEGIN
//               //VALIDATE("Direct Unit Cost",EDICrMemoLine."Marked-down Unit Price")
//             //END ELSE
//             VALIDATE("Direct Unit Cost",PurchInvLine."Direct Unit Cost");
//           END;
//           //ReSRP 2017-10-14 Start:
//           "Markup Level-1 Amount" := PurchInvLine."Markup Level-1 Amount";
//           "Markup Level-2 Amount" := PurchInvLine."Markup Level-2 Amount";
//           "Markup Level-3 Amount" := PurchInvLine."Markup Level-3 Amount";
//           VALIDATE("Vendor End Unit Cost",PurchInvLine."Vendor End Unit Cost");
//           //ReSRP 2017-10-14 End:

//           IF "No." = EDISetup."Unsch. Weekday Delivery Code" THEN
//             "Line Type" := "Line Type"::"Unsch Weekday Delivery";
//           IF "No." = EDISetup."Unsch. Weekend Delivery Code" THEN
//             "Line Type" := "Line Type"::"Unsch Weekend Delivery";
//           IF "No." = EDISetup."Min. Order Value Charge Code" THEN
//             "Line Type" := "Line Type"::"Minimum Order Value Charge";
//           //#CW4.55 Start:
//           IF "No." = EDISetup."Min. Order Qty Charge Code" THEN
//             "Line Type" := "Line Type"::MOQNA;
//           IF "No." = EDISetup."Late Order Fee Code" THEN
//             "Line Type" := "Line Type"::LOF;
//           //#CW4.55 End:

//           VALIDATE("EDI Entry No.",EDICrMemoLine."Entry No.");
//           VALIDATE("EDI Line No.",EDICrMemoLine."Invoice Line No.");
//           VALIDATE("EDI Cr Memo ID",EDICrMemoLine."Credit Memo ID");
//           VALIDATE("EDI Invoice Line No.",EDICrMemoLine."Invoice Line No.");
//           MODIFY(TRUE);
//         END;

//     end;

//     [Scope('Internal')]
//     procedure CreateSalesInvoiceHeader()
//     begin
//         //HBSTG 2017-03-02: Commented code after approval from helen to stop the old Spotless business logic
//         /*
//         CLEAR(SalesHeader);
//         WITH SalesHeader DO BEGIN
//           RESET;
//           INIT;
//           VALIDATE("Document Type",SalesHeader."Document Type"::Invoice);
//           VALIDATE("No.",NoSeriesMgmt.GetNextNo(SalesSetup."Invoice Nos.",EDICrMemoHeader."Credit Memo Date",TRUE));
//           INSERT(TRUE);
//           VALIDATE("Sell-to Customer No.",Cust."No.");
//           VALIDATE("Bill-to Customer No.",BillToCust."No.");
//           VALIDATE("Order Date",EDICrMemoHeader."Credit Memo Date");
//           VALIDATE("Posting Date",EDICrMemoHeader."Credit Memo Date");
//           VALIDATE("Document Date",EDICrMemoHeader."Credit Memo Date");
//           VALIDATE("External Document No.",EDICrMemoHeader."Credit Memo ID");
//           VALIDATE("Location Code",Loc.Code);
//           VALIDATE("No. Series",SalesSetup."Invoice Nos.");
//           VALIDATE("Posting Description",'Invoice ' + EDICrMemoHeader."Credit Memo ID");
//           VALIDATE("Reason Code",EDISetup."Reason Code Cr Memo");

//           IF SalesInvHeader."Bill-to Name" <> '' THEN
//             VALIDATE("Bill-to Name",SalesInvHeader."Bill-to Name");
//           IF SalesInvHeader."Bill-to Name 2" <> '' THEN
//             VALIDATE("Bill-to Name 2",SalesInvHeader."Bill-to Name 2");
//           IF SalesInvHeader."Bill-to Address" <> '' THEN
//             VALIDATE("Bill-to Address",SalesInvHeader."Bill-to Address");
//           IF SalesInvHeader."Bill-to Address 2" <> '' THEN
//             VALIDATE("Bill-to Address 2",SalesInvHeader."Bill-to Address 2");
//           IF SalesInvHeader."Bill-to City" <> '' THEN
//             VALIDATE("Bill-to City",SalesInvHeader."Bill-to City");
//           IF SalesInvHeader."Bill-to Contact" <> '' THEN
//             VALIDATE("Bill-to Contact",SalesInvHeader."Bill-to Contact");
//           IF SalesInvHeader."Bill-to Post Code" <> '' THEN
//             VALIDATE("Bill-to Post Code",SalesInvHeader."Bill-to Post Code");
//           IF SalesInvHeader."Bill-to County" <> '' THEN
//             VALIDATE("Bill-to County",SalesInvHeader."Bill-to County");
//           IF SalesInvHeader."Bill-to Country/Region Code" <> '' THEN
//             VALIDATE("Bill-to Country/Region Code",SalesInvHeader."Bill-to Country/Region Code");

//           IF SalesInvHeader."Ship-to Code" <> '' THEN
//             VALIDATE("Ship-to Code",SalesInvHeader."Ship-to Code");
//           IF SalesInvHeader."Ship-to Name" <> '' THEN
//             VALIDATE("Ship-to Name",SalesInvHeader."Ship-to Name");
//           IF SalesInvHeader."Ship-to Name 2" <> '' THEN
//             VALIDATE("Ship-to Name 2",SalesInvHeader."Ship-to Name 2");
//           IF SalesInvHeader."Ship-to Address" <> '' THEN
//             VALIDATE("Ship-to Address",SalesInvHeader."Ship-to Address");
//           IF SalesInvHeader."Ship-to Address 2" <> '' THEN
//             VALIDATE("Ship-to Address 2",SalesInvHeader."Ship-to Address 2");
//           IF SalesInvHeader."Ship-to City" <> '' THEN
//             VALIDATE("Ship-to City",SalesInvHeader."Ship-to City");
//           IF SalesInvHeader."Ship-to Contact" <> '' THEN
//             VALIDATE("Ship-to Contact",SalesInvHeader."Ship-to Contact");
//           IF SalesInvHeader."Ship-to Post Code" <> '' THEN
//             VALIDATE("Ship-to Post Code",SalesInvHeader."Ship-to Post Code");
//           IF SalesInvHeader."Ship-to County" <> '' THEN
//             VALIDATE("Ship-to County",SalesInvHeader."Ship-to County");
//           IF SalesInvHeader."Ship-to Country/Region Code" <> '' THEN
//             VALIDATE("Ship-to Country/Region Code",SalesInvHeader."Ship-to Country/Region Code");

//           VALIDATE("EDI Entry No.",EDICrMemoHeader."Entry No.");
//           VALIDATE("EDI Cr Memo ID",EDICrMemoHeader."Credit Memo ID");

//           MODIFY(TRUE);
//         END;
//         SIHeaderCreated := TRUE;
//         */

//     end;

//     [Scope('Internal')]
//     procedure CreateSalesInvoiceLine()
//     var
//         SalesInvLine: Record "113";
//     begin
//         //HBSTG 2017-03-02: Commented code after approval from helen to stop the old Spotless business logic
//         /*
//         CLEAR(SalesLine);
//         WITH SalesLine DO BEGIN
//           INIT;
//           VALIDATE("Document Type",SalesHeader."Document Type");
//           VALIDATE("Document No.",SalesHeader."No.");
//           "Line No." := LineNo;
//           INSERT(TRUE);
//           SalesInvLine.RESET;
//           SalesInvLine.SETRANGE("Document No.",SalesInvHeader."No.");
//           SalesInvLine.SETRANGE(Type,SalesInvLine.Type::Item);
//           SalesInvLine.SETRANGE("EDI Line No.",EDICrMemoLine."Invoice Line No.");
//           IF SalesInvLine.FINDFIRST AND (EDICrMemoLine.Quantity <> 0) THEN BEGIN
//             VALIDATE(Type,SalesInvLine.Type);
//             VALIDATE("No.",SalesInvLine."No.");
//             VALIDATE(Description,SalesInvLine.Description);
//             VALIDATE("VAT Prod. Posting Group",SalesInvLine."VAT Prod. Posting Group");
//             VALIDATE(Quantity,EDICrMemoLine.Quantity);
//             VALIDATE("Unit of Measure Code",SalesInvLine."Unit of Measure Code");
//           END ELSE BEGIN
//             VALIDATE(Type,Type::"G/L Account");
//             VALIDATE("No.",EDISetup."EDI Sales Cr Memo G/L Acc No.");
//             IF EDICrMemoLine.Quantity <> 0 THEN
//               VALIDATE(Quantity,EDICrMemoLine.Quantity)
//             ELSE
//               VALIDATE(Quantity,1);
//             VALIDATE(Description,EDICrMemoHeader.Description);
//           END;
//           VALIDATE("Return Reason Code",EDICrMemoLine."Reason Code");
//           VALIDATE("Reason Description",EDICrMemoLine."Reason Description");
//           VALIDATE("EDI Entry No.",EDICrMemoLine."Entry No.");
//           VALIDATE("EDI Line No.",EDICrMemoLine."Invoice Line No.");
//           VALIDATE("EDI Cr Memo ID",EDICrMemoLine."Credit Memo ID");
//           VALIDATE("EDI Invoice Line No.",EDICrMemoLine."Invoice Line No.");
//           VALIDATE("Unit Price",ROUND(-1 * EDICrMemoLine."Marked-down Unit Price" * (100 + BillToCust."Mark Up Percentage") / 100,0.01));
//           MODIFY(TRUE);
//         END;
//         */

//     end;

//     [Scope('Internal')]
//     procedure CreatePurchInvoiceHeader()
//     begin
//         //HBSTG 2017-03-02: Commented code after approval from helen to stop the old Spotless business logic
//         /*
//         CLEAR(PurchHeader);
//         WITH PurchHeader DO BEGIN
//           INIT;
//           VALIDATE("Document Type",PurchHeader."Document Type"::Invoice);
//           VALIDATE("No.",NoSeriesMgmt.GetNextNo(PurchSetup."Invoice Nos.",EDICrMemoHeader."Credit Memo Date",TRUE));
//           INSERT(TRUE);
//           VALIDATE("Buy-from Vendor No.",Vend."No.");
//           VALIDATE("Pay-to Vendor No.",PayToVend."No.");
//           VALIDATE("Order Date",EDICrMemoHeader."Credit Memo Date");
//           VALIDATE("Posting Date",EDICrMemoHeader."Credit Memo Date");
//           VALIDATE("Document Date",EDICrMemoHeader."Credit Memo Date");
//           VALIDATE("Vendor Cr. Memo No.",EDICrMemoHeader."Credit Memo ID");
//           VALIDATE("Location Code",Loc.Code);
//           VALIDATE("No. Series",PurchSetup."Invoice Nos.");
//           VALIDATE("Posting Description",'Credit Memo ' + EDICrMemoHeader."Credit Memo ID");
//           VALIDATE("Reason Code",EDISetup."Reason Code Cr Memo");

//           VALIDATE("Sell-to Customer No.",Cust."No.");
//           VALIDATE("Ship-to Code",PurchInvHeader."Ship-to Code");
//           IF PurchInvHeader."Ship-to Name" <> '' THEN
//             VALIDATE("Ship-to Name",PurchInvHeader."Ship-to Name");
//           IF PurchInvHeader."Ship-to Name 2" <> '' THEN
//             VALIDATE("Ship-to Name 2",PurchInvHeader."Ship-to Name 2");
//           IF PurchInvHeader."Ship-to Address" <> '' THEN
//             VALIDATE("Ship-to Address",PurchInvHeader."Ship-to Address");
//           IF PurchInvHeader."Ship-to Address 2" <> '' THEN
//             VALIDATE("Ship-to Address 2",PurchInvHeader."Ship-to Address 2");
//           IF PurchInvHeader."Ship-to City" <> '' THEN
//             VALIDATE("Ship-to City",PurchInvHeader."Ship-to City");
//           IF PurchInvHeader."Ship-to Contact" <> '' THEN
//             VALIDATE("Ship-to Contact",PurchInvHeader."Ship-to Contact");
//           IF PurchInvHeader."Ship-to Post Code" <> '' THEN
//             VALIDATE("Ship-to Post Code",PurchInvHeader."Ship-to Post Code");
//           IF PurchInvHeader."Ship-to County" <> '' THEN
//             VALIDATE("Ship-to County",PurchInvHeader."Ship-to County");
//           IF PurchInvHeader."Ship-to Country/Region Code" <> '' THEN
//             VALIDATE("Ship-to Country/Region Code",PurchInvHeader."Ship-to Country/Region Code");

//           VALIDATE("EDI Entry No.",EDICrMemoHeader."Entry No.");
//           VALIDATE("EDI Cr Memo ID",EDICrMemoHeader."Credit Memo ID");
//           VALIDATE("Shortcut Dimension 1 Code",CostCentre);
//           IF BillToCust."No." <>'' THEN
//             VALIDATE("VAT Bus. Posting Group",BillToCust."VAT Bus. Posting Group")
//           ELSE
//             VALIDATE("VAT Bus. Posting Group",Cust."VAT Bus. Posting Group");
//           MODIFY(TRUE);
//         END;
//         */

//     end;

//     [Scope('Internal')]
//     procedure CreatePurchInvoiceLine()
//     var
//         PurchInvLine: Record "123";
//     begin
//         //HBSTG 2017-03-02: Commented code after approval from helen to stop the old Spotless business logic
//         /*
//         CLEAR(PurchLine);
//         WITH PurchLine DO BEGIN
//           INIT;
//           VALIDATE("Document Type",PurchHeader."Document Type");
//           VALIDATE("Document No.",PurchHeader."No.");
//           "Line No." := LineNo;
//           INSERT(TRUE);
//           PurchInvLine.RESET;
//           PurchInvLine.SETRANGE("Document No.",PurchInvHeader."No.");
//           PurchInvLine.SETRANGE(Type,PurchInvLine.Type::Item);
//           PurchInvLine.SETRANGE("EDI Line No.",EDICrMemoLine."Invoice Line No.");
//           IF PurchInvLine.FINDFIRST AND (EDICrMemoLine.Quantity <> 0) THEN BEGIN
//             VALIDATE(Type,PurchInvLine.Type);
//             VALIDATE("No.",PurchInvLine."No.");
//             VALIDATE(Description,PurchInvLine.Description);
//             VALIDATE("VAT Prod. Posting Group",PurchInvLine."VAT Prod. Posting Group");
//             VALIDATE(Quantity,EDICrMemoLine.Quantity);
//             VALIDATE("Unit of Measure Code",PurchInvLine."Unit of Measure Code");
//           END ELSE BEGIN
//             VALIDATE(Type,Type::"G/L Account");
//             VALIDATE("No.",EDISetup."EDI Purch Cr Memo G/L Acc No.");
//             IF EDICrMemoLine.Quantity <> 0 THEN
//               VALIDATE(Quantity,EDICrMemoLine.Quantity)
//             ELSE
//               VALIDATE(Quantity,1);
//             VALIDATE(Description,EDICrMemoHeader.Description);
//           END;
//           VALIDATE("Return Reason Code",EDICrMemoLine."Reason Code");
//           VALIDATE("Reason Description",EDICrMemoLine."Reason Description");
//           VALIDATE("Direct Unit Cost",(-1 * EDICrMemoLine."Marked-down Unit Price"));
//           VALIDATE("EDI Entry No.",EDICrMemoLine."Entry No.");
//           VALIDATE("EDI Line No.",EDICrMemoLine."Invoice Line No.");
//           VALIDATE("EDI Cr Memo ID",EDICrMemoLine."Credit Memo ID");
//           VALIDATE("EDI Invoice Line No.",EDICrMemoLine."Invoice Line No.");
//           MODIFY(TRUE);
//         END;
//         */

//     end;

//     [Scope('Internal')]
//     procedure GetDocDimSetID(LDimID: Integer): Integer
//     var
//         DimensionSetEntry: Record "480";
//         DimVal: Record "349";
//         TempDimBuffer: Record "360" temporary;
//         TempDimSetEntry: Record "480" temporary;
//         DimMgt: Codeunit "408";
//     begin
//         IF LDimID <> 0  THEN BEGIN
//           DimensionSetEntry.RESET;
//           DimensionSetEntry.SETRANGE("Dimension Set ID",LDimID);
//           IF DimensionSetEntry.FINDSET THEN
//           REPEAT
//             TempDimSetEntry."Dimension Code" := DimensionSetEntry."Dimension Code";
//             TempDimSetEntry."Dimension Value Code" := DimensionSetEntry."Dimension Value Code";
//             TempDimSetEntry."Dimension Value ID" := DimensionSetEntry."Dimension Value ID";
//             TempDimSetEntry.INSERT;
//           UNTIL DimensionSetEntry.NEXT = 0;
//           IF NOT DimensionSetEntry.GET(LDimID,EDISetup."Cost Centre Dimension Code") THEN BEGIN
//             DimVal.GET(EDISetup."Cost Centre Dimension Code",CostCentre);
//             TempDimSetEntry."Dimension Code" := DimVal."Dimension Code";
//             TempDimSetEntry."Dimension Value Code" := DimVal.Code;
//             TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
//             TempDimSetEntry.INSERT;
//             NewDimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
//             EXIT(NewDimSetID);
//           END ELSE
//             EXIT(LDimID);;
//         END ELSE BEGIN
//           DimVal.GET(EDISetup."Cost Centre Dimension Code",CostCentre);
//           TempDimSetEntry."Dimension Code" := DimVal."Dimension Code";
//           TempDimSetEntry."Dimension Value Code" := DimVal.Code;
//           TempDimSetEntry."Dimension Value ID" := DimVal."Dimension Value ID";
//           TempDimSetEntry.INSERT;
//           NewDimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry);
//           EXIT(NewDimSetID);
//         END;
//     end;

//     [Scope('Internal')]
//     procedure UpdateOrderLineForFeeAndIncentives()
//     var
//         lvSalesLine: Record "37";
//         lvPaymentMethod: Record "289";
//         lvNoOfCarton: Decimal;
//         lvNoOfBrokenCarton: Decimal;
//         lvLineAmount: Decimal;
//         SalesInvLine: Record "113";
//         LocLineNo: Integer;
//         PurchInvLine: Record "123";
//         lvPurchLine: Record "39";
//         lvPurchLine2: Record "39";
//         lvItemLineAmount: Decimal;
//         lvMarkupLevel: Option "Level-1","Level-2","Level-3";
//         lvMarkupLevelTotalPurchAmt: Decimal;
//         lvMarkupLevelTotalSalesAmt: Decimal;
//         lvNoOfBag: Decimal;
//     begin
//         lvNoOfCarton := 0;
//         lvNoOfBrokenCarton := 0;
//         lvLineAmount := 0;
//         lvItemLineAmount := 0;
//         LocLineNo := 0;
//         lvNoOfBag := 0;                                                                                    //#CW4.55

//         lvSalesLine.RESET;
//         lvSalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
//         lvSalesLine.SETRANGE("Document No.",SalesHeader."No.");
//         lvSalesLine.SETRANGE(Type,lvSalesLine.Type::Item);
//         lvSalesLine.SETRANGE("EDI Partial Credit",FALSE);                                                  //HBSRP 2016-05-12
//         lvSalesLine.SETFILTER("Line Type",'%1|%2',lvSalesLine."Line Type"::" ",lvSalesLine."Line Type"::"Store Allocation");
//         IF lvSalesLine.FINDSET THEN
//           REPEAT
//             IF ReturnReason.GET(lvSalesLine."Return Reason Code") THEN
//               IF NOT ReturnReason."Do Not Credit Carton" THEN BEGIN
//                 IF NOT lvSalesLine."Random Weight Item" THEN BEGIN                                                       //HBSTG 20160902
//                   IF lvSalesLine."Unit of Measure Code" = EDISetup."Carton Unit of Measure" THEN
//                     lvNoOfCarton += lvSalesLine.Quantity
//                   ELSE IF (lvSalesLine."Unit of Measure Code" = EDISetup."Bag Unit of Measure") AND ContractDimVal."Allow BAG Seperate UOM" THEN                       //#CW4.55
//                     lvNoOfBag += lvSalesLine.Quantity
//                   ELSE
//                     lvNoOfBrokenCarton += lvSalesLine.Quantity;
//                 END ELSE BEGIN
//                   lvNoOfCarton += lvSalesLine."Quantity (Outer)";
//                 END;
//               END;
//           UNTIL lvSalesLine.NEXT = 0;

//         //ReSRP 2017-10-10 Start: Add Lines for Markup based on Sales Invoice
//         lvSalesLine.RESET;
//         lvSalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
//         lvSalesLine.SETRANGE("Document No.",SalesHeader."No.");
//         IF lvSalesLine.FINDLAST THEN
//           LocLineNo := lvSalesLine."Line No.";

//         SalesInvLine.RESET;
//         SalesInvLine.SETRANGE("Document No.",SalesInvHeader."No.");
//         SalesInvLine.SETFILTER(Type,'<>%1',SalesInvLine.Type::" ");                                        //HBSTG 2014-03-12: Fix for correction of wrongly posted sales invoices
//         SalesInvLine.SETFILTER("Line Type",'%1|%2|%3',
//                                             SalesInvLine."Line Type"::MU1,
//                                                SalesInvLine."Line Type"::MU2,
//                                                   SalesInvLine."Line Type"::MU3);
//         IF SalesInvLine.FINDSET THEN BEGIN
//           REPEAT
//             LocLineNo +=10000;
//             WITH lvSalesLine DO BEGIN
//               RESET;
//               INIT;
//               VALIDATE("Document Type",SalesHeader."Document Type");
//               VALIDATE("Document No.",SalesHeader."No.");
//               "Line No.":=  LocLineNo;
//               INSERT(TRUE);
//               VALIDATE(Type,SalesInvLine.Type);
//               SetHideValidationDialog(TRUE);
//               VALIDATE("No.",SalesInvLine."No.");
//               VALIDATE(Quantity,SalesInvLine.Quantity);
//               VALIDATE("Unit of Measure Code",SalesInvLine."Unit of Measure Code");
//               lvMarkupLevelTotalSalesAmt := 0;
//               lvMarkupLevelTotalSalesAmt := FindSalesMarkupLevelPrice(SalesInvLine."Line Type",SalesInvLine."VAT %");
//               VALIDATE("Unit Price",lvMarkupLevelTotalSalesAmt);
//               VALIDATE("Line Type",SalesInvLine."Line Type");
//               VALIDATE("EDI Line No.",SalesInvLine."Line No.");
//               MODIFY(TRUE);
//             END;
//           UNTIL SalesInvLine.NEXT = 0;
//         END;
//         //ReSRP 2017-10-10 End:

//         //Add Lines for Fees & Incentive based on Sales Invoice
//         lvSalesLine.RESET;
//         lvSalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
//         lvSalesLine.SETRANGE("Document No.",SalesHeader."No.");
//         IF lvSalesLine.FINDLAST THEN
//           LocLineNo := lvSalesLine."Line No.";

//         SalesInvLine.RESET;
//         SalesInvLine.SETRANGE("Document No.",SalesInvHeader."No.");
//         SalesInvLine.SETFILTER(Type,'<>%1',SalesInvLine.Type::" ");                                        //HBSTG 2014-03-12: Fix for correction of wrongly posted sales invoices
//         //#CW4.55 Start:
//         /*
//         SalesInvLine.SETFILTER("Line Type",'%1|%2|%3|%4|%5|%6|%7|%8|%9|%10',
//                                             SalesInvLine."Line Type"::"Case Rate",
//                                                SalesInvLine."Line Type"::"Broken Case Rate",
//                                                   SalesInvLine."Line Type"::"Carton Freight",
//                                                      SalesInvLine."Line Type"::"Carton Case Income",
//                                                         SalesInvLine."Line Type"::"Direct Debit Income",
//                                                            SalesInvLine."Line Type"::"Online Order Income",
//                                                               SalesInvLine."Line Type"::"CW Bad Debt",
//                                                                  SalesInvLine."Line Type"::"MOQ Incentive",
//                                                                     SalesInvLine."Line Type"::"Direct Debit Incentive",
//                                                                        SalesInvLine."Line Type"::"Online Order Incentive");
//         */
//         SalesInvLine.SETFILTER("Line Type",'<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8&<>%9&<>%10',
//                                          SalesInvLine."Line Type"::" ",
//                                            SalesInvLine."Line Type"::"Store Allocation",
//                                              SalesInvLine."Line Type"::MOQNA,
//                                                SalesInvLine."Line Type"::"Credit Card Surcharge",
//                                                  SalesInvLine."Line Type"::"Unsch Weekday Delivery",
//                                                    SalesInvLine."Line Type"::"Unsch Weekend Delivery",
//                                                      SalesInvLine."Line Type"::"CW User Pay",
//                                                        SalesInvLine."Line Type"::"Minimum Order Value Charge",
//                                                           SalesInvLine."Line Type"::MU2,
//                                                              SalesInvLine."Line Type"::LOF);

//         //#CW4.55 End:
//         IF SalesInvLine.FINDSET THEN BEGIN
//           REPEAT
//             LocLineNo +=10000;
//             WITH lvSalesLine DO BEGIN
//               RESET;
//               INIT;
//               VALIDATE("Document Type",SalesHeader."Document Type");
//               VALIDATE("Document No.",SalesHeader."No.");
//               "Line No.":=  LocLineNo;
//               INSERT(TRUE);
//               VALIDATE(Type,SalesInvLine.Type);
//               SetHideValidationDialog(TRUE);
//               VALIDATE("No.",SalesInvLine."No.");
//               CASE SalesInvLine."Line Type" OF
//                 SalesInvLine."Line Type"::"Case Rate":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfCarton);
//                   END;
//                 SalesInvLine."Line Type"::"Broken Case Rate":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfBrokenCarton);
//                   END;
//                 SalesInvLine."Line Type"::"Carton Freight":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton);
//                   END;
//                 SalesInvLine."Line Type"::"Carton Case Income":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton);
//                   END;
//                 SalesInvLine."Line Type"::"Direct Debit Income":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton +lvNoOfBag);
//                   END;
//                 SalesInvLine."Line Type"::"Online Order Income":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton +lvNoOfBag);
//                   END;
//                 SalesInvLine."Line Type"::"CW Bad Debt":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton+lvNoOfBag);
//                   END;
//                 SalesInvLine."Line Type"::"MOQ Incentive":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton +lvNoOfBag);
//                   END;
//                 SalesInvLine."Line Type"::"Direct Debit Incentive":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton +lvNoOfBag);
//                   END;
//                 SalesInvLine."Line Type"::"Online Order Incentive":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton +lvNoOfBag);
//                   END;
//                 //#CW4.55 Start:
//                 SalesInvLine."Line Type"::"Bag Rate":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfBag);
//                   END;
//                 SalesInvLine."Line Type"::"Bag Income":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfBag);
//                   END;
//                 SalesInvLine."Line Type"::"Bag Freight":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfBag);
//                   END;
//               END;
//               VALIDATE("Unit of Measure Code",SalesInvLine."Unit of Measure Code");
//               VALIDATE("Unit Price",SalesInvLine."Unit Price");
//               VALIDATE("Line Type",SalesInvLine."Line Type");
//               VALIDATE("EDI Line No.",SalesInvLine."Line No.");
//               MODIFY(TRUE);
//             END;

//           UNTIL SalesInvLine.NEXT = 0;
//         END;

//         //Add Line for Surcharge based on Sales Invoice
//         lvSalesLine.RESET;
//         lvSalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
//         lvSalesLine.SETRANGE("Document No.",SalesHeader."No.");
//         IF lvSalesLine.FINDLAST THEN
//           LocLineNo := lvSalesLine."Line No.";

//         SalesInvLine.RESET;
//         SalesInvLine.SETRANGE("Document No.",SalesInvHeader."No.");
//         SalesInvLine.SETFILTER(Type,'<>%1',SalesInvLine.Type::" ");                                        //HBSTG 2014-03-12: Fix for correction of wrongly posted sales invoices
//         SalesInvLine.SETFILTER("Line Type",'%1',SalesInvLine."Line Type"::"Credit Card Surcharge");
//         IF SalesInvLine.FINDFIRST THEN BEGIN
//           lvSalesLine.RESET;
//           lvSalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
//           lvSalesLine.SETRANGE("Document No.",SalesHeader."No.");
//           lvSalesLine.SETFILTER("Line Type",'<>%1',lvSalesLine."Line Type"::"Credit Card Surcharge");
//           IF lvSalesLine.FINDSET THEN
//             REPEAT
//               lvLineAmount += lvSalesLine."Line Amount";
//             UNTIL lvSalesLine.NEXT = 0;
//             LocLineNo +=10000;
//             WITH lvSalesLine DO BEGIN
//               RESET;
//               INIT;
//               VALIDATE("Document Type",SalesHeader."Document Type");
//               VALIDATE("Document No.",SalesHeader."No.");
//               "Line No.":=  LocLineNo;
//               INSERT(TRUE);
//               VALIDATE(Type,SalesInvLine.Type);
//               SetHideValidationDialog(TRUE);
//               VALIDATE("No.",SalesInvLine."No.");

//               VALIDATE("Unit of Measure Code",SalesInvLine."Unit of Measure Code");
//               VALIDATE(Quantity,SalesInvLine.Quantity);
//               VALIDATE("Unit Price",ROUND(lvLineAmount,0.01));
//               VALIDATE("Line Type",SalesInvLine."Line Type");
//               VALIDATE("EDI Line No.",SalesInvLine."Line No.");
//               MODIFY(TRUE);
//             END;
//         END;

//         //ReSRP 2017-10-14 Start: Add Lines for Markup based on Purchase Invoice
//         lvPurchLine.RESET;
//         lvPurchLine.SETRANGE("Document Type",PurchHeader."Document Type");
//         lvPurchLine.SETRANGE("Document No.",PurchHeader."No.");
//         IF lvPurchLine.FINDLAST THEN
//           LocLineNo := lvPurchLine."Line No.";

//         PurchInvLine.RESET;
//         PurchInvLine.SETRANGE("Document No.",PurchInvHeader."No.");
//         PurchInvLine.SETFILTER(Type,'<>%1',PurchInvLine.Type::" ");                                        //HBSTG 2014-03-12: Fix for correction of wrongly posted sales invoices
//         PurchInvLine.SETFILTER("Line Type",'%1|%2|%3',
//                                             PurchInvLine."Line Type"::MU1,
//                                                PurchInvLine."Line Type"::MU2,
//                                                   PurchInvLine."Line Type"::MU3);
//         IF PurchInvLine.FINDSET THEN BEGIN
//           REPEAT
//             LocLineNo += 10000;
//             WITH lvPurchLine DO BEGIN
//               RESET;
//               INIT;
//               VALIDATE("Document Type",PurchHeader."Document Type");
//               VALIDATE("Document No.",PurchHeader."No.");
//               "Line No.":=  LocLineNo;
//               INSERT(TRUE);
//               VALIDATE(Type,PurchInvLine.Type);
//               VALIDATE("No.",PurchInvLine."No.");
//               VALIDATE("Unit of Measure Code",PurchInvLine."Unit of Measure Code");
//               VALIDATE("Line Type",PurchInvLine."Line Type");
//               VALIDATE(Quantity,PurchInvLine.Quantity);
//               lvMarkupLevelTotalPurchAmt := 0;
//               lvMarkupLevelTotalPurchAmt:= FindPurchMarkupLevelPrice(PurchInvLine."Line Type",PurchInvLine."VAT %");
//               VALIDATE("Direct Unit Cost",lvMarkupLevelTotalPurchAmt);
//               MODIFY(TRUE);
//             END;
//           UNTIL PurchInvLine.NEXT = 0;
//         END;
//         //ReSRP 2017-10-14 End:

//         //Add Lines for Fees & Incentive based on Purchase Invoice
//         lvPurchLine.RESET;
//         lvPurchLine.SETRANGE("Document Type",PurchHeader."Document Type");
//         lvPurchLine.SETRANGE("Document No.",PurchHeader."No.");
//         IF lvPurchLine.FINDLAST THEN
//           LocLineNo := lvPurchLine."Line No.";

//         PurchInvLine.RESET;
//         PurchInvLine.SETRANGE("Document No.",PurchInvHeader."No.");
//         PurchInvLine.SETFILTER(Type,'<>%1',PurchInvLine.Type::" ");                                        //HBSTG 2014-03-12: Fix for correction of wrongly posted sales invoices
//         //#CW4.55 Start:
//         /*
//         PurchInvLine.SETFILTER("Line Type",'%1|%2|%3|%4|%5|%6|%7',
//                                             PurchInvLine."Line Type"::"Case Rate",
//                                                PurchInvLine."Line Type"::"Broken Case Rate",
//                                                   PurchInvLine."Line Type"::"MOQ Incentive",
//                                                      PurchInvLine."Line Type"::"Online Order Incentive",
//                                                         PurchInvLine."Line Type"::"CW User Pay",
//                                                           PurchInvLine."Line Type"::"Bag Rate",
//                                                             PurchLine."Line Type"::"Bag Income");          //#CW4.55
//         */
//         PurchInvLine.SETFILTER("Line Type",'<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8',
//                                          PurchInvLine."Line Type"::" ",
//                                            PurchInvLine."Line Type"::"Store Allocation",
//                                              PurchInvLine."Line Type"::MOQNA,
//                                                PurchInvLine."Line Type"::"Credit Card Surcharge",
//                                                  PurchInvLine."Line Type"::"Unsch Weekday Delivery",
//                                                    PurchInvLine."Line Type"::"Unsch Weekend Delivery",
//                                                      PurchInvLine."Line Type"::"Minimum Order Value Charge",
//                                                          PurchInvLine."Line Type"::LOF);
//         //#CW4.55 End:


//         IF PurchInvLine.FINDSET THEN BEGIN
//           REPEAT
//             LocLineNo += 10000;
//             WITH lvPurchLine DO BEGIN
//               RESET;
//               INIT;
//               VALIDATE("Document Type",PurchHeader."Document Type");
//               VALIDATE("Document No.",PurchHeader."No.");
//               "Line No.":=  LocLineNo;
//               INSERT(TRUE);
//               VALIDATE(Type,PurchInvLine.Type);
//               VALIDATE("No.",PurchInvLine."No.");
//               VALIDATE("Unit of Measure Code",PurchInvLine."Unit of Measure Code");
//               VALIDATE("Line Type",PurchInvLine."Line Type");
//               CASE PurchInvLine."Line Type" OF
//                 PurchInvLine."Line Type"::"Case Rate":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfCarton);
//                   END;
//                 PurchInvLine."Line Type"::"Broken Case Rate":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfBrokenCarton);
//                   END;
//                 PurchInvLine."Line Type"::"MOQ Incentive":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton+lvNoOfBag);
//                   END;
//                 PurchInvLine."Line Type"::"Online Order Incentive":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton+lvNoOfBag);
//                   END;
//                 PurchInvLine."Line Type"::"CW User Pay":                                                   //HBSTG 2016-09-07
//                   BEGIN
//                     VALIDATE(Quantity,PurchInvLine.Quantity);
//                   END;
//                 //#CW4.55 Start:
//                 PurchInvLine."Line Type"::"Bag Rate":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfBag);
//                   END;
//                 PurchInvLine."Line Type"::"Bag Income":
//                   BEGIN
//                     VALIDATE(Quantity,lvNoOfBag);
//                   END;
//                 //#CW4.55 End:
//               END;
//               IF PurchInvLine."Line Type" <> PurchInvLine."Line Type"::"CW User Pay" THEN                  //HBSTG 2016-09-07
//                 VALIDATE("Direct Unit Cost",PurchInvLine."Direct Unit Cost")
//               ELSE BEGIN
//                 lvPurchLine2.RESET;
//                 lvPurchLine2.SETRANGE("Document Type",PurchHeader."Document Type");
//                 lvPurchLine2.SETRANGE("Document No.",PurchHeader."No.");
//                 lvPurchLine2.SETRANGE(Type,lvPurchLine2.Type::Item);
//                 lvPurchLine2.SETFILTER("Line Type",'%1|%2',lvPurchLine2."Line Type"::" ",lvPurchLine2."Line Type"::"Store Allocation");
//                 IF lvPurchLine2.FINDSET THEN
//                   REPEAT
//                     lvItemLineAmount += lvPurchLine2."Line Amount";
//                   UNTIL lvPurchLine2.NEXT = 0;
//                 VALIDATE("Direct Unit Cost",-lvItemLineAmount);
//               END;
//               MODIFY(TRUE);
//             END;
//           UNTIL PurchInvLine.NEXT = 0;
//         END;

//     end;

//     local procedure FindPurchMarkupLevelPrice(pLineType: Option " ","Case Rate","Broken Case Rate","Carton Freight","MOQ Incentive","Direct Debit Incentive","Online Order Incentive","Credit Card Surcharge","Store Allocation","Carton Case Income","Direct Debit Income","Online Order Income","Unsch Weekday Delivery","Unsch Weekend Delivery","Minimum Order Value Charge","CW User Pay","CW Bad Debt",MU1,MU2,MU3,"Bag Rate","Bag Freight","Bag Income",LOF,MOQNA,FrghtAnclry;pGSTPerc: Decimal): Decimal
//     var
//         lvPurchLine: Record "39";
//         MarkupLevelPurchAmt: Decimal;
//     begin
//         MarkupLevelPurchAmt := 0;
//         lvPurchLine.RESET;
//         lvPurchLine.SETRANGE("Document Type",PurchHeader."Document Type");
//         lvPurchLine.SETRANGE("Document No.",PurchHeader."No.");
//         lvPurchLine.SETRANGE(Type,lvPurchLine.Type::Item);
//         lvPurchLine.SETFILTER("Line Type",'%1|%2',lvPurchLine."Line Type"::" ",lvPurchLine."Line Type"::"Store Allocation");
//         lvPurchLine.SETRANGE("VAT %",pGSTPerc);
//         IF lvPurchLine.FINDSET THEN BEGIN
//           IF pLineType = pLineType::MU1 THEN BEGIN
//             REPEAT
//               MarkupLevelPurchAmt += (lvPurchLine.Quantity * lvPurchLine."Markup Level-1 Amount") ;
//             UNTIL lvPurchLine.NEXT = 0;
//           END ELSE IF pLineType = pLineType::MU2 THEN BEGIN
//             REPEAT
//               MarkupLevelPurchAmt += (lvPurchLine.Quantity * lvPurchLine."Markup Level-2 Amount") ;
//             UNTIL lvPurchLine.NEXT = 0;
//           END ELSE IF pLineType = pLineType::MU3 THEN BEGIN
//             REPEAT
//               MarkupLevelPurchAmt += (lvPurchLine.Quantity * lvPurchLine."Markup Level-3 Amount") ;
//             UNTIL lvPurchLine.NEXT = 0;
//           END;
//           EXIT(ROUND(MarkupLevelPurchAmt,0.01));
//         END;
//     end;

//     local procedure FindSalesMarkupLevelPrice(pLineType: Option " ","Case Rate","Broken Case Rate","Carton Freight","MOQ Incentive","Direct Debit Incentive","Online Order Incentive","Credit Card Surcharge","Store Allocation","Carton Case Income","Direct Debit Income","Online Order Income","Unsch Weekday Delivery","Unsch Weekend Delivery","Minimum Order Value Charge","CW User Pay","CW Bad Debt",MU1,MU2,MU3,"Bag Rate","Bag Freight","Bag Income",LOF,MOQNA,FrghtAnclry;pGSTPerc: Decimal): Decimal
//     var
//         MarkupLevelSalesAmt: Decimal;
//         lvSalesLine: Record "37";
//     begin
//         MarkupLevelSalesAmt := 0;
//         lvSalesLine.RESET;
//         lvSalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
//         lvSalesLine.SETRANGE("Document No.",SalesHeader."No.");
//         lvSalesLine.SETRANGE(Type,lvSalesLine.Type::Item);
//         lvSalesLine.SETFILTER("Line Type",'%1|%2',lvSalesLine."Line Type"::" ",lvSalesLine."Line Type"::"Store Allocation");
//         lvSalesLine.SETRANGE("VAT %",pGSTPerc);

//         IF lvSalesLine.FINDSET THEN BEGIN
//           IF pLineType = pLineType::MU1 THEN BEGIN
//             REPEAT
//               MarkupLevelSalesAmt += (lvSalesLine.Quantity * lvSalesLine."Markup Level-1 Amount") ;
//             UNTIL lvSalesLine.NEXT = 0;
//           END ELSE IF pLineType = pLineType::MU2 THEN BEGIN
//             REPEAT
//               MarkupLevelSalesAmt += (lvSalesLine.Quantity * lvSalesLine."Markup Level-2 Amount") ;
//             UNTIL lvSalesLine.NEXT = 0;
//           END ELSE IF pLineType = pLineType::MU3 THEN BEGIN
//             REPEAT
//               MarkupLevelSalesAmt += (lvSalesLine.Quantity * lvSalesLine."Markup Level-3 Amount") ;
//             UNTIL lvSalesLine.NEXT = 0;
//           END;
//           EXIT(ROUND(MarkupLevelSalesAmt,0.01));
//         END;
//     end;

//     [Scope('Internal')]
//     procedure CheckCreditQtyWithInvQty(lvSalesInvLine: Record "113")
//     var
//         lvSalesCrMemoHeader: Record "114";
//         lvSalesCrMemoLine: Record "115";
//         lvSalesHeader: Record "36";
//         lvSalesLine: Record "37";
//         EDICreditMemoLine1: Record "50008";
//         TotalPostedCreditQty: Decimal;
//         TotalCreditQtyErr: Label 'Total Credit Qty including current credit qty is %1 is greater than original Invoice Qty %2 of Invoice %3.';
//         TotalUnpostedCreditQty: Decimal;
//         TotalCreditQty: Decimal;
//     begin

//         //Findout Posted Credit Qty
//         TotalCreditQty := 0;
//         EDICreditMemoLine1.RESET;
//         EDICreditMemoLine1.SETRANGE("Invoice ID",EDICrMemoLine."Invoice ID");
//         EDICreditMemoLine1.SETFILTER("Item No.",'%1|%2',EDICrMemoLine."Item No.",recItem."No.");
//         IF EDICreditMemoLine1.FINDSET THEN BEGIN
//           REPEAT
//             TotalCreditQty += EDICreditMemoLine1.Quantity;
//           UNTIL EDICreditMemoLine1.NEXT = 0;
//         END;

//         IF TotalCreditQty  > lvSalesInvLine.Quantity THEN
//           ERROR(TotalCreditQtyErr,TotalCreditQty,lvSalesInvLine.Quantity, EDICrMemoLine."Invoice ID");

//         // lvSalesCrMemoHeader.RESET;
//         // lvSalesCrMemoHeader.SETRANGE("Applies-to Ext.Doc.No.",EDICrMemoLine."Invoice ID");
//         // //lvSalesCrMemoHeader.SETRANGE("Sell-to Customer No.",EDICrMemoLine."Customer ID");
//         // IF lvSalesCrMemoHeader.FINDSET THEN BEGIN
//         //  REPEAT
//         //    lvSalesCrMemoLine.RESET;
//         //    lvSalesCrMemoLine.SETRANGE("Document No.",lvSalesCrMemoHeader."No.");
//         //    lvSalesCrMemoLine.SETRANGE(Type,lvSalesCrMemoLine.Type::Item);
//         //    lvSalesCrMemoLine.SETRANGE("No.",recItem."No.");
//         //    lvSalesCrMemoLine.SETRANGE("EDI Invoice Line No.",EDICrMemoLine."Invoice Line No.");
//         //    IF lvSalesCrMemoLine.FINDFIRST THEN BEGIN
//         //      TotalPostedCreditQty += lvSalesCrMemoLine."Quantity (Base)"
//         //    END;
//         //  UNTIL lvSalesCrMemoHeader.NEXT = 0;
//         // END;
//         // //Findout Un-Posted Credit Qty
//         // TotalUnpostedCreditQty := 0;
//         // lvSalesHeader.RESET;
//         // lvSalesHeader.SETFILTER("No.",'<>%1',SalesHeader."No.");
//         // lvSalesHeader.SETRANGE("Document Type",SalesHeader."Document Type");
//         // lvSalesHeader.SETRANGE("Applies-to Ext.Doc.No.",EDICrMemoLine."Invoice ID");
//         // //lvSalesHeader.SETRANGE("Sell-to Customer No.",EDICrMemoLine."Customer ID");
//         // IF lvSalesHeader.FINDSET THEN BEGIN
//         //  REPEAT
//         //    lvSalesLine.RESET;
//         //    lvSalesLine.SETRANGE("Document No.",lvSalesHeader."No.");
//         //    lvSalesLine.SETRANGE(Type,lvSalesLine.Type::Item);
//         //    lvSalesLine.SETRANGE("No.",recItem."No.");
//         //    lvSalesLine.SETRANGE("EDI Invoice Line No.",EDICrMemoLine."Invoice Line No.");
//         //    IF lvSalesLine.FINDFIRST THEN BEGIN
//         //      TotalUnpostedCreditQty += lvSalesLine."Quantity (Base)"
//         //    END;
//         //  UNTIL lvSalesHeader.NEXT = 0;
//         // END;

//         // IF (TotalPostedCreditQty+TotalUnpostedCreditQty + SalesLine."Quantity (Base)") > lvSalesInvLine."Quantity (Base)" THEN
//         //  ERROR(TotalCreditQtyErr,TotalPostedCreditQty + TotalUnpostedCreditQty+ SalesLine."Quantity (Base)",lvSalesInvLine."Quantity (Base)", EDICrMemoLine."Invoice ID");
//         // IF (TotalPostedCreditQty+TotalUnpostedCreditQty + SalesLine."Quantity (Base)") > lvSalesInvLine."Quantity (Base)" THEN
//         //  ERROR(TotalCreditQtyErr,TotalPostedCreditQty + TotalUnpostedCreditQty+ SalesLine."Quantity (Base)",lvSalesInvLine."Quantity (Base)", EDICrMemoLine."Invoice ID");
//     end;
// }

