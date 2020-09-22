pageextension 60000 "NXN EDISaleOrder Ext" extends "Sales Order" //42
{
    layout
    {
        // Add changes to page layout here
        addafter(Status)
        {

            field("NXN EDI Order ID"; "NXN EDI Order ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the NXN EDI Order ID field';
            }
            field("NXN IC SRC Order No."; "NXN IC SRC Order No.")
            {
                ApplicationArea = All;
                Enabled = false;
            }
            field("NXN IC SRC Inv_Cr No."; "NXN IC SRC Inv_Cr No.")
            {
                ApplicationArea = All;
                Enabled = false;
            }
        }
    }

}