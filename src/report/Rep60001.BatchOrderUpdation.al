// report 60001 "Batch - Order Updation"
// {
//     // HBSTG  2013-10-24: Code changed to change the Reason Code Priority based on Standard UOM functionality
//     // HBSTG P2CW014 2014-07-08: Flowing Manufacturer and Brand in Sales / Purchase Lines
//     // HBSTG P2CW014 2014-08-14: Changes to EDI Process as per Phase 2
//     // HBSRP 2015-03-18: Code commented to put the description from EDI invoice line
//     // HBSRP 2015-04-09: put the description from EDI invoice line for spotless
//     // HBSRP 2015-06-23: Code added to update the Document Date as TODAY.
//     // HBSRP 2015-06-29: Code commented for the Document Date as TODAY
//     // HBSRP 2015-09-16: Code Added for description from EDI Invoice line
//     // HBSRP 2016-05-12: Code added for checking customer ledger entry with customer and vendor ledger with member
//     // HBSRP 2016-06-02: Code commented for the UNSWK and UNSWE to check EDI Invoice Line No. with value zero(0)
//     // HBSRP 2016-12-04: Code added for allowing qty tolerance functionality
//     // HBSRP 2017-06-02: Code added for allowing price update from EDI Invoice Line of spotless contract when price is not found in the NAV.
//     // HBSRP 2017-07-13: Code added for pick GST% from EDI Invoice Line
//     // ReSRP 2018-02-26: Code added for replace by Item functionality
//     // ReSRP 2018-06-05: Code added for Undelivered Stroe Allocation
//     // #11467 2018-08-01: Code added for the Pieface Markup changes
//     // ReSRP 2018-10-11: Code added for flowing random weight Item
//     // #11835 2018-11-15: Code Added for "Reference Customer for Markup %"
//     // #CW4.55 2019-09-10: Code Added for "Pizza Hut" and Fees and Incentive for bags

//     ProcessingOnly = true;

//     dataset
//     {
//         dataitem(DataItem1000000000; Table50005)
//         {
//             DataItemTableView = SORTING (Entry No.)
//                                 WHERE (Doc Process Status=FILTER(' '|Document Error),
//                                       Sales Order Updated=FILTER(No),
//                                       Test Invoice=FILTER(No));
//             RequestFilterFields = "Entry No.","Order ID","Invoice ID";

//             trigger OnAfterGetRecord()
//             begin
//                 //TESTFIELD("Order ID");
//                 IF "Order ID" = '' THEN
//                   ERROR(OrderIdErr,"Invoice ID");                                                                               //NXNRP 2020-03-18
//                 TESTFIELD("Invoice ID");
//                 TESTFIELD("Invoice Date");

//                 SalesHeader.RESET;
//                 SalesHeader.SETRANGE("Document Type",SalesHeader."Document Type"::Order);
//                 SalesHeader.SETRANGE("EDI Order ID","Order ID");
//                 IF "Multiple Invoice" THEN BEGIN
//                   SalesHeader.SETRANGE("EDI Multiple Invoice ID","Invoice ID");
//                   IF NOT SalesHeader.FINDLAST THEN
//                     ERROR(Text0014,"Order ID","Invoice ID");
//                 END ELSE BEGIN
//                   SalesHeader.SETRANGE("EDI Multiple Invoice ID",'');
//                   IF NOT SalesHeader.FINDLAST THEN
//                     ERROR(Text0004,"Order ID");
//                 END;

//                 SalesLine.RESET;
//                 SalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
//                 SalesLine.SETRANGE("Document No.",SalesHeader."No.");
//                 IF NOT SalesLine.FINDLAST THEN
//                   ERROR(Text0006,SalesHeader."No.",SalesHeader."EDI Order ID");

//                 PurchHeader.RESET;
//                 PurchHeader.SETRANGE("Document Type",PurchHeader."Document Type"::Order);
//                 PurchHeader.SETRANGE("EDI Order ID","Order ID");
//                 IF "Multiple Invoice" THEN BEGIN
//                   PurchHeader.SETRANGE("EDI Multiple Invoice ID","Invoice ID");
//                   IF NOT PurchHeader.FINDLAST THEN
//                     ERROR(Text0015,"Order ID","Invoice ID");
//                 END ELSE BEGIN
//                   PurchHeader.SETRANGE("EDI Multiple Invoice ID",'');
//                   IF NOT PurchHeader.FINDLAST THEN
//                     ERROR(Text0005,"Order ID");
//                 END;

//                 PurchLine.RESET;
//                 PurchLine.SETRANGE("Document Type",PurchHeader."Document Type");
//                 PurchLine.SETRANGE("Document No.",PurchHeader."No.");
//                 IF NOT PurchLine.FINDLAST THEN
//                   ERROR(Text0006,PurchHeader."No.",PurchHeader."EDI Order ID");

//                 LineNo := 0;

//                 Cust.GET(SalesHeader."Sell-to Customer No.");
//                 BillToCust.GET(SalesHeader."Bill-to Customer No.");
//                 Vend.GET(PurchHeader."Buy-from Vendor No.");
//                 PayToVend.GET(PurchHeader."Pay-to Vendor No.");

//                 //#11835 Start:
//                 IF Cust."Ref. Customer for Markup %" <> '' THEN
//                   RefCust.GET(Cust."Ref. Customer for Markup %")
//                 ELSE
//                   RefCust.GET(Cust."No.");
//                 //#11835 End:

//                 //ReSRP 2018-02-23:Start:
//                 CostVendorNo := '';
//                 IF Vend."Unit Cost based on Buy From" THEN BEGIN
//                   CostVendorNo := Vend."No."
//                 END ELSE BEGIN
//                   IF Vend."Pay-to Vendor No." <> '' THEN
//                     CostVendorNo := Vend."Pay-to Vendor No."
//                   ELSE
//                     CostVendorNo := Vend."No."
//                 END;
//                 //ReSRP 2018-02-23:End:

//                 CostCentre := '';
//                 DefaultDimension.GET(DATABASE::Customer,BillToCust."No.",EDISetup."Cost Centre Dimension Code");
//                 CostCentre := DefaultDimension."Dimension Value Code";

//                 ContractDimVal.GET(EDISetup."Cost Centre Dimension Code",CostCentre);

//                 CustLedgEntry.RESET;
//                 CustLedgEntry.SETRANGE("Document Type",CustLedgEntry."Document Type"::Invoice);
//                 CustLedgEntry.SETRANGE("Customer No.",BillToCust."No.");                                           //HBSRP 2016-05-12
//                 CustLedgEntry.SETRANGE("External Document No.","Invoice ID");
//                 IF CustLedgEntry.FINDFIRST THEN
//                   ERROR(Text0019,"Invoice ID");

//                 VendLedgEntry.RESET;
//                 VendLedgEntry.SETRANGE("Vendor No.",PayToVend."No.");
//                 VendLedgEntry.SETRANGE("External Document No.","Invoice ID");
//                 IF VendLedgEntry.FINDFIRST THEN
//                   ERROR(Text0024,"Invoice ID");

//                 EDIInvoiceHeader.GET("Entry No.");
//                 EDIInvoiceLine.RESET;
//                 EDIInvoiceLine.SETRANGE("Entry No.","Entry No.");
//                 IF NOT EDIInvoiceLine.FINDSET THEN
//                   ERROR(Text0001,"Payload ID","Invoice ID");

//                 EDIOrderHeader.RESET;
//                 EDIOrderHeader.SETRANGE("Order ID","Order ID");
//                 EDIOrderHeader.FINDFIRST;
//                 EDIOrderLine.RESET;
//                 EDIOrderLine.SETRANGE("Entry No.",EDIOrderHeader."Entry No.");
//                 IF EDIOrderLine.FINDLAST THEN
//                   EDILineNo := EDIOrderLine."Line No.";

//                 UpdateSOHeader;
//                 UpdatePOHeader;
//                 IF EDIInvoiceLine.FINDSET THEN BEGIN
//                   IF SalesLine."Line No." >= PurchLine."Line No." THEN
//                     LineNo := SalesLine."Line No."
//                   ELSE
//                     LineNo := PurchLine."Line No.";
//                   REPEAT
//                     /*
//                     //Check for Duplicate Item
//                     IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN
//                       IF NOT EDIInvoiceLine."Duplicate Item" THEN BEGIN
//                         EDIInvoiceLine2.RESET;
//                         EDIInvoiceLine2.SETRANGE("Entry No.",EDIInvoiceLine."Entry No.");
//                         EDIInvoiceLine2.SETRANGE("Item No.",EDIInvoiceLine."Item No.");
//                         IF EDIInvoiceLine2.COUNT > 1 THEN BEGIN
//                           EDIInvoiceLine2.MODIFYALL("Duplicate Item",TRUE,TRUE);
//                           EDIInvoiceLine."Duplicate Item" := TRUE;
//                         END;
//                       END;
//                     //EDIInvoiceLine.TESTFIELD("Invoice Line No.");
//                     */
//                     UpdateSOLine;
//                     UpdatePOLine;
//                   UNTIL EDIInvoiceLine.NEXT = 0;
//                   SalesLine.RESET;
//                   SalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
//                   SalesLine.SETRANGE("Document No.",SalesHeader."No.");
//                   SalesLine.SETFILTER(Type,'<>%1',SalesLine.Type::" ");                                            //HBSTG 2014-03-12: Fix for correction of wrongly posted sales invoices
//                   SalesLine.SETFILTER("Line Type",'%1|%2|%3|%4|%5|%6|%7',SalesLine."Line Type"::" ",
//                                                                    SalesLine."Line Type"::"Store Allocation",
//                                                                    SalesLine."Line Type"::"Unsch Weekday Delivery",
//                                                                    SalesLine."Line Type"::"Unsch Weekend Delivery",
//                                                                    SalesLine."Line Type"::"Minimum Order Value Charge",
//                                                                    SalesLine."Line Type"::MOQNA,                   //#CW4.55
//                                                                    SalesLine."Line Type"::LOF);
//                   SalesLine.SETRANGE("EDI Invoice ID",'');
//                   IF SalesLine.FINDSET THEN BEGIN
//                     REPEAT
//                       SalesLine.VALIDATE(Quantity,0);
//                       IF CostCentre <> EDISetup."CC Dimension Code for Spotless" THEN
//                         SalesLine."Reason Code" := EDISetup."Reason Code No Supply";
//                       SalesLine.MODIFY(TRUE);
//                     UNTIL SalesLine.NEXT = 0;
//                   END;
//                   PurchLine.RESET;
//                   PurchLine.SETRANGE("Document Type",PurchHeader."Document Type");
//                   PurchLine.SETRANGE("Document No.",PurchHeader."No.");
//                   PurchLine.SETFILTER(Type,'<>%1',PurchLine.Type::" ");                                            //HBSTG 2014-03-12: Fix for correction of wrongly posted sales invoices
//                   PurchLine.SETFILTER("Line Type",'%1|%2|%3|%4|%5|%6|%7',PurchLine."Line Type"::" ",
//                                                                    PurchLine."Line Type"::"Store Allocation",
//                                                                    PurchLine."Line Type"::"Unsch Weekday Delivery",
//                                                                    PurchLine."Line Type"::"Unsch Weekend Delivery",
//                                                                    PurchLine."Line Type"::"Minimum Order Value Charge",
//                                                                    PurchLine."Line Type"::MOQNA,                   //#CW4.55
//                                                                    PurchLine."Line Type"::LOF);

//                   PurchLine.SETRANGE("EDI Invoice ID",'');
//                   IF PurchLine.FINDSET THEN BEGIN
//                     REPEAT
//                       PurchLine.VALIDATE(Quantity,0);
//                       IF CostCentre <> EDISetup."CC Dimension Code for Spotless" THEN
//                         PurchLine."Reason Code" := EDISetup."Reason Code No Supply";
//                       PurchLine.MODIFY(TRUE);
//                     UNTIL PurchLine.NEXT = 0;
//                   END;

//                   UpdateOrderLineForMarkup();
//                   UpdateOrderLineForFeeAndIncentives();
//                                                                                         //ReSRP 2017-10-10

//                   IF ContractDimVal."Archive Docs in EDI Process" THEN
//                     ArchiveManagement.StoreSalesDocument(SalesHeader,FALSE);
//                   ReleaseSalesDoc.RUN(SalesHeader);
//                   IF ContractDimVal."Archive Docs in EDI Process" THEN
//                     ArchiveManagement.StorePurchDocument(PurchHeader,FALSE);
//                   ReleasePurchDoc.RUN(PurchHeader);
//                 END;

//                 LineNo := PurchLine."Line No." + 10000;

