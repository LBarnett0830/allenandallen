public with sharing class ResolutionService {
    public ResolutionService() {}

    public static litify_pm__Resolution__c getResolutionByRecordId(String recordId){
        List<litify_pm__Resolution__c> resolutions = ResolutionSelector.getResolutionById(recordId);

        return resolutions[0];
    }
}