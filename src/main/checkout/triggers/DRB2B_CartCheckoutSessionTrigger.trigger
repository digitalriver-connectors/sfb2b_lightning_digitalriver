trigger DRB2B_CartCheckoutSessionTrigger on CartCheckoutSession (before insert, before update, before delete, after insert, after update) {
    TriggerDispatcher.runMetadataDefinedTriggers();
}