//                 //Update Staging Table
//                 "Cost Centre Code" := CostCentre;
//                 "Sell-to Customer ID" := Cust."EDI Customer ID";
//                 "Member ID" := Vend."Member ID";
//                 "Order Date" := SalesHeader."Order Date";
//                 "Sales Order Updated" := TRUE;
//                 "Sales Order No." := SalesHeader."No.";
//                 "Purchase Order Updated" := TRUE;
//                 "Purchase Order No." := PurchHeader."No.";
//                 "Doc Process Status" := "Doc Process Status"::Successful;
//                 MODIFY(TRUE);

//             end;

//             trigger OnPreDataItem()
//             begin
//                 GLSetup.GET;
//                 SalesSetup.GET;
//                 PurchSetup.GET;
//                 InvtSetup.GET;
//                 EDISetup.GET;
//                 EDISetup.TESTFIELD("Cost Centre Dimension Code");
//                 EDISetup.TESTFIELD("CC Dimension Code for Spotless");
//                 EDISetup.TESTFIELD("CC Dimension Code for Subway");
//                 EDISetup.TESTFIELD("CC Dimension Code for Pieface");
//                 EDISetup.TESTFIELD("CC Dimension Code for GYG");
//                 EDISetup.TESTFIELD("CC Dim Code for Sumo Salad");                                                  //ReSRP 2017-10-10
//                 EDISetup.TESTFIELD("CC Dim Code for Pizza Hut");                                                   //#CW4.55
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
//         EDIInvoiceHeader: Record "50005";
//         EDIInvoiceLine: Record "50006";
//         EDIInvoiceLine2: Record "50006";
//         EDIOrderHeader: Record "50001";
//         EDIOrderLine: Record "50002";
//         SalesHeader: Record "36";
//         SalesLine: Record "37";
//         xSalesLine: Record "37";
//         PurchHeader: Record "38";
//         PurchLine: Record "39";
//         xPurchLine: Record "39";
//         Cust: Record "18";
//         BillToCust: Record "18";
//         Vend: Record "23";
//         PayToVend: Record "23";
//         Loc: Record "14";
//         recItem: Record "27";
//         OrderItem: Record "27";
//         ItemCrossRef: Record "5717";
//         UOM: Record "204";
//         ItemUOM: Record "5404";
//         OrdItemUOM: Record "5404";
//         GSTPostingSetup: Record "325";
//         ContractDimVal: Record "349";
//         ReleaseSalesDoc: Codeunit "414";
//         ReleasePurchDoc: Codeunit "415";
//         NoSeriesMgmt: Codeunit "396";
//         ArchiveManagement: Codeunit "5063";
//         Text0001: Label 'Could not find Sales Lines for Payload ID %1 and Invoice ID %2.';
//         LineNo: Integer;
//         Text0002: Label 'The %1 for %2 %3 has changed from %4 to %5 since the Sales Order was created. Adjust the %6 on the Sales Order or the %1.';
//         Text0003: Label 'There were no lines to be retrieved from sales order %1.';
//         Text0004: Label 'Order ID %1 does not exist, has been invoiced OR cancelled.';
//         Text0005: Label 'Order ID %1 cannot be found in NAV Purchase Orders.';
//         Text0006: Label 'Sales Lines does not exist in Order No. %1, Order ID %2.';
//         Text0007: Label 'Purchase Lines does not exist in Order No. %1, Order ID %2.';
//         OutOfCatalogueItem: Boolean;
//         Text0011: Label 'Contract Purchase Price cannot be found for Contract %1, Item %2.This item is not linked from the date of order.';
//         Text0012: Label 'Item Price cannot be found for Item %1';
//         Text0013: Label 'Item Cost cannot be found for Item %1';
//         Text0014: Label 'Order ID %1 with Multiple Invoice ID %2 does not exist in Sales Orders.';
//         Text0015: Label 'Order ID %1  with Multiple Invoice ID %2 does not exist in Purchase Orders.';
//         OrderStdUOMddd: Code[10];
//         InvoiceStdUOM: Code[10];
//         OrderUOM: Record "204";
//         UnitPrice: Decimal;
//         EDILineNo: Integer;
//         CostCentre: Code[20];
//         DefaultDimension: Record "352";
//         Text0016: Label 'Cannot find Order Line for Item %1.This item does not exist on the order OR line number is incorrect.';
//         Text0017: Label 'Item %1 does not exist in Navision.';
//         Text0018: Label 'Item %1 does not match original Order Item %2 (NAV Item %3).';
//         StoreAllocationEntry: Record "50052";
//         FeesAndIncentives: Record "50021";
//         gvType: Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
//         LineType: Option " ","Case Rate","Broken Case Rate","Carton Freight","MOQ Incentive","Direct Debit Incentive","Online Order Incentive","Credit Card Surcharge","Store Allocation","Carton Case Income","Direct Debit Income","Online Order Income","Unsch Weekday Delivery","Unsch Weekend Delivery","Minimum Order Value Charge","CW User Pay","CW Bad Debt",MU1,MU2,MU3,"Bag Rate","Bag Freight","Bag Income",LOF,MOQNA,FrghtAnclry;
//         PurchUnitPrice: Decimal;
//         CustLedgEntry: Record "21";
//         VendLedgEntry: Record "25";
//         Text0019: Label 'Invoice ID %1 already exist in Customer Ledger Entry. ';
//         PurchPriceCalcMgt: Codeunit "7010";
//         Text0031: Label 'Quantity variation is more than permitted for Ordered Item %1(Item Cross Reference = %2). Invoice Qty is %3 and Order Qty is %4.';
//         Text0020: Label 'Quantity variation is more than permitted for Item %1. Invoice Qty is %2 and Order Qty is %3.';
//         Text0021: Label 'Invoice Quantity cannot be negative for Item %1.';
//         ItemCrossRef2: Record "5717";
//         SubstituteItem: Boolean;
//         Text0022: Label 'Item %1: Invoice UOM %2 does not match with NAV''s Unit of Measure %3 OR Customer Unit of Measure %4 OR Member Unit of Measure %5';
//         Text0023: Label 'Quantity variation is is more than permitted for Item %1. Invoice Qty is %2 and Order Qty is %3.';
//         Text0024: Label 'Invoice ID %1 already exist in Vendor Ledger Entry. ';
//         Text0025: Label 'Invoice Line No. should not be blank.';
//         ContractPurchPrice: Decimal;
//         ReasonCode: Record "231";
//         Text0026: Label 'Reason Code is not a valid substitute reason for Item %1.';
//         Text0027: Label 'New Invoice Line cannot be added for the item %1 unless approved. Note ONLY Spotless split subs are allowed.';
//         SalesPriceCalcMgt: Codeunit "7000";
//         ConvUOMPrice: Decimal;
//         Text0028: Label 'Cannot compare the UOM based price for Substitute because Size (Gm/Ml) is not defined in Invoice Lines for Substitute Out of Catalogue Item %1.';
//         Text0029: Label 'Cannot compare the UOM based price for Substitute because Size (Gm/Ml) is not defined in Item UOM for Substitute Catalogue Item %1.';
//         Text0030: Label 'Cannot compare the UOM based price for Substitute because Size (Gm/Ml) is not defined in Item UOM for Original Ordered Item %1.';
//         MUUnitCost: Decimal;
//         MUUnitPrice: Decimal;
//         MarkupLevel_1SalesPrice: Decimal;
//         MarkupLevel_2SalesPrice: Decimal;
//         MarkupLevel_3SalesPrice: Decimal;
//         MarkupLevel_1PurchPrice: Decimal;
//         MarkupLevel_2PurchPrice: Decimal;
//         MarkupLevel_3PurchPrice: Decimal;
//         PLUnitCost: Decimal;
//         SLUnitPrice: Decimal;
//         MarkupPurchAmt: array [3] of Decimal;
//         MarkupSalesAmt: array [3] of Decimal;
//         Lvl: Integer;
//         ReplaceByItem: Boolean;
//         TempContractPurchPrice: Record "50056" temporary;
//         ContractPurchPrice1: Record "50056";
//         ReplaceUOM: Code[10];
//         ReplaceUOMErr: Label 'Replace By Item No. %1 does not match with EDI Invoice Item No. %2 (NAV Item No. %3) OR Replace By Item UOM  is blank.';
//         OriginalItemNo: Code[20];
//         CostVendorNo: Code[20];
//         OrdUOMSalesPrice: Decimal;
//         OrdUOMSalesMarkup1: Decimal;
//         OrdUOMSalesMarkup2: Decimal;
//         OrdUOMSalesMarkup3: Decimal;
//         OrdUOMSalesEndPrice: Decimal;
//         OrdUOMDirectUnitCost: Decimal;
//         OrdUOMPurchMarkup1: Decimal;
//         OrdUOMPurchMarkup2: Decimal;
//         OrdUOMPurchMarkup3: Decimal;
//         OrdUOMPurchEndCost: Decimal;
//         OrdUOMConvRatio: Decimal;
//         CatalogueItemPriceFound: Boolean;
//         RefCust: Record "18";
//         OrderIdErr: Label 'Order ID is missing from the invoice %1. It cannot be zero or empty';

//     [Scope('Internal')]
//     procedure UpdateSOHeader()
//     begin
//         WITH SalesHeader DO BEGIN
//           ReleaseSalesDoc.Reopen(SalesHeader);
//           SetHideValidationDialog(TRUE);
//           VALIDATE("Posting Date",EDIInvoiceHeader."Invoice Date");
//           VALIDATE("Shipment Date",EDIInvoiceHeader."Actual Delivery Date");
//           VALIDATE("External Document No.",EDIInvoiceHeader."Invoice ID");
//           VALIDATE("EDI Invoice ID",EDIInvoiceHeader."Invoice ID");
//           VALIDATE("EDI Invoice Date",EDIInvoiceHeader."Invoice Date");                                    //HBSTG 2016-10-14
//           MODIFY(TRUE);
//         END;
//     end;

//     [Scope('Internal')]
//     procedure UpdateSOLine()
//     begin
//         UnitPrice := 0;

//         OrdUOMConvRatio := 0;
//         OrdUOMSalesMarkup1 := 0;
//         OrdUOMSalesMarkup2 := 0;
//         OrdUOMSalesMarkup3 := 0;
//         OrdUOMSalesEndPrice := 0;
//         OrdUOMSalesPrice := 0;
//         OrdUOMPurchMarkup1 := 0;
//         OrdUOMPurchMarkup2 := 0;
//         OrdUOMPurchMarkup3 := 0;
//         OrdUOMPurchEndCost := 0;
//         OrdUOMDirectUnitCost := 0;

