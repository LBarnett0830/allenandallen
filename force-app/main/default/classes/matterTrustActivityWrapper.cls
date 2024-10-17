public class matterTrustActivityWrapper {
    
    @auraEnabled
    public litify_pm__Matter__c objMatter{get;set;}
    
    @auraEnabled
    public decimal balanceAmount{get;set;}
    
    @auraEnabled
    public list<matterTrustActDetailWrapper>trustActDetailList{get;set;}
    
}