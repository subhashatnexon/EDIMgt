pageextension 60003 "NXN EDIPurchRetOrder Ext" extends "Purchase Return Order" //6640
{
    layout
    {
        // Add changes to page layout here
        addafter(Status)
        {

            field("NXN EDI Order ID"; "NXN EDI Order ID")
            {
                ApplicationArea = All;
                  ToolTip='Specifies the value of the NXN EDI Order ID field';
            }
        }
    }

}