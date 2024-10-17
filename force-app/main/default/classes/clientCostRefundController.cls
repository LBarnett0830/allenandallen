public class clientCostRefundController {
    
    
    @AuraEnabled
    public static  map<string,boolean> saveRefund(string matterId,decimal amount,string expenseId,string comment){
        map<string,boolean> mapMsg = new map<string,boolean>();
        map<string,string> mapGlAccounts = new  map<string,string>();
        savepoint sp;
        try{
            list<AcctSeed__Journal_Entry_Line__c>listJELinesToInsert = new list<AcctSeed__Journal_Entry_Line__c>();
            list<litify_pm__Matter__c> listMatter = [select id,name,litify_pm__Client__c from litify_pm__Matter__c where id=:matterId ];
            string projectTaskId='';
            
            
            List<AcctSeed__Project__c> listProjects = [select id,Matter__c,(select id,Name,AcctSeed__Sort_Order__c,AcctSeed__Labor_GL_Account__c from  AcctSeed__Project_Tasks__r where name='Default Task') from   AcctSeed__Project__c where Matter__c=:matterId];
            list<ATO_Void_GL_Accounts__c>listGLSettings = [select Credit_Account__c,Debit_Account__c from ATO_Void_GL_Accounts__c];
            List<litify_pm__Expense_Type__c> listExpType = [select id,Category__c from litify_pm__Expense_Type__c where name='Refund'];
            if(listGLSettings.size()==0){
                mapMsg.put('invalidGL',true);
                return mapMsg;
            }
            else if(listProjects.size()==0){
                mapMsg.put('invalidProject',true);
                return mapMsg;
            }
            for(AcctSeed__Project__c objProject:listProjects){
                for(AcctSeed__Project_Task__c pTask :objProject.AcctSeed__Project_Tasks__r ){
                    projectTaskId =pTask.id;
                }
            }
            if(projectTaskId==''){
                mapMsg.put('invalidProjectTask',true);
                return mapMsg;
            }
            if(listExpType.size()==0){
                mapMsg.put('invalidExpenseType',true);
                return mapMsg;
            }
            if(listMatter[0].litify_pm__Client__c==null){
                mapMsg.put('invalidClient',true);
                return mapMsg;
            }
            List<Account>listVendor = [select id from Account where (AcctSeed__Accounting_Type__c='Vendor' OR AcctSeed__Accounting_Type__c='Customer and Vendor') AND Id=:listMatter[0].litify_pm__Client__c];
            if(listVendor.size()==0){
                mapMsg.put('invalidClientType',true);
                return mapMsg;
            }
            for(AcctSeed__GL_Account__c  glAcc :[select id,name,Department__c,Department__r.Name from AcctSeed__GL_Account__c where name in( :listGLSettings[0].Credit_Account__c, :listGLSettings[0].Debit_Account__c)]){
                if(glAcc.name == listGLSettings[0].Credit_Account__c){
                    mapGlAccounts.put('creditGLAcc',glAcc.Id);
                }else  if(glAcc.name == listGLSettings[0].Debit_Account__c){
                    mapGlAccounts.put('debitGLAcc',glAcc.Id);
                }
            }
            if(mapGlAccounts.keyset().size()!=2){
                mapMsg.put('invalidGL',true);
                return mapMsg;
            }
            
            
            AcctSeed__Journal_Entry__c  objJE = new AcctSeed__Journal_Entry__c();
            objJE.Name ='ATO Void/Refund ' +'/'+listMatter[0].name+'/'+ system.now().format('MM-dd-yyyy');
            if(system.test.isRunningTest()){
                List<AcctSeed__Ledger__c>listLeder = [select id from AcctSeed__Ledger__c where  AcctSeed__Type__c = 'Transactional'];
                objJE.AcctSeed__Ledger__c = listLeder[0].id;
            }
            sp= database.setSavepoint();
            Insert objJE;
            
            AcctSeed__Journal_Entry_Line__c objDebitJELine= new AcctSeed__Journal_Entry_Line__c();
            objDebitJELine.AcctSeed__Journal_Entry__c =objJE.Id;
            objDebitJELine.AcctSeed__Reference__c ='ATO Void/Refund';
            objDebitJELine.AcctSeed__Debit__c = amount;
            objDebitJELine.AcctSeed__Date__c= system.Date.today();
            objDebitJELine.AcctSeed__GL_Account__c =mapGlAccounts.get('debitGLAcc');           
            
            if(listProjects.size()>0){
                objDebitJELine.AcctSeed__Project__c =listProjects[0].id;
            }
            objDebitJELine.AcctSeed__Project_Task__c = projectTaskId;
            listJELinesToInsert.add(objDebitJELine);
            
            AcctSeed__Journal_Entry_Line__c objCreditJELine= new AcctSeed__Journal_Entry_Line__c();
            objCreditJELine.AcctSeed__Journal_Entry__c =objJE.Id;            
            objCreditJELine.AcctSeed__Credit__c = amount;
            objCreditJELine.AcctSeed__Date__c= system.Date.today();
            objCreditJELine.AcctSeed__GL_Account__c =mapGlAccounts.get('creditGLAcc');
            if(listProjects.size()>0){
                objCreditJELine.AcctSeed__Project__c =listProjects[0].id;
            }
            objCreditJELine.AcctSeed__Project_Task__c = projectTaskId;
            objCreditJELine.AcctSeed__Reference__c ='ATO Void/Refund';
            listJELinesToInsert.add(objCreditJELine);
            
            if(listJELinesToInsert.size()>0){
                insert listJELinesToInsert;
            }
            system.debug('objCreditJELine '+objCreditJELine.Id);
            litify_pm__Expense__c objNegativeExpense = new litify_pm__Expense__c();
            objNegativeExpense.litify_pm__Matter__c =  matterId;
            objNegativeExpense.Origin__c = 'AP';
            objNegativeExpense.Stage__c = 'Approved';
            objNegativeExpense.Billing_Status__c ='Billed';
            objNegativeExpense.Vendor__c = listMatter[0].litify_pm__Client__c;
            objNegativeExpense.litify_pm__Date__c = system.Date.today();            
            objNegativeExpense.litify_pm__ExpenseType2__c = listExpType[0].id;
            objNegativeExpense.litify_pm__Amount__c = amount*(-1);
            objNegativeExpense.litify_pm__Expense_Description__c = comment;
            objNegativeExpense.Parent_Expense__c = expenseId;
            objNegativeExpense.Journal_Entry_Line__c = objCreditJELine.Id;
            insert objNegativeExpense;
            
            system.debug('objNegativeExpense.Expense_Category__c'+objNegativeExpense.Expense_Category__c);
            //since trigger set the Stage__c ='In-Process' and Billing_Status__c='Unbilled'
            objNegativeExpense.Stage__c = 'N/A'; 
            //objNegativeExpense.Origin__c='AP';
            objNegativeExpense.Billing_Status__c ='Billed';
            update objNegativeExpense;
            
           /* AcctSeed__Account_Payable__c objPayable = new AcctSeed__Account_Payable__c();
            objPayable.AcctSeed__Status__c='Approved';
            objPayable.AcctSeed__Date__c = system.Date.today();
            objPayable.AcctSeed__Payee_Reference__c = 'Client Cost Refund/'+listMatter[0].Name+'/'+system.now().format('yyyy-MM-dd hh:mm:ss a');
            objPayable.AcctSeed__Vendor__c = listMatter[0].litify_pm__Client__c;
            objPayable.Expense_Type__c ='Matter';
            objPayable.Origin__c ='Litify';
            if(system.test.isRunningTest()){
                List<AcctSeed__Ledger__c>listLeder = [select id from AcctSeed__Ledger__c where  AcctSeed__Type__c = 'Transactional'];
                objPayable.AcctSeed__Ledger__c = listLeder[0].id;
            }
            insert objPayable;
            
            AcctSeed__Account_Payable_Line__c objPayableLine = new AcctSeed__Account_Payable_Line__c();
            objPayableLine.AcctSeed__Account_Payable__c = objPayable.id;
            objPayableLine.AcctSeed__Amount__c = amount;
            objPayableLine.AcctSeed__Quantity__c =1;
            objPayableLine.Matter__c = matterId;
            objPayableLine.AcctSeed__Expense_GL_Account__c=  mapGlAccounts.get('creditGLAcc'); 
            objPayableLine.Matter__c = matterId;
            if(listProjects.size()>0){
                objPayableLine.AcctSeed__Project__c =listProjects[0].id;
            }
            objPayableLine.Expense_Type__c =listExpType[0].id;
            objPayableLine.AcctSeed__Project_Task__c = projectTaskId;
            insert objPayableLine;
*/
            mapMsg.put('success',true);
        }
        catch(Exception ex){
            mapMsg.put('errorOccured',true);
            if(sp!=null){
                database.rollback(sp);
            }
        }
        return mapMsg;
    }
    
    @AuraEnabled
    public static litify_pm__Expense__c getExpenseDetails(string expenseId){
        system.debug('expenseId '+expenseId);
        litify_pm__Expense__c objExpense = new litify_pm__Expense__c();
        try{
            if(!string.isEmpty(expenseId)){
                list<litify_pm__Expense__c>listExpense = [select id,litify_pm__Amount__c,litify_pm__Matter__c,Amount_after_Reductions__c from litify_pm__Expense__c where id=:expenseId]; 
                if(listExpense.size()>0){
                    objExpense= listExpense[0];
                }
            }
        }
        catch(Exception ex){}
        return objExpense;
    }
}