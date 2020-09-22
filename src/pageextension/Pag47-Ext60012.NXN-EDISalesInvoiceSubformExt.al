pageextension 60012 "NXN EDISalesInvoiceSubForm" extends "Sales Invoice Subform"//47
{
    layout
    {
        // Add changes to page layout here
        addafter(Description)
        {
            field("Sell-to Customer No."; "Sell-to Customer No.")
            {
                ApplicationArea = All;
                Editable = false;
            }

        }

    }

}