//         OutOfCatalogueItem := FALSE;
//         OriginalItemNo := '';
//         ReplaceByItem := FALSE;
//         WITH SalesLine DO BEGIN
//           IF NOT recItem.GET(EDIInvoiceLine."Item No.") THEN BEGIN
//             ItemCrossRef.RESET;
//             ItemCrossRef.SETRANGE("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::Vendor);
//             ItemCrossRef.SETFILTER("Cross-Reference Type No.",'%1|%2',PurchHeader."Buy-from Vendor No.",PurchHeader."Pay-to Vendor No.");
//             ItemCrossRef.SETRANGE("Cross-Reference No.",EDIInvoiceLine."Item No.");
//             IF ItemCrossRef.FINDFIRST THEN BEGIN
//               recItem.GET(ItemCrossRef."Item No.");
//             END ELSE BEGIN
//               ItemCrossRef.RESET;
//               ItemCrossRef.SETRANGE("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::Contract);
//               ItemCrossRef.SETRANGE("Cross-Reference Type No.",CostCentre);
//               ItemCrossRef.SETRANGE("Cross-Reference No.",EDIInvoiceLine."Item No.");
//               IF ItemCrossRef.FINDFIRST THEN BEGIN
//                 recItem.GET(ItemCrossRef."Item No.");
//               END ELSE BEGIN
//                 IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN BEGIN
//                   CreateItem(recItem,EDIInvoiceLine."Item No.",UPPERCASE(EDIInvoiceLine.Description),CostCentre,PurchHeader."Pay-to Vendor No.",EDIInvoiceLine."Unit Of Measure Code");
//                   IF EDISetup."Email Other Errors" THEN
//                     CreateMsgLog('Item Created' + recItem."No.",
//                                'Item ' + recItem."No." + ' is created (Cross-Reference ' + ItemCrossRef."Cross-Reference No." + ') while creating Invoice ID ' + EDIInvoiceHeader."Invoice ID",
//                                EDISetup."Errors Email Address",'','',
//                                'New Item',
//                                EDIInvoiceHeader."Invoice ID");
//                   OutOfCatalogueItem := TRUE;
//                 END ELSE BEGIN
//                   ERROR(Text0017,EDIInvoiceLine."Item No.");
//                 END;
//               END;
//             END;
//           END;
//           ItemCrossRef.RESET;
//           ItemCrossRef.SETRANGE("Item No.",recItem."No.");
//           ItemCrossRef.SETRANGE("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::Contract);
//           ItemCrossRef.SETRANGE("Cross-Reference Type No.",CostCentre);
//           ItemCrossRef.FINDFIRST;
//           ItemCrossRef.TESTFIELD("Unit of Measure");
//           RESET;
//           SETRANGE("Document Type",SalesHeader."Document Type");
//           SETRANGE("Document No.",SalesHeader."No.");
//           SETRANGE("EDI Line No.",EDIInvoiceLine."Invoice Line No.");
//           SETFILTER("Line Type",'%1|%2|%3|%4|%5|%6|%7',"Line Type"::" ","Line Type"::"Store Allocation","Line Type"::"Unsch Weekday Delivery","Line Type"::"Unsch Weekend Delivery","Line Type"::"Minimum Order Value Charge",
//                                                                                         "Line Type"::MOQNA,"Line Type"::LOF);   //#CW4.55
//           IF FINDFIRST THEN BEGIN                                                            //If Line No. is found in SL
//             xSalesLine := SalesLine;
//             IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN BEGIN             //If Line No. is found in SL but contract is Spotless
//               SubstituteItem := FALSE;
//               //HBSTG 2016-12-05: Start >> Commented UOM check.
//               //IF NOT (EDIInvoiceLine."Unit Of Measure Code" IN [ItemCrossRef."Unit of Measure",ItemCrossRef."Customer Unit of Measure",ItemCrossRef."Member Unit of Measure"]) THEN
//               //  ERROR(Text0022,EDIInvoiceLine."Item No.",EDIInvoiceLine."Unit Of Measure Code",ItemCrossRef."Unit of Measure",ItemCrossRef."Customer Unit of Measure",ItemCrossRef."Member Unit of Measure");
//               //HBSTG 2016-12-05: End <<
//               IF recItem."No." <> "No." THEN BEGIN                                                         //If Substitute Item
//                 OrderItem.GET("No.");
//                 IF EDIInvoiceLine."Reason Code" = '' THEN BEGIN                                                //RSTG 2017-08-30
//                   EDIInvoiceLine."Reason Code" := EDISetup."Default Subs Reason Code";
//                 END;
//                 ReasonCode.RESET;
//                 ReasonCode.SETRANGE(Code,EDIInvoiceLine."Reason Code");
//                 ReasonCode.SETRANGE("Spotless Substitution Reason",TRUE);
//                 IF NOT ReasonCode.FINDFIRST THEN
//                   ERROR(Text0026,EDIInvoiceLine."Item No.");
//                 //Code commented as requested by CW not to deploy now.
//                 //#11328 Start >>
//                 IF NOT ((recItem."Item Type" = recItem."Item Type"::"Auto-Created") OR (OrderItem."Item Type" = OrderItem."Item Type"::"Auto-Created")) THEN BEGIN                    //ReSRP 2017-12-13
//                   IF ReasonCode."Subs UOM based Pricing" THEN BEGIN
//                     ItemUOM.GET(ItemCrossRef."Item No.",ItemCrossRef."Unit of Measure");
//                     OrdItemUOM.GET("No.","Unit of Measure Code");
//                     IF OrdItemUOM."Size (Gm/Ml)" <> 0 THEN BEGIN
//                       IF ItemUOM."Size (Gm/Ml)" <> 0 THEN
//                         OrdUOMConvRatio := ItemUOM."Size (Gm/Ml)" / OrdItemUOM."Size (Gm/Ml)"
//                       ELSE IF EDIInvoiceLine."Size (Gm/Ml)" <> 0 THEN
//                         OrdUOMConvRatio := EDIInvoiceLine."Size (Gm/Ml)" / OrdItemUOM."Size (Gm/Ml)";
//                     END;
//                       //ELSE
//                         //ERROR(Text0029,EDIInvoiceLine."Item No.");
//                     //END ELSE
//                       //ERROR(Text0030,"No.");
//                     IF OrdUOMConvRatio <> 0 THEN BEGIN
//                       OrdUOMSalesMarkup1 := ROUND("Markup Level-1 Amount" * OrdUOMConvRatio,0.01);
//                       OrdUOMSalesMarkup2 := ROUND("Markup Level-2 Amount" * OrdUOMConvRatio,0.01);
//                       OrdUOMSalesMarkup3 := ROUND("Markup Level-3 Amount" * OrdUOMConvRatio,0.01);
//                       OrdUOMSalesEndPrice := ROUND("Customer End Unit Price" * OrdUOMConvRatio,0.01);
//                       OrdUOMSalesPrice := ROUND("Unit Price" * OrdUOMConvRatio,0.01);
//                     END;
//                   END;
//                 END;
//                 //#11328 End <<

//                 VALIDATE("No.",recItem."No.");
//                 VALIDATE("Unit of Measure Code",ItemCrossRef."Unit of Measure");
//                 VALIDATE("EDI Entry No.",xSalesLine."EDI Entry No.");
//                 VALIDATE("EDI Line No.",xSalesLine."EDI Line No.");
//                 VALIDATE("EDI Order ID",xSalesLine."EDI Order ID");
//                 VALIDATE("Client Unit Price",xSalesLine."Client Unit Price");
//                 VALIDATE("Order Quantity",xSalesLine."Order Quantity");
//                 VALIDATE("Order Item No.",xSalesLine."No.");                                               //HBSTG
//                 VALIDATE("Order Item Description",xSalesLine.Description);                                 //HBSTG
//                 VALIDATE("Substitute Line No.",xSalesLine."EDI Line No.");
//                 //VALIDATE(Description,ItemCrossRef.Description);                                            //HBSTG 2016-12-05
//                 Description:= ItemCrossRef.Description;                                                      //HBSRP

//                 SubstituteItem := TRUE;
//               END;
//               //HBSRP 2016-12-04 Start:
//               IF ContractDimVal."Enable Qty Tolerance Check" THEN BEGIN
//                 IF (NOT recItem."Random Weight Item") AND (NOT EDIInvoiceLine.Approved) AND (EDIInvoiceLine.Quantity <> 0) AND (ContractDimVal."Quantity Tolerance Limit" <> 0) AND
//                   ((EDIInvoiceLine.Quantity - Quantity) > 0) AND (NOT SubstituteItem) THEN
//                   ERROR(Text0023,EDIInvoiceLine."Item No.",EDIInvoiceLine.Quantity,Quantity);
//               END;
//               //HBSRP 2016-12-04 End:
//             END ELSE BEGIN                                                                 //If Line No. is found in SL but contract is other than Spotless
//               ItemCrossRef2.RESET;
//               ItemCrossRef2.SETRANGE("Item No.",SalesLine."No.");
//               ItemCrossRef2.SETRANGE("Cross-Reference Type",ItemCrossRef2."Cross-Reference Type"::Contract);
//               ItemCrossRef2.SETRANGE("Cross-Reference Type No.",CostCentre);
//               ItemCrossRef2.SETRANGE("Unit of Measure",SalesLine."Unit of Measure Code");
//               ItemCrossRef2.FINDFIRST;

//               //ReSRP 2018-02-26:Start:
//               IF recItem."No." <> SalesLine."No." THEN BEGIN
//                 IF ContractDimVal."Allow Replace By Item" THEN BEGIN
//                   IF IsExistReplaceItemNo() THEN BEGIN
//                     OriginalItemNo := SalesLine."No.";
//                     VALIDATE("No.",recItem."No.");
//                     VALIDATE("Unit of Measure Code",ContractPurchPrice1."Replace By Item UOM");
//                     "Random Weight Item" := recItem."Random Weight Item";                                            //ReSRP 2018-10-11
//                     VALIDATE("EDI Entry No.",xSalesLine."EDI Entry No.");
//                     VALIDATE("EDI Line No.",xSalesLine."EDI Line No.");
//                     VALIDATE("EDI Order ID",xSalesLine."EDI Order ID");
//                   END ELSE
//                     ERROR(Text0018,EDIInvoiceLine."Item No.",ItemCrossRef2."Cross-Reference No.",SalesLine."No.");
//                 END ELSE
//                   ERROR(Text0018,EDIInvoiceLine."Item No.",ItemCrossRef2."Cross-Reference No.",SalesLine."No.");
//               END;
//               //ReSRP 2018-02-26:End:

//               IF EDIInvoiceLine.Quantity < 0 THEN
//                 ERROR(Text0021,EDIInvoiceLine."Item No.");

//               //HBSRP 2016-12-04 Start:
//               IF ContractDimVal."Enable Qty Tolerance Check" THEN BEGIN
//                 //#CW4.56 Start:
//                 IF ItemCrossRef2."Quantity Tolerance Limit" <> 0 THEN BEGIN
//                   IF (NOT EDIInvoiceLine.Approved) AND ((EDIInvoiceLine.Quantity - Quantity) > (ItemCrossRef2."Quantity Tolerance Limit")) THEN
//                     ERROR(Text0031,SalesLine."No.",ItemCrossRef2."Cross-Reference No.",EDIInvoiceLine.Quantity,Quantity);
//                 END ELSE BEGIN
//                 //#CW4.56 End:
//                   IF (NOT EDIInvoiceLine.Approved) AND (ContractDimVal."Quantity Tolerance Limit" <> 0) AND ((EDIInvoiceLine.Quantity - Quantity) > (ContractDimVal."Quantity Tolerance Limit")) THEN
//                     ERROR(Text0020,EDIInvoiceLine."Item No.",EDIInvoiceLine.Quantity,Quantity);
//                 END
//               END;
//               //HBSRP 2016-12-04 End:
//             END;

//             SetHideValidationDialog(TRUE);

//             /* //HBSTG Commented Code because "Pick GST .." is only only used for EDI Order. For Invoice there is no requirement
//             IF ContractDimVal."Pick GST % from EDI" AND (CostCentre = EDISetup."CC Dimension Code for Spotless") THEN BEGIN
//               GSTPostingSetup.RESET;
//               GSTPostingSetup.SETRANGE("VAT Bus. Posting Group","VAT Bus. Posting Group");
//               GSTPostingSetup.SETRANGE("VAT Identifier",FORMAT(ROUND(EDIInvoiceLine."GST %",0.01)));
//               GSTPostingSetup.FINDFIRST;
//               VALIDATE("VAT Prod. Posting Group",GSTPostingSetup."VAT Prod. Posting Group");
//             END;
//             */
//             //HBSRP 2017-07-13 Start:
//             IF (recItem."Item Type" = recItem."Item Type"::"Auto-Created") AND (CostCentre = EDISetup."CC Dimension Code for Spotless") THEN BEGIN
//               GSTPostingSetup.RESET;
//               GSTPostingSetup.SETRANGE("VAT Bus. Posting Group","VAT Bus. Posting Group");
//               GSTPostingSetup.SETRANGE("VAT Identifier",FORMAT(ROUND(EDIInvoiceLine."GST %",0.01)));
//               GSTPostingSetup.FINDFIRST;
//               VALIDATE("VAT Prod. Posting Group",GSTPostingSetup."VAT Prod. Posting Group");
//             END;
//             //HBSRP 2017-07-13 End:
//             //VALIDATE(Quantity,EDIInvoiceLine.Quantity);
//             IF recItem."No." IN [EDISetup."Unsch. Weekday Delivery Code",EDISetup."Unsch. Weekend Delivery Code",EDISetup."Min. Order Value Charge Code",   //#CW4.55
//                                                                EDISetup."Min. Order Qty Charge Code",EDISetup."Late Order Fee Code"] THEN
//               VALIDATE(Quantity,1)
//             ELSE
//               VALIDATE(Quantity,EDIInvoiceLine.Quantity);
//             //HBSRP 2018-05-31 Start:
//             IF (Quantity = 0) AND ("Line Type" = "Line Type"::"Store Allocation") THEN
//               UpdateStoreAllocationLine();
//             //HBSRP 2018-05-31 End:

