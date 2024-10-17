/* 
* Name    : CloneController 
* Author  : Litify Developer
* Description   : Class used to store methods for Clone Lightning component
*/  
public with sharing class CloneController {

     /* 
        @Name     	  - getObjectName
        @Parameter    - recId - sObject record id
        @Return Type  - sObject Name 
        @Description  - this method execute method from CloneUtilities 'getObjectName'
    */
    @AuraEnabled
    public static String getObjectName(Id recId){
        return CloneUtilities.getObjectName(recId, 'Name');
    }

    /* 
        @Name     	  - getAvailableObjects
        @Parameter    - no
        @Return Type  - List<String> - return list of avialbe child records for cloning action
        @Description  - this method execute method from CloneUtilities 'getAvailableObjects'
    */
    @AuraEnabled
    public static List<SelectOptionCustom> getAvailableObjects(Id recId){
        return CloneUtilities.getAvailableObjects(recId);
    }

    /* 
        @Name     	  - clonesObjectRecord
        @Parameter    - sObjectId - SFDC object id for record which need to be cloned
						l_objects - selected child records for cloning
                        numberOfRecords - number of records which need to be created
        @Return Type  - return new cloned matter id 
        @Description  - this method used to clone matter record with child records
    */
    @AuraEnabled
    public static List<SelectOptionCustom> clonesObjectRecord(Id sObjectId,  List<String> l_objects, Integer numberOfRecords){
        if (numberOfRecords == 0) {
            numberOfRecords = 1;
        }
        Map<String, String> m_relationshipNames = CloneUtilities.getRelationshipNameAndObjectName(sObjectId, l_objects);
        List<SFDCObject> l_sObjectResults  = CloneUtilities.getQueryResultsWrapper(new List<Id>{sObjectId}, l_objects);

        Map<String, Schema.SObjectField> m_fields  = sObjectId.getSobjectType().getDescribe().fields.getMap();
        List<String> l_clearFields = CloneUtilities.getClearFields(sObjectId.getSobjectType().getDescribe().getName());
        Set<Id> s_newIds = new Set<Id>();
        if (l_sObjectResults.size() > 0) {
            SFDCObject sfdcObject = l_sObjectResults[0];
            try{
                for(Integer i =0; i< numberOfRecords ; i++ ) {
                    sObject newsfdcObject = sfdcObject.parentObject.clone(false, false, false, false);
                    if (l_clearFields != null && l_clearFields.size() > 0) {
                        for(String item : l_clearFields) {
                           	Schema.SObjectField objectfield =  m_fields.get(item);
                            if (objectfield != null) {
                                if (objectfield.getDescribe().getType() == Schema.DisplayType.BOOLEAN) {
                                    newsfdcObject.put(item, false);
                                }
                                else {
                                    newsfdcObject.put(item, null);
                                }
                            }
                        }
                    }
                    insert newsfdcObject;
                    s_newIds.add(newsfdcObject.Id);
                    String roleChildRelationship = m_relationshipNames.get('litify_pm__Roles__r');
                    if (roleChildRelationship != null) {
                        List<litify_pm__Role__c> l_objectsTemp = (List<litify_pm__Role__c>)l_sObjectResults[0].m_childRecords.get('litify_pm__Roles__r');
                        if (l_objectsTemp != null && l_objectsTemp.size() > 0) {
                            Map<Id, litify_pm__Role__c> m_roles = new Map<Id, litify_pm__Role__c>();
                            Map<Id, Id> m_parentRolesIds = new Map<Id, Id>();
                            for(litify_pm__Role__c rec : l_objectsTemp) {
                                litify_pm__Role__c newRec = rec.clone(false, false, false, false);
                                newRec.put(roleChildRelationship, newsfdcObject.Id);
                                if (newRec.litify_pm__Parent_Role__c != null) {
                                    m_parentRolesIds.put(rec.Id, newRec.litify_pm__Parent_Role__c);
                                }
                                newRec.litify_pm__Parent_Role__c = null;
                                m_roles.put(rec.Id, newRec);
                            }
                            insert m_roles.values();
                            /*List<String> l_roleFields = m_rolesFields.get;
                            if () {

                            }*/
                            if (m_parentRolesIds.size() > 0) {
                                for (Id roleId : m_roles.keySet()) {
                                    litify_pm__Role__c role = m_roles.get(roleId);
                                    Id parentId = (Id)m_parentRolesIds.get(roleId);
                                    if (parentId != null) {
                                        system.debug('CHECK CLONE ---');
                                        litify_pm__Role__c parentRole = (litify_pm__Role__c) m_roles.get(parentId);
                                        if (parentRole != null) {
                                            role.litify_pm__Parent_Role__c = parentRole.Id;
                                        }
                                    }
                                    m_roles.put(roleId, role);
                                }
                            }
                            update m_roles.values();
                        }
                    }
                    for(String item : m_relationshipNames.keySet()){
                        if ('litify_pm__Roles__r' != item) {
                            List<sObject> l_objectsTemp = sfdcObject.m_childRecords.get(item);
                            // List<Sobject> l_child = (List<Sobject>) sfdcObject.getSObjects(item); cannot be used - reason ' Aggregate query has too many rows for direct assignment, use FOR loop' error if many child record exist
                            
                            if (l_objectsTemp != null && l_objectsTemp.size() > 0) {
                                List<sObject> l_clonedRecords = new List<sObject>();
                                for(sObject rec : l_objectsTemp) {
                                    sObject newRec = rec.clone(false, false, false, false);
                                    newRec.put(m_relationshipNames.get(item), newsfdcObject.Id);
                                    l_clonedRecords.add(newRec);
                                }
                                insert l_clonedRecords;
                            }
                        }
                    }
                }
            }
            catch(Exception ex) {
                throw new AuraHandledException('Clone action failed :'+ex.getMessage());
            }
        }
        else {
            throw new AuraHandledException('Clone action failed : No records for cloning');
        }
        return CloneUtilities.getResults(s_newIds, sObjectId, 'Name');
    }
}