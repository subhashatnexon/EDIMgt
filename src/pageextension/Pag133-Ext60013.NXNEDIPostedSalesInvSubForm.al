pageextension 60013 NXN_EDI_PostedSalesInvSubForm extends "Posted Sales Invoice Subform"
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

    actions
    {
        // Add changes to page actions here
    }

    var
        myInt: Integer;
}