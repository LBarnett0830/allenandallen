@isTest
public class addGLVarsOnFinancialStmtControllerTest {
    
    public static testmethod void testAll(){
        
        AcctSeed__GL_Account__c objGL=   new AcctSeed__GL_Account__c(
            Name = '3050-Retained Earnings',
            AcctSeed__Active__c = true,
            AcctSeed__Type__c = 'Balance Sheet',
            AcctSeed__Sub_Type_1__c = 'Owners Equity',
            AcctSeed__Sub_Type_2__c = 'Equity'  
        );
        insert objGL;
        
        list<AcctSeed__Accounting_Variable__c>listGLVariables = new  list<AcctSeed__Accounting_Variable__c>();
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='Richmond',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 1'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test1',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 2'));
        listGLVariables.add(new AcctSeed__Accounting_Variable__c(name='test4',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 3'));
        listGLVariables.add( new AcctSeed__Accounting_Variable__c(name='PI',AcctSeed__Active__c=true,AcctSeed__Type__c='GL Account Variable 4'));
        insert listGLVariables;
        
        AcctSeed__Financial_Report_Definition__c objDef = new AcctSeed__Financial_Report_Definition__c();
        insert objDef;
        
        AcctSeed__Financial_Report_Row__c objRow = new AcctSeed__Financial_Report_Row__c(
            AcctSeed__Financial_Report_Definition__c = objDef.Id,
            AcctSeed__Position__c = 10,
            AcctSeed__GL_Account__c = objGL.id
        );
        insert objRow;
        
        addGLVarsOnFinancialStmtController.statementWrapper objWrapper =  addGLVarsOnFinancialStmtController.getWrapperDetails(objDef.Id);
        objWrapper.serviceLineId = listGLVariables[0].Id;
        addGLVarsOnFinancialStmtController.updateGLVars(objWrapper);
        
    }
}