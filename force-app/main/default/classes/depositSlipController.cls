/*
Description : depositSlipController
Author      : Cmentor/ Sampath Suranji
Date		: 07/21/2020
*/
public without sharing class depositSlipController {
    
    @AuraEnabled
    public static depositSlipWrapper getDepositDetails(string trustDepositId){
        depositSlipWrapper objDepositWrapper = new depositSlipWrapper();
        integer noOfCR=0; decimal CRTotal=0;
        try{
            if(!string.isempty(trustDepositId)){
                
                List<Trust_Deposit__c>listTrustDeposit =[select id,Name,Date__c,Number_of_Items__c,Status__c,Total__c from Trust_Deposit__c where id=: trustDepositId ];
                if(listTrustDeposit.size()>0){
                    objDepositWrapper.objTrustDeposit = listTrustDeposit[0];
                    
                    aggregateresult arTrustCR = [select sum(Amount__c)totalAmount from Trust_Cash_Receipt__c where Trust_Deposit__c=:listTrustDeposit[0].id ];
                    list<depositSlipCRWrapper> listTrustCRWrapper = new list<depositSlipCRWrapper>();
                    
                    for(Trust_Cash_Receipt__c objTrustCR :[select id,name,Trust_Deposit__c,Deposit_Type__c,Reference__c,Account__c,Account__r.Name,Amount__c,Matter__c,Matter__r.Name from Trust_Cash_Receipt__c where Trust_Deposit__c=:listTrustDeposit[0].id]){
                        depositSlipCRWrapper objCRWrapper = new depositSlipCRWrapper();//(objTrustCR.id,objTrustCR.name,objTrustCR.Matter__c,objTrustCR.Matter__r.Name,objTrustCR.Account__c,objTrustCR.Account__r.Name,objTrustCR.Reference__c,objTrustCR.Amount__c);
                        objCRWrapper.id = objTrustCR.id;
                        objCRWrapper.name = objTrustCR.name;
                        objCRWrapper.matterId = objTrustCR.Matter__c;
                        objCRWrapper.matterName = objTrustCR.Matter__r.Name;
                        objCRWrapper.payorId = objTrustCR.Account__c;
                        objCRWrapper.payorName = objTrustCR.Account__r.Name;
                        objCRWrapper.amount =objTrustCR.Amount__c;
                        objCRWrapper.reference =objTrustCR.Reference__c;
                        objCRWrapper.depositType =objTrustCR.Deposit_Type__c;
                        listTrustCRWrapper.add(objCRWrapper);
                        noOfCR++;
                    }
                    
                    objDepositWrapper.listTrustCRWrapper = listTrustCRWrapper;
                    CRTotal =  (decimal) arTrustCR.get('totalAmount')==null? 0 : ((decimal) arTrustCR.get('totalAmount')).setScale(2) ;
                    
                }
                else{
                    objDepositWrapper.objTrustDeposit = new Trust_Deposit__c(name='',Date__c=system.Date.today());
                    objDepositWrapper.listTrustCRWrapper = new  list<depositSlipCRWrapper>();
                    
                }
            }
            else{
                objDepositWrapper.objTrustDeposit = new Trust_Deposit__c(name='',Date__c=system.Date.today());
                objDepositWrapper.listTrustCRWrapper = new  list<depositSlipCRWrapper>();               
                
            }
            objDepositWrapper.objEmptyTrustCR = new Trust_Cash_Receipt__c();
            objDepositWrapper.noOfCR= noOfCR;
            objDepositWrapper.CRTotal =CRTotal;
            
        }
        catch(Exception ex){}
        return objDepositWrapper;
    }
    
    @AuraEnabled
    public static map<string,string> saveDepositDetails(depositSlipWrapper objDepositWrapper){
        map<string,string> msgMap = new map<string,string>();
        set<string>receivingCRIds = new set<string>();
        list<Trust_Cash_Receipt__c>listTrustCRToDelete = new  list<Trust_Cash_Receipt__c>();
        savepoint sp;
        try{
            
            if(objDepositWrapper!=null &&  objDepositWrapper.objTrustDeposit!=null){
                upsert  objDepositWrapper.objTrustDeposit;
                
                map<id,Trust_Cash_Receipt__c>  mapOldTrustCR=new  map<id,Trust_Cash_Receipt__c>([select id from Trust_Cash_Receipt__c where Trust_Deposit__c = :objDepositWrapper.objTrustDeposit.id ]);
                
                List<Trust_Cash_Receipt__c>listTrustCRToUpsert = new List<Trust_Cash_Receipt__c>();                
                
                if( objDepositWrapper.listTrustCRWrapper.size()>0){
                    for(depositSlipCRWrapper objCRWrpDetail:objDepositWrapper.listTrustCRWrapper){                        
                        Trust_Cash_Receipt__c objTrustCR = new Trust_Cash_Receipt__c();
                        objTrustCR.Id = objCRWrpDetail.Id;
                        objTrustCR.Amount__c = objCRWrpDetail.amount;
                        objTrustCR.Account__c = objCRWrpDetail.payorId;
                        if(objCRWrpDetail.Id==null){
                            objTrustCR.Matter__c = objCRWrpDetail.matterId;
                            objTrustCR.Trust_Deposit__c = objDepositWrapper.objTrustDeposit.id;
                        }
                        else{
                            receivingCRIds.add(objCRWrpDetail.Id);                        
                            
                        }
                        objTrustCR.Reference__c = objCRWrpDetail.reference; 
                        objTrustCR.Deposit_Type__c = objCRWrpDetail.depositType; 
                        listTrustCRToUpsert.add(objTrustCR);
                        
                        
                    }
                    //get deleted CR from the front end 
                    for(id crId:mapOldTrustCR.keyset()){
                        if(!receivingCRIds.contains(crId)){
                            listTrustCRToDelete.add(mapOldTrustCR.get(crId));
                        }
                    }
                    
                    sp = database.setSavepoint();
                    if(listTrustCRToDelete.size()>0){
                        delete listTrustCRToDelete;
                    }
                    
                    if(listTrustCRToUpsert.size()>0){
                        upsert listTrustCRToUpsert;
                    }
                    
                    
                }
                else{
                    // when all CR are deleted from the fron end
                    List<Trust_Cash_Receipt__c>listTrustCR =[select id,name,Trust_Deposit__c,Reference__c,Account__c,Account__r.Name,Amount__c,Matter__c,Matter__r.Name from Trust_Cash_Receipt__c where Trust_Deposit__c=:objDepositWrapper.objTrustDeposit.id];
                    if(listTrustCR.size()>0){
                        delete listTrustCR;
                    } 
                }
                msgMap.put('success','true');
            }
            
        }
        catch(Exception ex){
            if(sp!=null){
                database.rollback(sp);
            }
            msgMap.put('error','true');
        }
        return msgMap;
    }
    
    @AuraEnabled
    public static map<string,string> saveAndSubmitDepositDetails(depositSlipWrapper objDepositWrapper){
        map<string,string> msgMap = new map<string,string>();
        map<string,string> mapGlAccounts = new  map<string,string>(); 
        map<string,list<AcctSeed__Journal_Entry_Line__c>> mapMatterWithJELine = new  map<string,list<AcctSeed__Journal_Entry_Line__c>>(); 
        map<string,AcctSeed__Project_Task__c> mapMatterWithProjectTask = new  map<string,AcctSeed__Project_Task__c>();
        map<string,string>mapMatterWithProject = new  map<string,string>();
        list<AcctSeed__Journal_Entry_Line__c>listJELinesToInsert = new  list<AcctSeed__Journal_Entry_Line__c>();
        list<AcctSeed__Journal_Entry__c>listJEToInsert = new  list<AcctSeed__Journal_Entry__c>();
        AcctSeed__Journal_Entry__c  objJE = new AcctSeed__Journal_Entry__c();        
        list<Trust_Cash_Receipt__c>listTrustCRToDelete = new  list<Trust_Cash_Receipt__c>();
        set<string>receivingCRIds = new set<string>();
        set<string>matterIds = new set<string>();
        id trustLedgerId,accPeriodId;
        savepoint sp;
        
        try{
            
            if(objDepositWrapper!=null &&  objDepositWrapper.objTrustDeposit!=null){
                
                List<Trust_GL_Accounts__c> listTrustAccSetting = [select Trust_Cash_GL_Account__c,Trust_Liability_GL_Account__c from Trust_GL_Accounts__c];
                if(listTrustAccSetting.size()==0){
                    msgMap.put('invalidCustomSettings','true');
                    return msgMap;
                }
                for(AcctSeed__GL_Account__c  glAcc :[select id,name from AcctSeed__GL_Account__c where name in( :listTrustAccSetting[0].Trust_Cash_GL_Account__c, :listTrustAccSetting[0].Trust_Liability_GL_Account__c)]){
                    if(glAcc.name == listTrustAccSetting[0].Trust_Cash_GL_Account__c){
                        mapGlAccounts.put('cashGLAcc',glAcc.Id);
                    }
                    else if(glAcc.name == listTrustAccSetting[0].Trust_Liability_GL_Account__c){
                        mapGlAccounts.put('liabilityGLAcc',glAcc.Id);
                    }
                }
                if(mapGlAccounts.keyset().size()!=2){
                    msgMap.put('invalidCustomSettings','true');
                    return msgMap;
                }
                list<AcctSeed__Ledger__c>listTrustLedger = [select id from AcctSeed__Ledger__c where name='TRUST'];
                if(listTrustLedger.size()>0){
                    trustLedgerId = listTrustLedger[0].id;
                }
                else{
                    msgMap.put('invalidLedger','true');
                    return msgMap;
                }
                Date trustDepositDate = objDepositWrapper.objTrustDeposit.Date__c;
                if(trustDepositDate!=null){
                    Datetime dt = Datetime.newInstance(trustDepositDate.year(),trustDepositDate.month(),trustDepositDate.day());
                    string accPeriod = dt.format('yyyy-MM');
                    List<AcctSeed__Accounting_Period__c> listAccPeriod = [select id from AcctSeed__Accounting_Period__c where name=:accPeriod and AcctSeed__Status__c='Open'];
                    if(listAccPeriod.size()>0){
                        accPeriodId = listAccPeriod[0].Id;
                    }
                    else{
                        msgMap.put('invalidAccPeriod','true');
                        return msgMap;
                    }
                    
                }
                
                sp = database.setsavepoint();
                objDepositWrapper.objTrustDeposit.Status__c ='Closed';
               
                
                map<id,Trust_Cash_Receipt__c>  mapOldTrustCR=new  map<id,Trust_Cash_Receipt__c>([select id from Trust_Cash_Receipt__c where Trust_Deposit__c = :objDepositWrapper.objTrustDeposit.id ]);
                
                List<Trust_Cash_Receipt__c>listTrustCRToUpsert = new List<Trust_Cash_Receipt__c>();
               
                if( objDepositWrapper.listTrustCRWrapper.size()>0){
                    for(depositSlipCRWrapper objCRWrpDetail:objDepositWrapper.listTrustCRWrapper){                        
                        
                        Trust_Cash_Receipt__c objTrustCR = new Trust_Cash_Receipt__c();
                        objTrustCR.Id = objCRWrpDetail.Id;
                        objTrustCR.Amount__c = objCRWrpDetail.amount;
                        objTrustCR.Account__c = objCRWrpDetail.payorId;
                        if(objCRWrpDetail.id==null){
                            objTrustCR.Matter__c = objCRWrpDetail.matterId;
                            objTrustCR.Trust_Deposit__c = objDepositWrapper.objTrustDeposit.id;
                        }
                        else{
                            receivingCRIds.add(objCRWrpDetail.id);
                        }
                        matterIds.add(objCRWrpDetail.matterId);   
                        objTrustCR.Reference__c = objCRWrpDetail.reference; 
                        objTrustCR.Deposit_Type__c = objCRWrpDetail.depositType; 
                        
                        listTrustCRToUpsert.add(objTrustCR);
                        
                         //multiple Credit JE lines for each CR
                        AcctSeed__Journal_Entry_Line__c objCreditJELine= new AcctSeed__Journal_Entry_Line__c();
                        objCreditJELine.AcctSeed__Credit__c = objCRWrpDetail.amount;
                        //objCreditJELine.AcctSeed__Date__c= system.Date.today();
                        objCreditJELine.AcctSeed__Date__c= objDepositWrapper.objTrustDeposit.Date__c;
                        objCreditJELine.AcctSeed__GL_Account__c= mapGlAccounts.get('liabilityGLAcc');
                        objCreditJELine.AcctSeed__Account__c = objCRWrpDetail.payorId;
                        objCreditJELine.AcctSeed__Reference__c = objCRWrpDetail.reference;
                        listJELinesToInsert.add(objCreditJELine);                        
                        
                        
                        if(!mapMatterWithJELine.containskey(objCRWrpDetail.matterId)){
                            mapMatterWithJELine.put(objCRWrpDetail.matterId,new list<AcctSeed__Journal_Entry_Line__c>{objCreditJELine});
                        }
                        else{
                            List<AcctSeed__Journal_Entry_Line__c>exist = mapMatterWithJELine.get(objCRWrpDetail.matterId);
                            exist.add(objCreditJELine);
                            mapMatterWithJELine.put(objCRWrpDetail.matterId,exist );
                        }
                    }
                    
                    AcctSeed__Journal_Entry_Line__c objdebitJELine= new AcctSeed__Journal_Entry_Line__c();                        
                    objdebitJELine.AcctSeed__Debit__c = objDepositWrapper.objTrustDeposit.Total__c;
                    //objdebitJELine.AcctSeed__Date__c= system.Date.today();
                    objdebitJELine.AcctSeed__Date__c= objDepositWrapper.objTrustDeposit.Date__c;
                    objdebitJELine.AcctSeed__GL_Account__c= mapGlAccounts.get('cashGLAcc');
                    // objdebitJELine.AcctSeed__Account__c = objCRWrpDetail.payorId;
                    // objdebitJELine.AcctSeed__Reference__c = objCRWrpDetail.reference;
                    listJELinesToInsert.add(objdebitJELine);
                    
                    if(matterIds.size()>0){
                        map<id,litify_pm__Matter__c>mapMatters= new map<id,litify_pm__Matter__c>([select id,name from litify_pm__Matter__c where id in:matterIds]);
                        list<AcctSeed__Journal_Entry_Line__c>listJELines = new List<AcctSeed__Journal_Entry_Line__c>();
                        
                        for(AcctSeed__Project__c objProject:[select id,Matter__c,(select id,Name,AcctSeed__Sort_Order__c,AcctSeed__Labor_GL_Account__c from  AcctSeed__Project_Tasks__r where name='Default Task') from AcctSeed__Project__c where Matter__c in:matterIds]){
                            mapMatterWithProject.put(objProject.Matter__c,objProject.id);
                            for(AcctSeed__Project_Task__c pTask :objProject.AcctSeed__Project_Tasks__r ){
                                if(!mapMatterWithProjectTask.containskey(objProject.Matter__c)) {
                                    mapMatterWithProjectTask.put(objProject.Matter__c,pTask);
                                }
                                
                            }
                        }
                        for(string matterId:matterIds){
                            if(!mapMatterWithProjectTask.containskey(matterId)){
                                msgMap.put('invalidProjectTask','true');
                                msgMap.put('invalidProjectName',mapMatters.get(matterId).Name);
                                return msgMap;
                            }
                        }
                        
                    }
                    
                     upsert  objDepositWrapper.objTrustDeposit;                
                
                    
                    //Create the JE
                    objJE.Name ='Trust Deposit /'+objDepositWrapper.objTrustDeposit.name+ '/ '+ system.now().format('MM-dd-yyyy');
                    System.debug('JE name '+objJE.Name);
                    objJE.AcctSeed__Journal_Date__c = objDepositWrapper.objTrustDeposit.Date__c;
                    objJE.AcctSeed__Accounting_Period__c= accPeriodId;
                    objJE.Trust_Deposit__c = objDepositWrapper.objTrustDeposit.Id;
                    objJE.AcctSeed__Ledger__c = trustLedgerId;
                    if(system.Test.isRunningTest()){
                        List<AcctSeed__Ledger__c>listLedger = [select id from AcctSeed__Ledger__c where name='FIRM'];
                        if(listLedger.size()>0){
                            objJE.AcctSeed__Ledger__c = listLedger[0].id;
                        }
                        
                    }
                    listJEToInsert.add(objJE);
                    if(listJEToInsert.size() > 0) {
                        Insert listJEToInsert;
                    }
                   
                    
                    //get deleted CR from the front end 
                    for(id crId:mapOldTrustCR.keyset()){
                        if(!receivingCRIds.contains(crId)){
                            listTrustCRToDelete.add(mapOldTrustCR.get(crId));
                        }
                    }
                    
                    if(listTrustCRToDelete.size()>0){
                        delete listTrustCRToDelete;
                    }
                    if(listTrustCRToUpsert.size()>0){
                        for(Trust_Cash_Receipt__c trustCR:listTrustCRToUpsert){
                            if(trustCR.id==null){
                                 trustCR.Trust_Deposit__c = objDepositWrapper.objTrustDeposit.id;
                            }
                           
                        }
                        upsert listTrustCRToUpsert;
                    }
                    if(listJELinesToInsert.size()>0){
                        if(matterIds.size()>0){
                            list<AcctSeed__Journal_Entry_Line__c>listJELines = new List<AcctSeed__Journal_Entry_Line__c>();
                            
                            system.debug(mapMatterWithProjectTask);
                            system.debug(mapMatterWithProjectTask.values().size());
                            
                            for(string matterId:mapMatterWithJELine.keyset()){
                                for(AcctSeed__Journal_Entry_Line__c jeLine:mapMatterWithJELine.get(matterId)){
                                    jeLine.AcctSeed__Journal_Entry__c =objJE.Id;
                                    jeLine.AcctSeed__Project__c = mapMatterWithProject.get(matterId);
                                    if(mapMatterWithProjectTask.containskey(matterId)){
                                        jeLine.AcctSeed__Project_Task__c = mapMatterWithProjectTask.get(matterId).id;
                                    }
                                    listJELines.add(jeLine);
                                }
                            }
                            objdebitJELine.AcctSeed__Journal_Entry__c =objJE.Id;
                            listJELines.add(objdebitJELine);
                            insert listJELines;
                            
                            
                        }
                        
                    }
                }
                postJE(listJEToInsert);
                msgMap.put('success','true');
            }
            
        }
        catch(Exception ex){
            system.debug('========='+ex.getLineNumber()+'==========='+ex.getMessage());
            if(sp!=null){
                database.rollback(sp);
            }
            msgMap.put('error','true');
        }
        return msgMap;
    }
    
    public static void postJE(List<AcctSeed__Journal_Entry__c> listJE) {
        if(listJE.size() > 0) {
            AcctSeed.PostResult[] postResults = AcctSeed.JournalEntryPostService.postJournalEntries(listJE);
        }
    }
    
}