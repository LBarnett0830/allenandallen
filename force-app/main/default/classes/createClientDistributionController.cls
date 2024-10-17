public class createClientDistributionController {
    
    
    @AuraEnabled
    public static map<string,boolean> checkValidation(string resolutionId){
        map<string,boolean>  mapMsg = new  map<string,boolean>();
        try{
            List<litify_pm__Resolution__c> listResolution =[select id,name,Status__c,Client_Distribution__c,Alternate_Payee__c,
                                                            litify_pm__Matter__r.litify_pm__Client__c
                                                            from litify_pm__Resolution__c where id=:resolutionId];
            if(listResolution.size()>0){
                
                if(listResolution[0].Status__c =='Closed'){
                    mapMsg.put('isClosed',true);
                    return mapMsg; 
                }
                else if(listResolution[0].Status__c !='Approved'){
                    mapMsg.put('invalidStatus',true);
                    return mapMsg; 
                }
                else if(listResolution[0].Client_Distribution__c<=0){
                    mapMsg.put('invalidClintDistAmt',true);
                    return mapMsg; 
                }
                
                string payee='';
                if(listResolution[0].Alternate_Payee__c!=null){
                    payee = listResolution[0].Alternate_Payee__c;
                    
                }
                else{
                    payee = listResolution[0].litify_pm__Matter__r.litify_pm__Client__c;
                }
                list<AcctSeed__Account_Payable__c> listAP= [select id from AcctSeed__Account_Payable__c 
                                                            where Resolution__c=:resolutionId and AcctSeed__Vendor__c=:payee];
                
                if(listAP.size()>0){
                    mapMsg.put('clientDstAPAlreadyCreated',true);
                    return mapMsg;                    
                    
                }
                
                
                
            }
            
            
            
        }
        catch(Exception ex){}
        return mapMsg;
    }
    
    @AuraEnabled
    public static map<string,string> createClientDistAP(string resolutionId, boolean confirmTrustBalance){
        
        map<string,string>  mapMsg = new  map<string,string>();
        savepoint sp;
        
        try{
            List<litify_pm__Resolution__c> listResolution =[select id,name,Status__c,Client_Distribution__c,litify_pm__Resolution_Date__c,
                                                            litify_pm__Matter__c,litify_pm__Matter__r.name,litify_pm__Matter__r.litify_pm__Client__c,
                                                            Alternate_Payee__c,litify_pm__Matter__r.litify_pm__Principal_Attorney__r.alias,
                                                            litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c,
                                                            litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c,Total_Allocated__c
                                                            from litify_pm__Resolution__c where id=:resolutionId];
            if(listResolution.size()>0){
                
                litify_pm__Resolution__c objResolution = new litify_pm__Resolution__c();
                objResolution = listResolution[0];
                
                if(objResolution.Status__c =='Closed'){
                    mapMsg.put('isClosed','true');
                    return mapMsg; 
                }
                else if(objResolution.Status__c !='Approved'){
                    mapMsg.put('invalidStatus','true');
                    return mapMsg; 
                }
                else if(objResolution.Client_Distribution__c<=0){
                    mapMsg.put('invalidClintDistAmt','true');
                    return mapMsg; 
                }
                
                
                string payee='';
                if(listResolution[0].Alternate_Payee__c!=null){
                    payee = listResolution[0].Alternate_Payee__c;
                    
                }
                else{
                    payee = listResolution[0].litify_pm__Matter__r.litify_pm__Client__c;
                }
                list<AcctSeed__Account_Payable__c> listAP= [select id from AcctSeed__Account_Payable__c 
                                                            where Resolution__c=:resolutionId and AcctSeed__Vendor__c=:payee];
                
                
                if(listAP.size()>0){
                    mapMsg.put('clientDstAPAlreadyCreated','true');
                    return mapMsg;                    
                    
                }
                
                if(objResolution.Alternate_Payee__c ==null && objResolution.litify_pm__Matter__r.litify_pm__Client__c ==null ){
                    mapMsg.put('clientIsRequired','true');
                    return mapMsg; 
                }
                
                if(objResolution.litify_pm__Resolution_Date__c ==null ){
                    mapMsg.put('resDateIsNull','true');
                    return mapMsg; 
                }
                
                list<AcctSeed__Ledger__c>listLedger = [select id from AcctSeed__Ledger__c where name='TRUST'];
                
                if(!confirmTrustBalance){
                    
                    
                    list<AcctSeed__GL_Account__c>  listLiabilityGL= [select id,name from AcctSeed__GL_Account__c where name =:label.Trust_Ledger_Debit_GL_Account];
                    if(listLiabilityGL.size()>0){
                        
                        aggregateResult ARTransactions = [select sum(AcctSeed__Amount__c)totalAmount from AcctSeed__Transaction__c where AcctSeed__Project__r.Matter__c=:objResolution.litify_pm__Matter__c and AcctSeed__GL_Account__c=:listLiabilityGL[0].id];
                        decimal availableBalance =  ARTransactions.get('totalAmount')==null?0:((decimal)ARTransactions.get('totalAmount')).setScale(2);  
                        system.debug('availableBalance '+availableBalance);
                        aggregateResult ARTotalAP = [select sum(AcctSeed__Amount__c)totalAmount from AcctSeed__Account_Payable_Line__c  where AcctSeed__Project__r.Matter__c=:objResolution.litify_pm__Matter__c and AcctSeed__Expense_GL_Account__c=:listLiabilityGL[0].id 
                                                     and AcctSeed__Account_Payable__r.AcctSeed__Ledger__c=:listLedger[0].id and AcctSeed__Account_Payable__r.AcctSeed__Status__c<>'Posted'];
                        decimal totalAP =  ARTotalAP.get('totalAmount')==null?0:((decimal)ARTotalAP.get('totalAmount')).setScale(2);  
                        system.debug('totalAP '+totalAP);
                        //system.debug('objResolution.Total_Allocated__c '+objResolution.Total_Allocated__c);
                        decimal trustBalance = availableBalance*(-1)- totalAP;
                        system.debug('trustBalance '+trustBalance);
                        if(trustBalance<objResolution.Client_Distribution__c){
                            mapMsg.put('insufficientTrustBalance','true');
                            return mapMsg;
                        }
                    }
                }
                
                
                string attorneyAccVariable='',serviceLineAccVariable='',locationAccVariable='',accPeriodId='';
                map<string,AcctSeed__Project_Task__c> mapMatterWithProjectTask = new map<string,AcctSeed__Project_Task__c>();
                map<string,AcctSeed__Project__c> mapMatterWithProject = new map<string,AcctSeed__Project__c>();
                map<string,string> mapGlAccWithDepartmentAccVar = new map<string,string>();
                map<string,string> mapGlAccounts= new map<string,string>();
                map<string,string> mapGlAccWithDepartment= new map<string,string>();
                
                
                date resDate = objResolution.litify_pm__Resolution_Date__c;
                string accPeriodName =  Datetime.newInstance( resDate.year(),resDate.month(),resDate.day()).format('yyyy-MM');
                List<AcctSeed__Accounting_Period__c>listAccPeriod = [select id from AcctSeed__Accounting_Period__c where name=:accPeriodName];
                if(listAccPeriod.size()>0){
                    accPeriodId  = listAccPeriod[0].id;
                    
                }
                
                
                for(AcctSeed__GL_Account__c  glAcc :[select id,name from AcctSeed__GL_Account__c where name =:label.Trust_Ledger_Debit_GL_Account]){
                    mapGlAccounts.put('settlementLiabilityAcc',glAcc.Id);
                    
                }  
                
                list<string>listDepartmentNames = mapGlAccWithDepartment.values();
                
                for(AcctSeed__Accounting_Variable__c variable :[select id,name,AcctSeed__Type__c from AcctSeed__Accounting_Variable__c
                                                                where (AcctSeed__Type__c ='GL Account Variable 4' OR AcctSeed__Type__c ='GL Account Variable 3' OR 
                                                                       AcctSeed__Type__c ='GL Account Variable 2' OR AcctSeed__Type__c ='GL Account Variable 1')  AND 
                                                                ( name in(:objResolution.litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c,
                                                                          :objResolution.litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c,
                                                                          :objResolution.litify_pm__Matter__r.litify_pm__Principal_Attorney__r.alias) or 
                                                                 name in:listDepartmentNames)])
                {
                    if(variable.AcctSeed__Type__c=='GL Account Variable 1'){
                        serviceLineAccVariable = variable.id;
                    }
                    else if(variable.AcctSeed__Type__c=='GL Account Variable 2'){
                        locationAccVariable = variable.id;
                    }
                    else if(variable.AcctSeed__Type__c=='GL Account Variable 3'){
                        mapGlAccWithDepartmentAccVar.put(variable.name,variable.Id);
                    }
                    else if(variable.AcctSeed__Type__c=='GL Account Variable 4'){
                        attorneyAccVariable = variable.id;
                    }
                    
                }
                
                List<AcctSeed__Project__c> listProjects = [select id,Matter__c,(select id,Name,AcctSeed__Sort_Order__c,AcctSeed__Labor_GL_Account__c from  AcctSeed__Project_Tasks__r 
                                                                                where name='Default Task') from  AcctSeed__Project__c 
                                                           where Matter__c=:objResolution.litify_pm__Matter__c];
                if(listProjects.size()>0){
                    for(AcctSeed__Project__c objProject:listProjects){
                        if(!mapMatterWithProject.containskey(objProject.Matter__c)) {
                            mapMatterWithProject.put(objProject.Matter__c,objProject);
                        }                            
                        for(AcctSeed__Project_Task__c pTask :objProject.AcctSeed__Project_Tasks__r ){
                            if(!mapMatterWithProjectTask.containskey(objProject.Matter__c)) {
                                mapMatterWithProjectTask.put(objProject.Matter__c,pTask);
                            }
                            
                        }
                    }
                    
                    
                }  
                
                
                
                
                sp= database.setSavepoint();
                
                if(objResolution.Client_Distribution__c!=null && objResolution.Client_Distribution__c>0){
                    AcctSeed__Account_Payable__c objClientDistributionPayable = new AcctSeed__Account_Payable__c();
                    objClientDistributionPayable.AcctSeed__Status__c='Approved';
                    objClientDistributionPayable.AcctSeed__Date__c = objResolution.litify_pm__Resolution_Date__c; 
                    objClientDistributionPayable.AcctSeed__Accounting_Period__c = accPeriodId;
                    objClientDistributionPayable.AcctSeed__Payee_Reference__c = 'Client Distribution/'+objResolution.Name+'/'+objResolution.litify_pm__Matter__r.name;
                    
                    
                    if(listLedger.size()>0){
                        objClientDistributionPayable.AcctSeed__Ledger__c =  listLedger[0].id;
                    }        
                    objClientDistributionPayable.Resolution__c  = objResolution.Id;   
                    if(objResolution.Alternate_Payee__c!=null){
                        objClientDistributionPayable.AcctSeed__Vendor__c =objResolution.Alternate_Payee__c;
                        objClientDistributionPayable.Alternate_Payee__c = objResolution.Alternate_Payee__c;
                        
                        
                    }else{
                        objClientDistributionPayable.AcctSeed__Vendor__c = objResolution.litify_pm__Matter__r.litify_pm__Client__c;
                    }
                    
                    objClientDistributionPayable.Expense_Type__c ='Trust';
                    objClientDistributionPayable.Origin__c='Trust';
                    system.debug(objClientDistributionPayable);
                    
                    insert objClientDistributionPayable;
                    
                    AcctSeed__Account_Payable_Line__c objClientDistributionPayableLine = new AcctSeed__Account_Payable_Line__c();
                    objClientDistributionPayableLine.AcctSeed__Account_Payable__c = objClientDistributionPayable.id;
                    objClientDistributionPayableLine.AcctSeed__Amount__c = objResolution.Client_Distribution__c;
                    objClientDistributionPayableLine.AcctSeed__Quantity__c =1;
                    objClientDistributionPayableLine.Matter__c = objResolution.litify_pm__Matter__c;
                    objClientDistributionPayableLine.AcctSeed__Expense_GL_Account__c=  mapGlAccounts.get('settlementLiabilityAcc');           
                    objClientDistributionPayableLine.AcctSeed__Date__c = objResolution.litify_pm__Resolution_Date__c;
                    
                    if(!string.isEmpty(serviceLineAccVariable)){
                        objClientDistributionPayableLine.AcctSeed__GL_Account_Variable_1__c = serviceLineAccVariable;
                    }
                    
                    if(!string.isEmpty(locationAccVariable)){
                        objClientDistributionPayableLine.AcctSeed__GL_Account_Variable_2__c = locationAccVariable;
                    }
                    if(!string.isEmpty(attorneyAccVariable)){
                        objClientDistributionPayableLine.AcctSeed__GL_Account_Variable_4__c = attorneyAccVariable;
                    }
                    
                    if(mapGlAccWithDepartment.containskey('settlementLiabilityAcc')){
                        if(mapGlAccWithDepartmentAccVar.containskey(mapGlAccWithDepartment.get('settlementLiabilityAcc'))){
                            objClientDistributionPayableLine.AcctSeed__GL_Account_Variable_3__c = mapGlAccWithDepartmentAccVar.get(mapGlAccWithDepartment.get('settlementLiabilityAcc'));
                        }
                    }
                    if(mapMatterWithProject.containsKey(objResolution.litify_pm__Matter__c)){
                        objClientDistributionPayableLine.AcctSeed__Project__c = mapMatterWithProject.get(objResolution.litify_pm__Matter__c).id;
                        if(mapMatterWithProjectTask.containsKey(objResolution.litify_pm__Matter__c)){
                            objClientDistributionPayableLine.AcctSeed__Project_Task__c = mapMatterWithProjectTask.get(objResolution.litify_pm__Matter__c).id;
                        }
                        
                    }
                    
                    insert objClientDistributionPayableLine;
                    mapMsg.put('success','true');
                    // database.rollback(sp);
                }
                
                
            }
            
            
            
        }
        catch(Exception ex){
            mapMsg.put('error','true');
            if(sp!=null){
                database.rollback(sp);
                
            }
        }
        return mapMsg;
    }
    
    
}