//             //RSTG 20180702: Spotless Pricing is now based on markups i.e. derived from Contract Purchase Price. Look in UpdatePOLine
//             /*
//             //HBSTG 2016-12-05: Start >>
//             IF (OutOfCatalogueItem) OR (recItem."Item Type" = recItem."Item Type"::"Auto-Created") THEN BEGIN
//               IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN BEGIN
//                 VALIDATE("Unit Price",ROUND(EDIInvoiceLine."Unit Price" * (100 + BillToCust."Mark Up Percentage") / 100,0.01)); //Unit Price in EDI Inv Lines are marked down prices
//               END;
//             //HBSTG 2016-12-05: End <<
//             //HBSRP 2017-06-02: Start:
//             END ELSE BEGIN
//               IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN BEGIN
//                 CLEAR(SalesPriceCalcMgt);
//                 IF NOT SalesPriceCalcMgt.SalesLinePriceExists(SalesHeader,SalesLine,FALSE) THEN
//                   VALIDATE("Unit Price",ROUND(EDIInvoiceLine."Unit Price" * (100 + BillToCust."Mark Up Percentage") / 100,0.01)); //Unit Price in EDI Inv Lines are marked down prices
//               END;
//             END;
//             //HBSRP 2017-06-02: End:
//             */
//             //Code commented as requested by CW not to deploy now.
//             //RSTG 2017-09-19: Start >>
//             //IF ("Unit Price" > ConvUOMPrice) AND (ConvUOMPrice > 0) AND (SubstituteItem) AND (recItem."Item Type" <> recItem."Item Type"::"Auto-Created") THEN  //ReSRP 2017-12-13
//             //  VALIDATE("Unit Price",ConvUOMPrice);
//             //RSTG 2017-09-19: End <<
//             VALIDATE("Reason Code",EDIInvoiceLine."Reason Code");
//             VALIDATE("Reason Description",EDIInvoiceLine."Reason Description");
//           END ELSE BEGIN                                                                //If Line No. is NOT found in SL
//             //If EDI Line No is not found in Original Order
//             IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN BEGIN        //If Line No. is NOT found in SL and contract is Spotless
//               //ERROR(Text0016,EDIInvoiceLine."Item No.");                                                   //HBSTG 2015-12-09
//               IF NOT EDIInvoiceLine.Approved THEN
//                 ERROR(Text0027,EDIInvoiceLine."Item No.")                                                   //HBSTG 2015-12-09
//               ELSE BEGIN
//                 RESET;
//                 INIT;
//                 VALIDATE("Document Type",SalesHeader."Document Type");
//                 VALIDATE("Document No.",SalesHeader."No.");
//                 LineNo += 10000;
//                 "Line No." := LineNo;
//                 INSERT(TRUE);
//                 SetHideValidationDialog(TRUE);
//                 VALIDATE(Type,Type::Item);
//                 VALIDATE("No.",recItem."No.");
//                 GSTPostingSetup.RESET;
//                 GSTPostingSetup.SETRANGE("VAT Bus. Posting Group","VAT Bus. Posting Group");
//                 GSTPostingSetup.SETRANGE("VAT Identifier",FORMAT(ROUND(EDIInvoiceLine."GST %",0.01)));
//                 GSTPostingSetup.FINDFIRST;
//                 VALIDATE("VAT Prod. Posting Group",GSTPostingSetup."VAT Prod. Posting Group");
//                 //VALIDATE("VAT %",EDIInvoiceLine."GST %");
//                 VALIDATE(Quantity,EDIInvoiceLine.Quantity);

//                 //Needs to be checked - could be redundant code
//                 ItemCrossRef.RESET;
//                 ItemCrossRef.SETRANGE("Item No.",recItem."No.");
//                 ItemCrossRef.SETRANGE("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::Contract);
//                 ItemCrossRef.SETRANGE("Cross-Reference Type No.",CostCentre);
//                 ItemCrossRef.FINDFIRST;
//                 ItemCrossRef.TESTFIELD("Unit of Measure");
//                 VALIDATE("Unit of Measure Code",ItemCrossRef."Unit of Measure");
//                 //VALIDATE(Description,ItemCrossRef.Description);                                            //HBSTG 2016-12-05
//                 Description := ItemCrossRef.Description;

//                 IF EDIInvoiceLine."Reason Code" = '' THEN BEGIN                                                  //RSTG 2017-08-30
//                   EDIInvoiceLine."Reason Code" := EDISetup."Default Subs Reason Code";
//                 END;
//                 ReasonCode.RESET;
//                 ReasonCode.SETRANGE(Code,EDIInvoiceLine."Reason Code");
//                 ReasonCode.SETRANGE("Spotless Substitution Reason",TRUE);
//                 IF NOT ReasonCode.FINDFIRST THEN
//                   ERROR(Text0026,EDIInvoiceLine."Item No.");
//                 SubstituteItem := TRUE;

//                 //RSTG 20180702: Spotless Pricing is now based on markups i.e. derived from Contract Purchase Price. Look in UpdatePOLine
//                 //HBSTG 2016-12-05: Start >>
//                 /*
//                 IF OutOfCatalogueItem THEN BEGIN
//                   VALIDATE("Unit Price",ROUND(EDIInvoiceLine."Unit Price" * (100 + BillToCust."Mark Up Percentage") / 100,0.01)); //Unit Price in EDI Inv Lines are marked down prices
//                 //HBSTG 2016-12-05: End <<
//                 //HBSRP 2017-06-02: Start:
//                 END ELSE BEGIN
//                   IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN BEGIN
//                     CLEAR(SalesPriceCalcMgt);
//                     IF NOT SalesPriceCalcMgt.SalesLinePriceExists(SalesHeader,SalesLine,FALSE) THEN
//                       VALIDATE("Unit Price",ROUND(EDIInvoiceLine."Unit Price" * (100 + BillToCust."Mark Up Percentage") / 100,0.01)); //Unit Price in EDI Inv Lines are marked down prices
//                   END;
//                 END;
//                 */
//                 //HBSRP 2017-06-02: End:

//                 VALIDATE("EDI Order ID",EDIInvoiceHeader."Order ID");
//                 VALIDATE("Reason Code",EDIInvoiceLine."Reason Code");
//                 VALIDATE("Reason Description",EDIInvoiceLine."Reason Description");
//                 VALIDATE("Substitute Line No.",EDIInvoiceLine."Substitute Line No.");
//                 EDILineNo += 1;
//                 IF Cust."Site on SAP" THEN
//                   VALIDATE("EDI Line No.",EDIInvoiceLine."Substitute Line No." + 1)
//                 ELSE
//                   VALIDATE("EDI Line No.",EDILineNo);
//               END;

//             END ELSE BEGIN                                                                //If Line No. is NOT found in SL but contract is other than Spotless
//               IF recItem."No." IN [EDISetup."Unsch. Weekday Delivery Code",EDISetup."Unsch. Weekend Delivery Code",EDISetup."Min. Order Value Charge Code",
//                                                                EDISetup."Min. Order Qty Charge Code",EDISetup."Late Order Fee Code"] THEN BEGIN             //#CW4.55
//                 //IF EDIInvoiceLine."Invoice Line No." = 0 THEN
//                   //ERROR(Text0025);
//                 RESET;
//                 INIT;
//                 VALIDATE("Document Type",SalesHeader."Document Type");
//                 VALIDATE("Document No.",SalesHeader."No.");
//                 LineNo += 10000;
//                 "Line No." := LineNo;
//                 INSERT(TRUE);
//                 SetHideValidationDialog(TRUE);
//                 VALIDATE(Type,Type::Item);
//                 VALIDATE("No.",recItem."No.");
//                 //VALIDATE(Quantity,EDIInvoiceLine.Quantity);
//                 VALIDATE(Quantity,1);
//                 VALIDATE("Unit of Measure Code",ItemCrossRef."Unit of Measure");
//                 VALIDATE("EDI Order ID",EDIInvoiceHeader."Order ID");
//                 "EDI Line No." := EDIInvoiceLine."Invoice Line No.";
//                 IF recItem."No." = EDISetup."Unsch. Weekday Delivery Code" THEN
//                   "Line Type" := "Line Type"::"Unsch Weekday Delivery";
//                 IF recItem."No." = EDISetup."Unsch. Weekend Delivery Code" THEN
//                   "Line Type" := "Line Type"::"Unsch Weekend Delivery";
//                 IF recItem."No." = EDISetup."Min. Order Value Charge Code" THEN
//                   "Line Type" := "Line Type"::"Minimum Order Value Charge";
//                 //#CW4.55 Start:
//                 IF recItem."No." = EDISetup."Min. Order Qty Charge Code" THEN
//                   "Line Type" := "Line Type"::MOQNA;
//                 IF recItem."No." = EDISetup."Late Order Fee Code"THEN
//                   "Line Type" := "Line Type"::LOF;
//                 //#CW4.55 End:
//               END ELSE
//                 ERROR(Text0016,EDIInvoiceLine."Item No.");
//             END;
//           END;
//           IF OriginalItemNo <> '' THEN
//             "Original Item No." := OriginalItemNo;

//           IF EDIInvoiceLine."Manufacturer Code" <> '' THEN
//             VALIDATE("Manufacturer Code",EDIInvoiceLine."Manufacturer Code");
//           IF EDIInvoiceLine.Brand <> '' THEN
//             VALIDATE(Brand,EDIInvoiceLine.Brand);
//           //IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN              //HBSTG 2016-12-05
//           //  VALIDATE(Description,EDIInvoiceLine.Description);
//           VALIDATE("EDI Invoice Line No.",EDIInvoiceLine."Invoice Line No.");
//           VALIDATE("EDI Invoice ID",EDIInvoiceHeader."Invoice ID");
//           VALIDATE("EDI Inv PK Line No.",EDIInvoiceLine."Line No.");
//           VALIDATE("EDI Invoice UOM",EDIInvoiceLine."Unit Of Measure Code");                               //HBSTG 2015-09-29
//           UnitPrice := "Unit Price";
//           MODIFY(TRUE);
//         END;

//     end;

//     [Scope('Internal')]
//     procedure UpdatePOHeader()
//     begin
//         WITH PurchHeader DO BEGIN
//           ReleasePurchDoc.Reopen(PurchHeader);
//           SetHideValidationDialog(TRUE);
//           VALIDATE("Posting Date",EDIInvoiceHeader."Invoice Date");
//           VALIDATE("Expected Receipt Date",EDIInvoiceHeader."Actual Delivery Date");
//           VALIDATE("Vendor Invoice No.",EDIInvoiceHeader."Invoice ID");
//           VALIDATE("EDI Invoice ID",EDIInvoiceHeader."Invoice ID");
//           VALIDATE("EDI Invoice Date",EDIInvoiceHeader."Invoice Date");                                    //HBSTG 2016-10-14
//           MODIFY(TRUE);
//         END;
//     end;

//     [Scope('Internal')]
//     procedure UpdatePOLine()
//     begin
//         CatalogueItemPriceFound := FALSE;
//         WITH PurchLine DO BEGIN
//           RESET;
//           SETRANGE("Document Type",PurchHeader."Document Type");
//           SETRANGE("Document No.",PurchHeader."No.");
//           SETRANGE("EDI Line No.",EDIInvoiceLine."Invoice Line No.");
//           SETFILTER("Line Type",'%1|%2|%3|%4|%5|%6|%7',"Line Type"::" ","Line Type"::"Store Allocation","Line Type"::"Unsch Weekday Delivery","Line Type"::"Unsch Weekend Delivery","Line Type"::"Minimum Order Value Charge",
//                                                                                   "Line Type"::MOQNA,"Line Type"::LOF);//#CW4.55
//           IF FINDFIRST THEN BEGIN                                                                           //If Line is found in PL
//             xPurchLine := PurchLine;
//             IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN BEGIN                            //If Line is found in PL and contract is spotless
//               IF recItem."No." <> "No." THEN BEGIN                                                         //If Substitute Item
//                 //Code commented as requested by CW not to deploy now.
//                 //#11328 Start >>
//                 IF OrdUOMConvRatio > 0 THEN BEGIN
//                   OrdUOMPurchMarkup1 := ROUND("Markup Level-1 Amount" * OrdUOMConvRatio,0.01);
//                   OrdUOMPurchMarkup2 := ROUND("Markup Level-2 Amount" * OrdUOMConvRatio,0.01);
//                   OrdUOMPurchMarkup3 := ROUND("Markup Level-3 Amount" * OrdUOMConvRatio,0.01);
//                   OrdUOMPurchEndCost := ROUND("Vendor End Unit Cost" * OrdUOMConvRatio,0.01);
//                   OrdUOMDirectUnitCost := ROUND("Direct Unit Cost" * OrdUOMConvRatio,0.01);
//                 END;
//                 //#11328 End <<

