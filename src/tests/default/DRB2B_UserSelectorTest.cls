@IsTest
private class DRB2B_UserSelectorTest {
    @isTest
    static void testGetById() {
        //Given
        ATK.SaveResult result = ATK.prepare(User.SObjectType, 1).build(EntityBuilderFactory.userBuilder).save(false);

        User usr = (User) result.get(User.SObjectType)[0];
        Profile sysAdmin = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        usr.ProfileId = sysAdmin.Id;
        usr.CommunityNickname = 'NickTestAdmin';
        insert usr;

        //When
        Test.startTest();
            User userFromDB = new DRB2B_UserSelector().getById(usr.Id, new Set<String>{ 'Id', 'FirstName', 'LastName', 'Email', 'Username' });
        Test.stopTest();

        //Then
        System.assert(userFromDB.Id == usr.Id);
        System.assert(userFromDB.FirstName == usr.FirstName);
        System.assert(userFromDB.LastName == usr.LastName);
        System.assert(userFromDB.Email == usr.Email);
        System.assert(userFromDB.Username == usr.Username);
    }
}
