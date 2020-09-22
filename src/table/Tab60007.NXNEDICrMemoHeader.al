table 60007 "NXN EDI CrMemo Header"
{
    DataCaptionFields = "Entry No.";
    Caption = 'EDI Cr Memo Header';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
        }
        field(2; "Order ID"; Code[20])
        {
        }
        field(3; "Sell-to Customer ID"; Code[20])
        {
            Caption = 'Sell-to Customer ID';
            Description = 'Used as Exception Report Filter';
        }
        field(4; "Member ID"; Code[20])
        {
            Description = 'Used as Exception Report Filter - Vendor ID';
            NotBlank = true;
        }
        field(30; "Invoice Date"; Date)
        {
        }
        field(31; "Invoice Time"; Time)
        {
        }
        field(33; "Invoice ID"; Code[35])
        {
        }
        field(34; "Order Date"; Date)
        {
            Description = 'Used as Exception Report Filter';
        }
        field(35; "Multiple Invoice"; Boolean)
        {
            Description = 'HBSTG CW 2013-09-09';
        }
        field(36; "Cost Centre Code"; Code[20])
        {

            // trigger OnLookup()
            // begin
            //     EDISetup.GET;
            //     EDISetup.TESTFIELD("Cost Centre Dimension Code");
            //     DimVal.RESET;
            //     DimVal.SETRANGE("Dimension Code",EDISetup."Cost Centre Dimension Code");
            //     //IF PAGE.RUNMODAL(0,DimVal) = ACTION::LookupOK THEN;
            //     //  VALIDATE("Cost Centre Code",DimVal.Code);
            // end;

            // trigger OnValidate()
            // begin
            //     EDISetup.GET;
            //     EDISetup.TESTFIELD("Cost Centre Dimension Code");
            //     DimVal.RESET;
            //     DimVal.SETRANGE("Dimension Code",EDISetup."Cost Centre Dimension Code");
            //     DimVal.FINDFIRST;
            // end;
        }
        field(200; "Doc Process Status"; Option)
        {
            OptionCaption = ' ,Document Error,Successful,File Error';
            OptionMembers = " ","Document Error",Successful,"File Error";
        }
        field(201; "Sales Order Updated"; Boolean)
        {
        }
        field(202; "Sales Order No."; Code[20])
        {

            trigger OnLookup()
            var
                SalesHeader: Record "Sales Header";
                SalesInvoiceHeader: Record "Sales Invoice Header";
            begin
                IF "Sales Order Updated" THEN BEGIN
                    SalesHeader.RESET;
                    SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
                    SalesHeader.SETRANGE("No.", "Sales Order No.");
                    IF SalesHeader.FINDFIRST THEN BEGIN
                        IF PAGE.RUNMODAL(PAGE::"Sales List", SalesHeader) = ACTION::LookupOK THEN
                            //VALIDATE("Sales order No.",FORMAT(SalesHeader."No."));
                            EXIT;
                    END;

                    SalesInvoiceHeader.RESET;
                    //SalesInvoiceHeader.SETCURRENTKEY("Pre-Assigned No.");
                    SalesInvoiceHeader.SETRANGE("Order No.", "Sales Order No.");
                    IF SalesInvoiceHeader.FINDFIRST THEN BEGIN
                        IF PAGE.RUNMODAL(PAGE::"Posted Sales Invoices", SalesInvoiceHeader) = ACTION::LookupOK THEN
                            //VALIDATE("Sales order No.",FORMAT(SalesInvoiceHeader."No."));
                            EXIT;
                    END;

                END
            end;
        }
        field(203; "Purchase Order Updated"; Boolean)
        {
            Editable = true;
        }
        field(204; "Purchase Order No."; Code[20])
        {

            trigger OnLookup()
            var
                PurchaseHeader: Record "Purchase Header";
                PurchInvHeader: Record "Purch. Inv. Header";
            begin
                IF "Purchase Order Updated" THEN BEGIN
                    PurchaseHeader.RESET;
                    PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Order);
                    PurchaseHeader.SETRANGE("No.", "Purchase Order No.");
                    IF PurchaseHeader.FINDFIRST THEN BEGIN
                        IF PAGE.RUNMODAL(PAGE::"Purchase List", PurchaseHeader) = ACTION::LookupOK THEN
                            //VALIDATE("Purchase order No.",FORMAT(PurchaseHeader."No."));
                            EXIT;
                    END;

                    PurchInvHeader.RESET;
                    //PurchInvHeader.SETCURRENTKEY("Pre-Assigned No.");
                    PurchInvHeader.SETRANGE("Order No.", "Purchase Order No.");
                    IF PurchInvHeader.FINDFIRST THEN BEGIN
                        IF PAGE.RUNMODAL(PAGE::"Posted Purchase Invoices", PurchInvHeader) = ACTION::LookupOK THEN
                            //VALIDATE("Purchase order No.",FORMAT(PurchInvHeader."No."));
                            EXIT;
                    END;

                END
            end;
        }
        field(300; "Test Invoice"; Boolean)
        {
        }
        field(310; "Data Format"; Option)
        {
            OptionCaption = ' ,Phase 1,Phase 2';
            OptionMembers = " ","Phase 1","Phase 2";
        }
        field(311; "Import File Name"; Text[150])
        {
        }
        field(501; "Responsibility Center"; Code[10])
        {
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
        }
        field(50030; "Posting Date"; Date)
        {
            Description = 'CW3.01';
        }
        field(50031; "Actual Delivery Date"; Date)
        {
            Description = 'CW3.01';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Order ID", "Invoice ID", "Invoice Date", "Doc Process Status", "Sales Order No.", "Purchase Order No.")
        {
        }
    }

    trigger OnDelete()
    begin
        //IF CONFIRM(Text70000,TRUE,"Entry No.") THEN BEGIN
        // EDIInvoiceLine.RESET;
        // EDIInvoiceLine.SETRANGE("Entry No.", "Entry No.");
        // EDIInvoiceLine.DELETEALL;
        //END;
    end;

    var
        //EDIInvoiceLine: Record "NXN EDI Invoice Line";
        Text70000: Label 'Do you want to delete the EDI Invoice with Entry No. %1';
        EDISetup: Record "NXN EDI Setup";
        DimVal: Record "Dimension Value";
}

