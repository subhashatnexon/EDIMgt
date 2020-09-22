pageextension 60007 "NXN SKU Card Ext" extends "Stockkeeping Unit Card" //5700
{
    layout
    {
        // Add changes to page layout here
        addafter("Qty. on Asm. Component")
        {
            field("NXN Inventory Qty"; "NXN Inventory Qty")
            {
                ApplicationArea = All;
            }
            field("NXN Sales Order Qty"; "NXN Sales Order Qty")
            {
                ApplicationArea = All;
            }
            field("NXN Purch. Order Qty"; "NXN Purch. Order Qty")
            {
                ApplicationArea = All;
            }
            field("NXN Assembly Order Qty"; "NXN Assembly Order Qty")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}