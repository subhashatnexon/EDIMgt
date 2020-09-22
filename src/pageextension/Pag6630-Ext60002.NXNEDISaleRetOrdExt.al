pageextension 60002 "NXN EDISalesRetOrder Ext" extends "Sales Return Order" //6630
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