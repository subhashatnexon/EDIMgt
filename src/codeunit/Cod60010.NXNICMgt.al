codeunit 60010 "NXN Intercompany Mgt"
{

    trigger OnRun()
    begin
    end;

    var
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        SalesLine: Record "Sales Line";
        NoSeriesMgmt: Codeunit NoSeriesManagement;
        PurchSetup: Record "Purchases & Payables Setup";
        SalesHdr: Record "Sales Header";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ICInOutboxMgt: Codeunit ICInboxOutboxMgt;
        ICPartner: Record "IC Partner";
        EDISetup: Record "NXN EDI Setup";
        EDIOrderHdr: Record "NXN EDI Order Header";
        POCreationMsg: Label 'Purchase %1 created sucessfully and No. is %2';
        POExistErr: Label 'Purchase %1 is already exist for the EDI Order No. %2';
        CreateICPurchaseOrder: Boolean;


    [EventSubscriber(ObjectType::Codeunit, 414, 'OnAfterReleaseSalesDoc', '', false, false)]

    procedure CreatePOOnSalesReleseSubscriber(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean; var LinesWereModified: Boolean)
    begin
        EDISetup.GET;
        IF NOT EDISetup."Enable IC Transaction" then
            Exit;
        ICPartner.Reset();
        IF NOT ICPartner.FindFirst() then
            exit;

        IF SalesHeader."NXN IC SRC Inv_Cr No." <> '' then
            exit;
        //IF COMPANYNAME = EDISetup."Company Name" THEN BEGIN
        SalesHdr := SalesHeader;
        IF NOT CheckInterCompanyVendorExistInSaleLine(SalesHdr) then
            exit;
        //IF SalesHeader."NXN EDI Order ID" <> '' then begin
        PurchHeader.reset;
        //PurchHeader.SetRange("NXN EDI Order ID", SalesHeader."NXN EDI Order ID");
        PurchHeader.SetFilter("Document Type", '%1|%2', PurchHeader."Document Type"::Order, PurchHeader."Document Type"::"Return Order");
        PurchHeader.SetRange("IC Direction", PurchHeader."IC Direction"::Outgoing);
        PurchHeader.SetRange("IC Status", PurchHeader."IC Status"::Sent);
        PurchHeader.SetRange("NXN IC SRC Order No.", SalesHeader."No.");
        IF PurchHeader.FindFirst() then
            Error(POExistErr, SalesHeader."Document Type", SalesHeader."NXN EDI Order ID");
        //end;

        IF SalesHeader."Document Type" IN [SalesHeader."Document Type"::Order, SalesHeader."Document Type"::"Return Order"] THEN BEGIN
            CreatePurchHeader(SalesHdr);
            SalesLine.RESET;
            SalesLine.SETRANGE("Document Type", SalesHdr."Document Type");
            SalesLine.SETRANGE("Document No.", SalesHdr."No.");
            IF SalesLine.FINDSET THEN BEGIN
                REPEAT
                    CreatePurchLine(SalesLine);
                UNTIL SalesLine.NEXT = 0;
            END;
            //Update EDI Order
            IF PurchHeader."Document Type" = PurchHeader."Document Type"::Order then begin
                IF EDIOrderHdr.Get(SalesHeader."NXN EDI Entry No.") then begin
                    EDIOrderHdr."Purchase Order Created" := true;
                    EDIOrderHdr."Purchase Order No." := PurchHeader."No.";
                    EDIOrderHdr.Modify(true);
                end;
            end;
            IF ApprovalsMgmt.PrePostApprovalCheckPurch(PurchHeader) THEN
                ICInOutboxMgt.SendPurchDoc(PurchHeader, TRUE);
            MESSAGE(POCreationMsg, PurchHeader."Document Type", PurchHeader."No.");

        END;
    END;
    //end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Sales Document", 'OnBeforeManualReOpenSalesDoc', '', false, false)]
    local procedure DeleteOpenPurchaseOrderandICsalesOrder(var SalesHeader: Record "Sales Header"; PreviewMode: Boolean)
    var
        lvPurchHdr: Record "Purchase Header";
        lvICsalesHeader: Record "Sales Header";
        ICSalesDocDeleted: Boolean;
        lvSalesLine: Record "Sales Line";
        DeletionMsg: Label 'Intercompany Sales %1 No. %2 and Purchase %3 no. %4 got deleted';
        NotDeletionMsg: Label 'Intercompany Sale Document may be partially shipped or open status therefore Sale and Purchase Documents are not deleted.';
        ReopenConfirmMsg: Label 'Reopening the document will delete the related purchase and intercompany documents if they are open. Do you want to continue?';
    begin
        IF not PreviewMode then begin

            EDISetup.GET;
            ICSalesDocDeleted := false;
            IF NOT EDISetup."Enable IC Transaction" then
                Exit;
            ICPartner.Reset();
            IF NOT ICPartner.FindFirst() then
                exit;
            SalesHdr := SalesHeader;
            IF NOT CheckInterCompanyVendorExistInSaleLine(SalesHdr) then
                exit;

            //intercompany sales order
            IF NOT Confirm(ReopenConfirmMsg, true) then
                Error('');
            lvICsalesHeader.Reset();
            lvICsalesHeader.ChangeCompany(ICPartner."Inbox Details");
            lvICsalesHeader.SetRange("Document Type", SalesHeader."Document Type");
            lvICsalesHeader.SetRange("NXN IC SRC Order No.", SalesHeader."No.");
            //lvICsalesHeader.SetRange("Buy-from IC Partner Code",ICPartner."Vendor No.");
            lvICsalesHeader.SetRange("IC Direction", lvICsalesHeader."IC Direction"::Incoming);
            lvICsalesHeader.SetRange("IC Status", lvICsalesHeader."IC Status"::New);
            lvICsalesHeader.SetRange(Status, lvICsalesHeader.Status::Open);
            IF lvICsalesHeader.FindFirst() then begin
                lvSalesLine.reset;
                lvSalesLine.ChangeCompany(ICPartner."Inbox Details");
                lvSalesLine.SetRange("Document Type", lvICsalesHeader."Document Type");
                lvSalesLine.SetRange("Document No.", lvICsalesHeader."No.");
                lvSalesLine.Setfilter("Quantity Shipped", '<>%1', 0);
                IF NOT lvSalesLine.FindFirst() then begin
                    lvICsalesHeader.Delete(true);
                    ICSalesDocDeleted := True;
                end;
            end;

            //Current company purchase order
            IF ICSalesDocDeleted then begin
                lvPurchHdr.Reset();
                lvPurchHdr.SetRange("Document Type", SalesHeader."Document Type");
                lvPurchHdr.SetRange("NXN IC SRC Order No.", SalesHeader."No.");
                //lvPurchHdr.SetRange("Buy-from IC Partner Code", ICPartner."Vendor No.");
                //lvPurchHdr.SetRange("IC Direction", PurchHeader."IC Direction"::Outgoing);
                //lvPurchHdr.SetRange("IC Status", lvPurchHdr."IC Status"::Sent);
                lvPurchHdr.SetRange(Status, lvPurchHdr.Status::Open);
                IF lvPurchHdr.FindFirst() then begin
                    lvPurchHdr.Delete(true);
                end;
            end;
            IF ICSalesDocDeleted then
                Message(DeletionMsg, lvICsalesHeader."Document Type", lvICsalesHeader."No.", lvPurchHdr."Document Type", lvPurchHdr."No.")
            else
                Error(NotDeletionMsg);
        end;
    end;

    procedure CheckInterCompanyVendorExistInSaleLine(pSalesHdr: Record "Sales Header"): Boolean
    var
        lvSalesLine: Record "Sales Line";
        lvItem: Record Item;
    begin
        lvSalesLine.reset;
        lvSalesLine.SetRange("Document Type", pSalesHdr."Document Type");
        lvSalesLine.SetRange("Document No.", pSalesHdr."No.");
        lvSalesLine.SetRange(Type, lvSalesLine.type::Item);
        IF lvSalesLine.FindFirst() then begin
            repeat
                IF lvItem.get(lvSalesLine."No.") then begin
                    IF lvItem."Vendor No." = ICPartner."Vendor No." then
                        exit(true);
                end;
            until lvSalesLine.Next = 0;
        end;
        exit(false);
    end;

    procedure CreatePurchHeader(SalesHeader: Record "Sales Header")
    begin
        PurchSetup.GET;
        CLEAR(PurchHeader);
        WITH PurchHeader DO BEGIN
            INIT;
            VALIDATE("Document Type", SalesHeader."Document Type");
            VALIDATE("No.", NoSeriesMgmt.GetNextNo(PurchSetup."Order Nos.", SalesHeader."Order Date", TRUE));
            INSERT(TRUE);
            VALIDATE("Buy-from Vendor No.", ICPartner."Vendor No.");
            VALIDATE("Order Date", SalesHeader."Order Date");
            VALIDATE("Posting Date", SalesHeader."Order Date");
            VALIDATE("Document Date", SalesHeader."Order Date");
            VALIDATE("Location Code", SalesHeader."Location Code");
            VALIDATE("No. Series", PurchSetup."Order Nos.");
            //VALIDATE("Posting Description",'Order ' + SalesHeader."Order ID");
            VALIDATE("Sell-to Customer No.", SalesHeader."Sell-to Customer No.");
            VALIDATE("Ship-to Code", SalesHeader."Ship-to Code");
            IF SalesHeader."Ship-to Name" <> '' THEN
                VALIDATE("Ship-to Name", SalesHeader."Ship-to Name");
            IF SalesHeader."Ship-to Name 2" <> '' THEN
                VALIDATE("Ship-to Name 2", SalesHeader."Ship-to Name 2");
            IF SalesHeader."Ship-to Address" <> '' THEN
                VALIDATE("Ship-to Address", SalesHeader."Ship-to Address");
            IF SalesHeader."Ship-to City" <> '' THEN
                VALIDATE("Ship-to City", SalesHeader."Ship-to City");
            IF SalesHeader."Ship-to Contact" <> '' THEN
                VALIDATE("Ship-to Contact", SalesHeader."Ship-to Contact");
            IF SalesHeader."Ship-to Post Code" <> '' THEN
                VALIDATE("Ship-to Post Code", SalesHeader."Ship-to Post Code");
            IF SalesHeader."Ship-to Country/Region Code" <> '' THEN
                VALIDATE("Ship-to Country/Region Code", SalesHeader."Ship-to Country/Region Code");

            Validate("Vendor Invoice No.", SalesHeader."External Document No.");
            validate("NXN IC SRC Order No.", SalesHeader."No.");
            VALIDATE("NXN EDI Order ID", SalesHeader."NXN EDI Order ID");
            // Flow customized fields values on the Purchase Header
            //  VALIDATE("EDI Entry No.",SalesHeader."Entry No.");

            //  VALIDATE("EDI Multiple Invoice ID",SalesHeader."Multiple Invoice ID");                        //HBSTG CW 2013-09-09
            //  VALIDATE("Shortcut Dimension 1 Code",CostCentre);
            //  VALIDATE("VAT Bus. Posting Group",BillToCust."VAT Bus. Posting Group");
            //  SetHideValidationDialog(TRUE);                                                                   //CW3.01
            //  VALIDATE("Expected Receipt Date",SalesHeader."Expected Delivery Date");                       //CW3.01
            //  VALIDATE("Order Method",SalesHeader."Order Method");
            //  "Responsibility Center":= SalesHeader."Responsibility Center";                                //HBSRP 2015-03-31
            //  "EDI Header Comments" := SalesHeader."EDI Header Comments";                                   //HBSRP
            //  "EDI Delivery Instructions" := SalesHeader."EDI Delivery Instructions";                       //HBSRP
            //  "Reason Code" := EDISetup."Reason Code EDI Order";                                                   //HBSRP
            MODIFY(TRUE);
        END;
    end;


    procedure CreatePurchLine(SalesLine: Record "Sales Line")
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        CLEAR(PurchLine);
        WITH PurchLine DO BEGIN
            INIT;
            VALIDATE("Document Type", PurchHeader."Document Type");
            VALIDATE("Document No.", PurchHeader."No.");
            "Line No." := SalesLine."Line No.";
            INSERT(TRUE);
            VALIDATE(Type, SalesLine.Type);
            VALIDATE("No.", SalesLine."No.");
            Validate("Location Code", SalesLine."Location Code");
            Description := SalesLine.Description;
            VALIDATE(Quantity, SalesLine.Quantity);
            VALIDATE("Unit of Measure Code", SalesLine."Unit of Measure Code");
            VALIDATE("Direct Unit Cost", SalesLine."Unit Price");
            MODIFY(TRUE);
        END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 431, 'OnRunOutboxTransactionsOnBeforeSend', '', false, false)]

    procedure UpdateDocType(var ICOutboxTransaction: Record "IC Outbox Transaction")
    begin
        // IF (ICOutboxTransaction."Document Type" = ICOutboxTransaction."Document Type"::Invoice) AND
        //    (ICOutboxTransaction."Source Type" = ICOutboxTransaction."Source Type"::"Sales Document")  THEN BEGIN
        //  ICOutboxTransaction."Document Type" :=  ICOutboxTransaction."Document Type"::Order;
        //  //ICOutboxTransaction.MODIFY;
        // END;
    end;

    [EventSubscriber(ObjectType::Codeunit, 427, 'OnBeforeICInboxSalesHeaderInsert', '', false, false)]

    procedure InsertEDIOrderNoInSalesInboxSubscriber(var ICInboxSalesHeader: Record "IC Inbox Sales Header"; ICOutboxPurchaseHeader: Record "IC Outbox Purchase Header")
    begin
        ICInboxSalesHeader."NXN EDI Order ID" := ICOutboxPurchaseHeader."NXN EDI Order ID";
        ICInboxSalesHeader."External Document No." := ICOutboxPurchaseHeader."Vendor Invoice No.";
        ICInboxSalesHeader."NXN IC SRC Order No." := ICOutboxPurchaseHeader."NXN IC SRC Order No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, 427, 'OnAfterCreateSalesDocument', '', false, false)]

    procedure InsertExternalDocNoInSalesHdr(var SalesHeader: Record "Sales Header"; ICInboxSalesHeader: Record "IC Inbox Sales Header"; HandledICInboxSalesHeader: Record "Handled IC Inbox Sales Header")
    var
        CompanyInfo: Record "Company Information";
        ICPartner: Record "IC Partner";
        ICSalesHeader: Record "Sales Header";
    begin
        CompanyInfo.GET();
        SalesHeader."External Document No." := ICInboxSalesHeader."External Document No.";
        SalesHeader."NXN IC SRC Order No." := ICInboxSalesHeader."NXN IC SRC Order No.";
        HandledICInboxSalesHeader."External Document No." := ICInboxSalesHeader."External Document No.";
        HandledICInboxSalesHeader."NXN IC SRC Order No." := ICInboxSalesHeader."NXN IC SRC Order No.";
        IF ICPartner.GET(HandledICInboxSalesHeader."IC Partner Code") then begin
            IF ICPartner."Inbox Type" = ICPartner."Inbox Type"::Database THEN
                ICSalesHeader.CHANGECOMPANY(ICPartner."Inbox Details");
            ICSalesHeader.SetRange("Document Type", ICSalesHeader."Document Type"::Order);
            //ICSalesHeader.SetRange("External Document No.", ICInboxSalesHeader."External Document No.");
            ICSalesHeader.SetRange("No.", ICInboxSalesHeader."NXN IC SRC Order No.");
            IF ICSalesHeader.FindFirst() then begin
                SalesHeader."Shipping Agent Code" := ICSalesHeader."Shipping Agent Code";
                SalesHeader."Shipping Agent Service Code" := ICSalesHeader."Shipping Agent Service Code";
                SalesHeader."Shipment Method Code" := ICSalesHeader."Shipment Method Code";
                SalesHeader."Sell-to E-Mail" := ICSalesHeader."Sell-to E-Mail";
                OnUpdatingFromSalesHdrToICSalesHeader(SalesHeader, ICSalesHeader);
            end;
        end;
        SalesHeader.Modify();
        HandledICInboxSalesHeader.Modify();
    end;

    [EventSubscriber(ObjectType::Codeunit, 427, 'OnCreateOutboxPurchDocTransOnAfterTransferFieldsFromPurchHeader', '', false, false)]

    procedure InsertVendorInvNoInPurchOutboxSubscriber(var ICOutboxPurchHeader: Record "IC Outbox Purchase Header"; PurchHeader: Record "Purchase Header")
    begin
        //ICInboxSalesHeader."NXN EDI Order ID" := ICOutboxPurchaseHeader."NXN EDI Order ID";
        //ICInboxSalesHeader."External Document No." := ICOutboxPurchaseHeader."NXN EDI Order ID";
        ICOutboxPurchHeader."Vendor Invoice No." := PurchHeader."Vendor Invoice No.";
        ICOutboxPurchHeader."NXN EDI Order ID" := PurchHeader."NXN EDI Order ID";
        ICOutboxPurchHeader."NXN IC SRC Order No." := PurchHeader."NXN IC SRC Order No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, 427, 'OnBeforeICInboxPurchHeaderInsert', '', false, false)]

    procedure InsertEDIOrderNoInPurchInboxSubscriber(var ICInboxPurchaseHeader: Record "IC Inbox Purchase Header"; ICOutboxSalesHeader: Record "IC Outbox Sales Header")
    begin
        ICInboxPurchaseHeader."NXN EDI Order ID" := ICOutboxSalesHeader."NXN EDI Order ID";
        ICInboxPurchaseHeader."NXN IC SRC Order No." := ICOutboxSalesHeader."NXN IC SRC Order No.";
        ICInboxPurchaseHeader."NXN IC SRC Inv_Cr No." := ICOutboxSalesHeader."No.";
        ICInboxPurchaseHeader."Vendor Invoice No." := ICOutboxSalesHeader."External Document No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, 427, 'OnCreateSalesDocumentOnBeforeSalesHeaderInsert', '', false, false)]

    procedure InsertEDIOrderNoInSalesSubscriber(var SalesHeader: Record "Sales Header"; ICInboxSalesHeader: Record "IC Inbox Sales Header")
    begin
        SalesHeader."NXN EDI Order ID" := ICInboxSalesHeader."NXN EDI Order ID";
        SalesHeader."External Document No." := ICInboxSalesHeader."NXN EDI Order ID";
        SalesHeader."NXN IC SRC Order No." := ICInboxSalesHeader."NXN IC SRC Order No.";
    end;

    [EventSubscriber(ObjectType::Codeunit, 427, 'OnAfterCreateSalesLines', '', false, false)]

    procedure UpdateUnitPricefromSalesPriceSetup(ICInboxSalesLine: Record "IC Inbox Sales Line"; var SalesLine: Record "Sales Line")
    var
        SalesHdr: Record "Sales Header";
        SalesPriceCal: Codeunit "Sales Price Calc. Mgt.";
    begin
        IF SalesHdr.get(SalesLine."Document Type", SalesLine."Document No.") then begin
            SalesPriceCal.FindSalesLinePrice(SalesHdr, SalesLine, 0);
            SalesLine.validate("Unit Price");
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 427, 'OnCreatePurchDocumentOnBeforePurchHeaderInsert', '', false, false)]

    procedure InsertEDIOrderNoInPurchSubscriber(var PurchaseHeader: Record "Purchase Header"; ICInboxPurchaseHeader: Record "IC Inbox Purchase Header")
    begin
        PurchaseHeader."NXN EDI Order ID" := ICInboxPurchaseHeader."NXN EDI Order ID";
        PurchaseHeader."Vendor Invoice No." := ICInboxPurchaseHeader."NXN EDI Order ID";
        PurchaseHeader."NXN IC SRC Inv_Cr No." := ICInboxPurchaseHeader."NXN IC SRC Inv_Cr No.";
        PurchaseHeader."NXN IC SRC Order No." := ICInboxPurchaseHeader."NXN IC SRC Order No.";
        //PurchaseHeader.Modify()
    end;

    [EventSubscriber(ObjectType::Codeunit, 427, 'OnAfterCreatePurchDocument', '', false, false)]

    procedure UpdatePurchOrderSubscriber(var PurchaseHeader: Record "Purchase Header"; ICInboxPurchaseHeader: Record "IC Inbox Purchase Header"; HandledICInboxPurchHeader: Record "Handled IC Inbox Purch. Header")
    var
        TobeUpdatedPurchHdr: Record "Purchase Header";
        TobeUpdatedPurchLine: Record "Purchase Line";
        TobeUpdatedSalesHdr: Record "Sales Header";
        TobeUpdatedSalesLine: Record "Sales Line";
        TobeUpdatedPurchLineUpdated: Boolean;
        TobeUpdatedSalesLineUpdated: Boolean;
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        ArchiveMgt: Codeunit ArchiveManagement;
        PurchOrdErr: Label 'Related Purchase Document not found with IC Source Order No = %1';
        SalesOrdErr: Label 'Related Sales Document not found with IC Source Order No = %1';
    begin
        TobeUpdatedPurchLineUpdated := FALSE;
        TobeUpdatedSalesLineUpdated := FALSE;
        EDISetup.GET;

        //IF COMPANYNAME = EDISetup."Company Name" THEN BEGIN
        IF (PurchaseHeader."Document Type" IN [PurchaseHeader."Document Type"::Invoice, PurchaseHeader."Document Type"::"Credit Memo"]) AND (PurchaseHeader."IC Direction" = PurchaseHeader."IC Direction"::Incoming) THEN BEGIN

            //Get Purchase Order
            TobeUpdatedPurchHdr.RESET;
            IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice THEN
                TobeUpdatedPurchHdr.SETRANGE("Document Type", TobeUpdatedPurchHdr."Document Type"::Order)
            ELSE
                IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo" THEN
                    TobeUpdatedPurchHdr.SETRANGE("Document Type", TobeUpdatedPurchHdr."Document Type"::"Return Order");
            //TobeUpdatedPurchHdr.SETRANGE("NXN EDI Order ID", PurchaseHeader."NXN EDI Order ID");
            TobeUpdatedPurchHdr.SETRANGE("NXN IC SRC Order No.", PurchaseHeader."NXN IC SRC Order No.");
            IF TobeUpdatedPurchHdr.FINDFIRST THEN begin
                IF TobeUpdatedPurchHdr.Status = TobeUpdatedPurchHdr.Status::Released then
                    ReleasePurchDoc.Reopen(TobeUpdatedPurchHdr);
                IF EDISetup."Archive Doc in EDI Process" then begin
                    ArchiveMgt.StorePurchDocument(TobeUpdatedPurchHdr, false);
                end;
                IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice THEN begin
                    TobeUpdatedPurchHdr."Vendor Invoice No." := PurchaseHeader."Vendor Invoice No.";
                    TobeUpdatedPurchHdr."NXN IC SRC Inv_Cr No." := PurchaseHeader."NXN IC SRC Inv_Cr No.";
                end;

                IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo" THEN begin
                    TobeUpdatedPurchHdr."Vendor Cr. Memo No." := PurchaseHeader."Vendor Cr. Memo No.";
                    TobeUpdatedPurchHdr."NXN IC SRC Inv_Cr No." := PurchaseHeader."NXN IC SRC Inv_Cr No.";
                end;
                TobeUpdatedPurchHdr.Modify();
            end else begin
                Error(PurchOrdErr, PurchaseHeader."NXN IC SRC Order No.");
            end;
            ;

            //Get Sales Order
            TobeUpdatedSalesHdr.RESET;
            TobeUpdatedSalesHdr.SETRANGE("Document Type", TobeUpdatedPurchHdr."Document Type");
            //TobeUpdatedSalesHdr.SETRANGE("NXN EDI Order ID", PurchaseHeader."NXN EDI Order ID");
            TobeUpdatedSalesHdr.SETRANGE("No.", PurchaseHeader."NXN IC SRC Order No.");
            IF TobeUpdatedSalesHdr.FINDFIRST THEN begin
                IF TobeUpdatedSalesHdr.Status = TobeUpdatedSalesHdr.Status::Released then
                    ReleaseSalesDoc.Reopen(TobeUpdatedSalesHdr);
                IF EDISetup."Archive Doc in EDI Process" then begin
                    ArchiveMgt.StoreSalesDocument(TobeUpdatedSalesHdr, false);
                end;
                IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice THEN begin
                    //TobeUpdatedSalesHdr."External Document No." := PurchaseHeader."Vendor Invoice No.";
                    TobeUpdatedSalesHdr."NXN IC SRC Inv_Cr No." := PurchaseHeader."NXN IC SRC Inv_Cr No.";
                end;
                IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo" THEN begin
                    //TobeUpdatedSalesHdr."External Document No." := PurchaseHeader."Vendor Cr. Memo No.";
                    TobeUpdatedSalesHdr."NXN IC SRC Inv_Cr No." := PurchaseHeader."NXN IC SRC Inv_Cr No.";
                end;
                TobeUpdatedSalesHdr.Modify();
            end else begin
                Error(SalesOrdErr, PurchaseHeader."NXN IC SRC Order No.");
            end;


            //get purch line
            PurchLine.RESET;
            PurchLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
            PurchLine.SETRANGE("Document No.", PurchaseHeader."No.");
            IF PurchLine.FINDSET THEN BEGIN
                REPEAT
                    // update Purchase line
                    TobeUpdatedPurchLine.RESET;
                    TobeUpdatedPurchLine.SETRANGE("Document Type", TobeUpdatedPurchHdr."Document Type");
                    TobeUpdatedPurchLine.SETRANGE("Document No.", TobeUpdatedPurchHdr."No.");
                    TobeUpdatedPurchLine.SETRANGE("Line No.", PurchLine."Line No.");
                    TobeUpdatedPurchLine.SETRANGE(Type, PurchLine.Type);
                    TobeUpdatedPurchLine.SETRANGE("No.", PurchLine."No.");
                    IF TobeUpdatedPurchLine.FINDFIRST THEN BEGIN
                        IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice THEN begin
                            TobeUpdatedPurchLine.VALIDATE(Quantity, PurchLine.Quantity);
                            TobeUpdatedPurchLine.VALIDATE("Qty. to Receive", PurchLine.Quantity);

                        end;
                        IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo" THEN begin
                            TobeUpdatedPurchLine.VALIDATE(Quantity, PurchLine.Quantity);
                            TobeUpdatedPurchLine.VALIDATE("Return Qty. to Ship", PurchLine.Quantity);
                        end;
                        OnBeforeUpdatingICPurchaseOrderLine(TobeUpdatedPurchLine, PurchLine, PurchaseHeader);
                        TobeUpdatedPurchLine.MODIFY(TRUE);
                        TobeUpdatedPurchLineUpdated := TRUE;
                    END;


                    // update Sales line
                    TobeUpdatedSalesLine.RESET;
                    TobeUpdatedSalesLine.SETRANGE("Document Type", TobeUpdatedSalesHdr."Document Type");
                    TobeUpdatedSalesLine.SETRANGE("Document No.", TobeUpdatedSalesHdr."No.");
                    TobeUpdatedSalesLine.SETRANGE("Line No.", PurchLine."Line No.");
                    TobeUpdatedSalesLine.SETRANGE(Type, PurchLine.Type);
                    TobeUpdatedSalesLine.SETRANGE("No.", PurchLine."No.");
                    IF TobeUpdatedSalesLine.FINDFIRST THEN BEGIN
                        IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice THEN begin
                            TobeUpdatedSalesLine.VALIDATE(Quantity, PurchLine.Quantity);
                            TobeUpdatedSalesLine.VALIDATE("Qty. to Ship", PurchLine.Quantity);
                        End;
                        IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo" THEN begin
                            TobeUpdatedSalesLine.VALIDATE(Quantity, PurchLine.Quantity);
                            TobeUpdatedSalesLine.VALIDATE("Return Qty. to Receive", PurchLine.Quantity);
                        end;
                        TobeUpdatedSalesLine.MODIFY(TRUE);
                        TobeUpdatedSalesLineUpdated := TRUE;
                    END;

                UNTIL PurchLine.NEXT = 0;
                IF TobeUpdatedPurchLineUpdated THEN BEGIN
                    TobeUpdatedPurchHdr."Your Reference" := 'IC ORDER UPDATED';
                    TobeUpdatedPurchHdr.MODIFY;
                    ReleasePurchDoc.run(TobeUpdatedPurchHdr);
                END;
                IF TobeUpdatedSalesLineUpdated THEN BEGIN
                    TobeUpdatedSalesHdr."Your Reference" := 'IC ORDER UPDATED';
                    TobeUpdatedSalesHdr.MODIFY;
                    ReleaseSalesDoc.Run(TobeUpdatedSalesHdr);
                END;

                //PurchaseHeader."Your Reference" := 'IC ORDER UPDATED';
                IF TobeUpdatedPurchLineUpdated THEN
                    PurchaseHeader.Delete(true);
            END
        END;
    END;
    //end;


    procedure UpdateSalesOrder()
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeUpdatingICPurchaseOrderLine(var ToPurchLine: Record "Purchase Line"; var FromPurchLine: Record "Purchase Line"; PurchHdr: Record "Purchase Header")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnUpdatingFromSalesHdrToICSalesHeader(var ToSalesHdr: Record "Sales Header"; ICSalesHdr: Record "Sales Header")
    begin

    end;

}

