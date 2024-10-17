/*
Author     : Cmentor/ Sampath Suranji
Description: myFeesController for myFees lightning component
Date       : 11/05/2020
*/
public class myFeesController { 
    
    @auraEnabled
    public static myFeesWrapper getFeesWrapper(){
        myFeesWrapper objFeeWrapper = new myFeesWrapper();
        try{
            string userId = userInfo.getUserId();
            List<user>listUser = [select id, Alias from user where id=:userId];
            string attorney = listUser[0].alias;
            objFeeWrapper.attorney = attorney;
            objFeeWrapper.attorneyName = userinfo.getName();
            string feeIncomeGL = label.Fee_Income_GL_Account;
            decimal balance=0;
            //attorney='PDH';
            if(!string.isEmpty(feeIncomeGL)){
                list<AcctSeed__Accounting_Variable__c>listAccVar= [select id,name,AcctSeed__Type__c from AcctSeed__Accounting_Variable__c where AcctSeed__Type__c ='GL Account Variable 4' and name=:attorney];
                if(listAccVar.size()>0){
                    List<AcctSeed__GL_Account__c>listGl = [select id,name from AcctSeed__GL_Account__c where name=:feeIncomeGL.trim()];
                    list<transactionWrapper> listWrapper = new  list<transactionWrapper>();
                    if(listGl.size()>0){
                        for(AcctSeed__Transaction__c objTransactions : [select id,name,AcctSeed__Date__c,AcctSeed__Account__c,AcctSeed__Account__r.Name,AcctSeed__Amount__c,AcctSeed__Accounting_Period__c,AcctSeed__Accounting_Period__r.Name,AcctSeed__Project__c,AcctSeed__Project__r.name,AcctSeed__Project__r.Matter__c,AcctSeed__Project__r.Matter__r.litify_pm__Display_Name__c,
                                                                        AcctSeed__Journal_Entry_Line__r.AcctSeed__Journal_Entry__r.Resolution__c,  AcctSeed__Journal_Entry_Line__r.AcctSeed__Journal_Entry__r.Resolution__r.Name,Resolution_Date__c
                                                                        from AcctSeed__Transaction__c where AcctSeed__GL_Account_Variable_4__c =:listAccVar[0].id and AcctSeed__GL_Account__c=:listGl[0].id order by AcctSeed__Date__c] ){
                                                                            transactionWrapper objWrapper = new transactionWrapper();
                                                                            objWrapper.attorney = attorney;
                                                                            objWrapper.transDate = objTransactions.AcctSeed__Date__c;
                                                                            objWrapper.amount = (objTransactions.AcctSeed__Amount__c==null?0:(objTransactions.AcctSeed__Amount__c*(-1)));
                                                                            objWrapper.accPeriodId = objTransactions.AcctSeed__Accounting_Period__c;
                                                                            objWrapper.accPeriodName = objTransactions.AcctSeed__Accounting_Period__r.Name;
                                                                            objWrapper.projectId = objTransactions.AcctSeed__Project__c	;
                                                                            objWrapper.projectName = objTransactions.AcctSeed__Project__r.Name;
                                                                            objWrapper.matterId = objTransactions.AcctSeed__Project__r.matter__c;
                                                                            objWrapper.matterName = objTransactions.AcctSeed__Project__r.Matter__r.litify_pm__Display_Name__c;
                                                                            objWrapper.resolutionId= objTransactions.AcctSeed__Journal_Entry_Line__r.AcctSeed__Journal_Entry__r.Resolution__c;
                                                                            objWrapper.resolutionName = objTransactions.AcctSeed__Journal_Entry_Line__r.AcctSeed__Journal_Entry__r.Resolution__r.Name;
                                                                            objWrapper.resolutionDate = objTransactions.Resolution_Date__c;
                                                                            
                                                                            listWrapper.add(objWrapper);
                                                                        }
                        objFeeWrapper.listTransaction = listWrapper;
                        
                    }
                    
                }
                
            }
            
        }
        catch(Exception ex){}
        return objFeeWrapper;
    }
    
    public class myFeesWrapper{
        @auraEnabled public  list<transactionWrapper>listTransaction{get;set;}
        @auraEnabled public string attorney{get;set;}
        @auraEnabled public string attorneyName{get;set;}
        
    }
    public class transactionWrapper{
        @auraEnabled  public date transDate{get;set;}
        @auraEnabled public string accPeriodId{get;set;}
        @auraEnabled public string accPeriodName{get;set;}
        @auraEnabled public string projectId{get;set;}
        @auraEnabled public string projectName{get;set;}
        @auraEnabled public string matterId{get;set;}
        @auraEnabled public string matterName{get;set;}
        @auraEnabled public string resolutionId{get;set;}
        @auraEnabled public string resolutionName{get;set;}
        @auraEnabled public decimal amount{get;set;}
        @auraEnabled public date resolutionDate{get;set;}
        @auraEnabled public string attorney{get;set;}
        
    }
}