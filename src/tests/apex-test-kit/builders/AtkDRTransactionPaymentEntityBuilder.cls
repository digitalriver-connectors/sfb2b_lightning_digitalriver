public class AtkDRTransactionPaymentEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity drTransactionPaymentEntity, Integer size) {
        drTransactionPaymentEntity.field(DR_Transaction_Payment__c.Name).index('DRTP-{0000}');
    }
}
