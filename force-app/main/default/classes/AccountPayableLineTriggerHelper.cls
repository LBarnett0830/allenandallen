/*
Updated by Cmentor/Sampath Suranji
Date : 06/12/2020, 06/25/2020
Description : Fix delete issue
*/
public class AccountPayableLineTriggerHelper {
    public static List<AcctSeed__Account_Payable_Line__c> newList {get; set;}
    public static List<AcctSeed__Account_Payable_Line__c> oldList {get; set;}
    public static Map<Id, AcctSeed__Account_Payable_Line__c> newMap {get; set;}
    public static Map<Id, AcctSeed__Account_Payable_Line__c> oldMap {get; set;}
    
    public static void afterInsertOperation(){
        try{
            map<string,decimal> mapProjectWithTrustBalance = new  map<string,decimal>();
            map<string,decimal> mapProjectWithAPTotal = new  map<string,decimal>();
            map<id,AcctSeed__Account_Payable__c>mapPayable = new map<id,AcctSeed__Account_Payable__c>();
            set<id>setProjectIds = new set<id>();
            set<id>setPayableIds = new set<id>();
            list<AcctSeed__GL_Account__c>  listLiabilityGL= [select id,name from AcctSeed__GL_Account__c where name =:label.Trust_Ledger_Debit_GL_Account];
            list<AcctSeed__Ledger__c>listLedger = [select id from AcctSeed__Ledger__c where name='TRUST'];
            
            for(AcctSeed__Account_Payable_Line__c objPayableLine:newList){
                setProjectIds.add(objPayableLine.AcctSeed__Project__c);
                setPayableIds.add(objPayableLine.AcctSeed__Account_Payable__c);
            }
            if(setProjectIds.size()>0){
                set<id>setPyableIdsToProceed = new set<id>();
                if(setPayableIds.size()>0){
                     mapPayable = new map<id,AcctSeed__Account_Payable__c> ([select id,AcctSeed__Type__c,AcctSeed__Ledger__c,Resolution__c from AcctSeed__Account_Payable__c where id in:setPayableIds ]);
                   
                    
                    for(aggregateResult ARTransactions: [select AcctSeed__Project__c project, sum(AcctSeed__Amount__c)totalAmount from AcctSeed__Transaction__c where AcctSeed__Project__c in:setProjectIds and AcctSeed__GL_Account__c=:listLiabilityGL[0].id group by AcctSeed__Project__c]){
                        decimal trustBalance = ARTransactions.get('totalAmount')==null?0:((decimal)ARTransactions.get('totalAmount')).setScale(2);
                        mapProjectWithTrustBalance.put(string.valueof(ARTransactions.get('project')), trustBalance);
                    }
                    
                    for(aggregateResult ARTotalAP : [select AcctSeed__Project__c project,sum(AcctSeed__Amount__c)totalAmount from AcctSeed__Account_Payable_Line__c  where AcctSeed__Project__c in:setProjectIds and AcctSeed__Expense_GL_Account__c=:listLiabilityGL[0].id 
                                                     and AcctSeed__Account_Payable__r.AcctSeed__Ledger__c=:listLedger[0].id and AcctSeed__Account_Payable__r.AcctSeed__Status__c<>'Posted' group by AcctSeed__Project__c]){
                                                         decimal totalAP =  ARTotalAP.get('totalAmount')==null?0:((decimal)ARTotalAP.get('totalAmount')).setScale(2);    
                                                         mapProjectWithAPTotal.put(string.valueof(ARTotalAP.get('project')), totalAP);
                                                     }
                    //check validation
                    for(AcctSeed__Account_Payable_Line__c objPayableLine:newList){
                        if(mapPayable.keyset().contains(objPayableLine.AcctSeed__Account_Payable__c)){
                            if( mapPayable.get(objPayableLine.AcctSeed__Account_Payable__c).Resolution__c==null && mapPayable.get(objPayableLine.AcctSeed__Account_Payable__c).AcctSeed__Type__c=='Invoice' && mapPayable.get(objPayableLine.AcctSeed__Account_Payable__c).AcctSeed__Ledger__c==listLedger[0].id){
                                
                                if(mapProjectWithTrustBalance.containskey(objPayableLine.AcctSeed__Project__c) && mapProjectWithAPTotal.containskey(objPayableLine.AcctSeed__Project__c)){
                                    //System.debug('trustBalance= '+mapProjectWithTrustBalance.get(objPayableLine.AcctSeed__Project__c));
                                    //System.debug('APTotal= '+mapProjectWithAPTotal.get(objPayableLine.AcctSeed__Project__c));
                                    decimal availableBalance = mapProjectWithTrustBalance.get(objPayableLine.AcctSeed__Project__c)*(-1) - mapProjectWithAPTotal.get(objPayableLine.AcctSeed__Project__c);
                                    //system.debug('availableBalance '+availableBalance);
                                    if(availableBalance<0 ){
                                        objPayableLine.addError('Insufficient Trust Balance');
                                    }
                                }else  if(!mapProjectWithTrustBalance.containskey(objPayableLine.AcctSeed__Project__c)){
                                    objPayableLine.addError('Insufficient Trust Balance');
                                }
                            }
                        }
                        
                    }
                    
                    
                }
                
            }
            List<AcctSeed__Account_Payable_Line__c> payableLineRec = [Select Id,AcctSeed__Project__c,AcctSeed__Project__r.Matter__c,AcctSeed__Amount__c,AcctSeed__Account_Payable__r.Origin__c,
                                                                      AcctSeed__Internal_Comment__c,Expense_Type__c,AcctSeed__Account_Payable__r.Expense_Type__c,AcctSeed__Account_Payable__r.AcctSeed__Vendor__c, AcctSeed__Account_Payable__r.AcctSeed__Date__c,
                                                                      AcctSeed__Account_Payable__r.AcctSeed__Payee_Reference__c FROM AcctSeed__Account_Payable_Line__c
                                                                      WHERE Id IN: newList];
            List<litify_pm__Expense__c> expenseRecToInsert = new List<litify_pm__Expense__c>();
            Set<Id> payableIds = new Set<Id>();
            for(AcctSeed__Account_Payable_Line__c accPayRec : payableLineRec){
                system.debug('accPayRec.AcctSeed__Project__r.Matter__c '+accPayRec.AcctSeed__Project__r.Matter__c);
                if(accPayRec.AcctSeed__Account_Payable__r.Origin__c == 'AP' && accPayRec.AcctSeed__Project__c!=null && accPayRec.AcctSeed__Project__r.Matter__c!=null){
                    expenseRecToInsert.add(createExpenseRecord(accPayRec));
                    payableIds.add(accPayRec.Id);
                }
                
            }
            if(expenseRecToInsert.size() > 0){
                set<id>failedPayables= new set<id>();
                //insert expenseRecToInsert;
                Database.SaveResult [] srList= Database.insert(expenseRecToInsert,false);
                for(Integer i=0;i<srList.size();i++){
                    if(!srList[i].isSuccess()){
                        failedPayables.add(expenseRecToInsert[i].Payable_Line__c);
                    }
                }
                //if expenses creation failed, then delete the payable line also
                if(failedPayables.size()>0){
                    list<AcctSeed__Account_Payable_Line__c>listLineToDelete = [select id from AcctSeed__Account_Payable_Line__c where id in:failedPayables];
                    if(listLineToDelete.size()>0){
                        delete listLineToDelete;
                    }
                }
                updateExpenseOnPayable(payableIds);
                
            }
        }
        catch(Exception ex){
            
        }
        
    }
    
