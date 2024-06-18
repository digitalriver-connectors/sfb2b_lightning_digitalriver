public with sharing class DRB2B_UserSelector {

    public User getById(Id userId, Set<String> fields) {

        return (User) new DCM_Query('User')
            .selectFields(new List<String>(fields))
            .addConditionEq('Id', userId)
            .run()[0];
    }
}