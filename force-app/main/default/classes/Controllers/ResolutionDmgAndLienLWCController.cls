public with sharing class ResolutionDmgAndLienLWCController {
    public ResolutionDmgAndLienLWCController() {}

    @AuraEnabled
    public static litify_pm__Resolution__c getResolution(String recordId){
        try {
            return ResolutionService.getResolutionByRecordId(recordId);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    /**
     * @description: Get Damage records by Resolution Id
     * @param: String resolutionId
     * @return: List<litify_pm__Damage__c>
     */
    @AuraEnabled
    public static List<litify_pm__Damage__c> getSelectedDamages(String resolutionId){
        try{
            return DamageService.getSelectedDamages(resolutionId);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description: Get Damage records by Matter Id
     * @param: String matterId
     * @return: List<litify_pm__Damage__c>
     */
    @auraEnabled
    public static List<litify_pm__Damage__c> getAvailableDamages(String recordId){
        litify_pm__Resolution__c resolution = ResolutionSelector.getResolutionById(recordId)[0];
        String matterId = '';
        if (resolution.litify_pm__Matter__c != null){
            matterId = resolution.litify_pm__Matter__c;
        }

        try {
            return DamageService.getAvailableDamagesByMatterId(matterId);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description: Get Lien records by Matter Id
     * @param: String matterId
     * @return: List<litify_pm__Lien__c>
     */
    @AuraEnabled
    public static List<litify_pm__Lien__c> getSelectedLiens(String resolutionId) {
        try{
            return LienService.getSelectedLiens(resolutionId);
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description: Get Lien records by Matter Id
     * @param: String matterId
     * @return: List<litify_pm__Lien__c>
     */
    @AuraEnabled
    public static List<litify_pm__Lien__c> getAvailableLiens(String recordId){
        litify_pm__Resolution__c resolution = ResolutionSelector.getResolutionById(recordId)[0];
        String matterId = resolution.litify_pm__Matter__c;
        try{
            return LienService.getAvailableLiens(matterId);
        }catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }
}