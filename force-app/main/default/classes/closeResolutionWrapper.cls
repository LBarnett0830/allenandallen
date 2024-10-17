public class closeResolutionWrapper {
    @AuraEnabled
    public List<JEWrapper>listJELineWrapper{get;set;}
    
    @AuraEnabled
    public litify_pm__Resolution__c objResolution{get;set;}
    
    @AuraEnabled
    public boolean isAllDmgEscrowed{get;set;}
    
    @AuraEnabled
    public boolean isAllLienEscrowed{get;set;}
    
    @AuraEnabled
    public decimal escrowedDmgs{get;set;}
    
    @AuraEnabled
    public decimal escrowedLiens{get;set;}
    
    
    public class JEWrapper{
        @AuraEnabled
        public string GLName{get;set;}
        @AuraEnabled
        public string GLVariable1{get;set;}
        @AuraEnabled
        public string GLVariable2{get;set;}
        @AuraEnabled
        public string GLVariable4{get;set;}
        @AuraEnabled
        public decimal debit{get;set;}
        @AuraEnabled
        public decimal credit{get;set;}
        
        // public JEWrapper(){}
    }
    
}