@IsTest
public class DRB2B_TestEnvironment {

    public static final String ACCOUNT_SHOPPER_NAME = 'Shopper';

    public static User shopperUser {
        get {
            if (shopperUser == null) {
                shopperUser = getShopperUserInstance();
            }

            return shopperUser;
        }
        private set;
    }

    public static User integrationUser {
        get {
            if (integrationUser == null) {
                integrationUser = getIntegrationUserInstance();
            }

            return integrationUser;
        }
        private set;
    }

    public static User portalAccountOwner {
        get {
            if (portalAccountOwner == null) {
                portalAccountOwner = getPortalAccountOwnerInstance();
            }

            return portalAccountOwner;
        }
        private set;
    }

    public static UserRole portalRole {
        get {
            if (portalRole == null) {
                portalRole = getPortalRoleInstance();
            }

            return portalRole;
        }
        private set;
    }

    public static Account shopperAccount {
        get {
            if (shopperAccount == null) {
                createShopperUser();

                shopperAccount = [
                        SELECT Id
                        FROM Account
                        WHERE Name = :ACCOUNT_SHOPPER_NAME
                ];
            }

            return shopperAccount;
        }
        private set;
    }

    public static WebCart shopperCart {
        get {
            if (shopperCart == null) {
                shopperCart = [
                        SELECT Id
                        FROM WebCart
                        WHERE AccountId = :shopperAccount.Id
                ];
            }

            return shopperCart;
        }
        private set;
    }

    public static CartDeliveryGroup shopperCartDeliveryGroup {
        get {
            if (shopperCartDeliveryGroup == null) {
                shopperCartDeliveryGroup = [
                        SELECT Id
                        FROM CartDeliveryGroup
                        WHERE CartId = :shopperCart.Id Limit 1
                ];
            }

            return shopperCartDeliveryGroup;
        }
        private set;
    }

    private static User getShopperUserInstance() {
        List<User> users = [
                SELECT Id
                FROM User
                WHERE Profile.Name = :DRB2B_Constants.Profile.DR_SHOPPER
        ];

        User shopper;
        if (users.isEmpty()) {
            shopper = (User) ATK.prepare(Account.SObjectType)
                        .build(EntityBuilderFactory.accountBuilder)
                        .field(Account.Name).index(ACCOUNT_SHOPPER_NAME)
                            .withChildren(Contact.SObjectType, Contact.AccountId)
                            .build(EntityBuilderFactory.contactBuilder)
                                .withChildren(User.SObjectType, User.ContactId)
                                .build(EntityBuilderFactory.userBuilder)
                                .profile(DRB2B_Constants.Profile.DR_SHOPPER)
                        .save()
                        .get(User.SObjectType)
                        .get(0);
        } else {
            shopper = users.get(0);
        }


        return shopper;
    }

    public static User createShopperUser() {
        return getShopperUserInstance();
    }

    private static User getIntegrationUserInstance() {
        List<User> users = [
                SELECT Id
                FROM User
                WHERE Profile.Name = :DRB2B_Constants.Profile.DR_INTEGRATION
        ];

        User integrationUser;
        if (users.isEmpty()) {
            integrationUser = (User) ATK.prepare(User.SObjectType, 1)
                                .build(EntityBuilderFactory.userBuilder)
                                .profile(DRB2B_Constants.Profile.DR_INTEGRATION)
                                .save(false)
                                .get(User.SObjectType)
                                .get(0);
            integrationUser.UserName = 'integration' + System.currentTimeMillis() + '@test.com';
            integrationUser.Email = 'integration.user@test.com';
            integrationUser.Firstname = 'Integration';
            integrationUser.Lastname = 'User';
            integrationUser.CommunityNickname = System.currentTimeMillis() + '_' + integrationUser.CommunityNickname;
            insert integrationUser;
        } else {
            integrationUser = users.get(0);
        }
        return integrationUser;
    }

    public static User createIntegrationUser() {
        return getIntegrationUserInstance();
    }

    private static User getPortalAccountOwnerInstance() {
        UserRole portalRole = portalRole;
        List<User> users = [
                SELECT Id
                FROM User
                WHERE Profile.Name = :DRB2B_Constants.Profile.SYSTEM_ADMIN
                AND UserRoleId = :portalRole.Id
        ];

        User portalAccountOwner;
        if (users.isEmpty()) {
            portalAccountOwner = (User) ATK.prepare(User.SObjectType, 1)
                                .build(EntityBuilderFactory.userBuilder)
                                .profile(DRB2B_Constants.Profile.SYSTEM_ADMIN)
                                .save(false)
                                .get(User.SObjectType)
                                .get(0);
            portalAccountOwner.UserRoleId = portalRole.Id;
            portalAccountOwner.UserName = 'portalOwner' + System.currentTimeMillis() + '@test.com';
            portalAccountOwner.Email = 'portal.owner@test.com';
            portalAccountOwner.Firstname = 'Portal';
            portalAccountOwner.Lastname = 'Owner';
            portalAccountOwner.CommunityNickname = System.currentTimeMillis() + '_' + portalAccountOwner.CommunityNickname;
            insert portalAccountOwner;
        }
        else {
            portalAccountOwner = users.get(0);
        }
        return portalAccountOwner;
    }

    public static User createPortalAccountOwner() {
        return getPortalAccountOwnerInstance();
    }

    private static UserRole getPortalRoleInstance() {
        List<UserRole> userRoles = [
                SELECT Id
                FROM UserRole
                WHERE Name = :DRB2B_Constants.UserRole.DR_PORTAL_OWNER_ROLE_NAME
        ];

        UserRole portalRole;
        if (userRoles.isEmpty()) {
            portalRole = new UserRole(DeveloperName = DRB2B_Constants.UserRole.DR_PORTAL_OWNER_ROLE_DEVELOPER_NAME, Name = DRB2B_Constants.UserRole.DR_PORTAL_OWNER_ROLE_NAME, PortalType='None');
            insert portalRole;
        }
        else {
            portalRole = userRoles.get(0);
        }
        return portalRole;
    }

    public static UserRole createPortalRole() {
        return getPortalRoleInstance();
    }

    public static void assignPermissionSet(User user, String permissionSetName) {
        insert new PermissionSetAssignment(
                AssigneeId = user.Id,
                PermissionSetId = ATKCore.PERMISSION_SETS.getId(permissionSetName)
        );
    }

    public static void prepareStoreWithNonDigitalCart() {
        System.runAs(portalAccountOwner) {
            Account account = shopperAccount;

            ATK.SaveResult result = ATK.prepare(WebStore.SObjectType)
                .build(EntityBuilderFactory.webStoreBuilder)
                    .withChildren(WebCart.SObjectType, WebCart.WebStoreId)
                    .build(EntityBuilderFactory.webCartBuilder)
                    .field(WebCart.AccountId).repeat(account.Id)
                    .field(WebCart.DR_Checkout_Type__c).repeat(DRB2B_Constants.WebCart.TYPE_NON_DIGITAL)
                        .withChildren(CartDeliveryGroup.SObjectType, CartDeliveryGroup.CartId)
                        .build(EntityBuilderFactory.cartDeliveryGroupBuilder)
                .save();

            shopperCart = (WebCart) result.get(WebCart.SObjectType).get(0);
            shopperCartDeliveryGroup = (CartDeliveryGroup) result.get(CartDeliveryGroup.SObjectType).get(0);
        }
    }
}