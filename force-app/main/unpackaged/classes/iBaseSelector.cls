public interface iBaseSelector {
    Schema.SObjectType GetUnderlyingType();

    iBaseSelector WithField(Schema.SObjectField field);

    iBaseSelector WithFields(List<Schema.SObjectField> fields);

    iBaseSelector WithLimit(Integer rowLimit);

    String GenerateSoql();

    SobjectType GetSobjectType();

    Set<Schema.SObjectField> GetDefaultFields();

    List<Sobject> Execute();
}