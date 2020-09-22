pageextension 60001 "NXN EDIPurchOrder Ext" extends "Purchase Order" //50
{
    layout
    {
        // Add changes to page layout here
        addafter(Status)
        {

            field("NXN EDI Order ID"; "NXN EDI Order ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the EDI Order ID field';
            }
            field("NXN IC SRC Order No."; "NXN IC SRC Order No.")
            {
                ApplicationArea = All;
                Enabled = false;
                ToolTip = 'Shows the value of the IC source Order No.';
            }
            field("NXN IC SRC Inv_Cr No."; "NXN IC SRC Inv_Cr No.")
            {
                ApplicationArea = All;
                Enabled = false;
                ToolTip = 'Shows the value of the IC Source Invoice/Credit No.';
            }

        }
    }

}