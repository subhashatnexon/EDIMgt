report 60000 "NXN Batch - Order Creation"
{
    ProcessingOnly = true;
    Caption = 'Batch Order Creation';
    UsageCategory = Administration;
    ApplicationArea = All;
    UseRequestPage = true;
    dataset
    {
        dataitem("EDI Order Header"; "NXN EDI Order Header")
        {
            /*DataItemTableView = SORTING("Entry No.")
                                WHERE("Doc Process Status" = FILTER('' | "Document Error"),
                                      "Sales Order Created" = FILTER(false),
                                      Status = FILTER('' | 'Released (Manual)'));*/
            DataItemTableView = sorting("Entry No.") where("Doc Process Status" = filter('' | "Document Error"), "Sales Order Created" = FILTER(false), Status = FILTER('' | "Released (Manual)"));
            RequestFilterFields = "Entry No.", "Order ID";

            trigger OnAfterGetRecord()
            var
                Vend2: Record Vendor;
                lvEDIOrderHeader: Record "NXN EDI Order Header";
            begin
                LineNo := 0;
                SOHeaderCreated := FALSE;

                TESTFIELD("Order ID");
                //TESTFIELD("Customer No.");
                TestField("Customer ID");
                Cust.RESET;
                Cust.SETRANGE("NXN EDI Customer ID", "Customer ID");
                //Cust.SETRANGE("No.", "Customer No.");
                Cust.FINDFIRST;

                IF Cust."Bill-to Customer No." <> '' THEN
                    BillToCust.GET(Cust."Bill-to Customer No.")
                ELSE
                    BillToCust.GET(Cust."No.");

                BillToCust.TESTFIELD("VAT Bus. Posting Group");
                //Loc.GET(Vend."Location Code");
                TestField("Order Date");

                // SalesHeader.RESET;
                // SalesHeader.SETRANGE("Document Type",SalesHeader."Document Type"::Order);
                // SalesHeader.SETRANGE("EDI Order ID","Order ID");
                // SalesHeader.SETRANGE("EDI Multiple Invoice ID","Multiple Invoice ID");
                // IF SalesHeader.FINDFIRST THEN
                //   ERROR(Text0004,"Order ID",SalesHeader."No.");

                // SalesInvHeader.RESET;
                // SalesInvHeader.SETRANGE("EDI Order ID","Order ID");
                // SalesInvHeader.SETRANGE("EDI Multiple Invoice ID","Multiple Invoice ID");
                // IF SalesInvHeader.FINDFIRST THEN
                //   ERROR(Text0008,"Order ID",SalesInvHeader."No.");

                EDIOrderHeader.reset;
                EDIOrderHeader.SetRange("Order ID", "Order ID");
                EDIOrderHeader.SetFilter("Entry No.", '<>%1', "Entry No.");
                IF EDIOrderHeader.FindFirst() then begin
                    Error(EDIDuplicateOrderErr, EDIOrderHeader."Order ID", EDIOrderHeader."Entry No.");
                end;

                EDIOrderHeader.GET("Entry No.");


                EDIOrderLine.RESET;
                EDIOrderLine.SETRANGE("Entry No.", "Entry No.");
                IF NOT EDIOrderLine.FINDSET THEN
                    ERROR(Text0001, '', "Order ID");

                CreateSOHeader;
                //CreatePOHeader;
                IF EDIOrderLine.FINDSET THEN BEGIN
                    REPEAT
                        LineNo += 10000;
                        CreateSOLine;
                    //CreatePOLine;
                    UNTIL EDIOrderLine.NEXT = 0;
                    //ReleasePurchDoc.RUN(PurchHeader);
                END;

                "Sales Order Created" := TRUE;
                "Sales Order No." := SalesHeader."No.";
                //"Purchase Order Created" := TRUE;
                //"Purchase Order No." := PurchHeader."No.";
                "Doc Process Status" := "Doc Process Status"::Successful;
                "Amount Including VAT" := SalesHeader."Amount Including VAT";                                      //#14273
                MODIFY(TRUE);

            end;

            trigger OnPreDataItem()
            begin
                GLSetup.GET;
                SalesSetup.GET;
                PurchSetup.GET;
                InvtSetup.GET;
                EDISetup.GET;
                EDISetup.testfield("Reason Code EDI Order");
                SETFILTER(Status, '%1|%2', Status::" ", Status::"Released (Manual)");
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        GLSetup: Record "General Ledger Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        InvtSetup: Record "Inventory Setup";
        EDISetup: Record "NXN EDI Setup";
        EDIOrderHeader: Record "NXN EDI Order Header";
        EDIOrderLine: Record "NXN EDI Order Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        Cust: Record Customer;
        BillToCust: Record Customer;
        Vend: Record Vendor;
        Loc: Record Location;
        recItem: Record Item;
        ItemCrossRef: Record "Item Cross Reference";
        ItemCrossRef2: Record "Item Cross Reference";
        UOM: Record "Unit of Measure";
        ItemUOM: Record "Item Unit of Measure";
        PurchCode: Record "Purchasing";
        GSTPostingSetup: Record "VAT Posting Setup";
        SalesInvHeader: Record "Sales Invoice Header";
        ContractDimVal: Record "Dimension Value";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        NoSeriesMgmt: Codeunit NoSeriesManagement;
        CopyDocMgt: Codeunit "Copy Document Mgt.";
        ItemTrackingMgt: Codeunit "Item Tracking Management";
        TransferExtendedText: Codeunit "Transfer Extended Text";
        ArchiveManagement: Codeunit ArchiveManagement;
        SOHeaderCreated: Boolean;
        Text0001: Label 'Could not find Sales Lines for Payload ID %1 and Order ID %2.';
        LineNo: Integer;
        Text0002: Label 'The %1 for %2 %3 has changed from %4 to %5 since the Sales Order was created. Adjust the %6 on the Sales Order or the %1.';
        Text0003: Label 'There were no lines to be retrieved from sales order %1.';
        Text0004: Label 'Order ID %1 is already created with Order No. %2 .';
        UnitPrice: Decimal;
        CostCentre: Code[20];
        DefaultDimension: Record "Default Dimension";
        Text0005: Label 'Cost Center Dimension does not exist for the Customer No.=%1 ';
        NewDimSetID: Integer;
        OldDimSetID: Integer;
        ChangeDimSetID: Integer;
        //StoreAllocationEntry: Record "50052";
        //FeesAndIncentives: Record "50021";
        gvType: Option " ","G/L Account",Item,Resource,"Fixed Asset","Charge (Item)";
        LineType: Option " ","Case Rate","Broken Case Rate","Carton Freight","MOQ Incentive","Direct Debit Incentive","Online Order Incentive","Credit Card Surcharge","Store Allocation","Carton Case Income","Direct Debit Income","Online Order Income","Unsch Weekday Delivery","Unsch Weekend Delivery","Minimum Order Value Charge","CW User Pay","CW Bad Debt",MU1,MU2,MU3,"Bag Rate","Bag Freight","Bag Income",LOF,MOQNA,FrghtAnclry;
        PurchUnitPrice: Decimal;
        Text0006: Label 'Item %1 cannot be found in system.';
        Text0007: Label 'Item Price cannot be found for Item %1';
        SalesUnitPrice: Decimal;
        //PurchPriceCalcMgt: Codeunit "Purch. Price Calc. Mgt.";
        Text0008: Label 'Order ID %1 is already posted with Invoice No. %2 .';
        Text0009: Label 'Item Price cannot be found for Item %1 for Line Type %2';
        Text0010: Label 'Item Cost cannot be found for Item %1 for Line Type %2';
        MOQIUpdate: Boolean;
        DDIUpdate: Boolean;
        OOIUpdate: Boolean;
        //HumePDFSetup: Record "70000";
        //HumePDFDocSetup: Record "70001";
        //HumePDF: Codeunit "70000";
        Text0011: Label 'Contract Purchase Price cannot be found for Contract %1, Item %2';
        Text0012: Label 'Contract Purchase Price cannot be found for Contract %1, Store Allocation Item %2';
        ContractPurchPrice: Decimal;
        MUUnitCost: Decimal;
        MUUnitPrice: Decimal;
        MarkupLevel_1SalesPrice: Decimal;
        MarkupLevel_2SalesPrice: Decimal;
        MarkupLevel_3SalesPrice: Decimal;
        MarkupLevel_1PurchPrice: Decimal;
        MarkupLevel_2PurchPrice: Decimal;
        MarkupLevel_3PurchPrice: Decimal;
        PLUnitCost: Decimal;
        SLUnitPrice: Decimal;
        MarkupPurchAmt: array[3] of Decimal;
        MarkupSalesAmt: array[3] of Decimal;
        Text0014: Label 'Store Allocation is not allowed for Contract %1.';
        TotalMarkupPurchLineAmtGST: Decimal;
        TotalMarkupPurchLineAmtNoGST: Decimal;
        TotalMarkupSalesLineAmtGST: Decimal;
        TotalMarkupSalesLineAmtNoGST: Decimal;
        Lvl: Integer;
        //TempContractPurchPrice: Record "50056" temporary;
        //ContractPurchPrice1: Record "50056";
        PayToVend: Record Vendor;
        ReplaceUOM: Code[10];
        ReplaceUOMErr: Label 'Replace Item UOM should be defined for Item No. = %1 on Line No. = %2';
        CostVendorNo: Code[20];
        OriginalItemNo: Code[20];
        ReplaceByItem: Boolean;
        Text0017: Label 'Item Price cannot be found for Replaceble Item %1 for Item %2.';
        Text0018: Label 'Contract Purchase Price cannot be found for Contract %1, Replaceble Item %2 for Item %3';
        OutOfCatalogueItem: Boolean;
        CatalogueItemPriceFound: Boolean;
        CartonCappingErr: Label 'Maximum allowable quantitity for the item %1 (NAV Item No. %2) is %3.';
        EDIDuplicateOrderErr: Label 'The EDI Order ID %1 is already exist in the Entry No. %2';
        RefCust: Record Customer;
        PayPlanCrLimit: Decimal;
        NormalCrLimit: Decimal;
        SelltoCustBalAmt: Decimal;
        SelltoCustSalesOrdAmt: Decimal;
        SelltoCustEDIOrdAmt: Decimal;
    /// <summary> 
    /// Description for CreateSOHeader.
    /// </summary>
    procedure CreateSOHeader()
    begin
        CLEAR(SalesHeader);
        WITH SalesHeader DO BEGIN
            RESET;
            INIT;
            VALIDATE("Document Type", SalesHeader."Document Type"::Order);
            VALIDATE("No.", NoSeriesMgmt.GetNextNo(SalesSetup."Order Nos.", EDIOrderHeader."Order Date", TRUE));
            INSERT(TRUE);
            VALIDATE("Sell-to Customer No.", Cust."No.");
            VALIDATE("Order Date", EDIOrderHeader."Order Date");
            VALIDATE("Posting Date", EDIOrderHeader."Order Date");
            VALIDATE("Document Date", EDIOrderHeader."Order Date");
            //VALIDATE("External Document No.",EDIOrderHeader."Order ID");                                   //HBSTG 2014-03-12: Fix for correction of wrongly posted sales invoices
            //VALIDATE("Location Code", Cust."Location Code");
            VALIDATE("No. Series", SalesSetup."Order Nos.");
            VALIDATE("Posting Description", 'Order ' + EDIOrderHeader."Order ID");
            validate("External Document No.", EDIOrderHeader."Order ID");

            IF EDIOrderHeader."Bill-to Name" <> '' THEN
                //VALIDATE("Bill-to Name",EDIOrderHeader."Bill-to Name");                                     //HBSRP
                "Bill-to Name" := EDIOrderHeader."Bill-to Name";
            IF EDIOrderHeader."Bill-to Name 2" <> '' THEN
                VALIDATE("Bill-to Name 2", EDIOrderHeader."Bill-to Name 2");
            IF EDIOrderHeader."Bill-to Address" <> '' THEN
                VALIDATE("Bill-to Address", EDIOrderHeader."Bill-to Address");
            IF EDIOrderHeader."Bill-to Street" <> '' THEN
                VALIDATE("Bill-to Address 2", EDIOrderHeader."Bill-to Street");
            IF EDIOrderHeader."Bill-to City" <> '' THEN
                VALIDATE("Bill-to City", EDIOrderHeader."Bill-to City");
            IF EDIOrderHeader."Bill-to Contact" <> '' THEN
                VALIDATE("Bill-to Contact", EDIOrderHeader."Bill-to Contact");
            IF EDIOrderHeader."Bill-to Post Code" <> '' THEN
                VALIDATE("Bill-to Post Code", EDIOrderHeader."Bill-to Post Code");
            IF EDIOrderHeader."Bill-to State" <> '' THEN
                VALIDATE("Bill-to County", EDIOrderHeader."Bill-to State");
            IF EDIOrderHeader."Bill-to Country/Region Code" <> '' THEN
                VALIDATE("Bill-to Country/Region Code", EDIOrderHeader."Bill-to Country/Region Code");

            IF EDIOrderHeader."Ship-to Code" <> '' THEN
                VALIDATE("Ship-to Code", EDIOrderHeader."Ship-to Code");
            IF EDIOrderHeader."Ship-to Name" <> '' THEN
                VALIDATE("Ship-to Name", EDIOrderHeader."Ship-to Name");
            IF EDIOrderHeader."Ship-to Name 2" <> '' THEN
                VALIDATE("Ship-to Name 2", EDIOrderHeader."Ship-to Name 2");
            IF EDIOrderHeader."Ship-to Address" <> '' THEN
                VALIDATE("Ship-to Address", EDIOrderHeader."Ship-to Address");
            IF EDIOrderHeader."Ship-to Street" <> '' THEN
                VALIDATE("Ship-to Address 2", EDIOrderHeader."Ship-to Street");
            IF EDIOrderHeader."Ship-to City" <> '' THEN
                VALIDATE("Ship-to City", EDIOrderHeader."Ship-to City");
            IF EDIOrderHeader."Ship-to Contact" <> '' THEN
                VALIDATE("Ship-to Contact", EDIOrderHeader."Ship-to Contact");
            IF EDIOrderHeader."Ship-to Post Code" <> '' THEN
                VALIDATE("Ship-to Post Code", EDIOrderHeader."Ship-to Post Code");
            IF EDIOrderHeader."Ship-to State" <> '' THEN
                VALIDATE("Ship-to County", EDIOrderHeader."Ship-to State");
            IF EDIOrderHeader."Ship-to Country/Region Code" <> '' THEN
                VALIDATE("Ship-to Country/Region Code", EDIOrderHeader."Ship-to Country/Region Code");

            // Flow customized fields values on the Sales Header
            VALIDATE("NXN EDI Entry No.", EDIOrderHeader."Entry No.");
            VALIDATE("NXN EDI Order ID", EDIOrderHeader."Order ID");
            VALIDATE("NXN Order Method", EDIOrderHeader."Order Method");

            SetHideValidationDialog(TRUE);                                                                   //CW3.01
            VALIDATE("Requested Delivery Date", EDIOrderHeader."Expected Delivery Date");                     //CW3.01

            "Responsibility Center" := EDIOrderHeader."Responsibility Center";                                //HBSRP
            "NXN EDI Header Comments" := EDIOrderHeader."EDI Header Comments";                                   //HBSRP
            "NXN EDI Del. Instr." := EDIOrderHeader."EDI Delivery Instructions";                       //HBSRP
            "Reason Code" := EDISetup."Reason Code EDI Order";
            OnBeforeSalesHeaderInsertFromEDIHdr(SalesHeader, EDIOrderHeader);                                                //HBSRP
            MODIFY(TRUE);
        END;
        SOHeaderCreated := TRUE;
    end;


    /// <summary> 
    /// Description for CreateSOLine.
    /// </summary>
    procedure CreateSOLine()
    var
        SalesLine2: Record "Sales Line";
    begin
        CLEAR(SalesLine);
        UnitPrice := 0;
        OriginalItemNo := '';
        OutOfCatalogueItem := FALSE;
        ReplaceByItem := FALSE;
        WITH SalesLine DO BEGIN
            INIT;
            VALIDATE("Document Type", SalesHeader."Document Type");
            VALIDATE("Document No.", SalesHeader."No.");
            "Line No." := LineNo;
            INSERT(TRUE);
            VALIDATE(Type, Type::Item);
            IF NOT recItem.GET(EDIOrderLine."Item No.") THEN BEGIN
                ItemCrossRef.RESET;
                ItemCrossRef.SETRANGE("Cross-Reference Type", ItemCrossRef."Cross-Reference Type"::Customer);
                ItemCrossRef.SETRANGE("Cross-Reference Type No.", SalesHeader."Sell-to Customer No.");
                ItemCrossRef.SETRANGE("Cross-Reference No.", EDIOrderLine."Item No.");
                IF ItemCrossRef.FINDFIRST THEN BEGIN
                    recItem.GET(ItemCrossRef."Item No.");
                END ELSE BEGIN
                    ERROR(Text0006, EDIOrderLine."Item No.");
                END;
            END;
            //END;
            //InitItemCrossRef(EDIOrderLine."Unit Of Measure Code");
            salesLine.SetHideValidationDialog(TRUE);
            VALIDATE("No.", recItem."No.");
            VALIDATE(Quantity, EDIOrderLine.Quantity);
            VALIDATE("NXN Order Quantity", EDIOrderLine.Quantity);
            //VALIDATE("Unit of Measure Code", EDIOrderLine."Unit of Measure Code");
            //VALIDATE(Description,EDIOrderLine.Description);
            Description := EDIOrderLine.Description;
            IF EDIOrderLine."Requested Delivery Date" <> 0D THEN BEGIN
                "Requested Delivery Date" := EDIOrderLine."Requested Delivery Date";
                "Shipment Date" := EDIOrderLine."Requested Delivery Date";
                "Planned Delivery Date" := EDIOrderLine."Requested Delivery Date";
                "Planned Shipment Date" := EDIOrderLine."Requested Delivery Date";
            END;
            VALIDATE("NXN EDI Entry No.", EDIOrderHeader."Entry No.");
            VALIDATE("NXN EDI Order ID", EDIOrderHeader."Order ID");
            VALIDATE("NXN EDI Line No.", EDIOrderLine."Line No.");
            OnBeforeSalesLineInsertFromEDILine(SalesLine, EDIOrderLine);
            MODIFY(TRUE);
            //UnitPrice := EDIOrderLine."Unit Price";
        END;

    End;

    /// <summary> 
    /// Description for CreatePOHeader.
    /// </summary>
    procedure CreatePOHeader()
    begin
        CLEAR(PurchHeader);
        WITH PurchHeader DO BEGIN
            INIT;
            VALIDATE("Document Type", PurchHeader."Document Type"::Order);
            VALIDATE("No.", NoSeriesMgmt.GetNextNo(PurchSetup."Order Nos.", EDIOrderHeader."Order Date", TRUE));
            INSERT(TRUE);
            VALIDATE("Buy-from Vendor No.", Vend."No.");
            VALIDATE("Order Date", EDIOrderHeader."Order Date");
            VALIDATE("Posting Date", EDIOrderHeader."Order Date");
            VALIDATE("Document Date", EDIOrderHeader."Order Date");
            VALIDATE("Location Code", Loc.Code);
            VALIDATE("No. Series", PurchSetup."Order Nos.");
            VALIDATE("Posting Description", 'Order ' + EDIOrderHeader."Order ID");
            VALIDATE("Sell-to Customer No.", Cust."No.");
            VALIDATE("Ship-to Code", SalesHeader."Ship-to Code");
            IF EDIOrderHeader."Ship-to Name" <> '' THEN
                VALIDATE("Ship-to Name", EDIOrderHeader."Ship-to Name");
            IF EDIOrderHeader."Ship-to Name 2" <> '' THEN
                VALIDATE("Ship-to Name 2", EDIOrderHeader."Ship-to Name 2");
            IF EDIOrderHeader."Ship-to Address" <> '' THEN
                VALIDATE("Ship-to Address", EDIOrderHeader."Ship-to Address");
            IF EDIOrderHeader."Ship-to Street" <> '' THEN
                VALIDATE("Ship-to Address 2", EDIOrderHeader."Ship-to Street");
            IF EDIOrderHeader."Ship-to City" <> '' THEN
                VALIDATE("Ship-to City", EDIOrderHeader."Ship-to City");
            IF EDIOrderHeader."Ship-to Contact" <> '' THEN
                VALIDATE("Ship-to Contact", EDIOrderHeader."Ship-to Contact");
            IF EDIOrderHeader."Ship-to Post Code" <> '' THEN
                VALIDATE("Ship-to Post Code", EDIOrderHeader."Ship-to Post Code");
            IF EDIOrderHeader."Ship-to State" <> '' THEN
                VALIDATE("Ship-to County", EDIOrderHeader."Ship-to State");
            IF EDIOrderHeader."Ship-to Country/Region Code" <> '' THEN
                VALIDATE("Ship-to Country/Region Code", EDIOrderHeader."Ship-to Country/Region Code");

            // Flow customized fields values on the Purchase Header
            VALIDATE("NXN EDI Entry No.", EDIOrderHeader."Entry No.");
            VALIDATE("NXN EDI Order ID", EDIOrderHeader."Order ID");
            VALIDATE("Shortcut Dimension 1 Code", CostCentre);
            VALIDATE("VAT Bus. Posting Group", BillToCust."VAT Bus. Posting Group");
            SetHideValidationDialog(TRUE);                                                                   //CW3.01
            VALIDATE("Expected Receipt Date", EDIOrderHeader."Expected Delivery Date");
            OnBeforePurchHeaderInsertFromEDIHdr(PurchHeader, EDIOrderHeader);                       //CW3.01
            MODIFY(TRUE);
        END;
    end;


    /// <summary> 
    /// Description for CreatePOLine.
    /// </summary>
    procedure CreatePOLine()
    begin
        CatalogueItemPriceFound := FALSE;                                                                     //#11548   ;
        CLEAR(PurchLine);
        WITH PurchLine DO BEGIN
            INIT;
            VALIDATE("Document Type", PurchHeader."Document Type");
            VALIDATE("Document No.", PurchHeader."No.");
            "Line No." := LineNo;
            INSERT(TRUE);
            VALIDATE(Type, Type::Item);
            VALIDATE("No.", recItem."No.");
            VALIDATE(Quantity, EDIOrderLine.Quantity);
            //VALIDATE("Order Quantity", EDIOrderLine.Quantity);
            VALIDATE("Unit of Measure Code", ItemCrossRef."Unit of Measure");
            Description := EDIOrderLine.Description;
            IF EDIOrderLine."Requested Delivery Date" <> 0D THEN BEGIN
                VALIDATE("Requested Receipt Date", EDIOrderLine."Requested Delivery Date");
            END;
            Validate("Direct Unit Cost", EDIOrderLine."Unit Price");
            VALIDATE("NXN EDI Entry No.", EDIOrderHeader."Entry No.");
            VALIDATE("NXN EDI Order ID", EDIOrderHeader."Order ID");
            VALIDATE("NXN EDI Line No.", EDIOrderLine."Line No.");
            OnBeforePurchLineInsertFromEDILine(PurchLine, EDIOrderLine);
            MODIFY(TRUE);
        END;

    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforePurchHeaderInsertFromEDIHdr(var ToPurchHdr: Record "Purchase Header"; EDIOrderHdr: Record "NXN EDI Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforePurchLineInsertFromEDILine(var ToPurchLine: Record "Purchase Line"; EDIOrderLine: Record "NXN EDI Order Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeSalesHeaderInsertFromEDIHdr(var ToSalesHdr: Record "Sales Header"; EDIOrderHdr: Record "NXN EDI Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeSalesLineInsertFromEDILine(var ToSalesLine: Record "Sales Line"; EDIOrderLine: Record "NXN EDI Order Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPurchHeaderInsertFromEDIHdr(var ToPurchHdr: Record "Purchase Header"; EDIOrderHdr: Record "NXN EDI Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterPurchLineInsertFromEDILine(var ToPurchLine: Record "Purchase Line"; EDIOrderLine: Record "NXN EDI Order Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterSalesHeaderInsertFromEDIHdr(var ToSalesHdr: Record "Sales Header"; EDIOrderHdr: Record "NXN EDI Order Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterSalesLineInsertFromEDILine(var ToSalesLine: Record "Sales Line"; EDIOrderLine: Record "NXN EDI Order Line")
    begin
    end;

}

