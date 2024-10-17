public class createNewProjectController {
    public string matterId{get;set;}
    public string errorMsg{get;set;} 
    public boolean showSuccess{get;set;}
    public boolean showError{get;set;}
    public litify_pm__Matter__c objMatter{get;set;}
    
    public createNewProjectController(){
        string recId = ApexPages.currentPage().getParameters().get('id');
        if(!string.isEmpty(recId)){
            matterId = recId;
        }
    }
    
    public pagereference checkValidation(){
        showError = false;
        try{
            List<AcctSeed__Project__c>listProject = [select id from AcctSeed__Project__c where Matter__c=:matterId];
            list<litify_pm__Matter__c>listMatter = [select id,name from litify_pm__Matter__c where id=:matterId];
            if(listProject.size()>0){
                showError =true;
                errorMsg='Project is already created';
            }
            else if(listMatter.size()==0){
                showError =true;
                errorMsg='Invalid record Id';
            }
            else{
                objMatter= listMatter[0];
                createProject();
            }
        }        
        catch(Exception ex){}
        return null;
    }
    
    public void createProject(){
        AcctSeed__Project__c objProject = new AcctSeed__Project__c();
        objProject.name = objMatter.Name;
        objProject.Matter__c =matterId;        
        insert objProject;
        
        List<AcctSeed__GL_Account__c> listRevGLAccount=[select id from AcctSeed__GL_Account__c where name=:label.Project_task_Revenue_GL_Account];
        AcctSeed__Project_Task__c objProjectTask = new AcctSeed__Project_Task__c();
        objProjectTask.AcctSeed__Project__c = objProject.id;
        objProjectTask.Name ='Default Task';
        objProjectTask.AcctSeed__Labor_GL_Account__c=listRevGLAccount[0].Id;
        insert objProjectTask;
        showSuccess =true;
        
    }
    
    public PageReference redirectToDetail(){
        PageReference pg ;
        try
        {
            if(!string.isEmpty(matterId)){
                system.debug('recordId '+matterId);
                pg= new PageReference('/'+matterId);
                pg.setRedirect(true);
                return pg;
            }
            
        }
        catch(Exception ex){}
        return pg;
        
    }
}