//                 VALIDATE("No.",recItem."No.");
//                 //VALIDATE(Description,ItemCrossRef.Description);                                            //HBSTG 2016-12-05
//                 Description:= ItemCrossRef.Description;                                                      //HBSRP
//                 VALIDATE("Unit of Measure Code",ItemCrossRef."Unit of Measure");
//                 VALIDATE("EDI Entry No.",xPurchLine."EDI Entry No.");
//                 VALIDATE("EDI Line No.",xPurchLine."EDI Line No.");
//                 VALIDATE("EDI Order ID",xPurchLine."EDI Order ID");
//                 VALIDATE("Order Quantity",xPurchLine."Order Quantity");
//                 VALIDATE("Order Item No.",xPurchLine."No.");                                               //HBSTG
//                 VALIDATE("Order Item Description",xPurchLine.Description);                                 //HBSTG
//                 VALIDATE("Substitute Line No.",xSalesLine."EDI Line No.");
//               END;
//               /* //HBSTG Commented Code because "Pick GST .." is only only used for EDI Order. For Invoice there is no requirement
//               IF ContractDimVal."Pick GST % from EDI" THEN BEGIN
//                 GSTPostingSetup.RESET;
//                 GSTPostingSetup.SETRANGE("VAT Bus. Posting Group","VAT Bus. Posting Group");
//                 GSTPostingSetup.SETRANGE("VAT Identifier",FORMAT(ROUND(EDIInvoiceLine."GST %",0.01)));
//                 GSTPostingSetup.FINDFIRST;
//                 VALIDATE("VAT Prod. Posting Group",GSTPostingSetup."VAT Prod. Posting Group");
//               END;
//               */
//               //HBSRP 2017-07-13 Start:
//               IF (recItem."Item Type" = recItem."Item Type"::"Auto-Created") THEN BEGIN
//                 GSTPostingSetup.RESET;
//                 GSTPostingSetup.SETRANGE("VAT Bus. Posting Group","VAT Bus. Posting Group");
//                 GSTPostingSetup.SETRANGE("VAT Identifier",FORMAT(ROUND(EDIInvoiceLine."GST %",0.01)));
//                 GSTPostingSetup.FINDFIRST;
//                 VALIDATE("VAT Prod. Posting Group",GSTPostingSetup."VAT Prod. Posting Group");
//               END;
//               //HBSRP 2017-07-13 End:
//             END;

//             //VALIDATE(Quantity,EDIInvoiceLine.Quantity);

//             //ReSRP 2018-02-26:Start:
//             IF ContractDimVal."Allow Replace By Item" THEN BEGIN
//               IF ReplaceByItem THEN BEGIN
//                 "Original Item No.":= PurchLine."No.";
//                 VALIDATE("No.",recItem."No.");
//                 VALIDATE("Unit of Measure Code",ContractPurchPrice1."Replace By Item UOM");
//                 "Random Weight Item" := recItem."Random Weight Item";                                          //ReSRP 2018-10-11
//                 VALIDATE("EDI Entry No.",xPurchLine."EDI Entry No.");
//                 VALIDATE("EDI Line No.",xPurchLine."EDI Line No.");
//                 VALIDATE("EDI Order ID",xPurchLine."EDI Order ID");
//               END;
//             END;
//             //ReSRP 2018-02-26:End:

//             IF recItem."No." IN [EDISetup."Unsch. Weekday Delivery Code",EDISetup."Unsch. Weekend Delivery Code",EDISetup."Min. Order Value Charge Code",
//                                                                             EDISetup."Min. Order Qty Charge Code",EDISetup."Late Order Fee Code"] THEN     //#CW4.55
//               VALIDATE(Quantity,1)
//             ELSE
//               VALIDATE(Quantity,EDIInvoiceLine.Quantity);

//             //Pricing Business Logic
//             //#11467 Start:
//             /*
//             IF CostCentre = EDISetup."CC Dimension Code for Pieface" THEN BEGIN
//               ContractPurchPrice := 0;
//               IF NOT PurchPriceCalcMgt.PurchLineContractPriceExists(PurchHeader,PurchLine,FALSE) THEN
//                 ERROR(Text0011,CostCentre,EDIInvoiceLine."Item No.");
//               IF NOT (recItem."No." IN [EDISetup."Unsch. Weekday Delivery Code",EDISetup."Unsch. Weekend Delivery Code",EDISetup."Min. Order Value Charge Code"]) THEN BEGIN
//                 ContractPurchPrice := "Direct Unit Cost";
//                 VALIDATE("Direct Unit Cost",ROUND("Direct Unit Cost" * (100 + ContractDimVal."Purchase Mark up Percentage") / 100,0.01));
//                 //SalesLine.VALIDATE("Unit Price","Direct Unit Cost");
//                 //HBSTG 2016-09-22 >>
//                 IF recItem."Customer Based Markup" THEN
//                   SalesLine.VALIDATE("Unit Price",ROUND(ContractPurchPrice * (100 + BillToCust."Mark Up Percentage") / 100,0.01))
//                 ELSE
//                   SalesLine.VALIDATE("Unit Price",ROUND(ContractPurchPrice * (100 + ContractDimVal."Sales Mark up Percentage") / 100,0.01));  //RSTG 20180621
//                 //HBSTG 2016-09-22 <<
//                 SalesLine.MODIFY;
//               END;
//             END;
//             */
//             //#11467 End:
//             //ReSRP 2017-10-10 Start:
//             IF (CostCentre = EDISetup."CC Dimension Code for Spotless") AND (recItem."Item Type" <> recItem."Item Type"::"Auto-Created") THEN                //RSTG 20180702
//               IF PurchPriceCalcMgt.PurchLineContractPriceExists(PurchHeader,PurchLine,FALSE) THEN
//                 CatalogueItemPriceFound := TRUE;

//             IF (CostCentre = EDISetup."CC Dim Code for Sumo Salad") OR (CatalogueItemPriceFound) OR (CostCentre = EDISetup."CC Dimension Code for Pieface") OR (CostCentre = EDISetup."CC Dim Code for Pizza Hut") THEN BEGIN  //#11467 //#CW4.55
//               IF NOT PurchPriceCalcMgt.PurchLineContractPriceExists(PurchHeader,PurchLine,FALSE) THEN
//                 ERROR(Text0011,CostCentre,EDIInvoiceLine."Item No.");
//               IF NOT (recItem."No." IN [EDISetup."Unsch. Weekday Delivery Code",EDISetup."Unsch. Weekend Delivery Code",EDISetup."Min. Order Value Charge Code",EDISetup."Late Order Fee Code",EDISetup."Min. Order Qty Charge Code"]) THEN BEGIN //#CW4.55
//                 MUUnitCost := "Direct Unit Cost";
//                 MUUnitPrice := "Direct Unit Cost";
//                 GetContractMarkupLevelPrice();               //This function updates Markup Amounts, End Price & Cost, Unit Price & Cost in Global Variables
//                 "Markup Level-1 Amount" := MarkupPurchAmt[1];
//                 "Markup Level-2 Amount" := MarkupPurchAmt[2];
//                 "Markup Level-3 Amount" := MarkupPurchAmt[3];
//                 VALIDATE("Vendor End Unit Cost",MUUnitCost);
//                 VALIDATE("Direct Unit Cost",PLUnitCost);
//                 SalesLine."Markup Level-1 Amount" := MarkupSalesAmt[1];
//                 SalesLine."Markup Level-2 Amount" := MarkupSalesAmt[2];
//                 SalesLine."Markup Level-3 Amount" := MarkupSalesAmt[3];
//                 SalesLine.VALIDATE("Customer End Unit Price",MUUnitPrice);
//                 SalesLine.VALIDATE("Unit Price",SLUnitPrice);
//                 SalesLine.MODIFY;
//                 CLEAR(MarkupPurchAmt);
//                 CLEAR(MarkupSalesAmt);
//                 CLEAR(MUUnitPrice);
//                 CLEAR(MUUnitCost);
//               END;
//             END;
//             IF (CostCentre = EDISetup."CC Dimension Code for Spotless") AND ((recItem."Item Type" = recItem."Item Type"::"Auto-Created") OR (NOT CatalogueItemPriceFound)) THEN BEGIN
//               "Markup Level-1 Amount" := 0.01;
//               "Markup Level-2 Amount" := 0;
//               "Markup Level-3 Amount" := 0;
//               VALIDATE("Vendor End Unit Cost",ROUND(EDIInvoiceLine."Unit Price",0.01));
//               VALIDATE("Direct Unit Cost",ROUND(EDIInvoiceLine."Unit Price",0.01));

//               SalesLine."Markup Level-1 Amount" := 0.01;
//               SalesLine."Markup Level-2 Amount" := ROUND("Direct Unit Cost" * BillToCust."Mark Up Percentage" / 100,0.01);
//               SalesLine."Markup Level-3 Amount" := 0;
//               SalesLine.VALIDATE("Customer End Unit Price",ROUND("Direct Unit Cost" * (100 + BillToCust."Mark Up Percentage") / 100,0.01));
//               SalesLine.VALIDATE("Unit Price","Direct Unit Cost");
//               SalesLine.MODIFY;
//             END;
//             //ReSRP 2017-10-10 End:
//             IF CostCentre = EDISetup."CC Dimension Code for GYG" THEN BEGIN
//               IF NOT PurchPriceCalcMgt.PurchLineContractPriceExists(PurchHeader,PurchLine,FALSE) THEN
//                 ERROR(Text0011,CostCentre,EDIInvoiceLine."Item No.");
//               IF NOT (recItem."No." IN [EDISetup."Unsch. Weekday Delivery Code",EDISetup."Unsch. Weekend Delivery Code",EDISetup."Min. Order Value Charge Code"]) THEN BEGIN
//                 SalesLine.VALIDATE("Unit Price","Direct Unit Cost");
//                 SalesLine.MODIFY;
//               END;
//             END;

//             "Vendor Unit Price" := EDIInvoiceLine."Unit Price";
//             VALIDATE("Reason Code",EDIInvoiceLine."Reason Code");
//             VALIDATE("Reason Description",EDIInvoiceLine."Reason Description");

//             //#11328 Start >>
//             IF (SalesLine."Unit Price" > OrdUOMSalesPrice) AND (OrdUOMConvRatio > 0) AND (SubstituteItem) AND (recItem."Item Type" <> recItem."Item Type"::"Auto-Created") AND (OrdUOMSalesPrice >0) THEN BEGIN
//               "Markup Level-1 Amount" := OrdUOMPurchMarkup1;
//               "Markup Level-2 Amount" := OrdUOMPurchMarkup2;
//               "Markup Level-3 Amount" := OrdUOMPurchMarkup3;
//               VALIDATE("Vendor End Unit Cost",OrdUOMPurchEndCost);
//               VALIDATE("Direct Unit Cost",OrdUOMDirectUnitCost);
//               SalesLine."Markup Level-1 Amount" := OrdUOMSalesMarkup1;
//               SalesLine."Markup Level-2 Amount" := OrdUOMSalesMarkup2;
//               SalesLine."Markup Level-3 Amount" := OrdUOMSalesMarkup3;
//               SalesLine.VALIDATE("Customer End Unit Price",OrdUOMSalesEndPrice);
//               SalesLine.VALIDATE("Unit Price",OrdUOMSalesPrice);
//               SalesLine.MODIFY;
//             END;
//             //#11328 End <<

//           END ELSE BEGIN                                                                                  //If Line is NOT found in PL
//             IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN BEGIN                          //If Line is NOT found in PL and contract is spotless
//               //ERROR(Text0016,EDIInvoiceLine."Item No.");                                                   //HBSTG 2015-12-09
//               IF NOT EDIInvoiceLine.Approved THEN
//                 ERROR(Text0027,EDIInvoiceLine."Item No.")
//               ELSE BEGIN
//                 RESET;
//                 INIT;
//                 VALIDATE("Document Type",PurchHeader."Document Type");
//                 VALIDATE("Document No.",PurchHeader."No.");
//                 "Line No." := LineNo;
//                 INSERT(TRUE);
//                 VALIDATE(Type,Type::Item);
//                 VALIDATE("No.",recItem."No.");
//                 GSTPostingSetup.RESET;
//                 GSTPostingSetup.SETRANGE("VAT Bus. Posting Group","VAT Bus. Posting Group");
//                 GSTPostingSetup.SETRANGE("VAT Identifier",FORMAT(ROUND(EDIInvoiceLine."GST %",0.01)));
//                 GSTPostingSetup.FINDFIRST;
//                 VALIDATE("VAT Prod. Posting Group",GSTPostingSetup."VAT Prod. Posting Group");
//                 VALIDATE(Quantity,EDIInvoiceLine.Quantity);
//                 VALIDATE("Unit of Measure Code",ItemCrossRef."Unit of Measure");
//                 //VALIDATE(Description,ItemCrossRef.Description);                                            //HBSTG 2016-12-05
//                 Description := ItemCrossRef.Description;                                                     //HBSRP

