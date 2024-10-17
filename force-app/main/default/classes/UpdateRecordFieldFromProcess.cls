public with sharing class UpdateRecordFieldFromProcess {
    @InvocableMethod(label='Update Record field')
    public static void updateRecordField(List<InputParam> l_inputParams) {
        
        if (l_inputParams.size() > 0) {
            Schema.SObjectType objectType = l_inputParams[0].recordId.getSobjectType();
            Map<String, Schema.SObjectField> m_objectFields = objectType.getDescribe().fields.getMap();
            Set<String> s_soqlFields = new Set<String>();
            Map<String, String> m_fields = new Map<String, String>();
            List<Id> l_ids = new List<Id>();
            for(InputParam param : l_inputParams){
                Schema.SObjectField recordField = m_objectFields.get(param.recordField);
                if (recordField == null) {
                    for (Schema.SObjectField field : m_objectFields.values()) {
                        if (param.recordField == field.getDescribe().getLabel()) {
                            recordField = field;
                        }
                    }
                }
                if (recordField != null && m_fields.containsKey(param.recordField) == false) {
                    l_ids.add(param.recordId);
                    m_fields.put(param.recordField, recordField.getDescribe().getName());
                }
            }
            if (l_ids.size() > 0) {
                String fieldsStr = String.join(m_fields.values(), ',');
                String soqlQuery = 'SELECT '+fieldsStr+' FROM '+objectType.getDescribe().getName()+' WHERE Id IN: l_ids';
                Map<Id, sObject> m_records = new Map<Id, sObject>(Database.query(soqlQuery));
                List<sObject> l_forUpdate = new List<sObject>();
                for(InputParam param : l_inputParams){
                    String field = m_fields.get(param.recordField);
                    sObject obj = m_records.get(param.recordId);
                    if (field != null && obj != null) {
                        if (param.number_value != null){
                            obj.put(field, param.number_value);
                        }
                        else if (param.datetime_value != null){
                            obj.put(field, param.datetime_value);
                        }
                        else if (param.date_value != null){
                            obj.put(field, param.date_value);
                        }
                        else if (param.str_value != null){
                            obj.put(field, param.str_value);
                        }
                        else {
                            obj.put(field, param.boolean_value);
                        }
                        l_forUpdate.add(obj);
                    }
                }
                if (l_forUpdate.size() > 0) {
                    update l_forUpdate;
                }
            }
        }

       

    }
    //output details which goes from apex to flow
    public class InputParam{
        @InvocableVariable(required=true  label='Related Record Id ')
        public Id recordId;
        @InvocableVariable(required=true  label='Field Label or Api Name which need to be updated')
        public String recordField; // email template id 
        @InvocableVariable(label='String Value')
        public String str_value; 
        @InvocableVariable(label='Date Value')
        public Date date_value;  
        @InvocableVariable(label='Date time Value')
        public DateTime datetime_value;  
        @InvocableVariable(label='Number Value')
        public Decimal number_value;  
        @InvocableVariable(label='Boolean Value')
        public Boolean boolean_value; 
        
    }
}