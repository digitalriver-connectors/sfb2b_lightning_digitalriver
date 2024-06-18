public with sharing class AtkUserEntityBuilder implements ATK.EntityBuilder {
    public void build(ATK.Entity userEntity, Integer size) {
        userEntity
            .field(User.FirstName)
            .index('ABX {0000}')
            .field(User.LastName)
            .index('XYZ {0000}')
            .field(User.Username)
            .index('test.user+{0000}@email.com')
            .field(User.Alias)
            .index('test{0000}')
            .field(User.EmailEncodingKey)
            .repeat('ISO-8859-1')
            .field(User.TimeZoneSidKey)
            .repeat('America/Los_Angeles')
            .field(User.LocaleSidKey)
            .repeat('en_US')
            .field(User.LanguageLocaleKey)
            .repeat('en_US')
            .field(User.CommunityNickname)
            .Index('nick+{0000}')
            .field(User.IsActive)
            .repeat(true)
            .field(User.PortalRole)
            .repeat('Manager')
            .field(User.Email)
            .index('test.user+{0000}@email.com');
    }
}
