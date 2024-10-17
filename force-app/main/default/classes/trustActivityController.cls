/*
Author     : Cmentor/ Sampath Suranji
Description: trustActivityController for trust Actvity lightning component
Date       : 07/20/2020
*/
public class trustActivityController {
    
    @auraEnabled
    public static matterTrustActivityWrapper getMatterWrapper(string matterId){
        matterTrustActivityWrapper objWrapper = new matterTrustActivityWrapper();
        try{
            if(!string.isEmpty(matterId)){
                List<litify_pm__Matter__c>listMatter =[select id,name,litify_pm__Display_Name__c from litify_pm__Matter__c where id=:matterId];
                if(listMatter.size()>0){
                    objWrapper.objMatter =listMatter[0];
                    string trustLiabilityGL = label.Trust_Ledger_Debit_GL_Account;
                    decimal balance=0;
                    
                    if(!string.isEmpty(trustLiabilityGL)){
                        List<AcctSeed__GL_Account__c>listGl = [select id,name from AcctSeed__GL_Account__c where name=:trustLiabilityGL.trim()];
                        List<matterTrustActDetailWrapper>listActvityDetails = new list<matterTrustActDetailWrapper>();
                        
                        if(listGl.size()>0){
                            
                            List<AcctSeed__Transaction__c> transList = [select id,name,AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__c,AcctSeed__Date__c,AcctSeed__Account__c,AcctSeed__Account__r.Name,AcctSeed__Amount__c from AcctSeed__Transaction__c where AcctSeed__Project__r.name =:listMatter[0].name and AcctSeed__GL_Account__c=:listGl[0].id];
                            system.debug('===transList==='+transList);
                            if(transList.size() > 0) {
                                set<Id> payableIdsSet = new set<Id>();
                                map<Id,AcctSeed__AP_Disbursement__c> payableWithCDDateMap = new map<Id,AcctSeed__AP_Disbursement__c>();
                                
                                for(AcctSeed__Transaction__c objTransactions : transList){
                                    if(objTransactions.AcctSeed__Account_Payable_Line__c != null) {
                                        payableIdsSet.add(objTransactions.AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__c);
                                    }                                    
                                }
                                system.debug('===payableIdsSet==='+payableIdsSet);
                                if(payableIdsSet.size() > 0) {
                                    for(AcctSeed__AP_Disbursement__c apDis : [select id, Name,AcctSeed__Account_Payable__c,AcctSeed__Cash_Disbursement__r.AcctSeed__Disbursement_Date__c,AcctSeed__Cash_Disbursement__r.AcctSeed__Check_Number__c from AcctSeed__AP_Disbursement__c where AcctSeed__Account_Payable__c IN: payableIdsSet]) {
                                        if(apDis.AcctSeed__Cash_Disbursement__r.AcctSeed__Disbursement_Date__c != null) {
                                            payableWithCDDateMap.put(apDis.AcctSeed__Account_Payable__c,apDis);
                                        }                                        
                                    }
                                }
                                system.debug('===payableWithCDDateMap==='+payableWithCDDateMap);
                                for(AcctSeed__Transaction__c objTransactions : transList){
                                    matterTrustActDetailWrapper objDetailWrp = new matterTrustActDetailWrapper();
                                    objDetailWrp.id = objTransactions.id;
                                    objDetailWrp.transactioName = objTransactions.Name;
                                    if(objTransactions.AcctSeed__Account_Payable_Line__c != null && !payableWithCDDateMap.isEmpty() && payableWithCDDateMap.containsKey(objTransactions.AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__c)) {
                                         objDetailWrp.cdTransactioDate = payableWithCDDateMap.get(objTransactions.AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__c).AcctSeed__Cash_Disbursement__r.AcctSeed__Disbursement_Date__c;
                                        objDetailWrp.checkNo = payableWithCDDateMap.get(objTransactions.AcctSeed__Account_Payable_Line__r.AcctSeed__Account_Payable__c).AcctSeed__Cash_Disbursement__r.AcctSeed__Check_Number__c;
                                    } 
                                    objDetailWrp.transactioDate = objTransactions.AcctSeed__Date__c;
                                    objDetailWrp.amount = (objTransactions.AcctSeed__Amount__c==null?0:(objTransactions.AcctSeed__Amount__c*(-1)));
                                    objDetailWrp.accountId = objTransactions.AcctSeed__Account__c;
                                    objDetailWrp.accountName = objTransactions.AcctSeed__Account__r.Name;
                                    
                                    listActvityDetails.add(objDetailWrp);
                                    balance = balance+ objDetailWrp.amount;
                                }
                            }
                            
                            for(ATO_Trust_History__c objATOTrustHistory : [select id,Reference__c,Name,Date__c,Amount__c,Party__c,Party__r.Name,Trust_Code__c,Type__c from ATO_Trust_History__c where Matter__c=:matterId]){
                                matterTrustActDetailWrapper objDetailWrp = new matterTrustActDetailWrapper();
                                objDetailWrp.id = objATOTrustHistory.id;
                                objDetailWrp.transactioName = objATOTrustHistory.Name;
                                objDetailWrp.transactioDate = objATOTrustHistory.Date__c;
                                
                                if(objATOTrustHistory.Type__c=='Receipt'){
                                    system.debug(math.abs(objATOTrustHistory.Amount__c));
                                    objDetailWrp.amount = objATOTrustHistory.Amount__c==null?0: math.abs(objATOTrustHistory.Amount__c);
                                }
                                else if(objATOTrustHistory.Type__c=='Payment'){
                                    objDetailWrp.amount = objATOTrustHistory.Amount__c==null?0:math.abs(objATOTrustHistory.Amount__c)*(-1);
                                }
                                
                                // objDetailWrp.amount = objATOTrustHistory.Amount__c==null?0:objATOTrustHistory.Amount__c;
                                objDetailWrp.accountId = objATOTrustHistory.Party__c;
                                objDetailWrp.accountName = objATOTrustHistory.Party__r.Name;
                                objDetailWrp.trustCode = objATOTrustHistory.Trust_Code__c;
                                objDetailWrp.reference = objATOTrustHistory.Reference__c;
                                listActvityDetails.add(objDetailWrp);
                                
                                // balance = balance+ (objATOTrustHistory.Amount__c==null?0:objATOTrustHistory.Amount__c);
                            }
                            
                            objWrapper.trustActDetailList = listActvityDetails;
                            objWrapper.balanceAmount = balance;
                            
                        }
                        
                    }
                    
                }
            }
        }
        catch(Exception ex){}
        
        return objWrapper;
    }
}