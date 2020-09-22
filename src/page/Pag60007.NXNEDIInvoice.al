page 60007 "NXN EDI Invoice"
{
    PageType = Card;
    Caption = 'EDI Invoice';
    SourceTable = "NXN EDI Invoice Header";
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
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Entry No. field';
                }
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Order ID field';
                }
                field("Invoice ID"; "Invoice ID")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Invoice ID field';
                }
                field("Multiple Invoice"; "Multiple Invoice")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Multiple Invoice field';
                }
                field("Sell-to Customer ID"; "Sell-to Customer ID")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Sell-to Customer ID field';
                }
                field("Member ID"; "Member ID")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Member ID field';
                }
                field("Invoice Date"; "Invoice Date")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Invoice Date field';
                }
                field("Invoice Time"; "Invoice Time")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Invoice Time field';
                }
                field("Data Format"; "Data Format")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Data Format field';
                }
                field("Doc Process Status"; "Doc Process Status")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Doc Process Status field';
                }
                field("Sales Order Updated"; "Sales Order Updated")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Sales Order Updated field';
                }
                field("Sales Order No."; "Sales Order No.")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Sales Order No. field';
                }
                field("Purchase Order Updated"; "Purchase Order Updated")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Purchase Order Updated field';
                }
                field("Purchase Order No."; "Purchase Order No.")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Purchase Order No. field';
                }
                field("Cost Centre Code"; "Cost Centre Code")
                {
                    Editable = false;
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Cost Centre Code field';
                }
                field("Test Invoice"; "Test Invoice")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Test Invoice field';
                }
            }
            part(EDIInvoiceLine; 60006)
            {
                SubPageLink = "Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
            }
            group(Invoicing)
            {
                field("Bill-to Name"; "Bill-to Name")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Bill-to Name field';
                }
                field("Bill-to Name 2"; "Bill-to Name 2")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Bill-to Name 2 field';
                }
                field("Bill-to Address"; "Bill-to Address")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Bill-to Address field';
                }
                field("Bill-to Street"; "Bill-to Street")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Bill-to Street field';
                }
                field("Bill-to City"; "Bill-to City")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Bill-to City field';
                }
                field("Bill-to Contact"; "Bill-to Contact")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Bill-to Contact field';
                }
                field("Bill-to Post Code"; "Bill-to Post Code")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Bill-to Post Code field';
                }
                field("Bill-to State"; "Bill-to State")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Bill-to State field';
                }
            }
        }
        area(factboxes)
        {
            systempart(Link; Links)
            {
                ApplicationArea = All;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
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
                action("Show &Document Error")
                {
                    Caption = 'Show &Document Error';
                    Image = ErrorLog;
                    Promoted = true;
                    PromotedCategory = "Report";
                    ToolTip='Executes the Show &Document Error action';
                    ApplicationArea=All;
                    //RunObject = Page 60004;
                    // RunPageLink = "Table Name"= FILTER("EDI Invoice"),
                    //               "Table Entry No" =FIELD("Entry No."),
                    //               Status=FILTER("Document Error");
                }
            }
        }
    }

    trigger OnDeleteRecord(): Boolean
    begin
        IF NOT CONFIRM(Text70000, TRUE, "Entry No.") THEN BEGIN
            ERROR(Text70001);
        END;
    end;

    var
        Text70000: Label 'Do you want to delete the EDI Invoice with Entry No. %1';
        Text70001: Label 'Invoice Not Deleted.';
}

