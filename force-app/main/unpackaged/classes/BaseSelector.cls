public with sharing class BaseSelector implements iBaseSelector{
    private static final String LOG_PREFIX = '[BaseSelector] ';
    private Set<Schema.SObjectField> m_fields {get; set; }
    private Integer m_rowLimit { get; set; }
    private Schema.SobjectType m_SobjectType { get; set; }
    private Map<String, Schema.SObjectField> m_fieldMap { get; set; }
    private String m_whereCritera { get; set; }

    private Map<String, Schema.SObjectField> fieldMap {
        get {
            if (m_fieldMap == null) {
                m_fieldMap = m_SobjectType.fields.getMap();
            }
            return m_fieldMap;
        }
    }

    public BaseSelector(Schema.SObjectType coveredSobject) { m_SobjectType = coveredSobject; }

    public SojectType GetSobjectType() { return m_SobjectType; }

    private void initialize(Schema.SobjectType forType, Set<Schema.SObjectField> includedFields){
        m_fields = includedFields;

    }

    /** 
    * @description Define the 'WHERE' clause in the query
    * @param String criteria
    */
    public WithCriteria(String criteria){
        if(m_whereCritera == null){
            m_whereCritera = '';
            m_whereCritera += criteria;
        }else{
            m_whereCritera += ' ' + criteria;
        }
    }

    public String generateSelect() {
        String soql = 'SELECT ';
        Integer lenBefore = soql.length();
        soql += generateFields();
        return soql;

    }

    public String generateFields() {
        String soql = '';
        for(Schema.SObjectField field : m_fields) {
            if(soql.length() > 1 ){
                soql += ', ';
            }
            soql += field.getDescribe().getName();
        }
        return soql;
    }

    private String generateFrom() {
        return ' FROM ' + m_SobjectType.getDescribe().getName();
    }
}