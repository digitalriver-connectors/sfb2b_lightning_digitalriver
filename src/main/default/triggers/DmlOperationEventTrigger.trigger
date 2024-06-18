trigger DmlOperationEventTrigger on DmlOperation__e (after insert) {
  Map<String, List<SObject>> dmlRecord = new Map<String, List<SObject>>();
  List<SObject> payload = new List<SObject>();

  for (DmlOperation__e record : Trigger.new) {
    SObject obj = (SObject)JSON.deserialize(record.Payload__c, SObject.class);
    dmlRecord.put(record.Operation__c, new List<SObject> {obj});
  }

  for (String Operation : dmlRecord.keySet())
  {
    for (SObject record : dmlRecord.get(Operation))
    {
      payload.add(record);
    }
  }

  update(payload);

}