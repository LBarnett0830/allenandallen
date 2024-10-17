/*
Author     : Cmentor/ Sampath Suranji
Date       :06/05/2020
Description: Create Project and a Project task when matter create
*/
public class matterTriggerHandler {
    
    
    public static void afterInsert(list<litify_pm__Matter__c>newList){
        try{
            
            //Create Project & task
            List<AcctSeed__Project__c>listProjectToInsert = new List<AcctSeed__Project__c>();
            List<AcctSeed__Project_Task__c>listProjectTaskToInsert = new List<AcctSeed__Project_Task__c>();
            
            for(litify_pm__Matter__c objMatter:newList){
                AcctSeed__Project__c objProject = new AcctSeed__Project__c();
                objProject.name = objMatter.Name;
                objProject.Matter__c =objMatter.Id;
                listProjectToInsert.add(objProject);
            }
            
            if(listProjectToInsert.size()>0){
                set<id>insertedProjectIds = new set<id>();
                Database.SaveResult [] srList = Database.insert(listProjectToInsert);
                for( Database.SaveResult sr:srList){
                    insertedProjectIds.add(sr.getId());
                }
                
                //create default project task for each project
                List<AcctSeed__GL_Account__c> listRevGLAccount=[select id from AcctSeed__GL_Account__c where name=:label.Project_task_Revenue_GL_Account];
                for(id projectId:insertedProjectIds){
                    AcctSeed__Project_Task__c objProjectTask = new AcctSeed__Project_Task__c();
                    objProjectTask.AcctSeed__Project__c = projectId;
                    objProjectTask.Name ='Default Task';
                    objProjectTask.AcctSeed__Labor_GL_Account__c=listRevGLAccount[0].Id;
                    listProjectTaskToInsert.add(objProjectTask);
                }
                if(listProjectTaskToInsert.size()>0){
                    insert listProjectTaskToInsert;
                }
            }
            
        }
        catch(Exception ex){}
    }
    
}