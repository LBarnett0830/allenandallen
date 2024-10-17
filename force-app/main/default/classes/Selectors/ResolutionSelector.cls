public with sharing class ResolutionSelector {
    public ResolutionSelector() {}

    public static List<litify_pm__Resolution__c> getResolutionById(String recordId){
        List<litify_pm__Resolution__c> resolutions = new List<litify_pm__Resolution__c>();
        
        try {
            resolutions = [
                SELECT 
                    id,
                    name,
                    Status__c,
                    litify_pm__Matter__c,
                    litify_pm__Matter__r.Name,
                    litify_pm__Matter__r.litify_pm__Display_Name__c,
                    Firm_Distribution__c,litify_pm__Total_Damages__c,
                    Third_Party_Distributions__c,
                    Client_Distribution__c,
                    litify_pm__Settlement_Verdict_Amount__c,
                    litify_pm__Total_Expenses__c ,
                    Contingency_Fee__c ,
                    Voided_Hard_Costs__c,
                    Voided_Soft_Costs__c , 
                    Fees_Written_Off__c
                FROM 
                    litify_pm__Resolution__c where id=:recordId
                ];
                return resolutions;
        }catch(Exception ex){
            System.debug(LoggingLevel.Error, ex.getMessage());
            return null;
        }
    }
}