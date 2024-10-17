/*
Author: Cmentor/Sampath Suranji
Date  :06/15/2020
Description : closingStatementController for Resolution Closing statement custom button
*/
public class closingStatementController {
    public static litify_pm__Resolution__c objResolution{get;set;}
    
    @AuraEnabled
    public static  map<string,boolean> generateStatement(string resolutionId,string statementType){
        map<string,boolean> mapMsg = new map<string,boolean>();
        objResolution= new litify_pm__Resolution__c();
        try{
            List<litify_pm__Resolution__c> listResolution =[select id,Name,Status__c from litify_pm__Resolution__c where id=:resolutionId];
            if(listResolution.size()>0){
                objResolution = listResolution[0];
                /*if(objResolution.Status__c=='In-Process'){
mapMsg.put('invalidStage',true);
}
else{
createStatementPdf(statementType);
}*/
                
                createStatementPdf(statementType);
            }
            
        }
        catch(Exception ex){
            System.debug('num : ' + ex.getLineNumber());
            System.debug('msg : ' + ex.getMessage() );
        }
        return mapMsg;
    }
    
    
    public static void createStatementPdf(string statementType){
        
        List<Attachment>attachmentToInsert = new List<Attachment>();
        PageReference objPdfStatement =  page.closingStatementPdf;        
        Attachment objAttachment = new Attachment();
        
        if(statementType=='Rough'){
            objPdfStatement =  page.closingStatementPdf;
            objAttachment.Name ='Rough_'+objResolution.Name+'_'+ system.Datetime.now().format('MM-dd-yyyy HH:mm:ss')+'.pdf';
        }
        else{
            objPdfStatement =  page.closingStatementFinalPdf;
            objAttachment.Name ='Final_'+objResolution.Name+'_'+ system.Datetime.now().format('MM-dd-yyyy HH:mm:ss')+'.pdf';
        }
        objPdfStatement.getParameters().put('id',objResolution.Id);
        objPdfStatement.getParameters().put('type',statementType);       
        
        Blob pdfStatementBlob;
        if(System.Test.isRunningTest()){
            pdfStatementBlob = blob.valueOf('test');
        }else{
            pdfStatementBlob = objPdfStatement.getContent();
        }
        objAttachment.Body = pdfStatementBlob;            
        objAttachment.IsPrivate = false;
        objAttachment.ParentId = objResolution.Id;
        attachmentToInsert.add(objAttachment); 
        
        insert attachmentToInsert;
    }
    
    
}