codeunit 60045 "NXN CopyChangeLogToMaster"
{
    trigger OnRun()
    begin
        // EntryNo := 0;
        // MasterSyncLog.Reset();
        // MasterSyncLog.SetRange("Entry No.");
        // IF MasterSyncLog.FindLast() then
        //     EntryNo := MasterSyncLog."Entry No.";
        // Rec.reset;
        // Rec.SetFilter("Entry No.", '>%1', EntryNo);
        // If Rec.FindFirst() then begin
        //     repeat
        //         MasterSyncLog.Reset();
        //         MasterSyncLog.TransferFields(Rec);
        //         MasterSyncLog."From Company Name" := CompanyName;
        //         MasterSyncLog.Insert(true);
        //     until Rec.Next = 0;
        // end;
    end;

    [EventSubscriber(ObjectType::Table, 405, 'OnAfterInsertEvent', '', false, false)]
    procedure InsertMasterLog(var Rec: Record "Change Log Entry")
    var
        MasterDataSyncSetup: Record "NXN MasterDataSync Setup_Table";
        MasterDataSyncSetupFields: Record "NXN MasterDataSync Setup_Field";
        MasterSyncLog1: Record "NXN Master Data Sync Log";
        CompanyInfo: Record "Company Information";

    begin
        // procedure RegisterLog(RecRef: RecordRef; xRecRef: RecordRef; TypeofChange: Code[10])
        // begin
        CompanyInfo.GET;

        //Insert
        IF CompanyInfo."NXN Register Change log" THEN BEGIN
            MasterDataSyncSetup.RESET;
            MasterDataSyncSetup.SetRange("From Company Name", CompanyName);
            MasterDataSyncSetup.SETRANGE("Table ID", Rec."Table No.");
            IF MasterDataSyncSetup.FINDFIRST THEN BEGIN
                repeat
                    MasterSyncLog.reset;
                    MasterSyncLog.SetRange("From Company Name", MasterDataSyncSetup."From Company Name");
                    MasterSyncLog.SetRange("To Company Name", MasterDataSyncSetup."To Company Name");
                    MasterSyncLog.SetRange("Table No.", Rec."Table No.");
                    MasterSyncLog.SetRange("Type of Change", rec."Type of Change");
                    MasterSyncLog.SetRange("Record ID", Rec."Record ID");
                    MasterSyncLog.SetRange(Synced, false);
                    IF NOT MasterSyncLog.FindFirst() then begin
                        IF MasterSyncLog1.FindLast() then begin
                            EntryNo := MasterSyncLog1."Entry No." + 1;
                        end else
                            EntryNo := 1;

                        with MasterSyncLog do begin
                            init();
                            "Entry No." := EntryNo;
                            //MasterSyncLog.TransferFields(Rec);
                            "Date and Time" := Rec."Date and Time";
                            Time := Rec.Time;
                            "User ID" := Rec."User ID";
                            "Table No." := Rec."Table No.";
                            "Table Caption" := Rec."Table Caption";
                            "Field No." := Rec."Field No.";
                            "Field Caption" := Rec."Field Caption";
                            "Type of Change" := Rec."Type of Change";
                            "Old Value" := Rec."Old Value";
                            "New Value" := Rec."New Value";
                            "Primary Key" := Rec."Primary Key";
                            "Primary Key Field 1 No." := Rec."Primary Key Field 1 No.";
                            "Primary Key Field 1 Caption" := Rec."Primary Key Field 1 Caption";
                            "Primary Key Field 1 Value" := Rec."Primary Key Field 1 Value";
                            "Primary Key Field 2 No." := Rec."Primary Key Field 2 No.";
                            "Primary Key Field 2 Caption" := Rec."Primary Key Field 2 Caption";
                            "Primary Key Field 2 Value" := Rec."Primary Key Field 2 Value";
                            "Primary Key Field 3 No." := Rec."Primary Key Field 3 No.";
                            "Primary Key Field 3 Caption" := Rec."Primary Key Field 3 Caption";
                            "Primary Key Field 3 Value" := Rec."Primary Key Field 3 Value";
                            "Record ID" := Rec."Record ID";
                            "From Company Name" := MasterDataSyncSetup."From Company Name";
                            "To Company Name" := MasterDataSyncSetup."To Company Name";
                            Insert;
                        end;
                    end else begin
                        //rename code
                    end;
                    ;
                until MasterDataSyncSetup.Next = 0;
                //Rec."NXN Synced" := true;
                //Rec."NXN Synced Date" := Today;
            END;
        END;
    end;

    var
        MasterSyncLog: Record "NXN Master Data Sync Log";
        Rec: Record "Change Log Entry";
        EntryNo: Integer;
}