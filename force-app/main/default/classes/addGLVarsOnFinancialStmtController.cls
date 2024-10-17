public class addGLVarsOnFinancialStmtController {
    
    @auraEnabled
    public static statementWrapper getWrapperDetails(string stmtId){
        statementWrapper objWrapper = new statementWrapper();
        if(!string.isempty( stmtId)){
            list<AcctSeed__Financial_Report_Row__c> listRow =[select id,AcctSeed__GL_Account_Variable_1__c,AcctSeed__GL_Account_Variable_2__c,
                                                              AcctSeed__GL_Account_Variable_3__c,AcctSeed__GL_Account_Variable_1__r.Name,
                                                              AcctSeed__GL_Account_Variable_2__r.Name,AcctSeed__GL_Account_Variable_3__r.Name
                                                              from AcctSeed__Financial_Report_Row__c 
                                                              where AcctSeed__Financial_Report_Definition__c=:stmtId limit 1];
            if(listRow.size()>0){
                objWrapper.stmtId= stmtId;
                objWrapper.serviceLineId= listRow[0].AcctSeed__GL_Account_Variable_1__c;
                objWrapper.serviceLineName= listRow[0].AcctSeed__GL_Account_Variable_1__r.Name;
                objWrapper.locationId= listRow[0].AcctSeed__GL_Account_Variable_2__c;
                objWrapper.locationName= listRow[0].AcctSeed__GL_Account_Variable_2__r.Name;
                objWrapper.departmentId= listRow[0].AcctSeed__GL_Account_Variable_3__c;
                objWrapper.departmentName = listRow[0].AcctSeed__GL_Account_Variable_3__r.Name;
            }
        }
        return objWrapper;
    }
    
    @auraEnabled
    public static map<string,string> updateGLVars(statementWrapper objWrapper ){
        map<string,string> mapMsg = new map<string,string>();
        
        try{
            if(!string.isEmpty(objWrapper.stmtId)){
                
                list<AcctSeed__Financial_Report_Row__c> listRows = new   list<AcctSeed__Financial_Report_Row__c>();
                for(AcctSeed__Financial_Report_Row__c objRow:[select id,AcctSeed__GL_Account_Variable_1__c,AcctSeed__GL_Account_Variable_2__c,
                                                              AcctSeed__GL_Account_Variable_3__c from AcctSeed__Financial_Report_Row__c 
                                                              where AcctSeed__Financial_Report_Definition__c=:objWrapper.stmtId])
                {
                    if(!string.isEmpty(objWrapper.serviceLineId)){
                        objRow.AcctSeed__GL_Account_Variable_1__c = objWrapper.serviceLineId;
                    }
                    else{
                        objRow.AcctSeed__GL_Account_Variable_1__c = null;
                    }
                    
                    if(!string.isEmpty(objWrapper.locationId)){
                        objRow.AcctSeed__GL_Account_Variable_2__c = objWrapper.locationId;
                    }
                    else{
                        objRow.AcctSeed__GL_Account_Variable_2__c = null;
                    }
                    
                    if(!string.isEmpty(objWrapper.departmentId)){
                        objRow.AcctSeed__GL_Account_Variable_3__c = objWrapper.departmentId;
                    }
                    else{
                        objRow.AcctSeed__GL_Account_Variable_3__c = null;
                    }
                    
                    listRows.add(objRow);
                }
                
                if(listRows.size()>0){
                    update listRows;
                }
                mapMsg.put('success','true');
            }
            
        }
        catch(Exception ex){
            mapMsg.put('error','true');
        }
        return mapMsg;
    }
    
    public class statementWrapper{
        @auraEnabled public string stmtId{get;set;} 
        @auraEnabled public string locationId{get;set;}
        @auraEnabled public string locationName{get;set;}
        @auraEnabled public string departmentId{get;set;}
        @auraEnabled public string departmentName{get;set;}
        @auraEnabled public string serviceLineId{get;set;}
        @auraEnabled public string serviceLineName{get;set;}
    }
}