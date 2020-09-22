table 60002 "NXN EDI Order Line"
{

    DataCaptionFields = "Entry No.", "Line No.", "Item No.";
    Caption = 'EDI Order Line';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            TableRelation = "NXN EDI Order Header";
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(2; "Line No."; Integer)
        {
            Description = 'XML Line No.';
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(3; "Item No."; Code[20])
        {
            TableRelation = Item WHERE(Blocked = FILTER(false));
            DataClassification = CustomerContent;
            ValidateTableRelation = false;
            Caption = 'Item No.';


            trigger OnValidate()
            var
                EDISetup: Record "NXN EDI Setup";
                EDIOrderHeader: Record "NXN EDI Order Header";
                ItemCrossRef: Record "Item Cross Reference";
                Item: Record Item;
                GSTPostingSetup: Record "VAT Posting Setup";
            begin
                EDISetup.GET;
                EDIOrderHeader.GET("Entry No.");
                IF EDIOrderHeader.Status <> EDIOrderHeader.Status::" " THEN BEGIN
                    IF Item.GET("Item No.") THEN BEGIN
                        "Description" := Item.Description;
                    END
                    // ELSE BEGIN
                    // ItemCrossRef.RESET;
                    // ItemCrossRef.SETRANGE("Cross-Reference Type", ItemCrossRef."Cross-Reference Type"::Contract);
                    // ItemCrossRef.SETRANGE("Cross-Reference Type No.", EDIOrderHeader."Cost Centre Code");
                    // ItemCrossRef.SETRANGE("Cross-Reference No.", "Item No.");
                    // ItemCrossRef.FINDFIRST;
                    // Item.GET(ItemCrossRef."Item No.");
                    // "Description" := ItemCrossRef.Description;
                    // "Unit Of Measure Code" := ItemCrossRef."Unit of Measure";
                    //END;
                END;
                //"NAV Item No." := Item."No.";
                //END;
                //HBSRP 2015-01-28 End:
                //ReSRP 2019-05-03:Start:
                IF NOT Item.GET("Item No.") THEN BEGIN
                    ItemCrossRef.RESET;
                    //ItemCrossRef.SETRANGE("Cross-Reference Type", ItemCrossRef."Cross-Reference Type"::Contract);
                    //ItemCrossRef.SETRANGE("Cross-Reference Type No.", EDIOrderHeader."Cost Centre Code");
                    ItemCrossRef.SETRANGE("Cross-Reference No.", "Item No.");
                    IF ItemCrossRef.FINDFIRST THEN
                        Item.GET(ItemCrossRef."Item No.");
                END;
                GSTPostingSetup.RESET;
                GSTPostingSetup.SETRANGE("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                IF GSTPostingSetup.FINDFIRST THEN;
                //"GST %" := GSTPostingSetup."VAT %";
                //ReSRP 2019-05-03:End:
            end;
        }
        field(4; "Description"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(5; Quantity; Decimal)
        {

            DataClassification = CustomerContent;
            Caption = 'Quantity';
            trigger OnValidate()
            begin
                //IF CurrFieldNo = FIELDNO(Quantity) THEN
                //CheckCartonCapping();                                                                              //#11536
            end;
        }
        field(6; "Unit Of Measure Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit Of Measure Code';
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
            ValidateTableRelation = false;

            trigger OnValidate()
            begin
                EDIOrderHeader.GET("Entry No.");
                IF EDIOrderHeader.Status <> EDIOrderHeader.Status::" " THEN
                    ItemUOM.GET("Item No.", "Unit Of Measure Code");
            end;
        }
        field(7; "Unit Price"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Unit Price';
        }
        field(8; "GST Amount"; Decimal)
        {
            Description = 'GST Amount';
            DataClassification = CustomerContent;
        }
        field(10; "NAV Item No."; Code[20])
        {
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(11; "Item Cross Reference No."; Code[20])
        {

            trigger OnLookup()
            begin
                //HBSRP 2015-11-25 Start:
                EDISetup.GET;
                EDIOrderHeader.GET("Entry No.");
                //IF Cust.GET(EDIOrderHeader."Customer ID") THEN;
                //HBSRP 2016-05-03 Start:
                //ContractCode := '';
                //DefaultDimension.GET(DATABASE::Customer,Cust."Bill-to Customer No.",EDISetup."Cost Centre Dimension Code");
                //ContractCode := DefaultDimension."Dimension Value Code";

                // ItemCrossRef.RESET;
                // //ItemCrossRef.SETRANGE("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::Customer);
                // //ItemCrossRef.SETFILTER("Cross-Reference Type No.",'%1|%2|%3',Cust."Bill-to Customer No.",EDIOrderHeader."Customer No.",'');
                // ItemCrossRef.SETRANGE("Cross-Reference Type",ItemCrossRef."Cross-Reference Type"::Contract);
                // ItemCrossRef.SETRANGE("Cross-Reference Type No.",EDIOrderHeader."Cost Centre Code");
                //HBSRP 2016-05-03 End:
                // IF ItemCrossRef.FINDFIRST THEN BEGIN
                //   IF PAGE.RUNMODAL(PAGE::"Cross Reference List",ItemCrossRef) = ACTION::LookupOK THEN
                //     VALIDATE("Item Cross Reference No.",ItemCrossRef."Cross-Reference No.");
                // END
                //HBSRP 2015-11-25 End:
            end;

            trigger OnValidate()
            var
                GSTPostingSetup: Record "VAT Posting Setup";
            begin
                EDISetup.GET;
                EDIOrderHeader.GET("Entry No.");
                //HBSRP 2015-12-10 Start:
                //IF Cust.GET(EDIOrderHeader."Customer ID") THEN;
                //CostCentre := '';
                //DefaultDimension.GET(DATABASE::Customer,Cust."Bill-to Customer No.",EDISetup."Cost Centre Dimension Code");
                //CostCentre := DefaultDimension."Dimension Value Code";
                //HBSRP 2015-12-10 End:
                IF (EDIOrderHeader.Status <> EDIOrderHeader.Status::" ") THEN BEGIN
                    ItemCrossRef.RESET;
                    ItemCrossRef.SETRANGE("Cross-Reference No.", "Item Cross Reference No.");
                    ItemCrossRef.FINDFIRST;
                    Item.GET(ItemCrossRef."Item No.");
                    "Item No." := Item."No.";
                    Description := ItemCrossRef.Description;
                    "Unit Of Measure Code" := ItemCrossRef."Unit of Measure";
                    //   IF EDIOrderHeader."Cost Centre Code" = EDISetup."CC Dimension Code for Spotless" THEN BEGIN
                    //     IF ItemCrossRef."Customer Unit of Measure" <> '' THEN
                    //       "Unit Of Measure Code" := ItemCrossRef."Customer Unit of Measure"
                    //     ELSE
                    //       "Unit Of Measure Code" := ItemCrossRef."Unit of Measure";
                    //   END ELSE
                    //     "Unit Of Measure Code" := ItemCrossRef."Unit of Measure";
                    //   "NAV Item No." := Item."No.";
                    GSTPostingSetup.RESET;
                    GSTPostingSetup.SETRANGE("VAT Prod. Posting Group", Item."VAT Prod. Posting Group");
                    IF GSTPostingSetup.FINDFIRST THEN
                        "GST %" := GSTPostingSetup."VAT %";
                END;
            end;
        }
        field(13; "Requested Delivery Date"; Date)
        {
            DataClassification = CustomerContent;
        }
        field(14; "GST %"; Decimal)
        {
            DataClassification = CustomerContent;
        }
        field(38; "EDI Line Comments"; Text[100])
        {
            Description = 'HBSTG 2016-12-05';
            DataClassification = CustomerContent;
            caption = 'EDI Line Comments';
        }
        field(100; "Manufacturer Code"; Code[10])
        {
            Caption = 'Manufacturer Code';
            TableRelation = Manufacturer;
            DataClassification = CustomerContent;
        }
        field(101; Brand; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Brand';
        }
        field(110; Cold; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Cold';
        }
        field(115; "Item Category Code"; code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Category Code';
        }

    }

    keys
    {
        key(Key1; "Entry No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        Item: Record Item;
        ItemCrossRef: Record "Item Cross Reference";
        EDIOrderHeader: Record "NXN EDI Order Header";
        GSTPostingSetup: Record "VAT Posting Setup";
        ItemUOM: Record "Item Unit Of Measure";
        EDISetup: Record "NXN EDI Setup";
        Cust: Record Customer;
        CostCentre: Code[20];
        DefaultDimension: Record "Default Dimension";
        ContractCode: Code[20];
}