    // @future
    public static void updateExpenseOnPayable(Set<id> Ids){
        List<AcctSeed__Account_Payable_Line__c> payableLineRec = [Select Id, Expense__c,
                                                                  (Select Id,litify_pm__Matter__c,Stage__c from Expenses__r) FROM AcctSeed__Account_Payable_Line__c
                                                                  WHERE Id IN: Ids];
        for(AcctSeed__Account_Payable_Line__c accPayableRec  : payableLineRec){
            if(accPayableRec.Expenses__r.size() > 0){
                accPayableRec.Expense__c = accPayableRec.Expenses__r[0].Id;
            }
        }
        
        if(payableLineRec.size() > 0){
            update payableLineRec;
        }
    }
    
    public static void afterUpdateOperation(){
        try{
            map<string,decimal> mapProjectWithTrustBalance = new  map<string,decimal>();
            map<string,decimal> mapProjectWithAPTotal = new  map<string,decimal>();
            map<id,AcctSeed__Account_Payable__c>mapPayable = new map<id,AcctSeed__Account_Payable__c>();
            set<id>setProjectIds = new set<id>();
            set<id>setPayableIds = new set<id>();
            list<AcctSeed__GL_Account__c>  listLiabilityGL= [select id,name from AcctSeed__GL_Account__c where name =:label.Trust_Ledger_Debit_GL_Account];
            list<AcctSeed__Ledger__c>listLedger = [select id from AcctSeed__Ledger__c where name='TRUST'];
            
            for(AcctSeed__Account_Payable_Line__c objPayableLine:newList){                
                setProjectIds.add(objPayableLine.AcctSeed__Project__c);
                setPayableIds.add(objPayableLine.AcctSeed__Account_Payable__c);
            }
            if(setProjectIds.size()>0){
                set<id>setPyableIdsToProceed = new set<id>();
                if(setPayableIds.size()>0){
                    mapPayable = new map<id,AcctSeed__Account_Payable__c> ([select id,AcctSeed__Type__c,AcctSeed__Ledger__c,Resolution__c from AcctSeed__Account_Payable__c where id in:setPayableIds and Resolution__c=null]);
                   
                    
                    for(aggregateResult ARTransactions: [select AcctSeed__Project__c project, sum(AcctSeed__Amount__c)totalAmount from AcctSeed__Transaction__c where AcctSeed__Project__c in:setProjectIds and AcctSeed__GL_Account__c=:listLiabilityGL[0].id group by AcctSeed__Project__c]){
                        decimal trustBalance = ARTransactions.get('totalAmount')==null?0:((decimal)ARTransactions.get('totalAmount')).setScale(2);
                        mapProjectWithTrustBalance.put(string.valueof(ARTransactions.get('project')), trustBalance);
                    }
                    
                    for(aggregateResult ARTotalAP : [select AcctSeed__Project__c project,sum(AcctSeed__Amount__c)totalAmount from AcctSeed__Account_Payable_Line__c  where AcctSeed__Project__c in:setProjectIds and AcctSeed__Expense_GL_Account__c=:listLiabilityGL[0].id 
                                                     and AcctSeed__Account_Payable__r.AcctSeed__Ledger__c=:listLedger[0].id and AcctSeed__Account_Payable__r.AcctSeed__Status__c<>'Posted' group by AcctSeed__Project__c]){
                                                         decimal totalAP =  ARTotalAP.get('totalAmount')==null?0:((decimal)ARTotalAP.get('totalAmount')).setScale(2);    
                                                         mapProjectWithAPTotal.put(string.valueof(ARTotalAP.get('project')), totalAP);
                                                     }
                    //check validation
                    for(AcctSeed__Account_Payable_Line__c objPayableLine:newList){
                        if(mapPayable.keyset().contains(objPayableLine.AcctSeed__Account_Payable__c)){
                            if(mapPayable.get(objPayableLine.AcctSeed__Account_Payable__c).Resolution__c==null && mapPayable.get(objPayableLine.AcctSeed__Account_Payable__c).AcctSeed__Type__c=='Invoice' && mapPayable.get(objPayableLine.AcctSeed__Account_Payable__c).AcctSeed__Ledger__c==listLedger[0].id){
                                
                                if(mapProjectWithTrustBalance.containskey(objPayableLine.AcctSeed__Project__c) && mapProjectWithAPTotal.containskey(objPayableLine.AcctSeed__Project__c)){
                                    //System.debug('trustBalance= '+mapProjectWithTrustBalance.get(objPayableLine.AcctSeed__Project__c));
                                    //System.debug('APTotal= '+mapProjectWithAPTotal.get(objPayableLine.AcctSeed__Project__c));
                                    decimal availableBalance = mapProjectWithTrustBalance.get(objPayableLine.AcctSeed__Project__c)*(-1) - mapProjectWithAPTotal.get(objPayableLine.AcctSeed__Project__c);
                                    //system.debug('availableBalance '+availableBalance);
                                    if(availableBalance<0  ){
                                        objPayableLine.addError('Insufficient Trust Balance');
                                    }
                                }else  if(!mapProjectWithTrustBalance.containskey(objPayableLine.AcctSeed__Project__c)){
                                    objPayableLine.addError('Insufficient Trust Balance');
                                }
                            }
                            
                        }
                        
                        
                    }
                    
                    
                }
                
            }
            
            List<AcctSeed__Account_Payable_Line__c> payableLineRec = [Select Id,AcctSeed__Amount__c,AcctSeed__Project__r.Matter__c,AcctSeed__Account_Payable__r.AcctSeed__Status__c, 
                                                                      AcctSeed__Account_Payable__r.Expense_Type__c,AcctSeed__Internal_Comment__c, Expense_Type__c , AcctSeed__Account_Payable__r.AcctSeed__Vendor__c, AcctSeed__Account_Payable__r.AcctSeed__Date__c,
                                                                      AcctSeed__Account_Payable__r.AcctSeed__Payee_Reference__c,AcctSeed__Account_Payable__r.Origin__c,
                                                                      (Select Id,litify_pm__Matter__c,Stage__c,litify_pm__ExpenseType2__c,litify_pm__Amount__c from Expenses__r) FROM AcctSeed__Account_Payable_Line__c
                                                                      WHERE Id IN: newList];
            
            List<litify_pm__Expense__c> expenseRecToUpsert = new List<litify_pm__Expense__c>();
            List<litify_pm__Expense__c> expenseRecToDelete = new List<litify_pm__Expense__c>();
            map<id,AcctSeed__Account_Payable_Line__c>mapPayableLineToUpdate = new map<id,AcctSeed__Account_Payable_Line__c>();
            
            for(AcctSeed__Account_Payable_Line__c accPayableLineRec  : payableLineRec){
                if(accPayableLineRec.AcctSeed__Account_Payable__r.AcctSeed__Status__c == 'Posted')
                    continue;
                else if(accPayableLineRec.AcctSeed__Account_Payable__r.Origin__c == 'AP' && accPayableLineRec.AcctSeed__Project__c != null && 
                        oldMap.get(accPayableLineRec.Id).AcctSeed__Project__c == null){
                            expenseRecToUpsert.add(createExpenseRecord(accPayableLineRec));
                            mapPayableLineToUpdate.put(accPayableLineRec.Id,accPayableLineRec);
                        }
                
                
                else if(accPayableLineRec.AcctSeed__Account_Payable__r.Origin__c == 'AP' && accPayableLineRec.AcctSeed__Project__c == null && 
                        oldMap.get(accPayableLineRec.Id).AcctSeed__Project__c != null)
                    expenseRecToDelete.addAll(accPayableLineRec.Expenses__r);
                
                else if((accPayableLineRec.AcctSeed__Account_Payable__r.Origin__c == 'AP' )&& ((accPayableLineRec.AcctSeed__Project__c != null &&  oldMap.get(accPayableLineRec.Id).AcctSeed__Project__c != null) ||  (accPayableLineRec.AcctSeed__Amount__c != oldMap.get(accPayableLineRec.Id).AcctSeed__Amount__c) ||  (accPayableLineRec.Expense_Type__c != oldMap.get(accPayableLineRec.Id).Expense_Type__c)  )){
                    for( litify_pm__Expense__c expeRec : accPayableLineRec.Expenses__r){
                        expeRec.litify_pm__Matter__c = accPayableLineRec.AcctSeed__Project__r != null ? accPayableLineRec.AcctSeed__Project__r.Matter__c : null;
                        expeRec.litify_pm__Amount__c = accPayableLineRec.AcctSeed__Amount__c;                    
                        expeRec.litify_pm__ExpenseType2__c = accPayableLineRec.Expense_Type__c;
                        if(accPayableLineRec.AcctSeed__Account_Payable__r.Expense_Type__c=='Matter' && accPayableLineRec.AcctSeed__Internal_Comment__c!=null){
                            expeRec.litify_pm__Expense_Description__c = accPayableLineRec.AcctSeed__Internal_Comment__c;
                        }
                        expenseRecToUpsert.add(expeRec);
                    }
                }
                
                
                if(accPayableLineRec.AcctSeed__Account_Payable__r.Origin__c == 'Litify' && ( (accPayableLineRec.AcctSeed__Project__c != null &&  oldMap.get(accPayableLineRec.Id).AcctSeed__Project__c != null)  )){
                    //system.debug('passed');
                    for( litify_pm__Expense__c expeRec : accPayableLineRec.Expenses__r){
                        //system.debug('expeRec '+expeRec);
                        if(expeRec.Stage__c == 'Approved'){
                            expeRec.litify_pm__Matter__c = accPayableLineRec.AcctSeed__Project__r != null ?  accPayableLineRec.AcctSeed__Project__r.Matter__c : null;
                            expeRec.litify_pm__Amount__c = accPayableLineRec.AcctSeed__Amount__c;
                            expeRec.litify_pm__ExpenseType2__c = accPayableLineRec.Expense_Type__c;
                            if(accPayableLineRec.AcctSeed__Account_Payable__r.Expense_Type__c=='Matter' && accPayableLineRec.AcctSeed__Internal_Comment__c!=null){
                                expeRec.litify_pm__Expense_Description__c = accPayableLineRec.AcctSeed__Internal_Comment__c;
                            }
                            expenseRecToUpsert.add(expeRec);
                        }
                    }
                }
                
            }
            
            if(expenseRecToUpsert.size() > 0){
                upsert expenseRecToUpsert;
                set<id>createdExpenses =new set<id>();
                database.UpsertResult []srList= database.upsert(expenseRecToUpsert);
                for(database.UpsertResult sr:srList){
                    system.debug('sr '+sr);
                    createdExpenses.add(sr.getId());
                    
                }
                //set the Expense lookup to the parent ExpLine record
                if(createdExpenses.size()>0){
                    for(litify_pm__Expense__c expCreated : [select id,Payable_Line__c from litify_pm__Expense__c where id in: createdExpenses]){
                        if(mapPayableLineToUpdate.containsKey(expCreated.Payable_Line__c)){
                            mapPayableLineToUpdate.get(expCreated.Payable_Line__c).Expense__c = expCreated.Id;
                        }
                    }
                    update mapPayableLineToUpdate.values();
                }
            }
            if(expenseRecToDelete.size() > 0){
                /*expenseTriggerHandler.hasFiredFromPayableTrigger=true;*/
                delete expenseRecToDelete;
            }
        }
        catch(Exception ex){}
        
        
    }
    public static void beforeDeleteOperation(){
        Set<Id> paybaleIdSet = new Set<Id>();
        Set<Id> paybaleLineIdSet = new Set<Id>();
        for(AcctSeed__Account_Payable_Line__c accPayableLineRec  : oldList){
            paybaleIdSet.add(accPayableLineRec.AcctSeed__Account_Payable__c);
            paybaleLineIdSet.add(accPayableLineRec.Id);
        }
        map<id,AcctSeed__Account_Payable_Line__c>mapPayableLine = new map<id,AcctSeed__Account_Payable_Line__c>([select id,Expense__r.Billing_Status__c from AcctSeed__Account_Payable_Line__c where id in:paybaleLineIdSet]);
        
        Map<Id,AcctSeed__Account_Payable__c> PayableIdToRecMap = new Map<Id,AcctSeed__Account_Payable__c>([Select Id, Origin__c from AcctSeed__Account_Payable__c where Id IN : paybaleIdSet]);
        for(AcctSeed__Account_Payable_Line__c accPayableLineRec  : oldList){
            if(accPayableLineRec.AcctSeed__Account_Payable__c != null  && PayableIdToRecMap.containsKey(accPayableLineRec.AcctSeed__Account_Payable__c)
               && PayableIdToRecMap.get(accPayableLineRec.AcctSeed__Account_Payable__c).Origin__c == 'Litify' || mapPayableLine.get(accPayableLineRec.Id).Expense__r.Billing_Status__c=='Billed' )
                
                accPayableLineRec.adderror('Related Expense record must be cancelled.');
        }
    }
    public static void afterDeleteOperation(){
        Set<Id> paybaleIdSet = new Set<Id>();
        for(AcctSeed__Account_Payable_Line__c accPayableRec  : oldList){
            paybaleIdSet.add(accPayableRec.AcctSeed__Account_Payable__c);
        }
        List<litify_pm__Expense__c> expenseRecordToDelete = new List<litify_pm__Expense__c>();
        Map<Id,AcctSeed__Account_Payable__c> PayableIdToRecMap = new Map<Id,AcctSeed__Account_Payable__c>([Select Id, Origin__c from AcctSeed__Account_Payable__c where Id IN : paybaleIdSet]);
        for(AcctSeed__Account_Payable_Line__c accPayableRec  : oldList){
            if(accPayableRec.AcctSeed__Account_Payable__c != null  && PayableIdToRecMap.containsKey(accPayableRec.AcctSeed__Account_Payable__c)
               && PayableIdToRecMap.get(accPayableRec.AcctSeed__Account_Payable__c).Origin__c == 'AP' )
                if(accPayableRec.Expense__c != null){
                    litify_pm__Expense__c expRec = new litify_pm__Expense__c();
                    expRec.Id = accPayableRec.Expense__c;
                    expenseRecordToDelete.add(expRec);
                }
        }
        if(expenseRecordToDelete.size() > 0){
            delete expenseRecordToDelete;
        }
        
    }
    
