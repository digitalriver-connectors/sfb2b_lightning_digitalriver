trigger DRB2B_OrderTrigger on Order(before insert, before update, before delete, after insert, after update) {
    TriggerDispatcher.runMetadataDefinedTriggers();
}
