public with sharing class LienSelector {
    public LienSelector() {

    }

    public static List<litify_pm__Lien__c> getLiensByResolution(String resId){
        List<litify_pm__Lien__c> liens = new List<litify_pm__Lien__c>();
        try {
            liens = [SELECT 
                Id,
                Name,
                Payee_Party__c,
                Payee_Party__r.Name,
                litify_pm__lit_Payee__r.litify_pm__Party__c,
                litify_pm__lit_Payee__r.litify_pm__Party__r.Name,
                litify_pm__lit_Amount_Due__c,
                Date_Issued__c,
                Escrow__c,
                litify_pm__lit_Matter__c,
                Resolution__c
            FROM
                litify_pm__Lien__c
            WHERE   
                Resolution__c = :resId
            LIMIT 5000
            ];
            return liens;
        }catch(Exception ex){
            System.debug(LoggingLevel.Error, ex.getMessage());
            return null;
        }
    }

    public static List<litify_pm__Lien__c> getLiensByMatterId(String matterId){
        List<litify_pm__Lien__c> liens = new List<litify_pm__Lien__c>();
        try {
            liens = [SELECT 
                Id,
                Name,
                Payee_Party__c,
                Payee_Party__r.Name,
                litify_pm__lit_Payee__r.litify_pm__Party__c,
                litify_pm__lit_Payee__r.litify_pm__Party__r.Name,
                litify_pm__lit_Amount_Due__c,
                Date_Issued__c,
                Escrow__c,
                litify_pm__lit_Matter__c,
                Resolution__c
            FROM
                litify_pm__Lien__c
            WHERE   
                litify_pm__lit_Matter__c = :matterId
            LIMIT 5000
            ];
            return liens;
        }catch(Exception ex){
            System.debug(LoggingLevel.Error, ex.getMessage());
            return null;
        }
    }
}