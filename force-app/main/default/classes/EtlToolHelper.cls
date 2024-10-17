public with sharing class EtlToolHelper {
  @AuraEnabled
  public static String extractDocufyData() {
    DocufyData docufyData = new DocufyData();
    docufyData.inputFormatOptionRecords = Database.query('SELECT ' + String.join(getAccessibleFields('litify_docs__Input_Format_Option__c'), ',') + ' FROM litify_docs__Input_Format_Option__c');
    docufyData.inputOptionRecords = Database.query('SELECT ' + String.join(getAccessibleFields('litify_docs__Input_Option__c'), ',') + ' FROM litify_docs__Input_Option__c');
    docufyData.inputRuleGroupJunctionRecords = Database.query('SELECT ' + String.join(getAccessibleFields('litify_docs__Input_Rule_Group_Junction__c'), ',') + ' FROM litify_docs__Input_Rule_Group_Junction__c');
    docufyData.inputRecords = Database.query('SELECT ' + String.join(getAccessibleFields('litify_docs__Input__c'), ',') + ' FROM litify_docs__Input__c ORDER BY litify_docs__Input_Number__c');
    docufyData.nodeInputJunctionRecords = Database.query('SELECT ' + String.join(getAccessibleFields('litify_docs__Node_Input_Junction__c'), ',') + ' FROM litify_docs__Node_Input_Junction__c');
    docufyData.nodeRecords = Database.query('SELECT ' + String.join(getAccessibleFields('litify_docs__Node__c'), ',') + ' FROM litify_docs__Node__c');
    docufyData.packetRecords = Database.query('SELECT ' + String.join(getAccessibleFields('litify_docs__Packet__c'), ',') + ' FROM litify_docs__Packet__c');
    docufyData.packetTemplateJunctionRecords = Database.query('SELECT ' + String.join(getAccessibleFields('litify_docs__Packet_Template_Junction__c'), ',') + ' FROM litify_docs__Packet_Template_Junction__c');
    docufyData.ruleGroupRecords = Database.query('SELECT ' + String.join(getAccessibleFields('litify_docs__Rule_Group__c'), ',') + ' FROM litify_docs__Rule_Group__c');
    docufyData.ruleRecords = Database.query('SELECT ' + String.join(getAccessibleFields('litify_docs__Rule__c'), ',') + ' FROM litify_docs__Rule__c');
    docufyData.templateNodeJunctionRecords = Database.query('SELECT ' + String.join(getAccessibleFields('litify_docs__Template_Node_Junction__c'), ',') + ' FROM litify_docs__Template_Node_Junction__c');
    docufyData.templateRecords = Database.query('SELECT ' + String.join(getAccessibleFields('litify_docs__Template__c'), ',') + ' FROM litify_docs__Template__c');
    return JSON.serialize(docufyData);
  }

  @AuraEnabled
  public static void loadDocufyData(String serializedDocufyData) {
    DocufyData docufyData = (DocufyData) JSON.deserialize(serializedDocufyData, DocufyData.class);

    /**
     * litify_docs__Packet__c, litify_docs__Template__c, and litify_docs__Packet_Template_Junction__c
     */
    for (SObject templateRecord : docufyData.templateRecords) {
      templateRecord.put('litify_docs__Has_File__c', false);
    }
    Map<Id, Id> packetRecordOldIdToNewId = processGeneralRecords(docufyData.packetRecords);
    Map<Id, Id> templateRecordOldIdToNewId = processGeneralRecords(docufyData.templateRecords);
    processJunctionRecords(
      docufyData.packetTemplateJunctionRecords,
      'litify_docs__Packet__c',
      packetRecordOldIdToNewId,
      'litify_docs__Template__c',
      templateRecordOldIdToNewId
    );

    /**
     * litify_docs__Node__c and litify_docs__Template_Node_Junction__c
     */
    Map<Id, Id> nodeRecordOldIdToNewId = processGeneralRecords(docufyData.nodeRecords);
    processJunctionRecords(
      docufyData.templateNodeJunctionRecords,
      'litify_docs__Template__c',
      templateRecordOldIdToNewId,
      'litify_docs__Node__c',
      nodeRecordOldIdToNewId
    );

    /**
     * litify_docs__Input__c and litify_docs__Node_Input_Junction__c
     */
    Map<Id, Id> inputRecordOldIdToNewId = loadInputRecords(JSON.serialize(docufyData.inputRecords));

    processJunctionRecords(
      docufyData.nodeInputJunctionRecords,
      'litify_docs__Node__c',
      nodeRecordOldIdToNewId,
      'litify_docs__Input__c',
      inputRecordOldIdToNewId
    );

    /**
     * litify_docs__Input_Option__c and litify_docs__Input_Format_Option__c
     */
    processGeneralRecords(
      docufyData.inputOptionRecords,
      new Map<String, Map<Id, Id>> {
        'litify_docs__Input__c' => inputRecordOldIdToNewId
      }
    );
    processGeneralRecords(
      docufyData.inputFormatOptionRecords,
      new Map<String, Map<Id, Id>> {
        'litify_docs__Input__c' => inputRecordOldIdToNewId,
        'litify_docs__Template_Scope__c' => templateRecordOldIdToNewId
      }
    );

    /**
     * litify_docs__Rule_Group__c, litify_docs__Input_Rule_Group_Junction__c, and litify_docs__Rule__c
     */
    Map<Id, Id> ruleGroupRecordOldIdToNewId = processGeneralRecords(docufyData.ruleGroupRecords);
    processJunctionRecords(
      docufyData.inputRuleGroupJunctionRecords,
      'litify_docs__Input__c',
      inputRecordOldIdToNewId,
      'litify_docs__Rule_Group__c',
      ruleGroupRecordOldIdToNewId,
      new Map<String, Map<Id, Id>> {
        'litify_docs__Template_Scope__c' => templateRecordOldIdToNewId
      }
    );
    processGeneralRecords(
      docufyData.ruleRecords,
      new Map<String, Map<Id, Id>> {
        'litify_docs__Rule_Group__c' => ruleGroupRecordOldIdToNewId,
        'litify_docs__X_Input__c' => inputRecordOldIdToNewId,
        'litify_docs__Y_Input__c' => inputRecordOldIdToNewId
      }
    );
  }

  @AuraEnabled
  public static Map<Id, Id> loadInputRecords(String serializedRecords) {
    List<SObject> inputRecords = (List<SObject>)JSON.deserialize(serializedRecords, List<SObject>.class);
    /**
     * We need to ensure the Input Number values for the inputs remain the same as they were
     * in the source org. There could be gaps in the Input Number values due to inputs being
     * deleted in the past. For those gaps, we create "filler" inputs which are later deleted.
     */
    Integer maxInputNumber = -1;
    Map<Integer, SObject> inputsByInputNumber = new Map<Integer, SObject>();
    for (SObject input : inputRecords) {
      Integer inputNumber = Integer.valueOf(input.get('litify_docs__Input_Number__c'));
      inputsByInputNumber.put(inputNumber, input);
      if (inputNumber > maxInputNumber) {
        maxInputNumber = inputNumber;
      }
    }
    List<SObject> allInputs = new List<SObject>();
    List<SObject> parentInputs = new List<SObject>();
    List<SObject> childInputs = new List<SObject>();
    List<SObject> fillerInputs = new List<SObject>();
    for (Integer i = 1; i <= maxInputNumber; i++) {
      if (inputsByInputNumber.get(i) != null) {
        SObject realInput = inputsByInputNumber.get(i);
        allInputs.add(realInput);
        if (realInput.get('litify_docs__Parent_Input__c') == null) {
          parentInputs.add(realInput);
        } else {
          childInputs.add(realInput);
        }
      } else if (Test.isRunningTest() == false) {
        // In the context of a unit test, Salesforce was giving the input records an Input Number
        // of 100,000+, causing the unit test to try to create ~100,000 filler inputs. Therefore,
        // filler inputs are not created if the code is being run as part of a unit test.
        SObject fillerInput = (SObject)Type.forName('litify_docs__Input__c').newInstance();
        fillerInput.put('litify_docs__Starting_Object__c', 'Account');
        allInputs.add(fillerInput);
        fillerInputs.add(fillerInput);
      }
    }
    Map<Id, Id> oldChildInputIdToOldParentInputId = new Map<Id, Id>();
    for (SObject childInput : childInputs) {
      oldChildInputIdToOldParentInputId.put(childInput.Id, (Id)childInput.get('litify_docs__Parent_Input__c'));
      childInput.put('litify_docs__Parent_Input__c', null);
    }
    Map<Id, Integer> parentOldRecordIdToIndex = preprocessGeneralRecords(parentInputs);
    Map<Id, Integer> childOldRecordIdToIndex = preprocessGeneralRecords(childInputs);
    insert allInputs;
    delete fillerInputs;
    Map<Id, Id> parentInputRecordOldIdToNewId = postprocessGeneralRecords(parentInputs, parentOldRecordIdToIndex);
    Map<Id, Id> childInputRecordOldIdToNewId = postprocessGeneralRecords(childInputs, childOldRecordIdToIndex);
    for (Id oldRecordId : childOldRecordIdToIndex.keySet()) {
      SObject childInput = childInputs[childOldRecordIdToIndex.get(oldRecordId)];
      Id oldParentInputId = oldChildInputIdToOldParentInputId.get(oldRecordId);
      Id newParentInputId = parentInputRecordOldIdToNewId.get(oldParentInputId);
      childInput.put('litify_docs__Parent_Input__c', newParentInputId);
    }
    update childInputs;
    Map<Id, Id> inputRecordOldIdToNewId = new Map<Id, Id>();
    inputRecordOldIdToNewId.putAll(parentInputRecordOldIdToNewId);
    inputRecordOldIdToNewId.putAll(childInputRecordOldIdToNewId);
    return inputRecordOldIdToNewId;
  }

  @AuraEnabled
  public static void loadJunctionRecords(
    String serializedRecords,
    String detailOneKey,
    Map<Id, Id> detailOneOldIdToNewId,
    String detailTwoKey,
    Map<Id, Id> detailTwoOldIdToNewId
  ) {
    List<SObject> records = (List<SObject>)JSON.deserialize(serializedRecords, List<SObject>.class);
    processJunctionRecords(
      records,
      detailOneKey,
      detailOneOldIdToNewId,
      detailTwoKey,
      detailTwoOldIdToNewId
    );
  }

  @AuraEnabled
  public static void loadJunctionRecordsWithLookups(
    String serializedRecords,
    String detailOneKey,
    Map<Id, Id> detailOneOldIdToNewId,
    String detailTwoKey,
    Map<Id, Id> detailTwoOldIdToNewId,
    Map<String, Map<Id, Id>> lookupKeyToLookupRecordOldIdToNewId
  ) {
    List<SObject> records = (List<SObject>)JSON.deserialize(serializedRecords, List<SObject>.class);
    processJunctionRecords(
      records,
      detailOneKey,
      detailOneOldIdToNewId,
      detailTwoKey,
      detailTwoOldIdToNewId,
      lookupKeyToLookupRecordOldIdToNewId
    );
  }

  @AuraEnabled
  public static Map<Id, Id> loadNormalRecords(String serializedRecords) {
    List<SObject> records = (List<SObject>)JSON.deserialize(serializedRecords, List<SObject>.class);
    return processGeneralRecords(records);
  }

  @AuraEnabled
  public static Map<Id, Id> loadNormalRecordsWithLookups(
    String serializedRecords,
    Map<String, Map<Id, Id>> lookupKeyToLookupRecordOldIdToNewId
  ) {
    List<SObject> records = (List<SObject>)JSON.deserialize(serializedRecords, List<SObject>.class);
    return processGeneralRecords(records, lookupKeyToLookupRecordOldIdToNewId);
  }

  public static List<String> getAccessibleFields(String sObjectName) {
    List<String> accessibleFields = new List<String>();
    Map<String, Schema.SObjectField> fields = ((SObject) Type.forName(sObjectName).newInstance()).getSObjectType().getDescribe().fields.getMap();

    for (String field : fields.keySet()) {
      Schema.DescribeFieldResult fieldDescribe = fields.get(field).getDescribe();
      if (fieldDescribe.isAccessible()) {
        accessibleFields.add(fieldDescribe.getName());
      }
    }

    return accessibleFields;
  }

  private static Map<Id, Integer> preprocessGeneralRecords(List<SObject> records) {
    Map<Id, Integer> oldRecordIdToIndex = new Map<Id, Integer>();
    for (Integer i = 0; i < records.size(); i++) {
      oldRecordIdToIndex.put(records[i].Id, i);
      records[i].put('Id', null);
      
      try {
        records[i].put('OwnerId', UserInfo.getUserId());
      } catch (Exception e) {
        // Fail silently; not all SObjects have an OwnerId field
      }
    }
    return oldRecordIdToIndex;
  }

  private static void updateLookupFieldValues(
    List<SObject> records,
    Map<String, Map<Id, Id>> lookupKeyToLookupRecordOldIdToNewId
  ) {
    for (Integer i = 0; i < records.size(); i++) {
      for (String lookupKey : lookupKeyToLookupRecordOldIdToNewId.keySet()) {
        records[i].put(lookupKey, lookupKeyToLookupRecordOldIdToNewId.get(lookupKey).get((Id) records[i].get(lookupKey)));
      }
    }
  }

  private static Map<Id, Id> postprocessGeneralRecords(List<SObject> records, Map<Id, Integer> oldRecordIdToIndex) {
    Map<Id, Id> recordOldIdToNewId = new Map<Id, Id>();
    for (Id oldRecordId : oldRecordIdToIndex.keySet()) {
      recordOldIdToNewId.put(
        oldRecordId,
        records[oldRecordIdToIndex.get(oldRecordId)].Id
      );
    }

    return recordOldIdToNewId;
  }

  private static Map<Id, Id> processGeneralRecords(List<SObject> records) {
    return processGeneralRecords(records, new Map<String, Map<Id, Id>>());
  }

  private static Map<Id, Id> processGeneralRecords(
    List<SObject> records,
    Map<String, Map<Id, Id>> lookupKeyToLookupRecordOldIdToNewId
  ) {
    Map<Id, Integer> oldRecordIdToIndex = preprocessGeneralRecords(records);
    updateLookupFieldValues(records, lookupKeyToLookupRecordOldIdToNewId);
    insert records;
    return postprocessGeneralRecords(records, oldRecordIdToIndex);
  }

  private static void processJunctionRecords(
    List<SObject> records,
    String detailOneKey,
    Map<Id, Id> detailOneOldIdToNewId,
    String detailTwoKey,
    Map<Id, Id> detailTwoOldIdToNewId
  ) {
    processJunctionRecords(
      records,
      detailOneKey,
      detailOneOldIdToNewId,
      detailTwoKey,
      detailTwoOldIdToNewId,
      new Map<String, Map<Id, Id>>()
    );
  }

  private static void processJunctionRecords(
    List<SObject> records,
    String detailOneKey,
    Map<Id, Id> detailOneOldIdToNewId,
    String detailTwoKey,
    Map<Id, Id> detailTwoOldIdToNewId,
    Map<String, Map<Id, Id>> lookupKeyToLookupRecordOldIdToNewId
  ) {
    for (SObject record : records) {
      record.put(detailOneKey, detailOneOldIdToNewId.get((Id) record.get(detailOneKey)));
      record.put(detailTwoKey, detailTwoOldIdToNewId.get((Id) record.get(detailTwoKey)));
      record.put('Id', null);

      for (String lookupKey : lookupKeyToLookupRecordOldIdToNewId.keySet()) {
        record.put(lookupKey, lookupKeyToLookupRecordOldIdToNewId.get(lookupKey).get((Id) record.get(lookupKey)));
      }
    }

    insert records;
  }

  @TestVisible
  private class DocufyData {
    public List<SObject> inputFormatOptionRecords;
    public List<SObject> inputOptionRecords;
    public List<SObject> inputRuleGroupJunctionRecords;
    public List<SObject> inputRecords;
    public List<SObject> nodeInputJunctionRecords;
    public List<SObject> nodeRecords;
    public List<SObject> packetRecords;
    public List<SObject> packetTemplateJunctionRecords;
    public List<SObject> ruleGroupRecords;
    public List<SObject> ruleRecords;
    public List<SObject> templateNodeJunctionRecords;
    public List<SObject> templateRecords;
  }
}