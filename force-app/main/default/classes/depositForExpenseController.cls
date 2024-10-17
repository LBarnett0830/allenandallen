public class depositForExpenseController {
    
    class depositForExpenseControllerException extends Exception {}
    
    @AuraEnabled
    public static Map<String,String> MatterToProjectMap {get;set;}
    
    @AuraEnabled
    public static List<AcctSeed__Project__c> getRelatedProjects(String matterId){
        try {
            if(String.isNotBlank(matterId)){
                return [SELECT Id FROM AcctSeed__Project__c WHERE Matter__c =: matterId]; 
            }
        }catch(Exception ex){
            system.debug(ex.getMessage()+'---'+ex.getLineNumber());
            throw new auraHandledException(ex.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static depositWrapper getDepositDetailsFromTab(){
        depositWrapper objDepositWrapper = new depositWrapper();
        integer noOfJELines=0; decimal jeLineTotal=0;
        try{
            objDepositWrapper.objDeposit = new Trust_Deposit__c(name='',Date__c=system.Date.today());
            objDepositWrapper.listJELineWrapper = new  list<jeLineWrapper>();
            objDepositWrapper.objEmptyJELine = new AcctSeed__Journal_Entry_Line__c();
            objDepositWrapper.objJELineWrapper = new jeLineWrapper();
            objDepositWrapper.noOfJELines= noOfJELines;
            objDepositWrapper.jeLineTotal =jeLineTotal;
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+'---'+ex.getLineNumber());
            throw new auraHandledException(ex.getMessage());
        }
        return objDepositWrapper;
    }
    
    @AuraEnabled
    public static depositWrapper getDepositDetails(string depositId){
        depositWrapper objDepositWrapper = new depositWrapper();
        integer noOfJELines=0; decimal jeLineTotal=0;
        
        system.debug('========depositId=========='+depositId);
        try{
            if(!string.isempty(depositId)){
                List<Trust_Deposit__c> listDeposit =[SELECT id,Name,Date__c,Number_of_Items__c,Status__c,Total__c,GL_Account__c,GL_Account__r.Name
                                                     FROM Trust_Deposit__c 
                                                     WHERE id=: depositId ];
                
                if(listDeposit.size()>0)
                {
                    objDepositWrapper.objDeposit = listDeposit[0];
                    objDepositWrapper.GlId = listDeposit[0].GL_Account__c;
                    objDepositWrapper.GlName = listDeposit[0].GL_Account__r.Name;
                    objDepositWrapper.isGetDeposit = true;
                    
                    AcctSeed__Journal_Entry__c objJE = [SELECT Id,AcctSeed__Total_Credits__c,AcctSeed__Total_Debits__c,AcctSeed__Accounting_Period__c,AcctSeed__Accounting_Period__r.Name
                                                        FROM AcctSeed__Journal_Entry__c WHERE  Trust_Deposit__c=:listDeposit[0].id];
                    
                    
                    if(objJE != null) {
                        objDepositWrapper.accPeriodId = objJE.AcctSeed__Accounting_Period__c;
                        objDepositWrapper.accPeriodName = objJE.AcctSeed__Accounting_Period__r.Name;
                        
                        Double arTotalAmount = objJE.AcctSeed__Total_Credits__c != 0 ? objJE.AcctSeed__Total_Credits__c : objJE.AcctSeed__Total_Debits__c;
                        
                        List<jeLineWrapper> listJELineWrapper = new list<jeLineWrapper>();
                        
                        for(AcctSeed__Journal_Entry_Line__c objJELine :[SELECT id,name,AcctSeed__Date__c,AcctSeed__GL_Account__c,AcctSeed__GL_Account__r.Name,Payor__c,Is_Expense_Created__c,Expense_Status__c,
                                                                        AcctSeed__Reference__c,AcctSeed__Account__c,AcctSeed__Credit__c,AcctSeed__Project__r.Matter__c,AcctSeed__Project__r.Matter__r.Name, Expense_Type__c,Expense_Type__r.Name 
                                                                        FROM AcctSeed__Journal_Entry_Line__c 
                                                                        WHERE AcctSeed__Journal_Entry__c =: objJE.id AND AcctSeed__Credit__c != null])
                        {
                            jeLineWrapper objJELineWrapper = new jeLineWrapper();
                            objJELineWrapper.id = objJELine.id;
                            objJELineWrapper.name = objJELine.name;
                            objJELineWrapper.matterId = objJELine.AcctSeed__Project__r.Matter__c;
                            objJELineWrapper.matterName = objJELine.AcctSeed__Project__r.Matter__r.Name;
                            objJELineWrapper.payorName = objJELine.Payor__c;
                            objJELineWrapper.amount =objJELine.AcctSeed__Credit__c;
                            objJELineWrapper.narrative =objJELine.AcctSeed__Reference__c;
                            objJELineWrapper.CreditGlAccId = objJELine.AcctSeed__GL_Account__c;
                            objJELineWrapper.createExpense = String.isEmpty(objJELine.Is_Expense_Created__c) ? 'N/A' : objJELine.Is_Expense_Created__c;
                            objJELineWrapper.expenseStatus = String.isEmpty(objJELine.Expense_Status__c) ? 'N/A' : objJELine.Expense_Status__c;
                            objJELineWrapper.CreditGlAccName = objJELine.AcctSeed__GL_Account__r.Name;
                            objJELineWrapper.expenseTypeId = objJELine.Expense_Type__c;
                            objJELineWrapper.expenseTypeName = objJELine.Expense_Type__r.Name;
                            objJELineWrapper.jeLineDate = objJELine.AcctSeed__Date__c;
                            objJELineWrapper.payorId = objJELine.AcctSeed__Account__c;
                            listJELineWrapper.add(objJELineWrapper);
                            
                            noOfJELines++;
                        }
                        
                        objDepositWrapper.listJELineWrapper = listJELineWrapper;
                        jeLineTotal =  arTotalAmount ;
                    }
                }
                else{
                    objDepositWrapper.objDeposit = new Trust_Deposit__c(name='',Date__c=system.Date.today());
                    objDepositWrapper.listJELineWrapper = new  list<jeLineWrapper>();
                   }
            }
            else{
                objDepositWrapper.objDeposit = new Trust_Deposit__c(name='',Date__c=system.Date.today());
                objDepositWrapper.listJELineWrapper = new  list<jeLineWrapper>();  
               }
            objDepositWrapper.objEmptyJELine = new AcctSeed__Journal_Entry_Line__c();
            objDepositWrapper.objJELineWrapper = new jeLineWrapper();
            objDepositWrapper.noOfJELines= noOfJELines;
            objDepositWrapper.jeLineTotal =jeLineTotal;
        }
        catch(Exception ex){
            system.debug(ex.getMessage()+'---'+ex.getLineNumber());
            throw new auraHandledException(ex.getMessage());
        }
        system.debug('========objDepositWrapper=========='+objDepositWrapper);
        return objDepositWrapper;
    }
    
    @AuraEnabled
    public static void saveDepositDetails(depositWrapper objDepositWrapper, Id GLAccId){
        
        savepoint sp;
        system.debug('========GLAccId=========='+GLAccId);
        system.debug('========objDepositWrapper=========='+objDepositWrapper);
        try{
            sp =database.setSavepoint();
            if(objDepositWrapper!=null &&  objDepositWrapper.objDeposit!=null)
            {
                system.debug('objDepositWrapper.objDeposit ===> '+objDepositWrapper.objDeposit);
                
                objDepositWrapper.objDeposit.status__c = 'In-Process';
                objDepositWrapper.objDeposit.GL_Account__c = GLAccId;
                upsert  objDepositWrapper.objDeposit;
                
                List<AcctSeed__Journal_Entry__c> listJE = [SELECT Id,AcctSeed__Total_Credits__c,AcctSeed__Total_Debits__c FROM AcctSeed__Journal_Entry__c WHERE  Trust_Deposit__c=:objDepositWrapper.objDeposit.Id];
                    
                if(!listJE.isEmpty()) {
                    updateJE(objDepositWrapper,listJE[0]);
                }
                else {
                    listJE.add(createJE(objDepositWrapper));
                }
                createJELines(objDepositWrapper,listJE[0],false);
            }
            
        }
        catch(Exception ex){
            if(sp!=null){
                database.rollback(sp);
            }
            system.debug(ex.getMessage()+'---'+ex.getLineNumber());
            throw new auraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void saveAndSubmitDepositDetails(depositWrapper objDepositWrapper, Id GLAccId) {
        List<AcctSeed__Journal_Entry_line__c> listJELinesInserted = new List<AcctSeed__Journal_Entry_line__c>();
        savepoint sp;
        
        try{
            sp =database.setSavepoint();
            if(objDepositWrapper!=null &&  objDepositWrapper.objDeposit!=null)
            {
                sp = database.setsavepoint();
                objDepositWrapper.objDeposit.Status__c = 'Closed';
                objDepositWrapper.objDeposit.GL_Account__c = GLAccId;
                upsert objDepositWrapper.objDeposit;
                
                List<AcctSeed__Journal_Entry__c> listJE = [SELECT Id,AcctSeed__Total_Credits__c,AcctSeed__Total_Debits__c FROM AcctSeed__Journal_Entry__c WHERE  Trust_Deposit__c=:objDepositWrapper.objDeposit.Id];
                    
                if(!listJE.isEmpty()) {
                    updateJE(objDepositWrapper,listJE[0]);
                }
                else {
                    listJE.add(createJE(objDepositWrapper));
                }
                listJELinesInserted = createJELines(objDepositWrapper,listJE[0],true);
                if(!listJELinesInserted.isEmpty()) {
                    createExpenses(objDepositWrapper,listJELinesInserted);
                }
                postJE(listJE);
            }
        }
        catch(Exception ex){
            if(sp!=null){
                database.rollback(sp);
            }
            system.debug(ex.getMessage()+'---'+ex.getLineNumber());
            throw new auraHandledException(ex.getMessage());
        }
    }
    
    public static void createExpenses(depositWrapper objDepositWrapper, List<AcctSeed__Journal_Entry_line__c> listJELines) {
        List<litify_pm__Expense__c> listExpToInsert = new List<litify_pm__Expense__c>();

        if(objDepositWrapper != null && listJELines.size() > 0)
        {
            for(AcctSeed__Journal_Entry_line__c objJELine : [SELECT id,name,AcctSeed__Date__c,AcctSeed__GL_Account__c,AcctSeed__GL_Account__r.Name,Expense_Type__c,Is_Expense_Created__c,
                                                             AcctSeed__Reference__c,AcctSeed__Credit__c,AcctSeed__Project__r.Matter__c,AcctSeed__Project__r.Matter__r.Name ,Expense_Status__c
                                                             FROM AcctSeed__Journal_Entry_Line__c 
                                                             WHERE Id IN : listJELines AND AcctSeed__Credit__c != null])
            {                        
                litify_pm__Expense__c objExpense = new litify_pm__Expense__c();
                objExpense.litify_pm__Amount__c = (objJELine.Is_Expense_Created__c == 'Positive') ? objJELine.AcctSeed__Credit__c : objJELine.AcctSeed__Credit__c*(-1);
                objExpense.litify_pm__Date__c = objJELine.AcctSeed__Date__c;
                objExpense.litify_pm__ExpenseType2__c = objJELine.Expense_Type__c;
                objExpense.litify_pm__Matter__c = objJELine.AcctSeed__Project__r.Matter__c;
                objExpense.Deposit__c = objDepositWrapper.objDeposit.id;
                objExpense.Narrative__c = (objJELine.AcctSeed__Reference__c != null) ? objJELine.AcctSeed__Reference__c : '';
                objExpense.Billing_Status__c = (objJELine.Expense_Status__c != null) ? objJELine.Expense_Status__c : '';
                objExpense.Journal_Entry_Line__c = objJELine.Id;
                listExpToInsert.add(objExpense);
            }
        }
        if(!listExpToInsert.isEmpty()) {
            Insert listExpToInsert;
        }
        
        for(integer i=0; i<listJELines.size(); i++) {
            listJELines[0].Expense__c = listExpToInsert[0].Id;
        }
        if(!listJELines.isEmpty()) {
            Update listJELines;
        }
    }
    
    public static String getAccPeriod(depositWrapper objDepositWrapper) {
        Date depositDate = objDepositWrapper.objDeposit.Date__c;
        if(depositDate!=null){
            Datetime dt = Datetime.newInstance(depositDate.year(),depositDate.month(),depositDate.day());
            string accPeriodName = dt.format('yyyy-MM');
            List<AcctSeed__Accounting_Period__c> periodList = [SELECT Id FROM AcctSeed__Accounting_Period__c WHERE Name =: accPeriodName AND AcctSeed__Status__c = 'Open'];
            if(!periodList.isEmpty())
            {
                return periodList[0].Id;
            }
            else{
                throw new depositForExpenseControllerException('Accounting period '+ accPeriodName +' is missing');
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static void getProjects(List<Id> listMatterId) {
        MatterToProjectMap = new Map<String,String>();
        for(AcctSeed__Project__c objProject : [SELECT Id, matter__c FROM AcctSeed__Project__c WHERE matter__c IN : listMatterId]) 
        { 
            if(!MatterToProjectMap.containsKey(objProject.matter__c)) {
                MatterToProjectMap.put(objProject.matter__c, objProject.Id);
            }
        }
    }
    
    public static AcctSeed__Journal_Entry__c createJE(depositWrapper objDepositWrapper) {
        if(objDepositWrapper != null) 
        {
            //String accPeriodId = getAccPeriod(objDepositWrapper);
            
            AcctSeed__Journal_Entry__c  objJE = new AcctSeed__Journal_Entry__c();
            objJE.Name ='Deposit/'+objDepositWrapper.objDeposit.name+ '/'+ DateTime.newInstance(objDepositWrapper.objDeposit.Date__c.year(), objDepositWrapper.objDeposit.Date__c.month(), objDepositWrapper.objDeposit.Date__c.day()).format('MM-dd-yyyy');
            objJE.AcctSeed__Journal_Date__c = objDepositWrapper.objDeposit.Date__c;
            objJE.AcctSeed__Accounting_Period__c = String.isNotBlank(objDepositWrapper.accPeriodId) ? objDepositWrapper.accPeriodId : null;
            objJE.Trust_Deposit__c = objDepositWrapper.objDeposit.Id;
            List<AcctSeed__Ledger__c>ListLedger = [SELECT Name,AcctSeed__Type__c  FROM AcctSeed__Ledger__c 
                                                       WHERE Name='Actual'];
                if(ListLedger.size()>0)
                {
                    objJE.AcctSeed__Ledger__c = ListLedger[0].id;
                }
            
            if(objJE != null) {
                insert objJE;
                return objJE;
            }
        }
        return null;
    }
    
    public static void updateJE(depositWrapper objDepositWrapper,AcctSeed__Journal_Entry__c jeInserted) {
        if(objDepositWrapper != null) 
        {
            if(jeInserted != null) {
                jeInserted.Name ='Deposit/'+objDepositWrapper.objDeposit.name+ '/'+ DateTime.newInstance(objDepositWrapper.objDeposit.Date__c.year(), objDepositWrapper.objDeposit.Date__c.month(), objDepositWrapper.objDeposit.Date__c.day()).format('MM-dd-yyyy');
                jeInserted.AcctSeed__Journal_Date__c = objDepositWrapper.objDeposit.Date__c;
                jeInserted.AcctSeed__Accounting_Period__c = String.isNotBlank(objDepositWrapper.accPeriodId) ? objDepositWrapper.accPeriodId : null;
                jeInserted.Trust_Deposit__c = objDepositWrapper.objDeposit.Id;
                List<AcctSeed__Ledger__c>ListLedger = [SELECT Name,AcctSeed__Type__c  FROM AcctSeed__Ledger__c 
                                                       WHERE Name='Actual'];
                if(ListLedger.size()>0)
                {
                    jeInserted.AcctSeed__Ledger__c = ListLedger[0].id;
                }
                
                if(jeInserted != null) {
                    update jeInserted;
                }
            }
        }
    }
    
    public static List<AcctSeed__Journal_Entry_line__c> createJELines(depositWrapper objDepositWrapper, AcctSeed__Journal_Entry__c objJE, Boolean isSaveAndSubmit) {
        Set<string> receivingExpIds = new Set<string>();
        List<AcctSeed__Journal_Entry_line__c> listJELinesToUpsert = new List<AcctSeed__Journal_Entry_line__c>();               
        List<AcctSeed__Journal_Entry_line__c> listJELinesToDelete = new  List<AcctSeed__Journal_Entry_line__c>();
        List<AcctSeed__Journal_Entry_line__c> listJELineToCreateExpenses = new  List<AcctSeed__Journal_Entry_line__c>();
        List<Id> listMatterId = new List<Id>();
        
        if(objDepositWrapper != null && objJE != null) {
            Map<id,AcctSeed__Journal_Entry_line__c>  mapOldJELine = new  Map<id,AcctSeed__Journal_Entry_line__c>([SELECT id FROM AcctSeed__Journal_Entry_line__c 
                                                                                                                  WHERE AcctSeed__Journal_Entry__c = :objJE.Id ]);

            if(objDepositWrapper.listJELineWrapper.size()>0)
            {
                for(jeLineWrapper objJELineDetail : objDepositWrapper.listJELineWrapper) {
                    if(String.isNotEmpty(objJELineDetail.matterId)) {
                        listMatterId.add(objJELineDetail.matterId);   
                    }
                }
                map<id,litify_pm__Matter__c>mapMatters= new map<id,litify_pm__Matter__c>([SELECT Id,name,Matter_ID__c 
                                                                                          FROM litify_pm__Matter__c 
                                                                                          WHERE Id IN : listMatterId]);
                
                getProjects(listMatterId);
                for(jeLineWrapper objJELineDetail : objDepositWrapper.listJELineWrapper)
                {     
                    String matterId = (String.isNotEmpty(objJELineDetail.matterId)) ? objJELineDetail.matterId : '';
                    String projectId = MatterToProjectMap.containsKey(objJELineDetail.matterId) ? MatterToProjectMap.get(objJELineDetail.matterId) : '';
                    
                    //Credit JE Line
                    AcctSeed__Journal_Entry_Line__c objCreditJELine = new AcctSeed__Journal_Entry_Line__c();
                    objCreditJELine.AcctSeed__Credit__c = objJELineDetail.amount;
                    objCreditJELine.Payor__c = objJELineDetail.payorName;
                    objCreditJELine.AcctSeed__GL_Account__c = objJELineDetail.CreditGlAccId;
                    objCreditJELine.AcctSeed__Date__c = objJELineDetail.jeLineDate;
                    objCreditJELine.AcctSeed__Reference__c = objJELineDetail.narrative;
                    objCreditJELine.Expense_Status__c = objJELineDetail.expenseStatus;
                    objCreditJELine.Is_Expense_Created__c = objJELineDetail.createExpense;
                    objCreditJELine.Expense_Type__c = (String.isNotEmpty(objJELineDetail.expenseTypeId)) ? objJELineDetail.expenseTypeId : null;
                    objCreditJELine.AcctSeed__Account__c = objJELineDetail.payorId;
                    if(String.isNotEmpty(matterId)) {
                        objCreditJELine.AcctSeed__Project__c = (String.isNotEmpty(projectId)) ? projectId : null;
                        if(mapMatters.containsKey(matterId) && isSaveAndSubmit == true) {
                            if(mapMatters.get(matterId).Matter_ID__c!=null && string.isNotEmpty(objCreditJELine.AcctSeed__Reference__c)){
                                objCreditJELine.AcctSeed__Reference__c =  mapMatters.get(matterId).Matter_ID__c +'/' +objCreditJELine.AcctSeed__Reference__c;
                            }
                            else if(mapMatters.get(matterId).Matter_ID__c!=null && string.isempty(objCreditJELine.AcctSeed__Reference__c)){
                                objCreditJELine.AcctSeed__Reference__c =  mapMatters.get(matterId).Matter_ID__c;
                            }
                        }
                    }
                    
                    //Debit JE Line
                    AcctSeed__Journal_Entry_Line__c objDebitJELine = new AcctSeed__Journal_Entry_Line__c();
                    objDebitJELine.AcctSeed__Debit__c = objJELineDetail.amount;
                    objDebitJELine.Payor__c = objJELineDetail.payorName;
                    objDebitJELine.AcctSeed__GL_Account__c = objDepositWrapper.objDeposit.GL_Account__c;
                    objDebitJELine.AcctSeed__Date__c = objJELineDetail.jeLineDate;
                    objDebitJELine.AcctSeed__Reference__c = objJELineDetail.narrative;
                    objDebitJELine.Is_Expense_Created__c = objJELineDetail.createExpense;
                    if(String.isNotEmpty(matterId)) {
                        objDebitJELine.AcctSeed__Project__c = (String.isNotEmpty(projectId)) ? projectId : null;
                        if(mapMatters.containsKey(matterId) && isSaveAndSubmit == true) {
                            if(mapMatters.get(matterId).Matter_ID__c!=null && string.isNotEmpty(objDebitJELine.AcctSeed__Reference__c)){
                                objDebitJELine.AcctSeed__Reference__c =  mapMatters.get(matterId).Matter_ID__c +'/' +objDebitJELine.AcctSeed__Reference__c;
                            }
                            else if(mapMatters.get(matterId).Matter_ID__c!=null && string.isempty(objDebitJELine.AcctSeed__Reference__c)){
                                objDebitJELine.AcctSeed__Reference__c =  mapMatters.get(matterId).Matter_ID__c;
                            }
                        }
                    }
                    
                    //For new records
                    if(objCreditJELine.AcctSeed__Journal_Entry__c==null)
                    {
                        objCreditJELine.AcctSeed__Journal_Entry__c = objJE.Id;
                            listJELinesToUpsert.add(objCreditJELine);
                    }
                    else{
                        receivingExpIds.add(objCreditJELine.Id);                        
                    }
                    if(objDebitJELine.AcctSeed__Journal_Entry__c==null) 
                    {
                        objDebitJELine.AcctSeed__Journal_Entry__c = objJE.Id;
                           listJELinesToUpsert.add(objDebitJELine);
                    }
                    else{
                        receivingExpIds.add(objDebitJELine.Id);                        
                    }
                    
                    if(objJELineDetail.createExpense == 'Positive' || objJELineDetail.createExpense == 'Negative') {
                        listJELineToCreateExpenses.add(objCreditJELine);
                    }
                }
                
                //get deleted Expenses FROM the front end 
                for(id jeLineId:mapOldJELine.keyset()){
                    if(!receivingExpIds.contains(jeLineId)){
                        listJELinesToDelete.add(mapOldJELine.get(jeLineId));
                    }
                }
                
                if(listJELinesToDelete.size()>0){
                    delete listJELinesToDelete;
                }
                
                if(listJELinesToUpsert.size()>0){
                    upsert listJELinesToUpsert;
                }
                
            }
            else{
                    // when all CR are deleted FROM the front end
                    List<AcctSeed__Journal_Entry_line__c>listJELine =[SELECT id FROM AcctSeed__Journal_Entry_line__c WHERE AcctSeed__Journal_Entry__c = :objJE.Id ];
                    if(listJELine.size()>0){
                        delete listJELine;
                    } 
                } 
        }
        
        return listJELineToCreateExpenses;
    }
    
    public static void postJE(List<AcctSeed__Journal_Entry__c> listJE) {
        if(listJE.size() > 0) {
            AcctSeed.PostResult[] postResults = AcctSeed.JournalEntryPostService.postJournalEntries(listJE);
        }
    }
    
    public class depositWrapper {
        @AuraEnabled public Trust_Deposit__c objDeposit {get;set;}
        @AuraEnabled public List<jeLineWrapper>listJELineWrapper {get;set;}
        @AuraEnabled public AcctSeed__Journal_Entry_Line__c objEmptyJELine {get;set;}
        @AuraEnabled public decimal jeLineTotal {get;set;}
        @AuraEnabled public integer noOfJELines {get;set;}
        @AuraEnabled public jeLineWrapper objJELineWrapper {get;set;}
        @AuraEnabled public string GlId {get;set;}
        @AuraEnabled public string GlName {get;set;}
        @AuraEnabled public string accPeriodId {get;set;}
        @AuraEnabled public string accPeriodName {get;set;}
        @AuraEnabled public boolean isGetDeposit {get;set;}
    }
    
    
    public class jeLineWrapper {
        @AuraEnabled public string id {get;set;}
        @AuraEnabled public string name {get;set;}
        @AuraEnabled public string matterId {get;set;}
        @AuraEnabled public string matterName {get;set;}
        @AuraEnabled public string payorId {get;set;}
        @AuraEnabled public string payorName {get;set;}
        @AuraEnabled public string narrative {get;set;}
        @AuraEnabled public decimal amount {get;set;}        
        @AuraEnabled public string CreditGlAccId {get;set;}
        @AuraEnabled public string CreditGlAccName {get;set;}
        @AuraEnabled public string expenseTypeId {get;set;}
        @AuraEnabled public string expenseTypeName {get;set;}
        @AuraEnabled public date jeLineDate {get;set;}
        @AuraEnabled public string createExpense {get;set;}
        @AuraEnabled public List<String> createExpenseList {get;set;}
        @AuraEnabled public string expenseStatus {get;set;}
        @AuraEnabled public List<String> expenseStatusList {get;set;}
        public jeLineWrapper() {
            this.jeLineDate = null;
            createExpense = 'Negative';
            expenseStatus = 'N/A';
            createExpenseList = new List<String>();
            createExpenseList.add('Positive');
            createExpenseList.add('Negative');
            expenseStatusList = new List<String>();
            expenseStatusList.add('Billed');
            expenseStatusList.add('Unbilled');
        }
    }
}