//                 //RSTG 20180702: Start >>
//                 IF recItem."Item Type" <> recItem."Item Type"::"Auto-Created" THEN
//                   IF PurchPriceCalcMgt.PurchLineContractPriceExists(PurchHeader,PurchLine,FALSE) THEN
//                     CatalogueItemPriceFound := TRUE;
//                 IF CatalogueItemPriceFound THEN BEGIN
//                   IF NOT (recItem."No." IN [EDISetup."Unsch. Weekday Delivery Code",EDISetup."Unsch. Weekend Delivery Code",EDISetup."Min. Order Value Charge Code",
//                                                            EDISetup."Min. Order Qty Charge Code",EDISetup."Late Order Fee Code"]) THEN BEGIN    //#CW4.55
//                     MUUnitCost := "Direct Unit Cost";
//                     MUUnitPrice := "Direct Unit Cost";
//                     GetContractMarkupLevelPrice();               //This function updates Markup Amounts, End Price & Cost, Unit Price & Cost in Global Variables
//                     "Markup Level-1 Amount" := MarkupPurchAmt[1];
//                     "Markup Level-2 Amount" := MarkupPurchAmt[2];
//                     "Markup Level-3 Amount" := MarkupPurchAmt[3];
//                     VALIDATE("Vendor End Unit Cost",MUUnitCost);
//                     VALIDATE("Direct Unit Cost",PLUnitCost);
//                     SalesLine."Markup Level-1 Amount" := MarkupSalesAmt[1];
//                     SalesLine."Markup Level-2 Amount" := MarkupSalesAmt[2];
//                     SalesLine."Markup Level-3 Amount" := MarkupSalesAmt[3];
//                     SalesLine.VALIDATE("Customer End Unit Price",MUUnitPrice);
//                     SalesLine.VALIDATE("Unit Price",SLUnitPrice);
//                     SalesLine.MODIFY;
//                     CLEAR(MarkupPurchAmt);
//                     CLEAR(MarkupSalesAmt);
//                     CLEAR(MUUnitPrice);
//                     CLEAR(MUUnitCost);
//                   END;
//                 END;
//                 IF (recItem."Item Type" = recItem."Item Type"::"Auto-Created") OR (NOT CatalogueItemPriceFound) THEN BEGIN
//                   "Markup Level-1 Amount" := 0.01;
//                   "Markup Level-2 Amount" := 0;
//                   "Markup Level-3 Amount" := 0;
//                   VALIDATE("Vendor End Unit Cost",ROUND(EDIInvoiceLine."Unit Price",0.01));
//                   VALIDATE("Direct Unit Cost",ROUND(EDIInvoiceLine."Unit Price",0.01));

//                   SalesLine."Markup Level-1 Amount" := 0.01;
//                   SalesLine."Markup Level-2 Amount" := ROUND("Direct Unit Cost" * BillToCust."Mark Up Percentage" / 100,0.01);
//                   SalesLine."Markup Level-3 Amount" := 0;
//                   SalesLine.VALIDATE("Customer End Unit Price",ROUND("Direct Unit Cost" * (100 + BillToCust."Mark Up Percentage") / 100,0.01));
//                   SalesLine.VALIDATE("Unit Price","Direct Unit Cost");
//                   SalesLine.MODIFY;
//                 END;
//                 //RSTG 20180702: End <<

//                 "Vendor Unit Price" := EDIInvoiceLine."Unit Price";
//                 VALIDATE("EDI Order ID",EDIInvoiceHeader."Order ID");
//                 VALIDATE("Reason Code",EDIInvoiceLine."Reason Code");
//                 VALIDATE("Reason Description",EDIInvoiceLine."Reason Description");
//                 VALIDATE("Substitute Line No.",EDIInvoiceLine."Substitute Line No.");
//                 IF Cust."Site on SAP" THEN
//                   VALIDATE("EDI Line No.",EDIInvoiceLine."Substitute Line No." + 1)
//                 ELSE
//                   VALIDATE("EDI Line No.",EDILineNo);
//               END;

//             END ELSE BEGIN                                                                                        //If Line is NOT found in PL and contract is not spotless
//               IF recItem."No." IN [EDISetup."Unsch. Weekday Delivery Code",EDISetup."Unsch. Weekend Delivery Code",EDISetup."Min. Order Value Charge Code",
//                                                            EDISetup."Min. Order Qty Charge Code",EDISetup."Late Order Fee Code"] THEN BEGIN  //#CW4.55
//                 RESET;
//                 INIT;
//                 VALIDATE("Document Type",PurchHeader."Document Type");
//                 VALIDATE("Document No.",PurchHeader."No.");
//                 "Line No." := LineNo;
//                 INSERT(TRUE);
//                 VALIDATE(Type,Type::Item);
//                 VALIDATE("No.",recItem."No.");
//                 //VALIDATE(Quantity,EDIInvoiceLine.Quantity);
//                 VALIDATE(Quantity,1);
//                 VALIDATE("Unit of Measure Code",ItemCrossRef."Unit of Measure");
//                 "EDI Line No." := EDIInvoiceLine."Invoice Line No.";
//                 IF NOT PurchPriceCalcMgt.PurchLineContractPriceExists(PurchHeader,PurchLine,FALSE) THEN
//                   ERROR(Text0013,recItem."No.");
//                   //VALIDATE("Direct Unit Cost",UnitPrice);
//                 "Vendor Unit Price" := EDIInvoiceLine."Unit Price";
//                 VALIDATE("EDI Order ID",EDIInvoiceHeader."Order ID");
//                 IF recItem."No." = EDISetup."Unsch. Weekday Delivery Code" THEN
//                   "Line Type" := "Line Type"::"Unsch Weekday Delivery";
//                 IF recItem."No." = EDISetup."Unsch. Weekend Delivery Code" THEN
//                   "Line Type" := "Line Type"::"Unsch Weekend Delivery";
//                 IF recItem."No." = EDISetup."Min. Order Value Charge Code" THEN
//                   "Line Type" := "Line Type"::"Minimum Order Value Charge";
//                 //#CW4.55 Start:
//                 IF recItem."No." = EDISetup."Min. Order Qty Charge Code" THEN
//                   "Line Type" := "Line Type"::MOQNA;
//                 IF recItem."No." = EDISetup."Late Order Fee Code" THEN
//                   "Line Type" := "Line Type"::LOF;
//                 //#CW4.55 End:
//               END ELSE
//                 ERROR(Text0016,EDIInvoiceLine."Item No.");
//             END;
//           END;

//           IF (SalesLine.Quantity <> 0) AND (SalesLine."Unit Price" = 0) THEN
//             ERROR(Text0012,EDIInvoiceLine."Item No.");
//           IF (Quantity <> 0) AND ("Direct Unit Cost" = 0) THEN
//             ERROR(Text0013,EDIInvoiceLine."Item No.");

//           IF OriginalItemNo <> '' THEN
//             "Original Item No." := OriginalItemNo;

//           IF EDIInvoiceLine."Manufacturer Code" <> '' THEN
//             VALIDATE("Manufacturer Code",EDIInvoiceLine."Manufacturer Code");
//           IF EDIInvoiceLine.Brand <> '' THEN
//             VALIDATE(Brand,EDIInvoiceLine.Brand);
//           //IF CostCentre = EDISetup."CC Dimension Code for Spotless" THEN                                 //HBSTG 2016-12-05
//           //  VALIDATE(Description,EDIInvoiceLine.Description);                                            //HBSRP 2015-09-16
//           VALIDATE("EDI Invoice Line No.",EDIInvoiceLine."Invoice Line No.");
//           VALIDATE("EDI Invoice ID",EDIInvoiceHeader."Invoice ID");
//           VALIDATE("EDI Inv PK Line No.",EDIInvoiceLine."Line No.");
//           VALIDATE("EDI Invoice UOM",EDIInvoiceLine."Unit Of Measure Code");                               //HBSTG 2015-09-29
//           MODIFY(TRUE);
//         END;

//     end;

//     [Scope('Internal')]
//     procedure CreateItem(var pItem: Record "27";ItemCode: Code[20];ItemDesc: Text[50];ContractDimValCode: Code[20];VendorCode: Code[20];UOM: Code[10])
//     var
//         ConfigTemplateMgt: Codeunit "8612";
//         RecRef: RecordRef;
//         ConfigTemplateHeader: Record "8618";
//         lvItemUOM: Record "5404";
//     begin
//         ConfigTemplateHeader.GET(EDISetup."EDI Item Template");

//         RecRef.OPEN(27);
//         ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader,RecRef);
//         RecRef.SETTABLE(pItem);

//         lvItemUOM.RESET;
//         lvItemUOM.INIT;
//         lvItemUOM."Item No." := pItem."No.";
//         lvItemUOM.Code := UOM;
//         lvItemUOM."Qty. per Unit of Measure" := 1;
//         lvItemUOM."UOM Type" := lvItemUOM."UOM Type"::Inner;
//         lvItemUOM.INSERT(TRUE);

//         pItem.VALIDATE("Base Unit of Measure",UOM);
//         pItem.MODIFY(TRUE);

//         IF VendorCode <> '' THEN BEGIN
//           ItemCrossRef.RESET;
//           ItemCrossRef.INIT;
//           ItemCrossRef."Item No." := pItem."No.";
//           ItemCrossRef."Unit of Measure" := UOM;
//           ItemCrossRef."Cross-Reference Type" := ItemCrossRef."Cross-Reference Type"::Vendor;
//           ItemCrossRef."Cross-Reference Type No." := VendorCode;
//           ItemCrossRef."Cross-Reference No." := ItemCode;
//           ItemCrossRef.Description := ItemDesc;
//           ItemCrossRef."Member Unit of Measure" := UOM;
//           ItemCrossRef.INSERT(TRUE);
//         END;

//         IF ContractDimValCode <> '' THEN BEGIN
//           ItemCrossRef.RESET;
//           ItemCrossRef.INIT;
//           ItemCrossRef."Item No." := pItem."No.";
//           ItemCrossRef."Unit of Measure" := UOM;
//           ItemCrossRef."Cross-Reference Type" := ItemCrossRef."Cross-Reference Type"::Contract;
//           ItemCrossRef."Cross-Reference Type No." := ContractDimValCode;
//           ItemCrossRef."Cross-Reference No." := ItemCode;
//           ItemCrossRef.Description := ItemDesc;
//           ItemCrossRef."Customer Unit of Measure" := UOM;
//           ItemCrossRef.INSERT(TRUE);
//         END;
//     end;

//     [Scope('Internal')]
//     procedure CreateMsgLog(EmailSubject: Text[250];EmailBody: Text[250];EmailTo: Text[100];EmailCC: Text[100];EmailBCC: Text[100];SourceType: Code[50];SourceNo: Code[100])
//     var
//         MessageLog: Record "50011";
//     begin
//         MessageLog.RESET;
//         MessageLog.INIT;
//         MessageLog."Subject Line" := EmailSubject;
//         MessageLog."Body Line" := EmailBody;
//         MessageLog."To Address" := EmailTo;
//         MessageLog."CC Address" := EmailCC;            //HBSTG  2015-08-14
//         MessageLog."BCC Address" := EmailBCC;          //HBSTG  2015-08-14
//         MessageLog."Source Type" := SourceType;
//         MessageLog."Source No." := SourceNo;
//         MessageLog."Logging DateTime" := CURRENTDATETIME;
//         MessageLog.INSERT(TRUE);
//     end;

//     [Scope('Internal')]
//     procedure UpdateOrderLineForFeeAndIncentives()
//     var
//         lvSalesLine: Record "37";
//         lvPurchLine: Record "39";
//         lvPaymentMethod: Record "289";
//         lvNoOfCarton: Decimal;
//         lvNoOfBrokenCarton: Decimal;
//         lvLineAmount: Decimal;
//         lvItemLineAmount: Decimal;
//         lvNoOfBag: Decimal;
//     begin
//         lvNoOfCarton := 0;
//         lvNoOfBrokenCarton := 0;
//         lvLineAmount := 0;
//         lvItemLineAmount := 0;
//         lvNoOfBag := 0;                                                                                    //#CW4.55

