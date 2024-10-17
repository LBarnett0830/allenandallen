@isTest
private with sharing class EtlToolHelperTest {
  static {
    SObject fileObjectPreference = ((SObject) Type.forName('litify_docs__File_Object_Preferences__c').newInstance()).getSObjectType().newSObject();
    fileObjectPreference.put('Name', 'Account');
    insert fileObjectPreference;



    SObject packet = ((SObject) Type.forName('litify_docs__Packet__c').newInstance()).getSObjectType().newSObject();
    packet.put('litify_docs__Starting_Object__c', 'Account');

    SObject template = ((SObject) Type.forName('litify_docs__Template__c').newInstance()).getSObjectType().newSObject();
    template.put('litify_docs__Template_Number__c', String.valueOf(Crypto.getRandomInteger()));
    template.put('litify_docs__Starting_Object__c', 'Account');
    template.put('litify_docs__Merged_File_Name__c', 'Template 1');

    SObject templateTwo = ((SObject) Type.forName('litify_docs__Template__c').newInstance()).getSObjectType().newSObject();
    templateTwo.put('litify_docs__Template_Number__c', String.valueOf(Crypto.getRandomInteger()));
    templateTwo.put('litify_docs__Starting_Object__c', 'Case');
    templateTwo.put('litify_docs__Merged_File_Name__c', 'Template 2');

    insert new List<SObject> { packet, template, templateTwo };

    SObject junction = ((SObject) Type.forName('litify_docs__Packet_Template_Junction__c').newInstance()).getSObjectType().newSObject();
    junction.put('litify_docs__Packet__c', packet.get('Id'));
    junction.put('litify_docs__Template__c', template.get('Id'));

    SObject junctionTwo = ((SObject) Type.forName('litify_docs__Packet_Template_Junction__c').newInstance()).getSObjectType().newSObject();
    junctionTwo.put('litify_docs__Packet__c', packet.get('Id'));
    junctionTwo.put('litify_docs__Template__c', templateTwo.get('Id'));

    insert new List<SObject> { junction, junctionTwo };

    SObject node = ((SObject) Type.forName('litify_docs__Node__c').newInstance()).getSObjectType().newSObject();
    insert node;

    SObject templateNodeJunction = ((SObject) Type.forName('litify_docs__Template_Node_Junction__c').newInstance()).getSObjectType().newSObject();
    templateNodeJunction.put('litify_docs__Template__c', template.get('Id'));
    templateNodeJunction.put('litify_docs__Node__c', node.get('Id'));
    insert templateNodeJunction;

    SObject input = ((SObject) Type.forName('litify_docs__Input__c').newInstance()).getSObjectType().newSObject();
    input.put('litify_docs__Type__c', String.valueOf(Schema.DisplayType.STRING));
    input.put('litify_docs__Object_Field_Name__c', 'Account');
    input.put('litify_docs__Starting_Object__c', 'Account');

    SObject inputTwo = ((SObject) Type.forName('litify_docs__Input__c').newInstance()).getSObjectType().newSObject();
    inputTwo.put('litify_docs__Type__c', String.valueOf(Schema.DisplayType.STRING));
    inputTwo.put('litify_docs__Object_Field_Name__c', 'CreatedBy.Name');
    inputTwo.put('litify_docs__Starting_Object__c', 'Account');

    SObject inputThree = ((SObject) Type.forName('litify_docs__Input__c').newInstance()).getSObjectType().newSObject();
    inputThree.put('litify_docs__Type__c', String.valueOf(Schema.DisplayType.PICKLIST));
    inputThree.put('litify_docs__Object_Field_Name__c', 'CreatedBy.LanguageLocaleKey');
    inputThree.put('litify_docs__Starting_Object__c', 'Account');

    insert new List<SObject> { input, inputTwo, inputThree };

    SObject inputOption = ((SObject) Type.forName('litify_docs__Input_Option__c').newInstance()).getSObjectType().newSObject();
    inputOption.put('litify_docs__Input__c', input.get('Id'));
    inputOption.put('litify_docs__Value__c', 'Test Option Value');
    insert inputOption;

    SObject nodeInputJunction = ((SObject) Type.forName('litify_docs__Node_Input_Junction__c').newInstance()).getSObjectType().newSObject();
    nodeInputJunction.put('litify_docs__Node__c', node.get('Id'));
    nodeInputJunction.put('litify_docs__Input__c', input.get('Id'));
    insert nodeInputJunction;

    SObject nodeInputJunctionTwo = ((SObject) Type.forName('litify_docs__Node_Input_Junction__c').newInstance()).getSObjectType().newSObject();
    nodeInputJunctionTwo.put('litify_docs__Node__c', node.get('Id'));
    nodeInputJunctionTwo.put('litify_docs__Input__c', inputTwo.get('Id'));
    insert nodeInputJunctionTwo;

    SObject nodeInputJunctionThree = ((SObject) Type.forName('litify_docs__Node_Input_Junction__c').newInstance()).getSObjectType().newSObject();
    nodeInputJunctionThree.put('litify_docs__Node__c', node.get('Id'));
    nodeInputJunctionThree.put('litify_docs__Input__c', inputThree.get('Id'));
    insert nodeInputJunctionThree;

    SObject inputFour = ((SObject) Type.forName('litify_docs__Input__c').newInstance()).getSObjectType().newSObject();
    inputFour.put('litify_docs__Parent_Input__c', input.get('Id'));
    inputFour.put('litify_docs__Starting_Object__c', 'Account');
    inputFour.put('litify_docs__Child_Relationship_Api_Name__c', 'ChildAccounts');
    inputFour.put('litify_docs__Object_Field_Name__c', 'CreatedBy.AboutMe');
    insert inputFour;
  }

  @isTest
  // public static DocufyData extractDocufyData()
  private static void testExtractDocufyData() {
    Test.startTest();
    EtlToolHelper.DocufyData docufyData = (EtlToolHelper.DocufyData) JSON.deserializeStrict(EtlToolHelper.extractDocufyData(), EtlToolHelper.DocufyData.class);
    Test.stopTest();

    System.assertNotEquals(null, docufyData, 'EtlToolHelper.extractDocufyData should not return null.');
    System.assert((docufyData.inputRecords.isEmpty() == false), 'litify_docs__Input__c records should be returned.');
  }

  @isTest
  // public static void loadDocufyData(String serializedDocufyData)
  private static void testLoadDocufyData() {
    EtlToolHelper.DocufyData docufyData = (EtlToolHelper.DocufyData) JSON.deserializeStrict(EtlToolHelper.extractDocufyData(), EtlToolHelper.DocufyData.class);

    Integer totalRecordCountBefore = getRecordCount();

    deleteTestData();

    Test.startTest();
    EtlToolHelper.loadDocufyData(JSON.serialize(docufyData));
    Test.stopTest();

    Integer totalRecordCountAfter = getRecordCount();

    System.assertNotEquals(0, totalRecordCountAfter, 'Records should exist');
    System.assertEquals(totalRecordCountBefore, totalRecordCountAfter, 'Record count mismatch');
  }

  private static void deleteTestData() {
    delete Database.query('SELECT Id FROM litify_docs__Packet__c');
    delete Database.query('SELECT Id FROM litify_docs__Template__c');
    delete Database.query('SELECT Id FROM litify_docs__Node__c');
    delete Database.query('SELECT Id FROM litify_docs__Input__c');
    delete Database.query('SELECT Id FROM litify_docs__Input_Option__c');
  }

  private static Integer getRecordCount() {
    Integer totalRecordCount = 0;
    totalRecordCount += Database.countQuery('SELECT COUNT() FROM litify_docs__Input_Format_Option__c');
    totalRecordCount += Database.countQuery('SELECT COUNT() FROM litify_docs__Input_Option__c');
    totalRecordCount += Database.countQuery('SELECT COUNT() FROM litify_docs__Input_Rule_Group_Junction__c');
    totalRecordCount += Database.countQuery('SELECT COUNT() FROM litify_docs__Input__c');
    totalRecordCount += Database.countQuery('SELECT COUNT() FROM litify_docs__Node_Input_Junction__c');
    totalRecordCount += Database.countQuery('SELECT COUNT() FROM litify_docs__Node__c');
    totalRecordCount += Database.countQuery('SELECT COUNT() FROM litify_docs__Packet__c');
    totalRecordCount += Database.countQuery('SELECT COUNT() FROM litify_docs__Packet_Template_Junction__c');
    totalRecordCount += Database.countQuery('SELECT COUNT() FROM litify_docs__Rule_Group__c');
    totalRecordCount += Database.countQuery('SELECT COUNT() FROM litify_docs__Rule__c');
    totalRecordCount += Database.countQuery('SELECT COUNT() FROM litify_docs__Template_Node_Junction__c');
    totalRecordCount += Database.countQuery('SELECT COUNT() FROM litify_docs__Template__c');
    return totalRecordCount;
  }
}