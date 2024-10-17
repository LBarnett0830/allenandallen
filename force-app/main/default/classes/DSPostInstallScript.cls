global class DSPostInstallScript implements Database.Batchable<sObject>,Database.Stateful{
    global String ACTION_TYPE;
    global String soql_query;
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Integer LIMIT_INT = 10;
        if (soql_query != null) {
            return Database.getQueryLocator(soql_query);
        }
        else {
            if (ACTION_TYPE == 'MATTER_UPDATE') {
                return Database.getQueryLocator([SELECT Id,  litify_pm__Client__c,Client_Contact_ds__c FROM litify_pm__Matter__c WHERE Client_Contact_ds__c = null]);
            }
            else if (ACTION_TYPE == 'INTAKE_UPDATE') {
                return Database.getQueryLocator([SELECT Id,  litify_pm__Client__c,Client_Contact_ds__c FROM litify_pm__Intake__c WHERE Client_Contact_ds__c = null]);
            }
            else {
                return Database.getQueryLocator([SELECT Id FROM TASK LIMIT :LIMIT_INT]);
            }
        }
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        if (ACTION_TYPE == 'MATTER_UPDATE') {
            List<litify_pm__Matter__c> l_records = (List<litify_pm__Matter__c>)scope;
            l_records = [SELECT Id, litify_pm__Client__c,Client_Contact_ds__c FROM  litify_pm__Matter__c WHERE ID IN: l_records];
            DSUnitities.updateMatters(l_records, null);
            update l_records;
        }
        else if (ACTION_TYPE == 'INTAKE_UPDATE') {
            List<litify_pm__Intake__c> l_records = (List<litify_pm__Intake__c>)scope;
            l_records = [SELECT Id,  litify_pm__Client__c,Client_Contact_ds__c FROM litify_pm__Intake__c WHERE ID IN: l_records ];
            DSUnitities.updateIntakes(l_records, null);
            update l_records;
        }
    }
    
    global void finish(Database.BatchableContext BC)
    {    
    }
}