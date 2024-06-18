trigger DRB2B_CartItemTrigger on CartItem(
    before insert,
    before update,
    before delete,
    after insert,
    after update,
    after delete
) {
    TriggerDispatcher.runMetadataDefinedTriggers();
}
