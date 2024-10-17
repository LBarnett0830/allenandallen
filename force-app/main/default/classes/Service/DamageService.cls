public with sharing class DamageService {
    public DamageService() {}


    public static List<litify_pm__Damage__c> getAvailableDamagesByMatterId(String matterId){
        List<litify_pm__Damage__c> damages =  DamagesSelector.getDamagesByMatterId(matterId);

        List<litify_pm__Damage__c> toReturn = new List<litify_pm__Damage__c>();

        for(litify_pm__Damage__c dmg : damages){
            if(dmg.Resolution__c == null){
                toReturn.add(dmg);
            }
        }
        if(toReturn.size() > 0){
            return damages;
        }else{
            System.debug(LoggingLevel.ERROR, 'No damages found for Matter Id: '+matterId);
            return null;
        }
    }

    public static List<litify_pm__Damage__c> getSelectedDamages(String resolutionId) {
        List<litify_pm__Damage__c> damages = DamagesSelector.getDamagesByResolutionId(resolutionId);

        if(damages.size() > 0){
            return damages;
        }else{
            System.debug(LoggingLevel.ERROR, 'No damages found for Resolution Id: '+resolutionId);
            return null;
        }
    }
}