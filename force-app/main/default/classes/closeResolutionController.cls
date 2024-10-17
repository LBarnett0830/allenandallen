/*
Author: Cmentor/Sampath Suranji
Date  :06/09/2020
Description : closeResolutionController for Resolution Close custom button

Updated By: Cmentor/ Sampath Suranji
Date      :08/18/2020ƒ
Description : create payables for each Damages and Liens

Updated By: Cmentor/ Sampath Suranji
Date      : 10/12/2020
Description : Set vendor from AlternatePayee for payables for each Damages and Liens

Updated By : Cmentor/ Sampath Suranji
Date       : 12/16/2020
Description : check trust balance before close, AAA-115

Updated by:Impak/Dave Williams
Date: 12/22/2021
Description:  Close negative dist Resolution if Collection/Discharge Resolution Type

Updated by: Sampath Suranji
Date: 10/31/2022
Description:  validate and prevent creation of the Client Distribution AP
*/
public without sharing class closeResolutionController {
    public static   map<string,string> mapMsg {get;set;}
    public static   map<string,list<litify_pm__Expense__c>> mapTCodeWithExpenses {get;set;}
    public static   map<string,decimal> mapTCodeWithTotalExpAmount {get;set;}
    public static   map<string,AcctSeed__Project_Task__c> mapMatterWithProjectTask {get;set;}
    public static   map<string,AcctSeed__Project__c> mapMatterWithProject {get;set;}
    public static   map<string,string> mapGlAccounts {get;set;}
    public static   map<string,string> mapGlAccWithDepartment {get;set;}
    public static   map<string,string> mapGlAccWithDepartmentAccVar {get;set;}
    public static   map<string,string> mapGlAccById {get;set;}
    public static  list<AcctSeed__Journal_Entry_Line__c>listJELinesToInsert {get;set;}
    public static  list<AcctSeed__Journal_Entry__c> listJE{get;set;}
    public static  AcctSeed__Journal_Entry__c objJE{get;set;}
    public static  List<AcctSeed__Account_Payable__c>listPayablesToInsert{get;set;}
    public static  List<AcctSeed__Account_Payable_Line__c>listPayableLinesToInsert{get;set;}
    public static  litify_pm__Resolution__c objResolution{get;set;}
    public static  string locationAccVariable{get;set;}
    public static  string serviceLineAccVariable{get;set;}
    public static  string matterAccVariable{get;set;}
    public static  string attorneyAccVariable{get;set;}
    public static  string departmentAccVariable{get;set;}
    public static  string ACCGLAccountId {get;set;}
    public static  string accPeriodId {get;set;}
    
    
    @AuraEnabled
    public static  map<string,boolean> checkValidation(string resolutionId){
        map<string,boolean> mapMsg = new map<string,boolean>();
        try{
            
            set<string>listAccVariables1= new set<string>();
            set<string>listAccVariables2= new set<string>();
            set<string>listAccVariables3= new set<string>();
            set<string>listAccVariables4= new set<string>();
            
            list<litify_pm__Resolution__c>listResolution =[select id,Status__c,litify_pm__Resolution_Date__c,litify_pm__Matter__c,litify_pm__Matter__r.litify_pm__Principal_Attorney__c,
                                                           litify_pm__Matter__r.Claims_User__c,litify_pm__Matter__r.litify_pm__Client__c,litify_pm__Settlement_Verdict_Amount__c,Total_Allocated__c
                                                           ,Fee_Income__c ,Alternate_Payee__c,Client_Distribution__c ,Firm_Distribution__c,Firm_Distribution_After_Referral_Fees__c,
                                                           Third_Party_Distributions__c,Absorbed_Open_Case_Exp__c ,Total_Shares__c,litify_pm__Matter__r.litify_pm__Primary_Intake__c ,
                                                           litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c,litify_pm__Matter__r.litify_pm__Case_Type__c,
                                                           litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c,litify_pm__Resolution_Type__c 
                                                           from litify_pm__Resolution__c where id =:resolutionId];
            litify_pm__Resolution__c objResolution=listResolution[0];
            
            list<AcctSeed__Ledger__c>listLedger = [select id from AcctSeed__Ledger__c where name='TRUST'];
            
            List<Attorney_Split__c>listAttorneySplit = [select id,Amount__c,Share__c,Attorney__c,Attorney__r.Alias from Attorney_Split__c where Resolution__c=:resolutionId];
            system.debug('listAttorneySplit '+listAttorneySplit[0].Attorney__r.Alias);
            List<Firm_Ledger_COS_Fee_Revenue_GL_Account__c> listCOSGLCustomSetting=[select Fee_Revenue_GL_Account__c,Hard_Cost_Advanced__c,Soft_Cost_Reimbursed__c,Trust_Receivable_GL_Account__c
                                                                                    from Firm_Ledger_COS_Fee_Revenue_GL_Account__c];
            /*
            if((objResolution.litify_pm__Resolution_Type__c != 'Turn Down' && objResolution.litify_pm__Resolution_Type__c != 'Discharge' )
                    && (objResolution.Client_Distribution__c<0 || objResolution.Firm_Distribution__c<0 || objResolution.Firm_Distribution_After_Referral_Fees__c<0 || objResolution.Third_Party_Distributions__c<0)){
                mapMsg.put('negativeDestributions',true);
                return mapMsg;
            }
            */
            if(objResolution.litify_pm__Matter__r.litify_pm__Principal_Attorney__c==null && objResolution.litify_pm__Matter__r.Claims_User__c==null ){
                mapMsg.put('attorneyNotFound',true);
                return mapMsg;
            }
            
            for(AcctSeed__Accounting_Variable__c accVariables:[select id,name,AcctSeed__Type__c from AcctSeed__Accounting_Variable__c]){
                
                if(accVariables.AcctSeed__Type__c=='GL Account Variable 4'){
                    //Attorney
                    listAccVariables4.add(accVariables.name);
                }
                else if(accVariables.AcctSeed__Type__c=='GL Account Variable 3'){
                    listAccVariables3.add(accVariables.name);
                }
                else if(accVariables.AcctSeed__Type__c=='GL Account Variable 2'){
                    //Location
                    listAccVariables2.add(accVariables.name);
                }
                else if(accVariables.AcctSeed__Type__c=='GL Account Variable 1'){
                    listAccVariables1.add(accVariables.name);
                }
            }
            
            /* if(!listAccVariables2.contains(objResolution.litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c)){
mapMsg.put('noGLForOriginatingOffice',true);
return mapMsg;
}*/
            
            if(!listAccVariables1.contains(objResolution.litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c)){
                mapMsg.put('noGLForServiceLine',true);
                return mapMsg;
            }
            decimal totalSplit=0;
            for(Attorney_Split__c objSplit:listAttorneySplit){
                if(!listAccVariables4.contains(objSplit.Attorney__r.alias)){
                    mapMsg.put('noGLForAttorney',true);
                    return mapMsg;
                }
                if(objSplit.Amount__c>0){
                    totalSplit= totalSplit+ objSplit.Amount__c;
                }else{
                    totalSplit= totalSplit+ (objResolution.Fee_Income__c==null?0:objResolution.Fee_Income__c)* objSplit.Share__c/100;
                }
            }
            if(totalSplit.setScale(2)!= objResolution.Fee_Income__c.setScale(2)){
                mapMsg.put('AttSplitNotTally',true);
                return mapMsg;
            }
            if(listCOSGLCustomSetting.size()==0){
                mapMsg.put('invalidCustomSettings',true);
                return mapMsg;
            }
            List<AcctSeed__Project__c> listProjects = [select id,Matter__c,(select id,Name,AcctSeed__Sort_Order__c,AcctSeed__Labor_GL_Account__c from  AcctSeed__Project_Tasks__r where name='Default Task') from  AcctSeed__Project__c where Matter__c=:objResolution.litify_pm__Matter__c];
            if(listProjects.size()==0 ){
                mapMsg.put('projectNotFound',true);
                return mapMsg;
            }
            else if(listProjects[0].AcctSeed__Project_Tasks__r==null || listProjects[0].AcctSeed__Project_Tasks__r.size()==0 ){
                mapMsg.put('projectTaskNotFound',true);
                return mapMsg;
            }
            
            
            List<litify_pm__Lien__c>listLienes = [select id,name,Payee_Party__c,Payee_Party__r.Name,litify_pm__lit_Amount_Due__c,Date_Issued__c from litify_pm__Lien__c where  Resolution__c=:objresolution.Id];
            List<litify_pm__Damage__c>listDamages = [select id,name,litify_pm__Provider__r.litify_pm__Party__c,litify_pm__Provider__r.litify_pm__Party__r.Name,litify_pm__Amount_Due__c,Due_Date__c from litify_pm__Damage__c where Resolution__c=:objresolution.Id];
            
            for(litify_pm__Damage__c objDmg:listDamages){
                if(objDmg.litify_pm__Provider__r.litify_pm__Party__c==null ){
                    mapMsg.put('missingPartyInDamage',true);
                    return mapMsg;
                }
            }
            for(litify_pm__Lien__c objLien:listLienes){
                if(objLien.Payee_Party__c==null ){
                    mapMsg.put('missingPartyInLien',true);
                    return mapMsg;
                }
            }
            if(objResolution.litify_pm__Resolution_Date__c==null){
                mapMsg.put('missingResolutionDate',true);
                return mapMsg;
            }else{
                date resDate = objResolution.litify_pm__Resolution_Date__c;
                string accPeriodName =  Datetime.newInstance( resDate.year(),resDate.month(),resDate.day()).format('yyyy-MM');
                List<AcctSeed__Accounting_Period__c>listAccPeriod = [select id from AcctSeed__Accounting_Period__c where name=:accPeriodName and AcctSeed__Status__c='Open'];
                if(listAccPeriod.size()==0){
                    mapMsg.put('missingAccPeriod',true);
                    return mapMsg;
                }
            }
            
            list<AcctSeed__GL_Account__c>  listLiabilityGL= [select id,name from AcctSeed__GL_Account__c where name =:label.Trust_Ledger_Debit_GL_Account];
            if(listLiabilityGL.size()==0){
                mapMsg.put('missingLiabilityGL',true);
                return mapMsg;
            }
            
            /*if(objResolution.Client_Distribution__c>0){
                string payee='';
                if(listResolution[0].Alternate_Payee__c!=null){
                    payee = listResolution[0].Alternate_Payee__c;
                    
                }
                else{
                    payee = listResolution[0].litify_pm__Matter__r.litify_pm__Client__c;
                }
                list<AcctSeed__Account_Payable__c> listAP= [select id from AcctSeed__Account_Payable__c 
                                                            where Resolution__c=:resolutionId and AcctSeed__Vendor__c=:payee];
                
                
                
                if(listAP.size()==0){
                    mapMsg.put('clientDstAPNotCreated',true);
                    return mapMsg;                    
                    
                }
            }*/
            
        }
        catch(Exception ex){}
        return mapMsg;
        
    }
    
    @AuraEnabled
    public static closeResolutionWrapper getResolutionDetails(string resolutionId){
        closeResolutionWrapper objWrapper= new closeResolutionWrapper();
        try{
            List<litify_pm__Resolution__c> listResolution =[select id,Name,litify_pm__Matter__c,litify_pm__Matter__r.litify_pm__Display_Name__c,litify_pm__Matter__r.Name,Total_Shares__c,
                                                            Alternate_Payee__c,Alternate_Payee_Reason__c,litify_pm__Resolution_Date__c,Effective_Contingency_Fee__c, Fee_Income__c,Absorbed_Open_Case_Exp__c, Firm_Distribution_After_Referral_Fees__c,Net_Fees__c, litify_pm__Contingency_Fee_Rate__c,Contingency_Fee__c,Fees_Written_Off__c,Referral_Fees__c, litify_pm__Total_Expenses__c,Total_Liens__c,litify_pm__Total_Damages__c,Soft_Costs__c,Hard_Costs__c,Voided_Soft_Costs__c,Voided_Hard_Costs__c,Status__c,litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c,litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c,litify_pm__Settlement_Verdict_Amount__c, Post_Settlement_Flat_Fee__c,(select id,name,Amount__c from Distributions__r) 
                                                            ,Escrow__c,AAAA_Fee_Rate__c ,litify_pm__Matter__r.OwnerId   ,Total_Credits__c,Total_Debits__c ,Total_Allocated__c ,Attorney_Referrals__c,Firm_Distribution__c,Third_Party_Distributions__c,Client_Distribution__c ,(select id from Attorney_Splits__r) from litify_pm__Resolution__c where id=:resolutionId];
            if(listResolution.size()>0){
                boolean resUpdated=false;
                objResolution = new litify_pm__Resolution__c();                
                objResolution = listResolution[0];
                
                
                decimal totalEscrowedDmgs=0, totalDmgs=0,  totalEscrowedLiens=0, totalLiens=0;
                for(litify_pm__Damage__c objDmg:[select id,litify_pm__Amount_Due__c,Escrow__c from litify_pm__Damage__c where Resolution__c=:objresolution.Id]){
                    
                    totalDmgs= totalDmgs + objDmg.litify_pm__Amount_Due__c;
                    if(objDmg.Escrow__c){
                        totalEscrowedDmgs= totalEscrowedDmgs + objDmg.litify_pm__Amount_Due__c;
                    }
                    
                }
                for(litify_pm__Lien__c objLien:[select id,litify_pm__lit_Amount_Due__c,Escrow__c from litify_pm__Lien__c where Resolution__c=:objresolution.Id]){
                    
                    totalLiens= totalLiens + objLien.litify_pm__lit_Amount_Due__c;
                    if(objLien.Escrow__c){
                        totalEscrowedLiens= totalEscrowedLiens + objLien.litify_pm__lit_Amount_Due__c;
                    }
                    
                }
                
                if(totalDmgs!=objResolution.litify_pm__Total_Damages__c){
                    objResolution.litify_pm__Total_Damages__c = totalDmgs;
                    resUpdated=true;
                }
                if(totalLiens!=objResolution.Total_Liens__c){
                    objResolution.Total_Liens__c = totalLiens;
                    resUpdated=true;
                }
                if(resUpdated){
                    update objResolution;
                    objResolution =[select id,name,litify_pm__Matter__c,litify_pm__Matter__r.name,litify_pm__Matter__r.litify_pm__Open_Date__c,litify_pm__Matter__r.OwnerId,litify_pm__Matter__r.litify_pm__Client__c,litify_pm__Total_Expenses__c,Alternate_Payee_Reason__c,
                                    litify_pm__Total_Damages__c,Total_Liens__c,litify_pm__Matter__r.litify_pm__Principal_Attorney__r.alias,Fee_Income__c, Absorbed_Open_Case_Exp__c, Voided_Soft_Costs__c,Voided_Hard_Costs__c ,Referral_Fees__c,Client_Distribution__c ,Hard_Costs__c,Net_Fees__c,Firm_Distribution_After_Referral_Fees__c ,Soft_Costs__c ,Post_Settlement_Flat_Fee__c 
                                    ,litify_pm__Resolution_Date__c,litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c,litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c
                                    from litify_pm__Resolution__c where id=:resolutionId][0];
                }
                mapGlAccWithDepartmentAccVar = new  map<string,string>();
                map<id,AcctSeed__Accounting_Variable__c>mapGLVariables=new map<id,AcctSeed__Accounting_Variable__c>([select id,name,AcctSeed__Type__c from AcctSeed__Accounting_Variable__c where (AcctSeed__Type__c ='GL Account Variable 3' OR AcctSeed__Type__c ='GL Account Variable 2' OR AcctSeed__Type__c ='GL Account Variable 1' OR AcctSeed__Type__c ='GL Account Variable 4') ]);
                List<User>listUser = [select id,name,alias,Email from user where id=:objResolution.litify_pm__Matter__r.OwnerId];
                
                if(objResolution.litify_pm__Matter__c!=null){
                    for(AcctSeed__Accounting_Variable__c variable :[select id,name,AcctSeed__Type__c from AcctSeed__Accounting_Variable__c where (AcctSeed__Type__c ='GL Account Variable 3' OR AcctSeed__Type__c ='GL Account Variable 2' OR AcctSeed__Type__c ='GL Account Variable 1')  AND name in(:objResolution.litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c,:objResolution.litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c,:objResolution.litify_pm__Matter__r.Name,:listUser[0].alias)]){
                        if(variable.AcctSeed__Type__c=='GL Account Variable 1'){
                            serviceLineAccVariable = variable.id;
                        }
                        else if(variable.AcctSeed__Type__c=='GL Account Variable 2'){
                            locationAccVariable = variable.id;
                        }
                        else if(variable.AcctSeed__Type__c=='GL Account Variable 3'){
                            matterACCVariable = variable.id;
                        }
                        else if(variable.AcctSeed__Type__c=='GL Account Variable 4'){
                            attorneyAccVariable = variable.id;
                        }
                        
                    }
                    
                }
                
                
                objWrapper.objResolution = listResolution[0];
                listJELinesToInsert = new list<AcctSeed__Journal_Entry_Line__c>();
                
                bindGLMap();
                mapMatterWithProjectTask = new  map<string,AcctSeed__Project_Task__c>();
                mapMatterWithProject = new  map<string,AcctSeed__Project__c>();
                //Get JE details to display in screen
                createGLLines(false);
                list< closeResolutionWrapper.JEWrapper> listJELineWrapper = new List< closeResolutionWrapper.JEWrapper>();
                for(AcctSeed__Journal_Entry_Line__c jeLine:listJELinesToInsert){
                    closeResolutionWrapper.JEWrapper objJEWrapper = new closeResolutionWrapper.JEWrapper();
                    objJEWrapper.credit=jeLine.AcctSeed__Credit__c;
                    objJEWrapper.debit=jeLine.AcctSeed__Debit__c;
                    objJEWrapper.GLName = mapGlAccById.get(jeLine.AcctSeed__GL_Account__c);
                    if(mapGLVariables.containskey(jeLine.AcctSeed__GL_Account_Variable_1__c)){
                        objJEWrapper.GLVariable1 = mapGLVariables.get(jeLine.AcctSeed__GL_Account_Variable_1__c).name;
                    }
                    if(mapGLVariables.containskey(jeLine.AcctSeed__GL_Account_Variable_2__c)){
                        objJEWrapper.GLVariable2 = mapGLVariables.get(jeLine.AcctSeed__GL_Account_Variable_2__c).name;
                    }
                    if(mapGLVariables.containskey(jeLine.AcctSeed__GL_Account_Variable_4__c)){
                        objJEWrapper.GLVariable4 = mapGLVariables.get(jeLine.AcctSeed__GL_Account_Variable_4__c).name;
                    }
                    
                    listJELineWrapper.add(objJEWrapper);
                }
                if(listJELineWrapper.size()>0){
                    objWrapper.listJELineWrapper = listJELineWrapper;
                }
                
                
                objWrapper.isAllDmgEscrowed =false;
                objWrapper.isAllLienEscrowed =false;
                if(objResolution.litify_pm__Total_Damages__c== totalEscrowedDmgs && totalEscrowedDmgs!=0){
                    objWrapper.isAllDmgEscrowed =true;
                }
                
                if(objResolution.Total_Liens__c== totalEscrowedLiens && totalEscrowedLiens!=0){
                    objWrapper.isAllLienEscrowed =true;
                }
                objWrapper.escrowedDmgs=totalEscrowedDmgs;
                objWrapper.escrowedLiens=totalEscrowedLiens;
            }
            system.debug(objWrapper);
        }
        catch(Exception ex){}
        return objWrapper;
    }
    
    @AuraEnabled
    public static map<string,string> closeResolution(string resolutionId,boolean confirmTrustBalance){
        mapMsg = new  map<string,string>();
        mapTCodeWithExpenses = new  map<string,list<litify_pm__Expense__c>>();
        mapTCodeWithTotalExpAmount = new  map<string,decimal>();
        mapMatterWithProjectTask = new  map<string,AcctSeed__Project_Task__c>();
        mapMatterWithProject = new  map<string,AcctSeed__Project__c>();
        mapGlAccWithDepartmentAccVar = new  map<string,string>();
        listJELinesToInsert = new list<AcctSeed__Journal_Entry_Line__c>();
        decimal totalExpenseAmount=0;
        savepoint sp;
        
        objResolution= new litify_pm__Resolution__c();
        
        try{
            List<litify_pm__Resolution__c> listResolution =[select id,name,litify_pm__Matter__c,litify_pm__Matter__r.name,litify_pm__Matter__r.litify_pm__Open_Date__c,litify_pm__Matter__r.OwnerId,litify_pm__Matter__r.litify_pm__Client__c,litify_pm__Total_Expenses__c,
                                                            Total_Allocated__c, Alternate_Payee__c,Alternate_Payee_Reason__c,litify_pm__Resolution_Date__c, litify_pm__Total_Damages__c,Total_Liens__c,litify_pm__Matter__r.litify_pm__Principal_Attorney__r.alias,Fee_Income__c, Absorbed_Open_Case_Exp__c, Voided_Soft_Costs__c,Voided_Hard_Costs__c ,Referral_Fees__c,Client_Distribution__c ,Hard_Costs__c,Net_Fees__c,Firm_Distribution_After_Referral_Fees__c ,Soft_Costs__c ,Post_Settlement_Flat_Fee__c 
                                                            ,litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c,litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c
                                                            from litify_pm__Resolution__c where id=:resolutionId];
            if(listResolution.size()>0){
                
                objResolution = listResolution[0];
                // system.debug('Client_Distribution__c = '+objResolution.Client_Distribution__c);
                List<User>listUser = [select id,name,alias,Email from user where id=:objResolution.litify_pm__Matter__r.OwnerId];
                
                bindGLMap();
                
                if(mapGlAccounts.keyset().size()<5){
                    mapMsg.put('invalidCustomSettings','true');
                    return mapMsg;
                }
                
                else{
                    if(!confirmTrustBalance){
                        list<AcctSeed__Ledger__c>listTrustLedger = [select id from AcctSeed__Ledger__c where name='TRUST'];
                        
                        list<AcctSeed__GL_Account__c>  listLiabilityGL= [select id,name from AcctSeed__GL_Account__c where name =:label.Trust_Ledger_Debit_GL_Account];
                        if(listLiabilityGL.size()>0){
                            
                            aggregateResult ARTransactions = [select sum(AcctSeed__Amount__c)totalAmount from AcctSeed__Transaction__c where AcctSeed__Project__r.Matter__c=:objResolution.litify_pm__Matter__c and AcctSeed__GL_Account__c=:listLiabilityGL[0].id];
                            decimal availableBalance =  ARTransactions.get('totalAmount')==null?0:((decimal)ARTransactions.get('totalAmount')).setScale(2);  
                            system.debug('availableBalance '+availableBalance);
                            aggregateResult ARTotalAP = [select sum(AcctSeed__Amount__c)totalAmount from AcctSeed__Account_Payable_Line__c  where AcctSeed__Project__r.Matter__c=:objResolution.litify_pm__Matter__c and AcctSeed__Expense_GL_Account__c=:listLiabilityGL[0].id 
                                                         and AcctSeed__Account_Payable__r.AcctSeed__Ledger__c=:listTrustLedger[0].id and AcctSeed__Account_Payable__r.AcctSeed__Status__c<>'Posted'];
                            decimal totalAP =  ARTotalAP.get('totalAmount')==null?0:((decimal)ARTotalAP.get('totalAmount')).setScale(2);  
                            system.debug('totalAP '+totalAP);
                            system.debug('objResolution.Total_Allocated__c '+objResolution.Total_Allocated__c);
                            decimal trustBalance = availableBalance*(-1)- totalAP;
                            system.debug('trustBalance '+trustBalance);
                            if(trustBalance<objResolution.Total_Allocated__c){
                                mapMsg.put('insufficientTrustBalance','true');
                                return mapMsg;
                            }
                        }
                    }
                    
                    List<litify_pm__Expense__c> listPrebilledExpenses = [select id,Billing_Status__c,Resolution__c,litify_pm__Amount__c ,Amount_after_Reductions__c
                                                                         from litify_pm__Expense__c  where  (Billing_Status__c='Pre-Billed' OR  Billing_Status__c='Billed')  and Resolution__c= :resolutionId  ];
                    
                    sp =Database.setSavepoint();                    
                    
                    
                    
                    if(listPrebilledExpenses.size()>0){
                        for(litify_pm__Expense__c objExp:listPrebilledExpenses){
                            objExp.Billing_Status__c='Billed';
                            objExp.Settlement_Date__c = system.today();
                            // objExp.litify_pm__Bill__c =objBilling.Id;
                            totalExpenseAmount = totalExpenseAmount+objExp.Amount_after_Reductions__c;//totalExpenseAmount+objExp.litify_pm__Amount__c;
                            
                        }
                        
                    }
                    List<AcctSeed__Project__c> listProjects = [select id,Matter__c,(select id,Name,AcctSeed__Sort_Order__c,AcctSeed__Labor_GL_Account__c from  AcctSeed__Project_Tasks__r where name='Default Task') from  AcctSeed__Project__c where Matter__c=:objResolution.litify_pm__Matter__c];
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
                    boolean doProceed=true;
                    
                    if(doProceed){
                        if(objResolution.litify_pm__Total_Expenses__c!=null && totalExpenseAmount.setScale(2)!=objResolution.litify_pm__Total_Expenses__c.setScale(2)){
                            mapMsg.put('invalidTotalExpense','true');
                        }
                        else{
                            
                            // Create Billing record
                            litify_pm__Bill__c objBilling = new litify_pm__Bill__c();
                            objBilling.litify_pm__Matter__c = objResolution.litify_pm__Matter__c;
                            // objBilling.litify_pm__Amount__c = objResolution.litify_pm__Total_Expenses__c==null?0 :objResolution.litify_pm__Total_Expenses__c - objResolution.Amount_Written_off__c==null?0:objResolution.Amount_Written_off__c;
                            objBilling.litify_pm__Amount__c = objResolution.litify_pm__Total_Expenses__c==null?0 :objResolution.litify_pm__Total_Expenses__c;
                            // insert objBilling;
                            
                            if(listPrebilledExpenses.size()>0){
                                for(litify_pm__Expense__c objExp:listPrebilledExpenses){
                                    objExp.Billing_Status__c='Billed';
                                    objExp.Settlement_Date__c = system.today();
                                    // objExp.litify_pm__Bill__c =objBilling.Id;
                                    
                                }
                            }
                            
                            //objResolution.Status__c = 'Closed'; 
                            //update  objResolution;
                            
                            
                            if(listPrebilledExpenses.size()>0){
                                update listPrebilledExpenses;
                            }
                            
                            //Create Statement and Statement Lines for the resolution
                            createStatement();
                            
                            list<string>listDepartmentNames = mapGlAccWithDepartment.values();
                            system.debug(listDepartmentNames);
                            system.debug('alias='+objResolution.litify_pm__Matter__r.litify_pm__Principal_Attorney__r.alias);
                            for(AcctSeed__Accounting_Variable__c variable :[select id,name,AcctSeed__Type__c from AcctSeed__Accounting_Variable__c where (AcctSeed__Type__c ='GL Account Variable 4' OR AcctSeed__Type__c ='GL Account Variable 3' OR AcctSeed__Type__c ='GL Account Variable 2' OR AcctSeed__Type__c ='GL Account Variable 1')  AND ( name in(:objResolution.litify_pm__Matter__r.litify_pm__Primary_Intake__r.Originating_Office__c,:objResolution.litify_pm__Matter__r.litify_pm__Case_Type__r.Service_Line__c,:objResolution.litify_pm__Matter__r.litify_pm__Principal_Attorney__r.alias) or name in:listDepartmentNames)]){
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
                            
                            //create JE and JE Lines
                            list<AcctSeed__Ledger__c>listLedger = [select id from AcctSeed__Ledger__c where name='FIRM'];
                            if(listLedger.size()>0){
                                
                                string ACCGLNameFromMatter= string.valueOf( objResolution.litify_pm__Matter__r.litify_pm__Open_Date__c.year())+'-Cost';
                                string ACCGLAccountName='';
                                
                                listJE = new list<AcctSeed__Journal_Entry__c>();
                                
                                objJE = new AcctSeed__Journal_Entry__c();
                                objJE.Name ='Close Resolution/'+objResolution.name +'/'+objResolution.litify_pm__Matter__r.name +'/'+ system.now().format('MM-dd-yyyy');
                                
                                date resDate = objResolution.litify_pm__Resolution_Date__c;
                                objJE.AcctSeed__Journal_Date__c = resDate;
                                string accPeriodName =  Datetime.newInstance( resDate.year(),resDate.month(),resDate.day()).format('yyyy-MM');
                                List<AcctSeed__Accounting_Period__c>listAccPeriod = [select id from AcctSeed__Accounting_Period__c where name=:accPeriodName];
                                if(listAccPeriod.size()>0){
                                    accPeriodId  = listAccPeriod[0].id;
                                    objJE.AcctSeed__Accounting_Period__c = accPeriodId;
                                }
                                
                                //objRecoveredCostRevenueJE.Matter__c = objResolution.litify_pm__Matter__c;
                                objJE.Resolution__c = objResolution.Id;
                                
                                if(system.test.isRunningTest()){
                                    objJE.AcctSeed__Ledger__c = listLedger[0].id;
                                }
                                if(system.test.isRunningTest()){
                                    List<AcctSeed__Ledger__c>listLeder = [select id from AcctSeed__Ledger__c where  AcctSeed__Type__c = 'Transactional'];
                                    objJE.AcctSeed__Ledger__c = listLeder[0].id;
                                }
                                Insert objJE;
                                
                                //Created 4 JE lines
                                createGLLines(true);
                                
                                //Create payables for Client,Third Party,Firm’s distributions, for each referrals
                                createPayables();
                                
                                
                                if(listJELinesToInsert.size()>0){
                                    insert listJELinesToInsert;
                                }
                                
                                //post JE
                                if(listJE.size()>0){
                                    AcctSeed.PostResult[] postResults = AcctSeed.JournalEntryPostService.postJournalEntries(listJE);
                                }
                                
                                //createFinalStatementPdf();
                                
                            }
                            mapMsg.put('success','true');
                            
                            objResolution.Status__c = 'Closed'; 
                            update  objResolution;
                            
                            
                        }
                        
                    }
                    
                }
                
                
                
            }
            
        }
        catch(Exception ex){
            system.debug('========='+ex.getLineNumber()+'==========='+ex.getMessage());
            mapMsg.put('error','true');
            if(sp!=null){
                database.rollback(sp);
            }
        }
        
        return mapMsg;
    }
    
    public static void createStatement(){
        Statement__c objStatement = new Statement__c();
        objStatement.Resolution__c = objResolution.Id;
        objStatement.Settlement_Date__c = system.Date.today();
        //objStatement.Total_Expense_Amount__c = objResolution.litify_pm__Total_Expenses__c;
        
        List<litify_pm__Expense__c> listPrebilledExpense = [select id,name,litify_pm__Amount__c,Amount_after_Reductions__c  from litify_pm__Expense__c  where  Billing_Status__c='Billed'  and Resolution__c= :objResolution.Id ];
        
        
        objStatement.No_of_Expense_lines__c = listPrebilledExpense.size();
        // objStatement.No_of_Write_off_lines__c = listPreBilledWriteOff.size();
        // objStatement.Total Expenses Billed = objResolution.litify_pm__Matter__c;
        
        insert objStatement;
        
        List<Statement_Line__c>listStatementLinesToInsert = new List<Statement_Line__c>();
        
        for(litify_pm__Expense__c objExpense: listPrebilledExpense){
            Statement_Line__c objStatementLine = new Statement_Line__c();
            objStatementLine.Statement__c = objStatement.id;
            objStatementLine.Amount__c = objExpense.Amount_after_Reductions__c;//objExpense.litify_pm__Amount__c;
            objStatementLine.Expense__c = objExpense.id;
            // objStatementLine.Type__c = 'Expense';
            listStatementLinesToInsert.add(objStatementLine);
        }
        
        
        if(listStatementLinesToInsert.size()>0){
            insert listStatementLinesToInsert;
        }
        
        
    }   
    
    public static void createFinalStatementPdf(){
        
        List<Attachment>attachmentToInsert = new List<Attachment>();
        PageReference objPdfStatement =  page.clientStatementPDF;
        objPdfStatement.getParameters().put('id',objResolution.Id);
        Blob pdfStatementBlob=null;
        if(system.Test.isRunningTest()){
            pdfStatementBlob = blob.valueOf('test');
            
        }
        else{
            pdfStatementBlob = objPdfStatement.getContent();
        }
        
        Attachment objAttachment = new Attachment();
        objAttachment.Name ='Final_'+objResolution.Name+'_'+ system.Datetime.now().format('MM-dd-yyyy HH:mm:ss')+'.pdf';
        objAttachment.Body = pdfStatementBlob;            
        objAttachment.IsPrivate = false;
        objAttachment.ParentId = objResolution.Id;
        attachmentToInsert.add(objAttachment); 
        
        insert attachmentToInsert;
    }
    
    //Create GL entry lines
    public static void createGLLines(boolean doCreate){
        
        AcctSeed__Journal_Entry_Line__c objTrustRecDebitJELine= new AcctSeed__Journal_Entry_Line__c();
        if(doCreate){
            objTrustRecDebitJELine.AcctSeed__Journal_Entry__c =objJE.Id;
        }
        objTrustRecDebitJELine.AcctSeed__Debit__c = objResolution.Firm_Distribution_After_Referral_Fees__c;
        objTrustRecDebitJELine.AcctSeed__Date__c= objResolution.litify_pm__Resolution_Date__c;//system.Date.today();
        objTrustRecDebitJELine.AcctSeed__GL_Account__c =mapGlAccounts.get('trustReceivebleGLAcc');
        if(!string.isEmpty(serviceLineAccVariable)){
            objTrustRecDebitJELine.AcctSeed__GL_Account_Variable_1__c = serviceLineAccVariable;
        }
        if(!string.isEmpty(locationAccVariable)){
            objTrustRecDebitJELine.AcctSeed__GL_Account_Variable_2__c = locationAccVariable;
        }
        if(!string.isEmpty(attorneyAccVariable)){
            objTrustRecDebitJELine.AcctSeed__GL_Account_Variable_4__c = attorneyAccVariable;
        }
        if(mapGlAccWithDepartment.containskey('trustReceivebleGLAcc')){
            if(mapGlAccWithDepartmentAccVar.containskey(mapGlAccWithDepartment.get('trustReceivebleGLAcc'))){
                objTrustRecDebitJELine.AcctSeed__GL_Account_Variable_3__c = mapGlAccWithDepartmentAccVar.get(mapGlAccWithDepartment.get('trustReceivebleGLAcc'));
            }
        }
        if(mapMatterWithProject.containskey(objResolution.litify_pm__Matter__c)){
            objTrustRecDebitJELine.AcctSeed__Project__c = mapMatterWithProject.get(objResolution.litify_pm__Matter__c).id;
            
        }
        
        listJELinesToInsert.add(objTrustRecDebitJELine);
        
        //Credit JE line for Soft cost
        if(objResolution.Soft_Costs__c!=null && objResolution.Soft_Costs__c>0){            
            //Litigation Exp Reimbursed
            system.debug('objResolution.Soft_Costs__c '+objResolution.Soft_Costs__c);
            system.debug('objResolution.Voided_Soft_Costs__c '+objResolution.Voided_Soft_Costs__c);
            AcctSeed__Journal_Entry_Line__c objSoftCostCreditJELine= new AcctSeed__Journal_Entry_Line__c();
            objSoftCostCreditJELine.AcctSeed__Credit__c = objResolution.Soft_Costs__c- (objResolution.Voided_Soft_Costs__c==null?0:objResolution.Voided_Soft_Costs__c);
            
            if(doCreate){
                objSoftCostCreditJELine.AcctSeed__Journal_Entry__c =objJE.Id;
                
            }
            if(mapMatterWithProject.containskey(objResolution.litify_pm__Matter__c)){
                objSoftCostCreditJELine.AcctSeed__Project__c = mapMatterWithProject.get(objResolution.litify_pm__Matter__c).id;                
            }
            if(mapMatterWithProjectTask.containskey(objResolution.litify_pm__Matter__c)){
                objSoftCostCreditJELine.AcctSeed__Project_Task__c = mapMatterWithProjectTask.get(objResolution.litify_pm__Matter__c).id;            
            }
            objSoftCostCreditJELine.AcctSeed__Date__c= objResolution.litify_pm__Resolution_Date__c;//system.Date.today();
            objSoftCostCreditJELine.AcctSeed__GL_Account__c = mapGlAccounts.get('softCostGLAcc') ;
            if(!string.isEmpty(serviceLineAccVariable)){
                objSoftCostCreditJELine.AcctSeed__GL_Account_Variable_1__c = serviceLineAccVariable;
            }
            if(!string.isEmpty(locationAccVariable)){
                objSoftCostCreditJELine.AcctSeed__GL_Account_Variable_2__c = locationAccVariable;
            }
            if(!string.isEmpty(attorneyAccVariable)){
                objSoftCostCreditJELine.AcctSeed__GL_Account_Variable_4__c = attorneyAccVariable;
            }
            if(mapGlAccWithDepartment.containskey('softCostGLAcc')){
                if(mapGlAccWithDepartmentAccVar.containskey(mapGlAccWithDepartment.get('softCostGLAcc'))){
                    objSoftCostCreditJELine.AcctSeed__GL_Account_Variable_3__c = mapGlAccWithDepartmentAccVar.get(mapGlAccWithDepartment.get('softCostGLAcc'));
                }
            }
            if(doCreate ){
                if( objSoftCostCreditJELine.AcctSeed__Credit__c!=0)
                    listJELinesToInsert.add(objSoftCostCreditJELine);
            }
            else{
                listJELinesToInsert.add(objSoftCostCreditJELine);
            }
            
            
        }
        
        //Credit JE line for Hard cost
        if(objResolution.Hard_Costs__c!=null && objResolution.Hard_Costs__c>0){            
            //1200-Client Costs Advanced 
            
            AcctSeed__Journal_Entry_Line__c objHardCostCreditJELine= new AcctSeed__Journal_Entry_Line__c();
            if(doCreate){
                objHardCostCreditJELine.AcctSeed__Journal_Entry__c =objJE.Id;
            }
            objHardCostCreditJELine.AcctSeed__Credit__c = objResolution.Hard_Costs__c;
            objHardCostCreditJELine.AcctSeed__Date__c= objResolution.litify_pm__Resolution_Date__c;//system.Date.today();
            objHardCostCreditJELine.AcctSeed__GL_Account__c = mapGlAccounts.get('hardCostGLAcc') ;
            if(mapMatterWithProject.containskey(objResolution.litify_pm__Matter__c)){
                objHardCostCreditJELine.AcctSeed__Project__c = mapMatterWithProject.get(objResolution.litify_pm__Matter__c).id;                
            }
            if(mapMatterWithProjectTask.containskey(objResolution.litify_pm__Matter__c)){
                objHardCostCreditJELine.AcctSeed__Project_Task__c = mapMatterWithProjectTask.get(objResolution.litify_pm__Matter__c).id;            
            }
            
            if(!string.isEmpty(serviceLineAccVariable)){
                objHardCostCreditJELine.AcctSeed__GL_Account_Variable_1__c = serviceLineAccVariable;
            }
            if(!string.isEmpty(locationAccVariable)){
                objHardCostCreditJELine.AcctSeed__GL_Account_Variable_2__c = locationAccVariable;
            }
            if(!string.isEmpty(attorneyAccVariable)){
                objHardCostCreditJELine.AcctSeed__GL_Account_Variable_4__c = attorneyAccVariable;
            }
            if(mapGlAccWithDepartment.containskey('hardCostGLAcc')){
                if(mapGlAccWithDepartmentAccVar.containskey(mapGlAccWithDepartment.get('hardCostGLAcc'))){
                    objHardCostCreditJELine.AcctSeed__GL_Account_Variable_3__c = mapGlAccWithDepartmentAccVar.get(mapGlAccWithDepartment.get('hardCostGLAcc'));
                }
            }
            
            listJELinesToInsert.add(objHardCostCreditJELine);
        }
        
        //Credit JE lines for each Attorney Split
        if(objResolution.Net_Fees__c!=null){
            integer index=1;
            decimal splitAmount=0, currentTotal=0;
            map<string,id>mapAttorneyAccVariable = new  map<string,id>();
            for(AcctSeed__Accounting_Variable__c accVariables:[select id,name,AcctSeed__Type__c from AcctSeed__Accounting_Variable__c]){
                
                if(accVariables.AcctSeed__Type__c=='GL Account Variable 4'){
                    mapAttorneyAccVariable.put(accVariables.name,accVariables.Id);
                }
            }
            List<Attorney_Split__c>listAttorneySplit = [select id,Amount__c,Share__c,Attorney__c,Attorney__r.Alias from Attorney_Split__c where Resolution__c=:objResolution.Id];
            
            decimal voidedHardCost =objResolution.Voided_Hard_Costs__c==null?0 :objResolution.Voided_Hard_Costs__c;                
            for(Attorney_Split__c objSplit:listAttorneySplit){
                if(objSplit.Share__c>0 || objSplit.Amount__c>0){
                    if(index==listAttorneySplit.size()){
                        
                        splitAmount = objResolution.Fee_Income__c -currentTotal;
                    }
                    else{
                        if(objSplit.Amount__c>0){
                            splitAmount = objSplit.Amount__c;
                        }else{
                            splitAmount = (objResolution.Fee_Income__c)*objSplit.Share__c/100;                       
                        }
                        currentTotal = currentTotal+ splitAmount;
                        
                    }
                    AcctSeed__Journal_Entry_Line__c objSplitCreditJELine= new AcctSeed__Journal_Entry_Line__c();
                    if(doCreate){
                        objSplitCreditJELine.AcctSeed__Journal_Entry__c =objJE.Id;
                    }
                    objSplitCreditJELine.AcctSeed__Credit__c = splitAmount;
                    objSplitCreditJELine.AcctSeed__Date__c= objResolution.litify_pm__Resolution_Date__c;//system.Date.today();
                    objSplitCreditJELine.AcctSeed__GL_Account__c = mapGlAccounts.get('feeRevenueGLAcc') ;
                    
                    if(!string.isEmpty(serviceLineAccVariable)){
                        objSplitCreditJELine.AcctSeed__GL_Account_Variable_1__c = serviceLineAccVariable;
                    }
                    if(!string.isEmpty(locationAccVariable)){
                        objSplitCreditJELine.AcctSeed__GL_Account_Variable_2__c = locationAccVariable;
                    }
                    if(mapAttorneyAccVariable.containsKey(objSplit.Attorney__r.Alias)){
                        objSplitCreditJELine.AcctSeed__GL_Account_Variable_4__c = mapAttorneyAccVariable.get(objSplit.Attorney__r.Alias);
                    }
                    if(mapGlAccWithDepartment.containskey('feeRevenueGLAcc')){
                        system.debug(mapGlAccWithDepartment.containskey('feeRevenueGLAcc'));
                        if(mapGlAccWithDepartmentAccVar.containskey(mapGlAccWithDepartment.get('feeRevenueGLAcc'))){
                            system.debug(mapGlAccWithDepartmentAccVar.get(mapGlAccWithDepartment.get('feeRevenueGLAcc')));
                            objSplitCreditJELine.AcctSeed__GL_Account_Variable_3__c = mapGlAccWithDepartmentAccVar.get(mapGlAccWithDepartment.get('feeRevenueGLAcc'));
                        }
                    }
                    if(mapMatterWithProject.containskey(objResolution.litify_pm__Matter__c)){
                        objSplitCreditJELine.AcctSeed__Project__c = mapMatterWithProject.get(objResolution.litify_pm__Matter__c).id;                
                    }
                    if(mapMatterWithProjectTask.containskey(objResolution.litify_pm__Matter__c)){
                        objSplitCreditJELine.AcctSeed__Project_Task__c = mapMatterWithProjectTask.get(objResolution.litify_pm__Matter__c).id;            
                    }
                    listJELinesToInsert.add(objSplitCreditJELine);
                    index++;
                }
                
            }
        }
        
        if(objResolution.Absorbed_Open_Case_Exp__c!=null && objResolution.Absorbed_Open_Case_Exp__c>0){            
            //open CaseGLAcc
            system.debug('objResolution.Absorbed_Open_Case_Exp__c '+objResolution.Absorbed_Open_Case_Exp__c);
            AcctSeed__Journal_Entry_Line__c objAbsorbDebitJELine= new AcctSeed__Journal_Entry_Line__c();
            objAbsorbDebitJELine.AcctSeed__Debit__c = objResolution.Absorbed_Open_Case_Exp__c;
            
            if(doCreate){
                objAbsorbDebitJELine.AcctSeed__Journal_Entry__c =objJE.Id;
                
            }
            //objAbsorbDebitJELine.AcctSeed__Project__c = mapMatterWithProject.get(objResolution.litify_pm__Matter__c).id;
            
            objAbsorbDebitJELine.AcctSeed__Date__c= objResolution.litify_pm__Resolution_Date__c;//system.Date.today();
            objAbsorbDebitJELine.AcctSeed__GL_Account__c = mapGlAccounts.get('openCaseGLAcc') ;
            if(!string.isEmpty(serviceLineAccVariable)){
                objAbsorbDebitJELine.AcctSeed__GL_Account_Variable_1__c = serviceLineAccVariable;
            }
            if(!string.isEmpty(locationAccVariable)){
                objAbsorbDebitJELine.AcctSeed__GL_Account_Variable_2__c = locationAccVariable;
            }
            if(!string.isEmpty(attorneyAccVariable)){
                objAbsorbDebitJELine.AcctSeed__GL_Account_Variable_4__c = attorneyAccVariable;
            }
            if(mapGlAccWithDepartment.containskey('openCaseGLAcc')){
                if(mapGlAccWithDepartmentAccVar.containskey(mapGlAccWithDepartment.get('openCaseGLAcc'))){
                    objAbsorbDebitJELine.AcctSeed__GL_Account_Variable_3__c = mapGlAccWithDepartmentAccVar.get(mapGlAccWithDepartment.get('openCaseGLAcc'));
                }
            }
            if(doCreate ){
                if( objAbsorbDebitJELine.AcctSeed__Credit__c!=0)
                    listJELinesToInsert.add(objAbsorbDebitJELine);
            }
            else{
                listJELinesToInsert.add(objAbsorbDebitJELine);
            }
            
            
        }
        
        
        
    }
    
    
    //Create payables for Client,Third Party,Firm’s distributions, for each referrals 
    public static void createPayables(){
        
        listPayablesToInsert = new list<AcctSeed__Account_Payable__c>();
        listPayableLinesToInsert = new list<AcctSeed__Account_Payable_Line__c>();        
        
        for(AcctSeed__GL_Account__c  glAcc :[select id,name from AcctSeed__GL_Account__c where name =:label.Trust_Ledger_Debit_GL_Account]){
            mapGlAccounts.put('settlementLiabilityAcc',glAcc.Id);
            
        }        
        list<AcctSeed__Ledger__c>listLedger = [select id from AcctSeed__Ledger__c where name='TRUST'];
        
        //Client Distribution
        /* if(objResolution.Client_Distribution__c!=null && objResolution.Client_Distribution__c>0){
AcctSeed__Account_Payable__c objClientDistributionPayable = new AcctSeed__Account_Payable__c();
objClientDistributionPayable.AcctSeed__Status__c='Approved';
objClientDistributionPayable.AcctSeed__Date__c = objResolution.litify_pm__Resolution_Date__c;//system.Date.today();
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
listPayablesToInsert.add(objClientDistributionPayable);

AcctSeed__Account_Payable_Line__c objClientDistributionPayableLine = new AcctSeed__Account_Payable_Line__c();
objClientDistributionPayableLine.AcctSeed__Account_Payable__c = objClientDistributionPayable.id;
objClientDistributionPayableLine.AcctSeed__Amount__c = objResolution.Client_Distribution__c;
objClientDistributionPayableLine.AcctSeed__Quantity__c =1;
objClientDistributionPayableLine.Matter__c = objResolution.litify_pm__Matter__c;
objClientDistributionPayableLine.AcctSeed__Expense_GL_Account__c=  mapGlAccounts.get('settlementLiabilityAcc');           
objClientDistributionPayableLine.AcctSeed__GL_Account_Variable_1__c = serviceLineAccVariable;
objClientDistributionPayableLine.AcctSeed__GL_Account_Variable_2__c = locationAccVariable;
objClientDistributionPayableLine.AcctSeed__Date__c = objResolution.litify_pm__Resolution_Date__c;
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

listPayableLinesToInsert.add(objClientDistributionPayableLine);

}
*/
        
        //Third party distribution
        list<Distribution__c>listDistribution =[select id,name,Amount__c,Account__c from Distribution__c where Resolution__c=:objresolution.Id];
        if(listDistribution.size()>0){
            
            integer index=1;
            for(Distribution__c objDistribution:listDistribution){
                AcctSeed__Account_Payable__c objThirdPartyDistributionPayable = new AcctSeed__Account_Payable__c();
                objThirdPartyDistributionPayable.AcctSeed__Status__c='Approved';
                objThirdPartyDistributionPayable.AcctSeed__Date__c = system.Date.today();
                //payee reference cannot be duplicated
                objThirdPartyDistributionPayable.AcctSeed__Payee_Reference__c = 'Third party distribution/'+objResolution.Name+'/'+objResolution.litify_pm__Matter__r.name+'_'+index;
                // objThirdPartyDistributionPayable.Distribution__c = objDistribution.id;
                if(listLedger.size()>0){
                    objThirdPartyDistributionPayable.AcctSeed__Ledger__c =  listLedger[0].id;
                }        
                objThirdPartyDistributionPayable.Resolution__c  = objResolution.Id;
                //  objThirdPartyDistributionPayable.Distribution__c = objDistribution.Id;
                objThirdPartyDistributionPayable.Expense_Type__c ='Trust';
                objThirdPartyDistributionPayable.Origin__c='Trust';
                if(objDistribution.Account__c!=null){
                    objThirdPartyDistributionPayable.AcctSeed__Vendor__c = objDistribution.Account__c;
                    system.debug(objThirdPartyDistributionPayable);
                    listPayablesToInsert.add(objThirdPartyDistributionPayable);
                }
                
                
                AcctSeed__Account_Payable_Line__c objThirdPartyDistributionPayableLine = new AcctSeed__Account_Payable_Line__c();
                objThirdPartyDistributionPayableLine.AcctSeed__Account_Payable__c = objThirdPartyDistributionPayable.id;
                objThirdPartyDistributionPayableLine.AcctSeed__Amount__c = objDistribution.Amount__c;
                objThirdPartyDistributionPayableLine.AcctSeed__Quantity__c =1;
                objThirdPartyDistributionPayableLine.Matter__c = objResolution.litify_pm__Matter__c;
                objThirdPartyDistributionPayableLine.AcctSeed__Expense_GL_Account__c= mapGlAccounts.get('settlementLiabilityAcc');//ACCGLAccountId;
                
                if(mapMatterWithProject.containsKey(objResolution.litify_pm__Matter__c)){
                    objThirdPartyDistributionPayableLine.AcctSeed__Project__c = mapMatterWithProject.get(objResolution.litify_pm__Matter__c).id;
                    if(mapMatterWithProjectTask.containsKey(objResolution.litify_pm__Matter__c)){
                        objThirdPartyDistributionPayableLine.AcctSeed__Project_Task__c = mapMatterWithProjectTask.get(objResolution.litify_pm__Matter__c).id;
                    }
                }
                objThirdPartyDistributionPayableLine.AcctSeed__GL_Account_Variable_1__c = serviceLineAccVariable ;
                objThirdPartyDistributionPayableLine.AcctSeed__GL_Account_Variable_2__c = locationAccVariable;
                // objThirdPartyDistributionPayableLine.AcctSeed__GL_Account_Variable_3__c = matterAccVariable;      
                
                
                listPayableLinesToInsert.add(objThirdPartyDistributionPayableLine);
                
                index++;
            }
            
            
        }
        
        
        //Firm distribution        
        if(objResolution.Firm_Distribution_After_Referral_Fees__c!=null && objResolution.Firm_Distribution_After_Referral_Fees__c>0){
            AcctSeed__Account_Payable__c objFirmDistributionPayable = new AcctSeed__Account_Payable__c();
            objFirmDistributionPayable.AcctSeed__Status__c='Approved';
            objFirmDistributionPayable.AcctSeed__Date__c = objResolution.litify_pm__Resolution_Date__c;//system.Date.today();
            objFirmDistributionPayable.AcctSeed__Accounting_Period__c = accPeriodId;
            objFirmDistributionPayable.AcctSeed__Payee_Reference__c = 'Firm distribution/'+objResolution.Name+'/'+objResolution.litify_pm__Matter__r.name;
            
            if(listLedger.size()>0){
                objFirmDistributionPayable.AcctSeed__Ledger__c =  listLedger[0].id;
            }        
            objFirmDistributionPayable.Resolution__c  = objResolution.Id; 
            List<Account>listAcc = [select id,name from Account where name=:label.Firm_Distribution_Account_AAA];
            if(listAcc.size()>0){
                objFirmDistributionPayable.AcctSeed__Vendor__c =listAcc[0].id;
            }
            objFirmDistributionPayable.Expense_Type__c ='Trust';
            objFirmDistributionPayable.Origin__c='Trust';
            system.debug(objFirmDistributionPayable);
            listPayablesToInsert.add(objFirmDistributionPayable);
            
            AcctSeed__Account_Payable_Line__c objFirmDistributionPayableLine = new AcctSeed__Account_Payable_Line__c();
            objFirmDistributionPayableLine.AcctSeed__Account_Payable__c = objFirmDistributionPayable.id;
            objFirmDistributionPayableLine.AcctSeed__Amount__c = objResolution.Firm_Distribution_After_Referral_Fees__c;
            objFirmDistributionPayableLine.AcctSeed__Quantity__c =1;
            objFirmDistributionPayableLine.Matter__c = objResolution.litify_pm__Matter__c;
            objFirmDistributionPayableLine.AcctSeed__Expense_GL_Account__c= mapGlAccounts.get('settlementLiabilityAcc');//ACCGLAccountId;
            objFirmDistributionPayableLine.AcctSeed__Date__c = objResolution.litify_pm__Resolution_Date__c;
            if(mapMatterWithProject.containsKey(objResolution.litify_pm__Matter__c)){
                objFirmDistributionPayableLine.AcctSeed__Project__c = mapMatterWithProject.get(objResolution.litify_pm__Matter__c).id;
                if(mapMatterWithProjectTask.containsKey(objResolution.litify_pm__Matter__c)){
                    objFirmDistributionPayableLine.AcctSeed__Project_Task__c = mapMatterWithProjectTask.get(objResolution.litify_pm__Matter__c).id;
                }
            }
            
            objFirmDistributionPayableLine.AcctSeed__GL_Account_Variable_1__c = serviceLineAccVariable ;
            objFirmDistributionPayableLine.AcctSeed__GL_Account_Variable_2__c = locationAccVariable;
            if(!string.isEmpty(attorneyAccVariable)){
                objFirmDistributionPayableLine.AcctSeed__GL_Account_Variable_4__c = attorneyAccVariable;
            }
            if(mapGlAccWithDepartment.containskey('settlementLiabilityAcc')){
                if(mapGlAccWithDepartmentAccVar.containskey(mapGlAccWithDepartment.get('settlementLiabilityAcc'))){
                    objFirmDistributionPayableLine.AcctSeed__GL_Account_Variable_3__c = mapGlAccWithDepartmentAccVar.get(mapGlAccWithDepartment.get('settlementLiabilityAcc'));
                }
            }
            //objFirmDistributionPayableLine.AcctSeed__GL_Account_Variable_3__c = matterAccVariable;  
            
            listPayableLinesToInsert.add(objFirmDistributionPayableLine);
        }
        
        //Payable for each damages
        List<litify_pm__Damage__c>listDamages = [select id,Account__c,litify_pm__Invoice__c,Alternate_Payee__c,name,litify_pm__Provider__r.litify_pm__Party__c,
                                                 litify_pm__Provider__r.litify_pm__Party__r.AccountNumber,litify_pm__Provider__r.litify_pm__Party__r.Name,litify_pm__Amount_Due__c,Due_Date__c 
                                                 from litify_pm__Damage__c where Resolution__c=:objresolution.Id and litify_pm__Amount_Due__c>0 and Escrow__c=false];
        if(listDamages.size()>0){
            decimal totalDamages=0;
            map<id,decimal> mapPartyWithTotal = new map<id,decimal>();
            map<id,string> mapParty = new map<id,string>();
            for(litify_pm__Damage__c objDamage:listDamages){
                //group by party deprecated 08/18/2020
                /*if(objDamage.litify_pm__Provider__r.litify_pm__Party__c!=null ){
if( !mapPartyWithTotal.containsKey(objDamage.litify_pm__Provider__r.litify_pm__Party__c)){
mapPartyWithTotal.put(objDamage.litify_pm__Provider__r.litify_pm__Party__c,objDamage.litify_pm__Amount_Due__c);
mapParty.put(objDamage.litify_pm__Provider__r.litify_pm__Party__c,objDamage.litify_pm__Provider__r.litify_pm__Party__r.Name);
}
else{
decimal Exist=  mapPartyWithTotal.get(objDamage.litify_pm__Provider__r.litify_pm__Party__c);
mapPartyWithTotal.put(objDamage.litify_pm__Provider__r.litify_pm__Party__c,Exist+objDamage.litify_pm__Amount_Due__c);
}
}*/
                if(objDamage.litify_pm__Amount_Due__c>0){
                    totalDamages = totalDamages+ objDamage.litify_pm__Amount_Due__c;
                    AcctSeed__Account_Payable__c objDamagePayable = new AcctSeed__Account_Payable__c();
                    objDamagePayable.AcctSeed__Status__c='Approved';
                    objDamagePayable.AcctSeed__Date__c = objResolution.litify_pm__Resolution_Date__c;//system.Date.today();
                    objDamagePayable.AcctSeed__Accounting_Period__c = accPeriodId;
                    
                    //be carefull when change reference since it is being used in set payable to Damage
                    objDamagePayable.AcctSeed__Payee_Reference__c = 'Damage/'+objDamage.Id+'/'+objDamage.litify_pm__Provider__r.litify_pm__Party__c+'/'+objResolution.Name+'/'+objResolution.litify_pm__Matter__r.name;
                    if(listLedger.size()>0){
                        objDamagePayable.AcctSeed__Ledger__c =  listLedger[0].id;
                    } 
                    objDamagePayable.Resolution__c  = objResolution.Id;    
                    if(objDamage.Alternate_Payee__c!=null){
                        objDamagePayable.AcctSeed__Vendor__c = objDamage.Alternate_Payee__c;
                    }else{
                        objDamagePayable.AcctSeed__Vendor__c = objDamage.litify_pm__Provider__r.litify_pm__Party__c;
                    }
                    
                    objDamagePayable.Expense_Type__c ='Trust';
                    objDamagePayable.Origin__c='Trust';  
                    //objDamagePayable.Damage_Lien_Account__c= objDamage.litify_pm__Provider__r.litify_pm__Party__r.AccountNumber;
                    objDamagePayable.Damage_Lien_Account__c= objDamage.Account__c;
                    objDamagePayable.Damage_Lien_Invoice__c= objDamage.litify_pm__Invoice__c;
                    objDamagePayable.Damage__c = objDamage.Id;
                    system.debug(objDamagePayable);
                    listPayablesToInsert.add(objDamagePayable);
                    
                    AcctSeed__Account_Payable_Line__c objDamagePayableLine = new AcctSeed__Account_Payable_Line__c();
                    objDamagePayableLine.AcctSeed__Account_Payable__c = objDamagePayable.id;
                    objDamagePayableLine.AcctSeed__Amount__c = objDamage.litify_pm__Amount_Due__c;
                    objDamagePayableLine.AcctSeed__Quantity__c =1;
                    objDamagePayableLine.Matter__c = objResolution.litify_pm__Matter__c;
                    objDamagePayableLine.AcctSeed__Expense_GL_Account__c=  mapGlAccounts.get('settlementLiabilityAcc');           
                    objDamagePayableLine.AcctSeed__GL_Account_Variable_1__c = serviceLineAccVariable;
                    objDamagePayableLine.AcctSeed__GL_Account_Variable_2__c = locationAccVariable;
                    objDamagePayableLine.AcctSeed__Date__c = objResolution.litify_pm__Resolution_Date__c;
                    if(!string.isEmpty(attorneyAccVariable)){
                        objDamagePayableLine.AcctSeed__GL_Account_Variable_4__c = attorneyAccVariable;
                    }
                    
                    if(mapGlAccWithDepartment.containskey('settlementLiabilityAcc')){
                        if(mapGlAccWithDepartmentAccVar.containskey(mapGlAccWithDepartment.get('settlementLiabilityAcc'))){
                            objDamagePayableLine.AcctSeed__GL_Account_Variable_3__c = mapGlAccWithDepartmentAccVar.get(mapGlAccWithDepartment.get('settlementLiabilityAcc'));
                        }
                    }
                    if(mapMatterWithProject.containsKey(objResolution.litify_pm__Matter__c)){
                        objDamagePayableLine.AcctSeed__Project__c = mapMatterWithProject.get(objResolution.litify_pm__Matter__c).id;
                        if(mapMatterWithProjectTask.containsKey(objResolution.litify_pm__Matter__c)){
                            objDamagePayableLine.AcctSeed__Project_Task__c = mapMatterWithProjectTask.get(objResolution.litify_pm__Matter__c).id;
                        }
                        
                    }
                    listPayableLinesToInsert.add(objDamagePayableLine);
                }
            }
            
            
        }        
        
        //Payable for each Liens
        List<litify_pm__Lien__c>listLienes = [select id,Account__c,litify_pm__lit_Invoice__c,Alternate_Payee__c,name,Payee_Party__c,Payee_Party__r.Name,
                                              Payee_Party__r.AccountNumber,litify_pm__lit_Amount_Due__c,Date_Issued__c 
                                              from litify_pm__Lien__c where  Resolution__c=:objresolution.Id and litify_pm__lit_Amount_Due__c>0 and Escrow__c=false];
        if(listLienes.size()>0){
            decimal totalLien=0;
            map<id,decimal> mapPartyWithTotal = new map<id,decimal>();
            map<id,string> mapParty = new map<id,string>();
            //group by party deprecated
            /*for(litify_pm__Lien__c objLien:listLienes){
if(objLien.litify_pm__lit_Payee__r.litify_pm__Party__c!=null ){
if( !mapPartyWithTotal.containsKey(objLien.litify_pm__lit_Payee__r.litify_pm__Party__c)){
mapPartyWithTotal.put(objLien.litify_pm__lit_Payee__r.litify_pm__Party__c,objLien.litify_pm__lit_Amount_Due__c);
mapParty.put(objLien.litify_pm__lit_Payee__r.litify_pm__Party__c,objLien.litify_pm__lit_Payee__r.litify_pm__Party__r.Name);
}
else{
decimal exist=  mapPartyWithTotal.get(objLien.litify_pm__lit_Payee__r.litify_pm__Party__c);
mapPartyWithTotal.put(objLien.litify_pm__lit_Payee__r.litify_pm__Party__c,exist+objLien.litify_pm__lit_Amount_Due__c);
}
}
}*/
            
            for(litify_pm__Lien__c objLien:listLienes){
                if(objLien.litify_pm__lit_Amount_Due__c>0){
                    totalLien =totalLien +objLien.litify_pm__lit_Amount_Due__c;
                    AcctSeed__Account_Payable__c objLienPayable = new AcctSeed__Account_Payable__c();
                    objLienPayable.AcctSeed__Status__c='Approved';
                    objLienPayable.AcctSeed__Date__c = objResolution.litify_pm__Resolution_Date__c;//system.Date.today();
                    objLienPayable.AcctSeed__Accounting_Period__c = accPeriodId;
                    //be carefull when change reference since it is being used in set payable to Lien
                    objLienPayable.AcctSeed__Payee_Reference__c = 'Lien/'+objLien.Id+'/'+objLien.Payee_Party__c+'/'+objResolution.Name+'/'+objResolution.litify_pm__Matter__r.name;
                    if(listLedger.size()>0){
                        objLienPayable.AcctSeed__Ledger__c =  listLedger[0].id;
                    } 
                    objLienPayable.Resolution__c  = objResolution.Id;   
                    if(objLien.Alternate_Payee__c!=null){
                        objLienPayable.AcctSeed__Vendor__c = objLien.Alternate_Payee__c;
                    }else{
                        objLienPayable.AcctSeed__Vendor__c = objLien.Payee_Party__c;
                    }
                    
                    objLienPayable.Expense_Type__c ='Trust';
                    objLienPayable.Origin__c='Trust';
                    // objLienPayable.Damage_Lien_Account__c= objLien.Payee_Party__r.AccountNumber;
                    objLienPayable.Damage_Lien_Account__c= objLien.Account__c;
                    objLienPayable.Damage_Lien_Invoice__c= objLien.litify_pm__lit_Invoice__c;
                    objLienPayable.Lien__c = objLien.id;
                    system.debug(objLienPayable);
                    listPayablesToInsert.add(objLienPayable);
                    
                    AcctSeed__Account_Payable_Line__c objLienPayableLine = new AcctSeed__Account_Payable_Line__c();
                    objLienPayableLine.AcctSeed__Account_Payable__c = objLienPayable.id;
                    objLienPayableLine.AcctSeed__Amount__c = objLien.litify_pm__lit_Amount_Due__c;
                    objLienPayableLine.AcctSeed__Quantity__c =1;
                    objLienPayableLine.Matter__c = objResolution.litify_pm__Matter__c;
                    objLienPayableLine.AcctSeed__Expense_GL_Account__c=  mapGlAccounts.get('settlementLiabilityAcc');           
                    objLienPayableLine.AcctSeed__GL_Account_Variable_1__c = serviceLineAccVariable;
                    objLienPayableLine.AcctSeed__GL_Account_Variable_2__c = locationAccVariable;
                    objLienPayableLine.AcctSeed__Date__c = objResolution.litify_pm__Resolution_Date__c;
                    if(!string.isEmpty(attorneyAccVariable)){
                        objLienPayableLine.AcctSeed__GL_Account_Variable_4__c = attorneyAccVariable;
                    }
                    if(mapGlAccWithDepartment.containskey('settlementLiabilityAcc')){
                        if(mapGlAccWithDepartmentAccVar.containskey(mapGlAccWithDepartment.get('settlementLiabilityAcc'))){
                            objLienPayableLine.AcctSeed__GL_Account_Variable_3__c = mapGlAccWithDepartmentAccVar.get(mapGlAccWithDepartment.get('settlementLiabilityAcc'));
                        }
                    }
                    if(mapMatterWithProject.containsKey(objResolution.litify_pm__Matter__c)){
                        objLienPayableLine.AcctSeed__Project__c = mapMatterWithProject.get(objResolution.litify_pm__Matter__c).id;
                        if(mapMatterWithProjectTask.containsKey(objResolution.litify_pm__Matter__c)){
                            objLienPayableLine.AcctSeed__Project_Task__c = mapMatterWithProjectTask.get(objResolution.litify_pm__Matter__c).id;
                        }
                        
                    }
                    listPayableLinesToInsert.add(objLienPayableLine);
                }
            }
            
            
        }        
        
        
        
        //PAYABLE for each  Referall Fee record
        if(objResolution.Referral_Fees__c!=null && objResolution.Referral_Fees__c>0){
            list<Referral_Fee__c>listReferral =[select id,name,Amount__c,Account__c,Effective_Fee_Amount__c from Referral_Fee__c where Resolution__c=:objresolution.Id];
            
            if(listReferral.size()>0){
                integer i=1;
                for(Referral_Fee__c objReferral:listReferral){
                    AcctSeed__Account_Payable__c objRefferalPayable = new AcctSeed__Account_Payable__c();
                    objRefferalPayable.AcctSeed__Status__c='Approved';
                    objRefferalPayable.AcctSeed__Date__c = objResolution.litify_pm__Resolution_Date__c;//system.Date.today();
                    objRefferalPayable.AcctSeed__Accounting_Period__c = accPeriodId;
                    objRefferalPayable.AcctSeed__Payee_Reference__c = 'Referral Fee/'+objReferral.Id+'/'+objResolution.Name+'/'+objResolution.litify_pm__Matter__r.name;
                    
                    if(listLedger.size()>0){
                        objRefferalPayable.AcctSeed__Ledger__c =  listLedger[0].id;
                    }        
                    objRefferalPayable.Resolution__c  = objResolution.Id; 
                    objRefferalPayable.AcctSeed__Vendor__c =objReferral.Account__c;
                    objRefferalPayable.Expense_Type__c ='Trust';
                    objRefferalPayable.Origin__c='Trust';
                    system.debug(objRefferalPayable);
                    listPayablesToInsert.add(objRefferalPayable);
                    
                    AcctSeed__Account_Payable_Line__c objFirmDistributionPayableLine = new AcctSeed__Account_Payable_Line__c();
                    objFirmDistributionPayableLine.AcctSeed__Account_Payable__c = objRefferalPayable.id;
                    objFirmDistributionPayableLine.AcctSeed__Amount__c = objReferral.Effective_Fee_Amount__c;
                    objFirmDistributionPayableLine.AcctSeed__Quantity__c =1;
                    objFirmDistributionPayableLine.Matter__c = objResolution.litify_pm__Matter__c;
                    objFirmDistributionPayableLine.AcctSeed__Expense_GL_Account__c= mapGlAccounts.get('settlementLiabilityAcc');//ACCGLAccountId;
                    objFirmDistributionPayableLine.AcctSeed__Date__c = objResolution.litify_pm__Resolution_Date__c;
                    if(mapMatterWithProject.containsKey(objResolution.litify_pm__Matter__c)){
                        objFirmDistributionPayableLine.AcctSeed__Project__c = mapMatterWithProject.get(objResolution.litify_pm__Matter__c).id;
                        if(mapMatterWithProjectTask.containsKey(objResolution.litify_pm__Matter__c)){
                            objFirmDistributionPayableLine.AcctSeed__Project_Task__c = mapMatterWithProjectTask.get(objResolution.litify_pm__Matter__c).id;
                        }
                    }
                    
                    objFirmDistributionPayableLine.AcctSeed__GL_Account_Variable_1__c = serviceLineAccVariable ;
                    objFirmDistributionPayableLine.AcctSeed__GL_Account_Variable_2__c = locationAccVariable;
                    if(mapGlAccWithDepartment.containskey('settlementLiabilityAcc')){
                        if(mapGlAccWithDepartmentAccVar.containskey(mapGlAccWithDepartment.get('settlementLiabilityAcc'))){
                            objFirmDistributionPayableLine.AcctSeed__GL_Account_Variable_3__c = mapGlAccWithDepartmentAccVar.get(mapGlAccWithDepartment.get('settlementLiabilityAcc'));
                        }
                    }
                    if(!string.isEmpty(attorneyAccVariable)){
                        objFirmDistributionPayableLine.AcctSeed__GL_Account_Variable_4__c = attorneyAccVariable;
                    }
                    listPayableLinesToInsert.add(objFirmDistributionPayableLine);
                    i++;
                }
                
                
            }
            
        }
        
        if(listPayablesToInsert.size()>0){
            set<id>insertedPayables = new set<id>();
            system.debug('Payables: '+listPayablesToInsert);
            database.SaveResult [] srList = database.insert(listPayablesToInsert,true);
            for(database.SaveResult sr :srList ){
                if(sr.success){
                    insertedPayables.add(sr.getId());
                }
            }
            map<id,string>mapPayableWithReference = new map<id,string>();
            for(AcctSeed__Account_Payable__c objPayable : [select id,AcctSeed__Payee_Reference__c from AcctSeed__Account_Payable__c where id in:insertedPayables]){
                mapPayableWithReference.put(objPayable.id,objPayable.AcctSeed__Payee_Reference__c);
            }
            
            for(string payableId:mapPayableWithReference.keyset()){
                for(litify_pm__Lien__c objLien:listLienes){
                    if(mapPayableWithReference.get(payableId).contains(objLien.Id)){
                        objLien.payable__c= payableId;
                        break;
                    }
                }
                for(litify_pm__Damage__c objDamage:listDamages){
                    if(mapPayableWithReference.get(payableId).contains(objDamage.Id)){
                        objDamage.payable__c= payableId;
                        break;
                    }
                }
            }
            
            update listDamages;
            update listLienes;
        }
        //Insert listPayablesToInsert;
        
        integer i=0;
        for(AcctSeed__Account_Payable_Line__c pl:listPayableLinesToInsert){
            if(i<listPayablesToInsert.size()){
                pl.AcctSeed__Account_Payable__c = listPayablesToInsert[i].id;
                // system.debug('ledger '+listPayablesToInsert[i].AcctSeed__Ledger__c);
                i++;
            }
            else{
                pl.AcctSeed__Account_Payable__c = listPayablesToInsert[i-1].id;
                // system.debug('ledger -1 '+listPayablesToInsert[i-1].AcctSeed__Ledger__c);
            }
            
            
        }
        for(AcctSeed__Account_Payable_Line__c pl:listPayableLinesToInsert){
            // system.debug('payable id '+pl.AcctSeed__Account_Payable__c);
        }
        Insert listPayableLinesToInsert;
        
    }
    
    public static void bindGLMap(){
        mapGlAccounts = new  map<string,string>();
        mapGlAccWithDepartment = new  map<string,string>();
        mapGlAccById = new map<string,string>();
        List<Firm_Ledger_COS_Fee_Revenue_GL_Account__c> listCOSGLCustomSetting=[select Fee_Revenue_GL_Account__c,Hard_Cost_Advanced__c,Soft_Cost_Reimbursed__c,Trust_Receivable_GL_Account__c,Open_case_expenses_GL_Account__c
                                                                                from Firm_Ledger_COS_Fee_Revenue_GL_Account__c];
        
        
        for(AcctSeed__GL_Account__c  glAcc :[select id,name,Department__c,Department__r.Name from AcctSeed__GL_Account__c where name in( :listCOSGLCustomSetting[0].Fee_Revenue_GL_Account__c, :listCOSGLCustomSetting[0].Hard_Cost_Advanced__c,:listCOSGLCustomSetting[0].Soft_Cost_Reimbursed__c,:listCOSGLCustomSetting[0].Trust_Receivable_GL_Account__c,:listCOSGLCustomSetting[0].Open_case_expenses_GL_Account__c)]){
            if(glAcc.name == listCOSGLCustomSetting[0].Fee_Revenue_GL_Account__c){
                mapGlAccounts.put('feeRevenueGLAcc',glAcc.Id);
                if(glAcc.Department__c!=null){
                    mapGlAccWithDepartment.put('feeRevenueGLAcc',glAcc.Department__r.Name);
                }
            }
            else if(glAcc.name == listCOSGLCustomSetting[0].Hard_Cost_Advanced__c){
                mapGlAccounts.put('hardCostGLAcc',glAcc.Id);
                if(glAcc.Department__c!=null){
                    mapGlAccWithDepartment.put('hardCostGLAcc',glAcc.Department__r.Name);
                }
            }
            
            else if(glAcc.name == listCOSGLCustomSetting[0].Soft_Cost_Reimbursed__c){
                mapGlAccounts.put('softCostGLAcc',glAcc.Id);
                if(glAcc.Department__c!=null){
                    mapGlAccWithDepartment.put('softCostGLAcc',glAcc.Department__r.Name);
                }
            }
            else if(glAcc.name == listCOSGLCustomSetting[0].Trust_Receivable_GL_Account__c){
                mapGlAccounts.put('trustReceivebleGLAcc',glAcc.Id);
                if(glAcc.Department__c!=null){
                    mapGlAccWithDepartment.put('trustReceivebleGLAcc',glAcc.Department__r.Name);
                }
            }
            else if(glAcc.name == listCOSGLCustomSetting[0].Open_case_expenses_GL_Account__c){
                mapGlAccounts.put('openCaseGLAcc',glAcc.Id);
                if(glAcc.Department__c!=null){
                    mapGlAccWithDepartment.put('openCaseGLAcc',glAcc.Department__r.Name);
                }
            }
            mapGlAccById.put(glAcc.Id,glAcc.Name);
        }
        
    }
    
}