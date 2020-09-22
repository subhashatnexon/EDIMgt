page 60005 "NXN EDI Invoices"
{
    // HBSRP 2017-05-30: Field "Sell To customer ID" has been added

    CardPageID = "NXN EDI Invoice";
    Editable = false;
    PageType = List;
    SourceTable = "NXN EDI Invoice Header";
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Entry No. field';
                }
                field("Invoice ID"; "Invoice ID")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Invoice ID field';
                }
                field("Order ID"; "Order ID")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Order ID field';
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
                field("Test Invoice"; "Test Invoice")
                {
                    ApplicationArea = All;
                    ToolTip='Specifies the value of the Test Invoice field';
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
        area(navigation)
        {
            group("&Invoice")
            {
                Caption = '&Invoice';
                Image = Invoice;
                action(Card)
                {
                    Caption = 'Card';
                    Image = EditLines;
                    Promoted = true;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F7';
                    ApplicationArea = All;
                    ToolTip='Executes the Card action';

                    trigger OnAction()
                    begin
                        PAGE.RUN(PAGE::"NXN EDI Invoice", Rec)
                    end;
                }
            }
        }
    }
}

