// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

tableextension 60000 "NXN EDICustomer Ext" extends Customer //18
{
    fields
    {
        // Add changes to table fields here
        field(60000; "NXN EDI Customer ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Customer ID';
        }
        field(60001; "NXN Cons. Inv."; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Consolidated Invoice';
        }

    }
}