    public static litify_pm__Expense__c createExpenseRecord(AcctSeed__Account_Payable_Line__c  payableLineRec){
        litify_pm__Expense__c expRec = new litify_pm__Expense__c();
        expRec.litify_pm__Matter__c =  payableLineRec.AcctSeed__Project__c != null ? payableLineRec.AcctSeed__Project__r.Matter__c : null;
        expRec.Origin__c = 'AP';
        expRec.Stage__c = 'Approved';
        expRec.Vendor__c = payableLineRec.AcctSeed__Account_Payable__r.AcctSeed__Vendor__c != null ? 
            payableLineRec.AcctSeed__Account_Payable__r.AcctSeed__Vendor__c : '';
        expRec.litify_pm__Date__c = payableLineRec.AcctSeed__Account_Payable__r.AcctSeed__Date__c != null ?
            payableLineRec.AcctSeed__Account_Payable__r.AcctSeed__Date__c : null;
        expRec.litify_pm__lit_Invoice__c = payableLineRec.AcctSeed__Account_Payable__r.AcctSeed__Payee_Reference__c != null ?
            payableLineRec.AcctSeed__Account_Payable__r.AcctSeed__Payee_Reference__c : '';
        expRec.Payable_Line__c = payableLineRec.Id;
        expRec.litify_pm__ExpenseType2__c = payableLineRec.Expense_Type__c;
        expRec.litify_pm__Amount__c = payableLineRec.AcctSeed__Amount__c;
        if(payableLineRec.AcctSeed__Account_Payable__r.Expense_Type__c=='Matter' && payableLineRec.AcctSeed__Internal_Comment__c!=null){
            expRec.litify_pm__Expense_Description__c = payableLineRec.AcctSeed__Internal_Comment__c;
        }
        return expRec;
    }
}