//         lvSalesLine.RESET;
//         lvSalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
//         lvSalesLine.SETRANGE("Document No.",SalesHeader."No.");
//         lvSalesLine.SETRANGE(Type,lvSalesLine.Type::Item);
//         lvSalesLine.SETFILTER("Line Type",'%1|%2',lvSalesLine."Line Type"::" ",lvSalesLine."Line Type"::"Store Allocation");
//         IF lvSalesLine.FINDSET THEN
//           REPEAT
//             IF NOT lvSalesLine."Random Weight Item" THEN BEGIN                                                       //HBSTG 20160902
//               IF lvSalesLine."Unit of Measure Code" = EDISetup."Carton Unit of Measure" THEN
//                 lvNoOfCarton += lvSalesLine.Quantity
//               ELSE IF (lvSalesLine."Unit of Measure Code" = EDISetup."Bag Unit of Measure") AND ContractDimVal."Allow BAG Seperate UOM" THEN
//                 lvNoOfBag += lvSalesLine.Quantity
//               ELSE
//                 lvNoOfBrokenCarton += lvSalesLine.Quantity;
//             END ELSE BEGIN
//               lvNoOfCarton += lvSalesLine."Quantity (Outer)";
//             END;
//           UNTIL lvSalesLine.NEXT = 0;

//         SalesLine.RESET;
//         SalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
//         SalesLine.SETRANGE("Document No.",SalesHeader."No.");
//         SalesLine.SETFILTER(Type,'<>%1',SalesLine.Type::" ");                                              //HBSTG 2014-03-12: Fix for correction of wrongly posted sales invoices
//         //#CW4.55 Start:
//         /*
//         SalesLine.SETFILTER("Line Type",'%1|%2|%3|%4|%5|%6|%7|%8|%9|%10',
//                                          SalesLine."Line Type"::"Case Rate",
//                                             SalesLine."Line Type"::"Broken Case Rate",
//                                                SalesLine."Line Type"::"Carton Freight",
//                                                   SalesLine."Line Type"::"Carton Case Income",
//                                                      SalesLine."Line Type"::"Direct Debit Income",
//                                                         SalesLine."Line Type"::"Online Order Income",
//                                                            SalesLine."Line Type"::"CW Bad Debt",
//                                                               SalesLine."Line Type"::"MOQ Incentive",
//                                                                  SalesLine."Line Type"::"Direct Debit Incentive",
//                                                                     SalesLine."Line Type"::"Online Order Incentive");
//         */
//         SalesLine.SETFILTER("Line Type",'<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8&<>%9',
//                                          SalesLine."Line Type"::" ",
//                                            SalesLine."Line Type"::"Store Allocation",
//                                              SalesLine."Line Type"::MOQNA,
//                                                SalesLine."Line Type"::"Credit Card Surcharge",
//                                                  SalesLine."Line Type"::"Unsch Weekday Delivery",
//                                                    SalesLine."Line Type"::"Unsch Weekend Delivery",
//                                                      SalesLine."Line Type"::"CW User Pay",
//                                                        SalesLine."Line Type"::"Minimum Order Value Charge",
//                                                          SalesLine."Line Type"::LOF);
//         //#CW4.55 End:
//         IF SalesLine.FINDSET THEN BEGIN
//           REPEAT
//             CASE SalesLine."Line Type" OF
//               SalesLine."Line Type"::"Case Rate":
//                 BEGIN
//                   SalesLine.VALIDATE(Quantity,lvNoOfCarton);
//                 END;
//               SalesLine."Line Type"::"Broken Case Rate":
//                 BEGIN
//                   SalesLine.VALIDATE(Quantity,lvNoOfBrokenCarton);
//                 END;
//               SalesLine."Line Type"::"Carton Freight":
//                 BEGIN
//                   SalesLine.VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton);
//                 END;
//               SalesLine."Line Type"::"Carton Case Income":
//                 BEGIN
//                   SalesLine.VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton);
//                 END;
//               SalesLine."Line Type"::"Direct Debit Income":
//                 BEGIN
//                   SalesLine.VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton +lvNoOfBag);
//                 END;
//               SalesLine."Line Type"::"Online Order Income":
//                 BEGIN
//                   SalesLine.VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton +lvNoOfBag);
//                 END;
//               SalesLine."Line Type"::"CW Bad Debt":
//                 BEGIN
//                   SalesLine.VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton +lvNoOfBag);
//                 END;
//               SalesLine."Line Type"::"MOQ Incentive":
//                 BEGIN
//                   SalesLine.VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton +lvNoOfBag);
//                 END;
//               SalesLine."Line Type"::"Direct Debit Incentive":
//                 BEGIN
//                   SalesLine.VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton +lvNoOfBag);
//                 END;
//               SalesLine."Line Type"::"Online Order Incentive":
//                 BEGIN
//                   SalesLine.VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton +lvNoOfBag);
//                 END;
//               //#CW4.55 Start:
//               SalesLine."Line Type"::"Bag Rate":
//                 BEGIN
//                   SalesLine.VALIDATE(Quantity,lvNoOfBag);
//                 END;
//               SalesLine."Line Type"::"Bag Income":
//                 BEGIN
//                   SalesLine.VALIDATE(Quantity,lvNoOfBag);
//                 END;
//               SalesLine."Line Type"::"Bag Freight":
//                 BEGIN
//                   SalesLine.VALIDATE(Quantity,lvNoOfBag);
//                 END;
//               //#CW4.55 End:
//             END;
//             SalesLine.MODIFY(TRUE);
//           UNTIL SalesLine.NEXT = 0;
//         END;

//         SalesLine.RESET;
//         SalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
//         SalesLine.SETRANGE("Document No.",SalesHeader."No.");
//         SalesLine.SETFILTER(Type,'<>%1',SalesLine.Type::" ");                                              //HBSTG 2014-03-12: Fix for correction of wrongly posted sales invoices
//         SalesLine.SETFILTER("Line Type",'%1',SalesLine."Line Type"::"Credit Card Surcharge");
//         IF SalesLine.FINDFIRST THEN BEGIN
//           lvSalesLine.RESET;
//           lvSalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
//           lvSalesLine.SETRANGE("Document No.",SalesHeader."No.");
//           lvSalesLine.SETFILTER("Line Type",'<>%1',lvSalesLine."Line Type"::"Credit Card Surcharge");
//           IF lvSalesLine.FINDSET THEN
//             REPEAT
//               lvLineAmount += lvSalesLine."Line Amount";
//             UNTIL lvSalesLine.NEXT = 0;
//           SalesLine.VALIDATE("Unit Price",ROUND(lvLineAmount,0.01));
//           SalesLine.MODIFY(TRUE);
//         END;

//         PurchLine.RESET;
//         PurchLine.SETRANGE("Document Type",PurchHeader."Document Type");
//         PurchLine.SETRANGE("Document No.",PurchHeader."No.");
//         PurchLine.SETFILTER(Type,'<>%1',PurchLine.Type::" ");                                              //HBSTG 2014-03-12: Fix for correction of wrongly posted sales invoices
//         //#CW4.55 Start:
//         /*
//         PurchLine.SETFILTER("Line Type",'%1|%2|%3|%4|%5|%6|%7',
//                                          PurchLine."Line Type"::"Case Rate",
//                                             PurchLine."Line Type"::"Broken Case Rate",
//                                                PurchLine."Line Type"::"MOQ Incentive",
//                                                   PurchLine."Line Type"::"Online Order Incentive",         //HBSTG 2015-06-29
//                                                      PurchLine."Line Type"::"CW User Pay",                //HBSTG 2016-09-07
//                                                        PurchLine."Line Type"::"Bag Rate",
//                                                          PurchLine."Line Type"::"Bag Income");            //#CW4.55
//         */
//         PurchLine.SETFILTER("Line Type",'<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8',
//                                          PurchLine."Line Type"::" ",
//                                            PurchLine."Line Type"::"Store Allocation",
//                                              PurchLine."Line Type"::MOQNA,
//                                                PurchLine."Line Type"::"Credit Card Surcharge",
//                                                  PurchLine."Line Type"::"Unsch Weekday Delivery",
//                                                    PurchLine."Line Type"::"Unsch Weekend Delivery",
//                                                      PurchLine."Line Type"::"Minimum Order Value Charge",
//                                                          PurchLine."Line Type"::LOF);
//         //#CW4.55 End:

//         IF PurchLine.FINDSET THEN BEGIN
//           REPEAT
//             CASE PurchLine."Line Type" OF
//               PurchLine."Line Type"::"Case Rate":
//                 BEGIN
//                   PurchLine.VALIDATE(Quantity,lvNoOfCarton);
//                 END;
//               PurchLine."Line Type"::"Broken Case Rate":
//                 BEGIN
//                   PurchLine.VALIDATE(Quantity,lvNoOfBrokenCarton);
//                 END;
//               PurchLine."Line Type"::"MOQ Incentive":
//                 BEGIN
//                   PurchLine.VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton +lvNoOfBag);
//                 END;
//               PurchLine."Line Type"::"Online Order Incentive":                                             //HBSTG 2015-06-29
//                 BEGIN
//                   PurchLine.VALIDATE(Quantity,lvNoOfCarton + lvNoOfBrokenCarton +lvNoOfBag);
//                 END;
//               //#CW4.55 Start:
//               PurchLine."Line Type"::"Bag Rate":
//                 BEGIN
//                   PurchLine.VALIDATE(Quantity,lvNoOfBag);
//                 END;
//               PurchLine."Line Type"::"Bag Income":                                             //HBSTG 2015-06-29
//                 BEGIN
//                   PurchLine.VALIDATE(Quantity,lvNoOfBag);
//                 END;

//               //#CW4.55 End:
//               PurchLine."Line Type"::"CW User Pay":                                                        //HBSTG 2016-09-07
//                 BEGIN
//                   lvPurchLine.RESET;
//                   lvPurchLine.SETRANGE("Document Type",PurchHeader."Document Type");
//                   lvPurchLine.SETRANGE("Document No.",PurchHeader."No.");
//                   lvPurchLine.SETRANGE(Type,lvPurchLine.Type::Item);
//                   lvPurchLine.SETFILTER("Line Type",'%1|%2',lvPurchLine."Line Type"::" ",lvPurchLine."Line Type"::"Store Allocation");
//                   IF lvPurchLine.FINDSET THEN
//                     REPEAT
//                       lvItemLineAmount += lvPurchLine."Line Amount";
//                     UNTIL lvPurchLine.NEXT = 0;
//                   PurchLine.VALIDATE("Direct Unit Cost",-lvItemLineAmount);
//                 END;
//             END;
//             PurchLine.MODIFY(TRUE);
//           UNTIL PurchLine.NEXT = 0;
//         END;

//     end;

//     [Scope('Internal')]
//     procedure GetContractMarkupLevelPrice()
//     var
//         MarkupSetup: Record "50038";
//         MarkupLevelPercentageSetup: Record "50039";
//     begin
//         MarkupSetup.RESET;
//         MarkupSetup.SETRANGE("Contract Dimension Code",CostCentre);
//         MarkupSetup.SETFILTER("Start Date",'<=%1',SalesHeader."Order Date");
//         MarkupSetup.SETFILTER("End Date",'>=%1',SalesHeader."Order Date");
//         IF MarkupSetup.FINDSET THEN BEGIN
//           PLUnitCost := 0;
//           SLUnitPrice := 0;
//           CLEAR(MarkupPurchAmt);
//           CLEAR(MarkupSalesAmt);
//           REPEAT
//             Lvl := MarkupSetup."Mark-up Level" + 1;                         //Since Option "Level 1" = 0, add 1

