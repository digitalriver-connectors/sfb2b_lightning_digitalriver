public with sharing class DRB2B_AccountService {
    @TestVisible
    private DRB2B_ContactPointAddressSelector contactPointAddressSelector = new DRB2B_ContactPointAddressSelector();

    @TestVisible
    private static String FOREIGNKEY = 'ParentId';

    @TestVisible
    private static DRB2B_UserSelector userSelector = new DRB2B_UserSelector();

    @TestVisible
    private static final Set<String> BASE_FIELD_SET = new Set<String>{ 'Address', 'IsDefault', 'AddressType', 'Id' };

    public List<ContactPointAddress> getContactAddresses(Id accountId) {
        return contactPointAddressSelector.getByForeignKey(FOREIGNKEY, BASE_FIELD_SET, accountId);
    }

    public List<ContactPointAddress> getCurrentUserAddresses() {
        User user = userSelector.getById(UserInfo.getUserId(), new Set<String>{ 'Contact.AccountId' });
        return getContactAddresses(user.Contact.AccountId);
    }
}
