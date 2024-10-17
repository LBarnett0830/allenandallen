public with sharing class DamagesSelector {
    public DamagesSelector() {
}

    public static List<litify_pm__Damage__c> getAllDamages() {
        List<litify_pm__Damage__c> damages = new List<litify_pm__Damage__c>();
        try {
            damages = [
                SELECT 
                    Id,
                    Name,
                    litify_pm__Provider__r.litify_pm__Party__c,
                    litify_pm__Provider__r.litify_pm__Party__r.Name,
                    Balance_Due__c,
                    Damage_Verification_Completion_Time__c,
                    litify_pm__Type__c,
                    Party_Name__c,
                    Escrow__c,
                    litify_pm__Matter__c,
                    Resolution__c
                FROM
                    litify_pm__Damage__c
                LIMIT 5000
            ];
            return damages;
        }catch(Exception ex) {
            System.debug(LoggingLevel.Error, ex.getMessage());
            return null;
        }
    }

    /**
     * Gets Selected Damages by Resolutions
     * @param {String} resId - resolution Id
     * @return {List<litify_pm__Damage__c>} - List of Damages
     */
    public static List<litify_pm__Damage__c> getDamagesByResolutionId(String resId){
        List<litify_pm__Damage__c> damages = new List<litify_pm__Damage__c>();
        try {
            damages = [
                SELECT 
                    Id,
                    Name,
                    litify_pm__Provider__r.litify_pm__Party__c,
                    litify_pm__Provider__r.litify_pm__Party__r.Name,
                    Balance_Due__c,
                    Damage_Verification_Completion_Time__c,
                    litify_pm__Type__c,
                    Party_Name__c,
                    Escrow__c,
                    litify_pm__Matter__c,
                    Resolution__c
                FROM
                    litify_pm__Damage__c
                WHERE
                    Resolution__c =: resId
                LIMIT 5000
            ];
            return damages;
        }catch(Exception ex) {
            System.debug(LoggingLevel.Error, ex.getMessage());
            return null;
        }
    }
    /**
     * Gets Damages by Matter Id
     * @param {String} matterId - matter Id
     * @return {List<litify_pm__Damage__c>} - List of Damages
     */
    public static List<litify_pm__Damage__c> getDamagesByMatterId(String matterId){
        List<litify_pm__Damage__c> damages = new List<litify_pm__Damage__c>();
        try {
            damages = [
                SELECT 
                    Id,
                    Name,
                    litify_pm__Provider__r.litify_pm__Party__c,
                    litify_pm__Provider__r.litify_pm__Party__r.Name,
                    Balance_Due__c,
                    Damage_Verification_Completion_Time__c,
                    litify_pm__Type__c,
                    Party_Name__c,
                    Escrow__c,
                    litify_pm__Matter__c,
                    Resolution__c
                FROM
                    litify_pm__Damage__c
                WHERE
                    litify_pm__Matter__c =: matterId
                LIMIT 5000
            ];
            return damages;
        }catch(Exception ex){
            System.debug(LoggingLevel.Error, ex.getMessage());
            return null;
        }
    }
    /**
     *   Gets Used Damages by Resolutions
     * @param {String} resId - resolution Id
     * @param {String} matterId - matter Id
     * @return {List<litify_pm__Damage__c>} - List of Damages
     */
    public static list<litify_pm__Damage__c> getUsedDamages(String resolutionId, String matterId){
        List<litify_pm__Damage__c> damages = new List<litify_pm__Damage__c>();
        try {
            damages = [
                SELECT 
                    Id,
                    Name,
                    litify_pm__Provider__r.litify_pm__Party__c,
                    litify_pm__Provider__r.litify_pm__Party__r.Name,
                    Balance_Due__c,
                    Damage_Verification_Completion_Time__c,
                    litify_pm__Type__c,
                    Party_Name__c,
                    Escrow__c,
                    litify_pm__Matter__c,
                    Resolution__c
                FROM
                    litify_pm__Damage__c
                WHERE
                    litify_pm__Matter__c =: matterId
                        AND 
                    Resolution__c != null 
                        AND 
                    Resolution__c !=: resolutionId
                LIMIT 5000
            ];
            return damages;
        }catch(Exception ex){
            System.debug(LoggingLevel.Error, ex.getMessage());
            return null;
        }
    }
}