//             MarkupLevelPercentageSetup.RESET;
//             MarkupLevelPercentageSetup.SETRANGE("Contract Dimension Code",CostCentre);
//             MarkupLevelPercentageSetup.SETRANGE("Mark-up Level",MarkupSetup."Mark-up Level");
//             MarkupLevelPercentageSetup.SETRANGE("Customer No.",Cust."No.");
//             MarkupLevelPercentageSetup.SETRANGE("Item No.",recItem."No.");
//             MarkupLevelPercentageSetup.SETFILTER("Start Date",'<=%1',SalesHeader."Order Date");
//             MarkupLevelPercentageSetup.SETFILTER("End Date",'>=%1',SalesHeader."Order Date");
//             IF MarkupLevelPercentageSetup.FINDFIRST THEN BEGIN
//               IF MarkupLevelPercentageSetup."Calculation Type" = MarkupLevelPercentageSetup."Calculation Type"::"Mark-Up Percentage" THEN BEGIN
//                 MarkupPurchAmt[Lvl] := ROUND(MUUnitCost * MarkupLevelPercentageSetup."Markup Purch (% or Amt)" / 100,0.01);
//                 MarkupSalesAmt[Lvl] := ROUND(MUUnitPrice * MarkupLevelPercentageSetup."Markup Sales (% or Amt)" / 100,0.01);
//               END ELSE IF MarkupLevelPercentageSetup."Calculation Type" = MarkupLevelPercentageSetup."Calculation Type"::Amount THEN BEGIN
//                 MarkupPurchAmt[Lvl] := MarkupLevelPercentageSetup."Markup Purch (% or Amt)";
//                 MarkupSalesAmt[Lvl] := MarkupLevelPercentageSetup."Markup Sales (% or Amt)";
//               //#11473 Start:
//               END ELSE IF MarkupLevelPercentageSetup."Calculation Type" = MarkupLevelPercentageSetup."Calculation Type"::"Margin Percentage" THEN BEGIN
//                 MarkupPurchAmt[Lvl] := ROUND((MUUnitCost/(1-(MarkupLevelPercentageSetup."Markup Purch (% or Amt)" / 100)))-MUUnitCost,0.01);
//                 MarkupSalesAmt[Lvl] := ROUND((MUUnitPrice/(1-(MarkupLevelPercentageSetup."Markup Sales (% or Amt)" / 100)))-MUUnitPrice,0.01);
//               END;
//               //#11473 End:
//             //#11835 Start:
//             END ELSE BEGIN
//               MarkupLevelPercentageSetup.RESET;
//               MarkupLevelPercentageSetup.SETRANGE("Contract Dimension Code",CostCentre);
//               MarkupLevelPercentageSetup.SETRANGE("Mark-up Level",MarkupSetup."Mark-up Level");
//               MarkupLevelPercentageSetup.SETRANGE("Customer No.",RefCust."No.");
//               MarkupLevelPercentageSetup.SETRANGE("Item No.",recItem."No.");
//               MarkupLevelPercentageSetup.SETFILTER("Start Date",'<=%1',SalesHeader."Order Date");
//               MarkupLevelPercentageSetup.SETFILTER("End Date",'>=%1',SalesHeader."Order Date");
//               IF MarkupLevelPercentageSetup.FINDFIRST THEN BEGIN
//                 IF MarkupLevelPercentageSetup."Calculation Type" = MarkupLevelPercentageSetup."Calculation Type"::"Mark-Up Percentage" THEN BEGIN
//                   MarkupPurchAmt[Lvl] := ROUND(MUUnitCost * MarkupLevelPercentageSetup."Markup Purch (% or Amt)" / 100,0.01);
//                   MarkupSalesAmt[Lvl] := ROUND(MUUnitPrice * MarkupLevelPercentageSetup."Markup Sales (% or Amt)" / 100,0.01);
//                 END ELSE IF MarkupLevelPercentageSetup."Calculation Type" = MarkupLevelPercentageSetup."Calculation Type"::Amount THEN BEGIN
//                   MarkupPurchAmt[Lvl] := MarkupLevelPercentageSetup."Markup Purch (% or Amt)";
//                   MarkupSalesAmt[Lvl] := MarkupLevelPercentageSetup."Markup Sales (% or Amt)";
//                 //#11473 Start:
//                 END ELSE IF MarkupLevelPercentageSetup."Calculation Type" = MarkupLevelPercentageSetup."Calculation Type"::"Margin Percentage" THEN BEGIN
//                   MarkupPurchAmt[Lvl] := ROUND((MUUnitCost/(1-(MarkupLevelPercentageSetup."Markup Purch (% or Amt)" / 100)))-MUUnitCost,0.01);
//                   MarkupSalesAmt[Lvl] := ROUND((MUUnitPrice/(1-(MarkupLevelPercentageSetup."Markup Sales (% or Amt)" / 100)))-MUUnitPrice,0.01);
//                 END;
//               END;
//             END;
//             //#11835 End:
//             MUUnitCost += MarkupPurchAmt[Lvl];
//             MUUnitPrice += MarkupSalesAmt[Lvl];
//             IF MarkupSetup."Include In Unit Cost (Purch)" THEN
//               PLUnitCost := MUUnitCost;
//             IF MarkupSetup."Include In Unit Price (Sales)" THEN
//               SLUnitPrice := MUUnitPrice;
//           UNTIL MarkupSetup.NEXT = 0;
//         END;
//     end;

//     local procedure UpdateOrderLineForMarkup()
//     var
//         lMarkupSetup: Record "50038";
//         lItem: Record "27";
//         lvSalesLine: Record "37";
//         lvPurchLine: Record "39";
//         lvMarkupLevel: Option "Level-1","Level-2","Level-3";
//         lvMarkupLevelTotalPurchAmt: Decimal;
//         lvMarkupLevelTotalSalesAmt: Decimal;
//     begin
//         lvSalesLine.RESET;
//         lvSalesLine.SETRANGE("Document Type",SalesHeader."Document Type");
//         lvSalesLine.SETRANGE("Document No.",SalesHeader."No.");
//         lvSalesLine.SETFILTER(Type,'<>%1',lvSalesLine.Type::" ");                                        //HBSTG 2014-03-12: Fix for correction of wrongly posted sales invoices
//         lvSalesLine.SETFILTER("Line Type",'%1|%2|%3',
//                                             lvSalesLine."Line Type"::MU1,
//                                                lvSalesLine."Line Type"::MU2,
//                                                   lvSalesLine."Line Type"::MU3);
//         IF lvSalesLine.FINDSET THEN BEGIN
//           REPEAT
//             lvMarkupLevelTotalSalesAmt := 0;
//             lvMarkupLevelTotalSalesAmt:= FindSalesMarkupLevelPrice(lvSalesLine."Line Type",lvSalesLine."VAT %");
//             lvSalesLine.VALIDATE("Unit Price",lvMarkupLevelTotalSalesAmt);
//             lvSalesLine.MODIFY(TRUE);
//           UNTIL lvSalesLine.NEXT = 0;
//         END;

//         lvPurchLine.RESET;
//         lvPurchLine.SETRANGE("Document Type",PurchHeader."Document Type");
//         lvPurchLine.SETRANGE("Document No.",PurchHeader."No.");
//         lvPurchLine.SETFILTER(Type,'<>%1',lvPurchLine.Type::" ");                                        //HBSTG 2014-03-12: Fix for correction of wrongly posted purch invoices
//         lvPurchLine.SETFILTER("Line Type",'%1|%2|%3',
//                                             lvPurchLine."Line Type"::MU1,
//                                                lvPurchLine."Line Type"::MU2,
//                                                   lvPurchLine."Line Type"::MU3);
//         IF lvPurchLine.FINDSET THEN BEGIN
//           REPEAT
//             lvMarkupLevelTotalPurchAmt := 0;
//             lvMarkupLevelTotalPurchAmt:= FindPurchMarkupLevelPrice(lvPurchLine."Line Type",lvPurchLine."VAT %");
//             lvPurchLine.VALIDATE("Direct Unit Cost",lvMarkupLevelTotalPurchAmt);
//             lvPurchLine.MODIFY(TRUE);
//           UNTIL lvPurchLine.NEXT = 0;
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

//     local procedure IsExistReplaceItemNo(): Boolean
//     begin
//         //check Replace by item
//         //ReSRP 2018-02-26:New Functions added
//         ReplaceByItem := FALSE;
//         ContractPurchPrice1.RESET;
//         ContractPurchPrice1.SETRANGE("Global Dimension 1 Code",CostCentre);
//         ContractPurchPrice1.SETRANGE("Item No.",SalesLine."No.");
//         ContractPurchPrice1.SETRANGE("Vendor No.",CostVendorNo);
//         ContractPurchPrice1.SETFILTER("Variant Code",'%1','');
//         ContractPurchPrice1.SETFILTER("Currency Code",'%1|%2',PurchHeader."Currency Code",'');
//         //ContractPurchPrice1.SETFILTER("Unit of Measure Code",'%1|%2',ItemCrossRef2."Unit of Measure",'');
//         ContractPurchPrice1.SETRANGE("Unit of Measure Code",SalesLine."Unit of Measure Code");
//         //ContractPurchPrice1.SETFILTER("Starting Date",'<%1',SalesHeader."Order Date");
//         //ContractPurchPrice1.SETFILTER("Ending Date",'<%1',SalesHeader."Order Date");
//         IF ContractPurchPrice1.FINDLAST THEN BEGIN
//           OriginalItemNo := SalesLine."No.";
//           IF (recItem."No." = ContractPurchPrice1."Replace By Item No.") AND (ContractPurchPrice1."Replace By Item UOM" <> '') THEN
//             ReplaceByItem := TRUE
//           ELSE
//             ERROR(ReplaceUOMErr,ContractPurchPrice1."Replace By Item No.",EDIInvoiceLine."Item No.",recItem."No.");
//         END;
//         EXIT(ReplaceByItem);
//     end;

//     local procedure UpdateStoreAllocationLine()
//     var
//         HumePDFSetup: Record "70000";
//         HumePDF: Codeunit "70000";
//         ToEmailAddr: Text[100];
//         CCEmailAddr: Text[100];
//         BCCEmailAddr: Text[100];
//     begin
//         HumePDFSetup.GET;
//         WITH StoreAllocationEntry DO BEGIN
//           RESET;
//           SETRANGE("Customer ID",SalesHeader."Sell-to Customer No.");
//           SETRANGE(Status,StoreAllocationEntry.Status::Closed);
//           SETRANGE("Item No.",SalesLine."No.");
//           SETRANGE("Sales Order No.",SalesHeader."No.");
//           SETRANGE("Sales Order Line No.",SalesLine."Line No.");
//           IF FINDLAST THEN BEGIN
//             "Sales Order No." := '';
//             "Sales Order Line No." :=  0;
//             "Delivery Date" := 0D;
//             "Purchase Order No." := '';
//             "Purch Order Line No." := 0;
//             "Receipt Date" := 0D;
//             Status := StoreAllocationEntry.Status::Open;
//             MODIFY;
//         //    IF ContractDimVal."PO Creation Alert Code" <> '' THEN BEGIN
//         //      HumePDF.SetContractDimValues(TRUE,ContractDimVal.Code);
//         //      HumePDF.SetBatchProcessName('ORDERCREATE');
//         //      IF HumePDF.DocEnabledforEntity(ContractDimVal."PO Creation Alert Code",PurchHeader."Buy-from Vendor No.") THEN BEGIN
//         //        HumePDF.GetEmailAddresses(ToEmailAddr,CCEmailAddr,BCCEmailAddr,ContractDimVal."PO Creation Alert Code",PurchHeader."Buy-from Vendor No.");
//         //        CreateMsgLog('Order No. ' + PurchHeader."EDI Order ID" + ' is created','A new purchase order ' + PurchHeader."EDI Order ID" + ' has been created for store: ' + Cust."EDI Customer ID" + ' - ' + Cust.Name,
//         //          ToEmailAddr,CCEmailAddr,BCCEmailAddr,'Purchase Order',PurchHeader."EDI Order ID");
//         //      END;
//         //    END;

//             IF EDISetup."Email Store Allocations Alerts" THEN BEGIN
//               HumePDFSetup.TESTFIELD("Store Allocation Alert Code");
//               IF HumePDF.DocEnabledforEntity(HumePDFSetup."Store Allocation Alert Code",SalesHeader."Sell-to Customer No.") THEN BEGIN
//                 HumePDF.GetEmailAddresses(ToEmailAddr,CCEmailAddr,BCCEmailAddr,HumePDFSetup."Store Allocation Alert Code",SalesHeader."Sell-to Customer No.");
//                 CreateMsgLog('Store Allocation Item ' + SalesLine."No." + ' is not delivered.',
//                       'Store Allocation Item ' + SalesLine."No." + ' ,Item Cross Reference No.('+  ItemCrossRef."Cross-Reference No." + ') is  not delivered for the customer '
//                       + SalesHeader."Sell-to Customer No." +'('+ SalesHeader."Sell-to Customer Name" +
//                         ') in the order id ' + SalesHeader."EDI Order ID" +'. It will be added in the next order if the store allocation is still active.',
//                       ToEmailAddr,CCEmailAddr,BCCEmailAddr,
//                       'Store Allocation Item',
//                       SalesHeader."EDI Order ID");
//               END ELSE BEGIN
//                 CreateMsgLog('Store Allocation Item ' + SalesLine."No." + ' is not delivered.',
//                       'Store Allocation Item ' + SalesLine."No." + ' ,Item Cross Reference No.('+  ItemCrossRef."Cross-Reference No." + ') is  not delivered for the customer '
//                       + SalesHeader."Sell-to Customer No." +'('+ SalesHeader."Sell-to Customer Name" +
//                        ') in the order id ' + SalesHeader."EDI Order ID" +'. It will be added in the next order if the store allocation is still active.',
//                       EDISetup."Email for Store Alloc. Alerts",'','',
//                       'Store Allocation Item',
//                       SalesHeader."EDI Order ID");
//               END;
//             END;
//           END;
//         END;
//     end;
// }

