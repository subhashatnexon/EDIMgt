codeunit 60043 "Execute Master Data Sync"
{

    trigger OnRun()
    begin
        CompanyInfo.GET;
        IF NOT CompanyInfo."NXN Activate Sync" THEN
            EXIT;

        //Insertion

        MasterSyncLogEntry.RESET;
        //MasterSyncLogEntry.SETRANGE("Type of Change",MasterSyncLogEntry."Type of Change"::Insertion);
        MasterSyncLogEntry.SetRange("To Company Name", CompanyName);
        MasterSyncLogEntry.SETRANGE(Synced, FALSE);
        IF MasterSyncLogEntry.FINDFIRST THEN BEGIN
            REPEAT
                COMMIT;
                IF MasterDataSyncMgt.RUN(MasterSyncLogEntry) THEN BEGIN
                    MasterSyncLogEntry.Synced := TRUE;
                    MasterSyncLogEntry."Synced Date" := WORKDATE;
                    MasterSyncLogEntry."Synced Time" := TIME;
                    MasterSyncLogEntry."Error Occured" := FALSE;
                    MasterSyncLogEntry."Error Message" := '';
                    MasterSyncLogEntry.MODIFY;
                END ELSE BEGIN
                    MasterSyncLogEntry."Error Occured" := TRUE;
                    MasterSyncLogEntry."Error Message" := COPYSTR(GETLASTERRORTEXT, 1, 250);
                    MasterSyncLogEntry.MODIFY;
                END;
            UNTIL MasterSyncLogEntry.NEXT = 0;
        END;
    end;

    var
        MasterChangeLogMgt: Codeunit "NXN Master Data Log Mgt";
        MasterDataSyncMgt: Codeunit "NXN Master Sync Mgt";
        CompanyInfo: Record "Company Information";
        MasterDataSyncSetup: Record "NXN MasterDataSync Setup_Table";
        MasterSyncLogEntry: Record "NXN Master Data Sync Log";
}