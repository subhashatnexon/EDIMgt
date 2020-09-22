// This table is related to EDI 
table 60001 "NXN EDI Order Header"
{
    DataCaptionFields = "Entry No.", "Order ID";
    DrillDownPageID = 60001;
    LookupPageID = 60001;
    Caption = 'EDI Order Header';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(2; "Order ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Order ID';
        }
        field(3; "Customer ID"; Code[20])
        {
            Description = 'Customer Site ID';
            DataClassification = CustomerContent;
            Caption = 'Customer ID';
        }
        field(4; "Member ID"; Code[20])
        {
            Description = 'Member/Depot ID';
            //NotBlank = true;
            DataClassification = CustomerContent;
            Caption = 'Vendor ID';
        }
        field(5; "Bill-to Name"; Text[50])
        {
            Caption = 'Bill-to Name';
            DataClassification = CustomerContent;

        }
        field(6; "Bill-to Name 2"; Text[50])
        {
            Caption = 'Bill-to Name 2';
            DataClassification = CustomerContent;
        }
        field(7; "Bill-to Address"; Text[50])
        {
            Caption = 'Bill-to Address';
            DataClassification = CustomerContent;
        }
        field(8; "Bill-to Street"; Text[50])
        {
            Caption = 'Bill-to Street';
            DataClassification = CustomerContent;
            Description = 'Bill-to Address 2';
        }
        field(9; "Bill-to City"; Text[30])
        {
            Caption = 'Bill-to City';
            DataClassification = CustomerContent;
            TableRelation = "Post Code".City;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(10; "Bill-to Contact"; Text[50])
        {
            Caption = 'Bill-to Contact';
            DataClassification = CustomerContent;
        }
        field(11; "Bill-to Post Code"; Code[20])
        {
            Caption = 'Bill-to Post Code';
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
            DataClassification = CustomerContent;
        }
        field(12; "Bill-to State"; Text[30])
        {
            Caption = 'Bill-to State';
            Description = 'Bill-to County';
            DataClassification = CustomerContent;
        }
        field(13; "Bill-to Country/Region Code"; Code[10])
        {
            Caption = 'Bill-to Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(20; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            DataClassification = CustomerContent;
        }
        field(21; "Ship-to Name"; Text[50])
        {
            Caption = 'Ship-to Name';
            DataClassification = CustomerContent;
        }
        field(22; "Ship-to Name 2"; Text[50])
        {
            Caption = 'Ship-to Name 2';
            DataClassification = CustomerContent;
        }
        field(23; "Ship-to Address"; Text[50])
        {
            Caption = 'Ship-to Address';
            DataClassification = CustomerContent;
        }
        field(24; "Ship-to Street"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Ship-to Street';
            Description = 'Ship-to Address 2';
        }
        field(25; "Ship-to City"; Text[30])
        {
            Caption = 'Ship-to City';
            TableRelation = "Post Code".City;
            DataClassification = CustomerContent;
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(26; "Ship-to Contact"; Text[50])
        {
            Caption = 'Ship-to Contact';
            DataClassification = CustomerContent;
        }
        field(27; "Ship-to Post Code"; Code[20])
        {
            Caption = 'Ship-to Post Code';
            DataClassification = CustomerContent;
            TableRelation = "Post Code";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(28; "Ship-to State"; Text[30])
        {
            Caption = 'Ship-to State';
            Description = 'Ship-to County';
            DataClassification = CustomerContent;
        }
        field(29; "Ship-to Country/Region Code"; Code[10])
        {
            Caption = 'Ship-to Country/Region Code';
            TableRelation = "Country/Region";
            DataClassification = CustomerContent;
        }
        field(30; "Order Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Date';
        }
        field(31; "Order Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Time';
        }
        field(32; "Cust Order Received Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Customer Order Received Date';
        }
        field(33; "Cust Order Received Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Customer Order Received Time';
        }
        field(34; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            Description = 'ONLY used in Manual EDI Order Entry';
            TableRelation = Customer;

            trigger OnValidate()
            begin
                Customer.GET("Customer No.");
                IF Customer."Bill-to Customer No." <> '' THEN
                    BillToCust.GET(Customer."Bill-to Customer No.")
                ELSE
                    BillToCust.GET("Customer No.");

                "Bill-to Name" := BillToCust.Name;
                "Bill-to Address" := BillToCust.Address;
                "Bill-to Street" := BillToCust."Address 2";
                "Bill-to City" := BillToCust.City;
                "Bill-to Post Code" := BillToCust."Post Code";
                "Bill-to State" := BillToCust.County;
                "Bill-to Country/Region Code" := BillToCust."Country/Region Code";
                "Ship-to Name" := Customer.Name;
                "Ship-to Address" := Customer.Address;
                "Ship-to Street" := Customer."Address 2";
                "Ship-to City" := Customer.City;
                "Ship-to Post Code" := Customer."Post Code";
                "Ship-to State" := Customer.County;
                "Ship-to Country/Region Code" := Customer."Country/Region Code";
                "Cost Centre Code" := Customer."Global Dimension 1 Code";
                "Customer ID" := Customer."NXN EDI Customer ID";
            END;
            //end;
        }
        field(35; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            Description = 'ONLY used in Manual EDI Order Entry';
            TableRelation = Vendor;
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                //IF Vendor.GET("Vendor No.") THEN
                //"Member ID" := Vendor."Member ID";
            end;
        }
        field(36; "Cost Centre Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Cost Centre Code';
            //     trigger OnLookup()
            //     begin
            //         EDISetup.GET;
            //         EDISetup.TESTFIELD("Cost Centre Dimension Code");
            //         DimVal.RESET;
            //         DimVal.SETRANGE("Dimension Code", EDISetup."Cost Centre Dimension Code");
            //         IF PAGE.RUNMODAL(0, DimVal) = ACTION::LookupOK THEN;
            //         //  VALIDATE("Cost Centre Code",DimVal.Code);
            //     end;

            //     trigger OnValidate()
            //     begin
            //         EDISetup.GET;
            //         EDISetup.TESTFIELD("Cost Centre Dimension Code");
            //         DimVal.RESET;
            //         DimVal.SETRANGE("Dimension Code", EDISetup."Cost Centre Dimension Code");
            //         DimVal.FINDFIRST;
            //     end;
            //
        }

        field(38; "EDI Header Comments"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Header Comments';
        }
        field(39; "EDI Delivery Instructions"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Delivery Instructions';

        }
        field(40; "Responsibility Center"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Responsibility Center';
            TableRelation = "Responsibility Center";
            trigger OnValidate()
            var
                UserSetupMgt: Codeunit "User Setup Management";
                RespCenter: Record "Responsibility Center";
            begin
                TESTFIELD(Status, Status::"Open (Manual)");
                IF NOT UserSetupMgt.CheckRespCenter(0, "Responsibility Center") THEN
                    ERROR(
                      Text027,
                      RespCenter.TABLECAPTION, UserSetupMgt.GetSalesFilter);
            end;
        }
        //Document Parser fields
        field(45; "Document Parser ID"; code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'Document Parser ID';
            Editable = false;

        }
        field(48; "Document Parser Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Document Parser Name';
        }
        //Excel Order Fields
        field(65; "Business Unit"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Business Unit';
        }
        field(70; "Telephone No."; text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Telephone No.';
        }
        field(73; "Preferred Delivery Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Preferred Delivery Time';
        }
        field(76; "Floor Contact Name"; text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Floor Contact Name';
        }

        field(79; "Tracking Email"; text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Tracking Email';
        }
        field(83; "Supplier Question 1"; text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Supplier Question 1';
        }
        field(86; "Supplier Question 2"; text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Supplier Question 2';
        }
        field(89; "Supplier Question 3"; text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Supplier Question 3';
        }
        field(90; "Supplier Question 4"; text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Supplier Question 4';
        }
        field(94; "Message To"; text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Message To';
        }
        field(95; "Message From"; text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Message From';
        }
        field(96; "Message Text"; text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Message Text';
        }

        field(200; "Doc Process Status"; Option)
        {
            OptionCaption = ' ,Document Error,Successful,File Error,Cancelled';
            OptionMembers = " ","Document Error",Successful,"File Error",Cancelled;
            DataClassification = CustomerContent;
        }
        field(201; "Sales Order Created"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Sales Order Created';
        }
        field(202; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            trigger OnLookup()
            var
                SalesHeader: Record "Sales Header";
                SalesInvoiceHeader: Record "Sales Invoice Header";
            begin
                IF "Sales Order Created" THEN BEGIN
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
        field(203; "Purchase Order Created"; Boolean)
        {
            Editable = true;
            DataClassification = CustomerContent;
            Caption = 'Purchase Order Created';
        }
        field(204; "Purchase Order No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchase Order No.';
            trigger OnLookup()
            var
                PurchaseHeader: Record "Purchase Header";
                PurchInvHeader: Record "Purch. Inv. Header";
            begin
                IF "Purchase Order Created" THEN BEGIN
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
        field(301; "Order Method"; Option)
        {
            Description = 'HBSTG CWS004 2015-01-24';
            OptionCaption = ' ,Online,Mobile App,Email,Fax,Phone,Other,Complimentary';
            OptionMembers = " ",Online,"Mobile App",Email,Fax,Phone,Other,Complimentary;
            DataClassification = CustomerContent;
        }
        field(302; Status; Option)
        {
            OptionCaption = ' ,Released (Manual),Open (Manual)';
            OptionMembers = " ","Released (Manual)","Open (Manual)";
            DataClassification = CustomerContent;
        }
        field(303; Cold; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Cold';
        }
        field(502; "Amount Including VAT"; Decimal)
        {
            Caption = 'Amount Including VAT';
            Editable = false;
            DataClassification = CustomerContent;
        }
        field(503; "Expected Delivery Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Requested Delivery Date';
        }
        field(504; "Import File Name"; Text[150])
        {
            DataClassification = CustomerContent;
            Caption = 'Import File Name';
        }
        field(505; "Email Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Email Date';
        }
        field(506; "Email Time"; Time)
        {

            DataClassification = CustomerContent;
            Caption = 'Email Time';
        }
        field(507; "Email Subject"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Email Subject';
        }

    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Doc Process Status", "Order Method", "Expected Delivery Date")
        {
        }
        key(Key3; "Expected Delivery Date", "Doc Process Status", "Order Method")
        {
        }
        key(Key4; "Order ID")
        {
        }
        key(Key5; "Customer ID", "Doc Process Status")
        {
            SumIndexFields = "Amount Including VAT";
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Entry No.", "Order ID", "Customer ID", "Member ID", "Doc Process Status", "Sales Order No.", "Purchase Order No.")
        {
        }
    }

    trigger OnDelete()
    begin
        //IF CONFIRM(Text70000,TRUE,"Entry No.") THEN BEGIN
        EDIOrderLine.RESET;
        EDIOrderLine.SETRANGE("Entry No.", "Entry No.");
        EDIOrderLine.DELETEALL;
        //END;
    end;

    var
        EDIOrderLine: Record "NXN EDI Order Line";
        Text70000: Label 'Do you want to delete the EDI Order with Entry No. %1';
        Customer: Record "Customer";
        Vendor: Record "Vendor";
        EDISetup: Record "NXN EDI Setup";
        DimVal: Record "Dimension Value";
        Text027: Label 'Your identification is set up to process from %1 %2 only.';
        BillToCust: Record "Customer";
}

