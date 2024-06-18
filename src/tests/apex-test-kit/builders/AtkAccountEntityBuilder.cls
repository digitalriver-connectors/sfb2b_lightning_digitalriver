public class AtkAccountEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity accountEntity, Integer size) {
        accountEntity
                .field(Account.Name).index('Community Account {0000}')
                .field(Account.Type).repeat('Customer');
    }
}