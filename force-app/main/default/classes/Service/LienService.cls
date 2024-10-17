public with sharing class LienService {
    public LienService() {}

    public static List<litify_pm__Lien__c> getAvailableLiens(String matterId){
        List<litify_pm__Lien__c> liens = LienSelector.getLiensByMatterId(matterId);

        List<litify_pm__Lien__c> toReturn = new List<litify_pm__Lien__c>();

        for(litify_pm__Lien__c lien : liens) {
            if(lien.Resolution__c == null) {
                    toReturn.add(lien);
            }
        }
        if (toReturn.size() > 0){
            return liens;
        }else{
            System.debug(LoggingLevel.Error, 'No damages found for matter Id: ' + matterId);
            return null;
        }
    }

    public static List<litify_pm__Lien__c> getSelectedLiens(String resolutionId) {
        List<litify_pm__Lien__c> liens = LienSelector.getLiensByResolution(resolutionId);

        if(liens.size() > 0){
            return liens;
        }else {
            System.debug(LoggingLevel.ERROR, 'No Liens found for Resolution with Id: ' + resolutionId);
            return null;
        }
    }
}