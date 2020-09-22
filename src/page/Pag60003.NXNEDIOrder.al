page 60003 "NXN EDI Order"
{
    PageType = Card;
    SourceTable = "NXN EDI Order Header";
    Caption = 'EDI Order';
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            group(General)
            {
                field("Entry No."; "Entry No.")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order ID field';

                    trigger OnValidate()
                    var
                        EDIOrderHeader: Record "NXN EDI Order Header";
                    begin
                        IF "Order ID" <> '' THEN BEGIN
                            EDIOrderHeader.RESET;
                            EDIOrderHeader.SETRANGE("Order ID", "Order ID");
                            IF EDIOrderHeader.FINDFIRST THEN
                                ERROR(Text70004);
                        END;
                    end;
                }
                field("Customer No."; "Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer No. field';
                }
                field("Vendor No."; "Vendor No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Vendor No. field';
                    Visible = false;
                }
                field("Customer ID"; "Customer ID")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer ID field';
                }
                field("Member ID"; "Member ID")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Member ID field';
                    Visible = false;
                }
                field("Order Date"; "Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Date field';
                }
                field("Order Time"; "Order Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Time field';
                }
                field("Expected Delivery Date"; "Expected Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Expected Delivery Date field';
                }
                field(Status; Status)
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Doc Process Status"; "Doc Process Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Doc Process Status field';
                }
                field("Sales Order Created"; "Sales Order Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Order Created field';
                }
                field("Sales Order No."; "Sales Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Order No. field';
                }
                field("Purchase Order Created"; "Purchase Order Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Order Created field';
                }
                field("Purchase Order No."; "Purchase Order No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Purchase Order No. field';
                }
                field("Order Method"; "Order Method")
                {
                    Editable = true;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Method field';
                }
                field("Import File Name"; "Import File Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("EDI Header Comments"; "EDI Header Comments")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EDI Header Comments field';
                }
                field("EDI Delivery Instructions"; "EDI Delivery Instructions")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the EDI Delivery Instructions field';
                }
                field(Cold; Cold)
                {
                    ApplicationArea = All;
                }

            }
            part(EDIOrderLines; 60002)
            {
                SubPageLink = "Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
            }
            group(Invoicing)
            {
                field("Bill-to Name"; "Bill-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Name field';
                }
                field("Bill-to Name 2"; "Bill-to Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Name 2 field';
                }
                field("Bill-to Address"; "Bill-to Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Address field';
                }
                field("Bill-to Street"; "Bill-to Street")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Street field';
                }
                field("Bill-to City"; "Bill-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to City field';
                }
                field("Bill-to Contact"; "Bill-to Contact")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Contact field';
                }
                field("Bill-to Post Code"; "Bill-to Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Post Code field';
                }
                field("Bill-to State"; "Bill-to State")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to State field';
                }
                field("Bill-to Country/Region Code"; "Bill-to Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Country/Region Code field';
                }
            }
            group(Shipping)
            {
                field("Ship-to Code"; "Ship-to Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Code field';
                }
                field("Ship-to Name"; "Ship-to Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Name field';
                }
                field("Ship-to Name 2"; "Ship-to Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Name 2 field';
                }
                field("Ship-to Address"; "Ship-to Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Address field';
                }
                field("Ship-to Street"; "Ship-to Street")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Street field';
                }
                field("Ship-to City"; "Ship-to City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to City field';
                }
                field("Ship-to Contact"; "Ship-to Contact")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Contact field';
                }
                field("Ship-to Post Code"; "Ship-to Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Post Code field';
                }
                field("Ship-to State"; "Ship-to State")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to State field';
                }
                field("Ship-to Country/Region Code"; "Ship-to Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ship-to Country/Region Code field';
                }
            }
            group("Doc Parser")
            {
                field("Document Parser ID"; "Document Parser ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Parser ID field';
                    Editable = false;
                }
                field("Document Parser Name"; "Document Parser Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document Parser Name field';
                    Editable = false;
                }
                field("Cust Order Received Date"; "Cust Order Received Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Order Received Date field';
                }
                field("Cust Order Received Time"; "Cust Order Received Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customer Order Received Time field';
                }

            }
            group("Excel Order")
            {
                field("Cost Centre Code"; "Cost Centre Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cost Centre Code field';
                }
                field("Business Unit"; "Business Unit")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Business Unit field';
                }
                field("Floor Contact Name"; "Floor Contact Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Floor Contact Name field';
                }
                field("Message From"; "Message From")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Message From field';
                }
                field("Message To"; "Message To")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Message To field';
                }
                field("Message Text"; "Message Text")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Message Text field';
                }
                field("Preferred Delivery Time"; "Preferred Delivery Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Preferred Delivery Time field';
                }
                field("Email Date"; "Email Date")
                {
                    ApplicationArea = All;
                }
                field("Email Time"; "Email Time")
                {
                    ApplicationArea = All;
                }
            }
        }

    }


    actions
    {
        area(processing)
        {
            group(Functions)
            {
                Caption = 'Functions';
                action("&Cancel Order")
                {
                    Caption = '&Cancel Order';
                    Image = Cancel;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ApplicationArea = All;
                    ToolTip = 'Executes the &Cancel Order action';

                    trigger OnAction()
                    var
                        EDIInvoiceHeader: Record "NXN EDI Invoice Header";
                        DocCreationErrorLog: Record "NXN Doc. Creation Error Log";
                    begin

                        IF CONFIRM(Text001, TRUE) THEN BEGIN
                            IF "Doc Process Status" = "Doc Process Status"::"Document Error" THEN BEGIN
                                DocCreationErrorLog.RESET;
                                DocCreationErrorLog.SETRANGE("Table Name", DocCreationErrorLog."Table Name"::"EDI Order");
                                DocCreationErrorLog.SETRANGE("Table Entry No", "Entry No.");
                                DocCreationErrorLog.SETRANGE(Closed, FALSE);
                                IF DocCreationErrorLog.FINDSET(TRUE, FALSE) THEN
                                    REPEAT
                                        DocCreationErrorLog.Closed := TRUE;
                                        DocCreationErrorLog.Status := DocCreationErrorLog.Status::Cancelled;
                                        DocCreationErrorLog.MODIFY;
                                    UNTIL DocCreationErrorLog.NEXT = 0;
                            END ELSE
                                IF "Doc Process Status" = "Doc Process Status"::Successful THEN BEGIN
                                    SalesHeader.GET(SalesHeader."Document Type"::Order, "Sales Order No.");
                                    IF SalesHeader.Status = SalesHeader.Status::Open then begin
                                        SalesHeader.DELETE(TRUE);
                                    end;

                                    IF PurchHeader.GET(PurchHeader."Document Type"::Order, "Purchase Order No.") then begin
                                        IF (PurchHeader.Status = PurchHeader.Status::Open) AND (PurchHeader."NXN IC SRC Order No." = SalesHeader."No.") then begin
                                            PurchHeader.DELETE(TRUE);
                                        end;
                                    End;

                                    "Sales Order Created" := FALSE;
                                    "Sales Order No." := '';
                                    "Purchase Order Created" := FALSE;
                                    "Purchase Order No." := '';
                                END;

                            "Doc Process Status" := "Doc Process Status"::Cancelled;
                            MODIFY;

                        END;
                    end;
                }
                action("Re&lease Order")
                {
                    Caption = 'Re&lease Order';
                    Image = ReleaseDoc;
                    ShortcutKey = 'Ctrl+F9';
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Re&lease Order action';

                    trigger OnAction()
                    begin
                        IF CONFIRM(Text70002, TRUE) THEN BEGIN
                            TESTFIELD(Status, Status::"Open (Manual)");
                            TESTFIELD("Order ID");
                            TESTFIELD("Doc Process Status", "Doc Process Status"::" ");
                            TESTFIELD("Sales Order Created", FALSE);
                            Cust.GET("Customer No.");
                            IF Cust.Blocked <> Cust.Blocked::" " THEN
                                IF NOT CONFIRM(Text70008, FALSE, "Customer No.") THEN
                                    EXIT;
                            //HBSRP 2015-06-23 Start:
                            //"Order Date" := TODAY;
                            //"Order Time" := TIME;
                            //HBSRP 2015-06-23 End:
                            Status := Status::"Released (Manual)";
                            MODIFY;
                        END;
                    end;
                }
                action("Re&open Order")
                {
                    Caption = 'Re&open Order';
                    Image = ReOpen;
                    Promoted = true;
                    PromotedCategory = Process;
                    ApplicationArea = All;
                    ToolTip = 'Executes the Re&open Order action';

                    trigger OnAction()
                    begin
                        IF CONFIRM(Text70003, TRUE) THEN BEGIN
                            //TESTFIELD(Status,Status::"Released (Manual)");
                            IF "Doc Process Status" = "Doc Process Status"::Successful THEN
                                ERROR(Text70006);
                            IF "Doc Process Status" = "Doc Process Status"::Cancelled THEN
                                ERROR(Text70007);
                            TESTFIELD("Sales Order Created", FALSE);
                            Status := Status::"Open (Manual)";
                            MODIFY;
                        END;
                    end;
                }
                action("Show &Document Error")
                {
                    Caption = 'Show &Document Error';
                    Image = ErrorLog;
                    Promoted = true;
                    PromotedCategory = "Report";
                    ToolTip = 'Executes the Show &Document Error action';
                    ApplicationArea = All;
                    RunObject = Page "NXN Doc. Creation Error Log";
                    RunPageLink = "Table Name" = FILTER("EDI Order"), "Table Entry No" = FIELD("Entry No."), Status = FILTER("Document Error");
                }
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        IF NOT CONFIRM(Text70000, TRUE, "Entry No.") THEN BEGIN
            ERROR(Text70001);
        END;

        IF Status = Status::"Released (Manual)" THEN
            ERROR(Text70005);

        IF "Doc Process Status" = "Doc Process Status"::Successful THEN
            ERROR(Text70006);

        IF "Doc Process Status" = "Doc Process Status"::Cancelled THEN
            ERROR(Text70007);
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        "Order Method" := "Order Method"::Other;
        "Order Date" := WORKDATE;
        "Order Time" := TIME;
        Status := Status::"Open (Manual)";
    end;

    trigger OnModifyRecord(): Boolean
    begin
        IF Status = Status::"Released (Manual)" THEN
            ERROR(Text70005);

        IF "Doc Process Status" = "Doc Process Status"::Successful THEN
            ERROR(Text70006);

        IF "Doc Process Status" = "Doc Process Status"::Cancelled THEN
            ERROR(Text70007);
    end;

    var
        Text001: Label 'Do you wish to cancel this order? The corresponding Sales and Purchase Orders will be deleted. ';
        SalesHeader: Record "Sales Header";
        PurchHeader: Record "Purchase Header";
        EDIInvoiceHeader: Record "NXN EDI Invoice Header";
        //DocCreationErrorLog: Record Doc;
        Text002: Label 'Order cannot be cancelled because an EDI Invoice is found with Entry No. %1  and Invoice ID %2. ';
        CustList: Page "Customer List";
        Cust: Record Customer;
        VendList: Page "Vendor List";
        Vend: Record Vendor;
        Text70000: Label 'Do you want to delete the EDI Order with Entry No. %1';
        Text70001: Label 'Order not deleted.';
        Text70002: Label 'Do you want to Release the Order?';
        Text70003: Label 'Do you want to Re-Open the Order?';
        EDIOrderHeader: Record "NXN EDI Order Header";
        Text70004: Label 'Order ID already exist.';
        Text70005: Label 'Order cannot be modified. Reopen the Order to make changes.';
        Text70006: Label 'Order cannot be modified because Doc Process Status is Successful.';
        Text70007: Label 'Order cannot be modified because Doc Process Status is Cancelled.';
        Text70008: Label 'Customer %1 is on credit hold. Do you still want to continue?';
    //DailyJobAlertsCustBlock: Codeunit "50052";
}

