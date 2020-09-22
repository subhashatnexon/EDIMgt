pageextension 60021 "NXN EDICustomer Card Ext" extends "Customer Card" //21
{
    layout
    {
        addafter(Shipping)
        {
            group(EDI)
            {
                field("NXN EDI Customer ID"; "NXN EDI Customer ID")
                {
                    ApplicationArea = All;
                }
                field("NXN Cons. Inv."; "NXN Cons. Inv.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}