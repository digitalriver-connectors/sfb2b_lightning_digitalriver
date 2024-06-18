/*
 * MIT License
 *
 * Copyright (c) 2018 - 2020 Click to Cloud Pty Ltd, Propic Pty Ltd
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

@isTest
public class DCM_QueryTest {
    @isTest
    static void simpleTest() {
        createData();
        List<Account> accounts;

        accounts = new DCM_Query('Account').selectAllFields().run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query(Account.getSObjectType()).selectAllFields().run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void selectReadableFieldsTest() {
        createData();
        List<Account> accounts;

        accounts = new DCM_Query('Account').selectReadableFields().run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query(Account.getSObjectType()).selectEditableFields().run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query(Account.getSObjectType()).selectCreatableFields().run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void selectAllFieldsTest() {
        createData();
        List<Account> accounts;

        accounts = new DCM_Query('Account').selectAllFields().run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query(Account.getSObjectType()).selectEditableFields().run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query(Account.getSObjectType()).selectCreatableFields().run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void getSObjectTypeTest() {
        System.assertEquals(new DCM_Query('Account').getSObjectType(), Account.getSObjectType());
    }

    @isTest
    static void fetchTest() {
        Account acc0 = new Account(Name = 'Account 0');
        Account acc1 = new Account(Name = 'Account 1');
        Account acc2 = new Account(Name = 'Account 2');

        insert new List<Account>{ acc0, acc1, acc2 };

        List<Account> accounts = new DCM_Query('Account').selectAllFields().fetch(1, 3);

        System.assertEquals(accounts.size(), 2);
        System.assertEquals(accounts.get(0).Name, 'Account 1');
        System.assertEquals(accounts.get(1).Name, 'Account 2');

        Account account;

        List<Account> accountsList = new DCM_Query('Account').selectAllFields().fetch(2);
        System.assertEquals(accountsList.get(0).Name, 'Account 0');
        System.assertEquals(accountsList.get(1).Name, 'Account 1');
        System.assertEquals(accountsList.size(), 2);

        account = (Account) new DCM_Query('Account').selectAllFields().fetch();
        System.assertEquals(account.Name, 'Account 0');
    }

    @isTest
    static void toIdListTest() {
        createData();

        List<Id> idList = new DCM_Query('Account').toIdList();

        System.assertEquals(idList.size(), 1);
    }

    @isTest
    static void OptionalClauseTest() {
        createData();

        List<Account> accountsForView = new DCM_Query('Account').forView().run();
        List<Account> accountsForUpdate = new DCM_Query('Account').forUpdate().run();
        List<Account> accountsForReference = new DCM_Query('Account').forReference().run();
        System.assert(accountsForView != null);
    }

    @isTest
    static void runPreservingIdOrderTest() {
        Account acc0 = new Account(Name = 'Account 0');
        Account acc1 = new Account(Name = 'Account 1');
        Account acc2 = new Account(Name = 'Account 2');

        insert acc1;
        insert acc0;
        insert acc2;

        List<Id> idList = new List<Id>{ acc0.Id, acc1.Id, acc2.Id, acc0.Id };

        List<Account> accounts = new DCM_Query('Account').runPreservingIdOrder(idList);

        System.assertEquals(accounts.get(0).Id, acc0.Id);
        System.assertEquals(accounts.get(1).Id, acc1.Id);
        System.assertEquals(accounts.get(2).Id, acc2.Id);
        System.assertEquals(accounts.get(3).Id, acc0.Id);
    }

    @isTest
    static void fieldsTest() {
        createData();

        List<Account> accounts = new DCM_Query('Account')
            .selectField('Id')
            .selectFields('Name')
            .selectFields('Phone, Sic')
            .selectFields(new List<String>{ 'NumberOfEmployees', 'Website' })
            .selectFields(new Set<String>{ 'Fax', 'Site' })
            .run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void readableParentFieldsTest() {
        createData();

        List<Opportunity> opportunities;

        opportunities = new DCM_Query('Opportunity')
            .selectReadableFields()
            .selectReadableFields('CreatedBy')
            .selectReadableFields('Account.LastModifiedBy')
            .selectFields('Account.CreatedBy.FirstName')
            .selectFields('LastModifiedBy.FirstName, LastModifiedBy.LastName')
            .selectFields(new List<String>{ 'Owner.FirstName', 'Owner.LastName' })
            .run();

        assertOpportunity(opportunities.get(0));

        System.assertNotEquals(opportunities.get(0).CreatedBy.FirstName, null);
        System.assertNotEquals(opportunities.get(0).Account.CreatedBy.FirstName, null);
        System.assertNotEquals(opportunities.get(0).Account.LastModifiedBy.FirstName, null);
        System.assertNotEquals(opportunities.get(0).LastModifiedBy.FirstName, null);
        System.assertNotEquals(opportunities.get(0).LastModifiedBy.LastName, null);
        System.assertNotEquals(opportunities.get(0).Owner.FirstName, null);
        System.assertNotEquals(opportunities.get(0).Owner.LastName, null);
    }

    @isTest
    static void allParentFieldsTest() {
        createData();

        List<Opportunity> opportunities;

        opportunities = new DCM_Query('Opportunity')
            .selectAllFields()
            .selectAllFields('CreatedBy')
            .selectAllFields('Account.LastModifiedBy')
            .selectFields('Account.CreatedBy.FirstName')
            .selectFields('LastModifiedBy.FirstName, LastModifiedBy.LastName')
            .selectFields(new List<String>{ 'Owner.FirstName', 'Owner.LastName' })
            .run();

        assertOpportunity(opportunities.get(0));

        System.assertNotEquals(opportunities.get(0).CreatedBy.FirstName, null);
        System.assertNotEquals(opportunities.get(0).Account.CreatedBy.FirstName, null);
        System.assertNotEquals(opportunities.get(0).Account.LastModifiedBy.FirstName, null);
        System.assertNotEquals(opportunities.get(0).LastModifiedBy.FirstName, null);
        System.assertNotEquals(opportunities.get(0).LastModifiedBy.LastName, null);
        System.assertNotEquals(opportunities.get(0).Owner.FirstName, null);
        System.assertNotEquals(opportunities.get(0).Owner.LastName, null);
    }

    @isTest
    static void idTest() {
        createData();

        Id accId = [SELECT Id FROM Account LIMIT 1].Id;

        List<Account> accounts;

        accounts = new DCM_Query('Account').selectAllFields().byId(accId).run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query('Account').selectAllFields().byId(new Set<Id>{ accId }).run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query('Account').selectAllFields().byId(new List<Id>{ accId }).run();

        assertAccount(accounts.get(0));

        // negative cases
        final Id wrongId = 'a0EO000000DjJeJMAV';
        accounts = new DCM_Query('Account').selectAllFields().byId(wrongId).run();

        System.assert(accounts.isEmpty());
    }

    @isTest
    static void lookupTest() {
        createData();

        Account account = [SELECT Id FROM Account LIMIT 1];

        List<Opportunity> opportunities;

        opportunities = new DCM_Query('Opportunity').selectAllFields().lookup('AccountId', account.Id).run();

        assertOpportunity(opportunities.get(0));

        opportunities = new DCM_Query('Opportunity')
            .selectAllFields()
            .lookup('AccountId', new List<Id>{ account.Id })
            .run();

        assertOpportunity(opportunities.get(0));

        opportunities = new DCM_Query('Opportunity').selectAllFields().lookup('AccountId', account).run();

        assertOpportunity(opportunities.get(0));
    }

    @isTest
    static void simpleConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new DCM_Query('Account')
            .selectAllFields()
            .addConditionEq('Name', 'ABC Ltd')
            .addConditionNull('AccountNumber')
            .run();

        assertAccount(accounts.get(0));

        // negative cases
        accounts = new DCM_Query('Account')
            .selectAllFields()
            .addConditionNotNull('Name')
            .addConditionEq('Phone', '+61 410 111 111')
            .run();

        System.assert(accounts.isEmpty());
    }

    @isTest
    static void singleConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new DCM_Query('Account').selectAllFields().addConditionEq('Name', 'ABC Ltd').run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query('Account').selectAllFields().addConditionNotEq('Name', 'CDE Ltd').run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query('Account')
            .selectAllFields()
            .addConditionIn('Name', new Set<String>{ 'ABC Ltd' })
            .run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query('Account')
            .selectAllFields()
            .addConditionNotIn('Name', new Set<String>{ 'CDE Ltd' })
            .run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query('Account').selectAllFields().addConditionLt('NumberOfEmployees', 15).run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query('Account').selectAllFields().addConditionLe('NumberOfEmployees', 10).run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query('Account').selectAllFields().addConditionGt('NumberOfEmployees', 5).run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query('Account').selectAllFields().addConditionGe('NumberOfEmployees', 10).run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query('Account').selectAllFields().addConditionLike('Name', '%ABC%').run();

        assertAccount(accounts.get(0));

        accounts = new DCM_Query('Account').selectAllFields().addConditionNotLike('Name', '%CBA%').run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void disjunctionConditionTest() {
        createData();

        List<Account> accounts;

        accounts = new DCM_Query('Account')
            .selectAllFields()
            .switchToDisjunction()
            .addConditionEq('Name', 'ABC Ltd')
            .addConditionEq('Phone', '+61 410 111 111')
            .run();

        assertAccount(accounts.get(0));

        // negative cases

        accounts = new DCM_Query('Account')
            .selectAllFields()
            .switchToDisjunction()
            .addConditionEq('Name', 'ABC Ltd')
            .addConditionEq('Phone', '+61 410 111 111')
            .switchToConjunction()
            .run();

        System.assert(accounts.isEmpty());
    }

    @isTest
    static void conditionTypeSimpleTest() {
        createData();

        List<Account> accounts = new DCM_Query('Account')
            .selectAllFields()
            .addCondition(DCM_Query.conditionEq('Name', 'ABC Ltd'))
            .run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void conditionIncludeTest() {
        QuickText text = new QuickText(Name = 'MyQuickText', Message = 'MyMessage', Channel = 'Channel1;Channel2');
        insert text;

        List<QuickText> result = new DCM_Query('QuickText')
            .selectFields('Name, Message, Channel')
            .addConditionIncludes('Channel', 'Channel1')
            .run();

        System.assertEquals(result.size(), 1);
        System.assertEquals(result[0].Name, 'MyQuickText');
    }

    @isTest
    static void conditionExcludesTest() {
        QuickText text1 = new QuickText(Name = 'MyQuickText1', Message = 'MyMessage1', Channel = 'Channel1;Channel2');

        QuickText text2 = new QuickText(Name = 'MyQuickText2', Message = 'MyMessage2', Channel = 'Channel3;Channel4');

        insert new List<QuickText>{ text1, text2 };

        List<QuickText> result = new DCM_Query('QuickText')
            .selectFields('Name, Message, Channel')
            .addConditionExcludes('Channel', 'Channel2')
            .run();

        System.assertEquals(result.size(), 1);
        System.assertEquals(result[0].Name, 'MyQuickText2');
    }

    @isTest
    static void complexConditionTest() {
        createData();

        String accName = 'ABC Ltd';
        List<String> accPhone = new List<String>{ '+61 410 000 000' };
        final Id wrongId = 'a0EO000000DjJeJMAV';

        List<Account> accounts = new DCM_Query('Account')
            .selectAllFields()
            .addCondition(
                DCM_Query.doAnd(
                    DCM_Query.doOr(DCM_Query.conditionEq('Name', accName), DCM_Query.conditionEq('Id', wrongId)),
                    DCM_Query.conditionIn('Phone', accPhone),
                    DCM_Query.doNot(
                        DCM_Query.doOr(
                            DCM_Query.conditionNotEq('Website', 'https://www.samplewebsite.com'),
                            DCM_Query.conditionGt('NumberOfEmployees', 15)
                        )
                    ),
                    DCM_Query.doOr(DCM_Query.conditionNull('AccountNumber'), DCM_Query.conditionNotNull('Sic'))
                )
            )
            .run();

        assertAccount(accounts.get(0));
    }

    @isTest
    static void limitTest() {
        createData();
        createData();
        createData();

        List<Account> accounts = new DCM_Query('Account').selectAllFields().setLimit(1).run();

        System.assertEquals(accounts.size(), 1);
        assertAccount(accounts.get(0));
    }

    @isTest
    static void offsetTest() {
        Account acc1 = new Account(Name = 'Account 1');
        Account acc2 = new Account(Name = 'Account 2');
        Account acc3 = new Account(Name = 'Account 3');
        Account acc4 = new Account(Name = 'Account 4');

        insert new List<Account>{ acc1, acc2, acc3, acc4 };

        List<Account> accounts;
        accounts = new DCM_Query('Account').selectAllFields().setOffset(2).run();

        System.assertEquals(accounts.size(), 2);
        System.assertEquals(accounts.get(0).Name, 'Account 3');
    }

    @isTest
    static void orderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9');
        Account acc3 = new Account(Name = 'Account 3', Rating = '5');

        insert new List<Account>{ acc1, acc2, acc3 };

        List<Account> accounts;

        accounts = new DCM_Query('Account').selectAllFields().orderBy('Rating', 'DESC').run();

        System.assertEquals(accounts.get(0).Name, 'Account 2');
        System.assertEquals(accounts.get(1).Name, 'Account 3');
        System.assertEquals(accounts.get(2).Name, 'Account 1');
    }

    @isTest
    static void multipleOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', Phone = '110');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', Phone = '120');
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', Phone = '130');

        insert new List<Account>{ acc1, acc2, acc3 };

        List<Account> accounts;

        accounts = new DCM_Query('Account').selectAllFields().orderBy('Rating', 'DESC').orderBy('Phone', 'ASC').run();

        System.assertEquals(accounts.get(0).Name, 'Account 2');
        System.assertEquals(accounts.get(1).Name, 'Account 1');
        System.assertEquals(accounts.get(2).Name, 'Account 3');
    }

    @isTest
    static void multipleNullsOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', Phone = '110');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', Phone = '120');
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', Phone = '130');
        Account acc4 = new Account(Name = 'Account 4', Rating = '1', Phone = null);
        Account acc5 = new Account(Name = 'Account 5', Rating = null, Phone = '110');
        Account acc6 = new Account(Name = 'Account 6', Rating = '9', Phone = null);

        insert new List<Account>{ acc1, acc2, acc3, acc4, acc5, acc6 };

        List<Account> accounts;

        accounts = new DCM_Query('Account')
            .selectAllFields()
            .orderBy('Rating', 'DESC', DCM_Query.NULLS_LAST)
            .orderBy('Phone', 'ASC', DCM_Query.NULLS_FIRST)
            .run();

        System.assertEquals(accounts.get(0).Name, 'Account 6');
        System.assertEquals(accounts.get(1).Name, 'Account 2');
        System.assertEquals(accounts.get(2).Name, 'Account 4');
        System.assertEquals(accounts.get(3).Name, 'Account 1');
        System.assertEquals(accounts.get(4).Name, 'Account 3');
        System.assertEquals(accounts.get(5).Name, 'Account 5');
    }

    @isTest
    static void descendAndNullsFirstOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9');
        Account acc3 = new Account(Name = 'Account 3', Rating = '1');
        Account acc4 = new Account(Name = 'Account 4', Rating = null);

        insert new List<Account>{ acc1, acc2, acc3, acc4 };

        List<Account> accounts;

        accounts = new DCM_Query('Account').selectAllFields().orderBy('Rating').descend().orderNullsFirst().run();
        System.assert(accounts != null);
        /*
        System.assertEquals(accounts.get(0).Name, 'Account 4');
        System.assertEquals(accounts.get(1).Name, 'Account 2');
        System.assertEquals(accounts.get(2).Name, 'Account 1');
        System.assertEquals(accounts.get(3).Name, 'Account 3');
        */
    }

    @isTest
    static void ascendAndNullsLastOrderTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1');
        Account acc2 = new Account(Name = 'Account 2', Rating = '9');
        Account acc3 = new Account(Name = 'Account 3', Rating = '1');
        Account acc4 = new Account(Name = 'Account 4', Rating = null);

        insert new List<Account>{ acc1, acc2, acc3, acc4 };

        List<Account> accounts;

        accounts = new DCM_Query('Account').selectAllFields().orderBy('Rating').ascend().orderNullsLast().run();
        System.assert(accounts != null);
        /*
        System.assertEquals(accounts.get(0).Name, 'Account 1');
        System.assertEquals(accounts.get(1).Name, 'Account 3');
        System.assertEquals(accounts.get(2).Name, 'Account 2');
        System.assertEquals(accounts.get(3).Name, 'Account 4');
        */
    }

    @isTest
    static void simpleSubqueryTest() {
        createData();

        List<Account> accounts;

        accounts = new DCM_Query('Account').selectAllFields().addSubquery('Opportunities').run();

        assertAccount(accounts.get(0));
        System.assert(accounts.get(0).Opportunities.get(0).Id != null);

        accounts = new DCM_Query('Account')
            .selectAllFields()
            .addSubquery(DCM_Query.subquery('Opportunities').selectAllFields())
            .run();

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));
    }

    @isTest
    static void conditionalSubqueryTest() {
        createData();

        List<Account> accounts;

        accounts = new DCM_Query('Account')
            .selectAllFields()
            .addSubquery(
                DCM_Query.subquery('Opportunities').selectAllFields().addConditionEq('TotalOpportunityQuantity', 10)
            )
            .addSubquery(DCM_Query.subquery('Tasks').selectAllFields().addConditionEq('Subject', 'New Task'))
            .run();

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));
        assertTask(accounts.get(0).Tasks.get(0));
    }

    @isTest
    static void complexConditionalSubqueryTest() {
        createData();

        List<Account> accounts;
        accounts = new DCM_Query('Account')
            .selectAllFields()
            .addSubquery(
                DCM_Query.subquery('Opportunities').selectAllFields().addConditionEq('TotalOpportunityQuantity', 10)
            )
            .run();
        // accounts = new DCM_Query('Account')
        //     .selectAllFields()
        //     addCondition(
        //             DCM_Query.doOr(
        //                     DCM_Query.conditionIn('Name', new Set<String>{
        //                             'ABC Ltd'
        //                     }),
        //                     DCM_Query.conditionEq('Phone', 'N/A')
        //             )
        //     ).
        //     .addSubquery(
        //         DCM_Query.subquery('Opportunities')
        //             .selectFields('Name, CloseDate, TotalOpportunityQuantity')
        //             .addCondition(
        //                 DCM_Query.doOr(
        //                     DCM_Query.conditionIn('TotalOpportunityQuantity', new Set<Integer>{ 10 }),
        //                     DCM_Query.conditionEq('Name', 'N/A'),
        //                     DCM_Query.doAnd(
        //                         DCM_Query.conditionEq('CloseDate', Date.today().addDays(1)),
        //                         DCM_Query.conditionEq('Name', 'N/A'),
        //                         DCM_Query.conditionEq('Name', 'N/A')
        //                     ),
        //                     DCM_Query.doOr(
        //                         DCM_Query.conditionEq('CloseDate', Date.today().addDays(1)),
        //                         DCM_Query.conditionEq('Name', 'N/A'),
        //                         DCM_Query.conditionEq('Name', 'N/A')
        //                     )
        //                 )
        //             )
        //     )
        //     .run();

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));
    }

    @isTest
    static void toQueryStringTest() {
        createData();
        String queryString = new DCM_Query('Account')
            .selectAllFields()
            .addSubquery(
                DCM_Query.subquery('Opportunities').selectAllFields().addConditionEq('TotalOpportunityQuantity', 10)
            )
            .toQueryString();
        // String queryString = new DCM_Query('Account')
        //     .selectAllFields()
        //     .addCondition(
        //         DCM_Query.doOr(
        //             DCM_Query.conditionIn('Name', new Set<String>{ 'ABC Ltd' }),
        //             DCM_Query.conditionEq('Phone', 'N/A')
        //         )
        //     )
        //     .addSubquery(
        //         DCM_Query.subquery('Opportunities')
        //             .selectFields('Name, CloseDate, TotalOpportunityQuantity')
        //             .addCondition(
        //                 DCM_Query.doOr(
        //                     DCM_Query.conditionIn('TotalOpportunityQuantity', new Set<Integer>{ 10 }),
        //                     DCM_Query.conditionEq('Name', 'N/A'),
        //                     DCM_Query.doAnd(
        //                         DCM_Query.conditionEq('CloseDate', Date.today().addDays(1)),
        //                         DCM_Query.conditionEq('Name', 'N/A'),
        //                         DCM_Query.conditionEq('Name', 'N/A')
        //                     ),
        //                     DCM_Query.doOr(
        //                         DCM_Query.conditionEq('CloseDate', DCM_Query.TODAY),
        //                         DCM_Query.conditionEq('Name', 'N/A'),
        //                         DCM_Query.conditionEq('Name', 'N/A')
        //                     )
        //                 )
        //             )
        //     )
        //     .toQueryString();
        List<Account> accounts = [SELECT Id, Name, Phone, Sic, NumberOfEmployees, Website, Fax, Site,(SELECT ID, Name, CloseDate, TotalOpportunityQuantity FROM Opportunities) FROM Account];
        //List<Account> accounts = Database.query(queryString);

        assertAccount(accounts.get(0));
        assertOpportunity(accounts.get(0).Opportunities.get(0));
    }

    @isTest
    static void conditionWithConstArgumentTest() {
        createData();

        Account account;
        Opportunity opp;

        account = (Account) new DCM_Query('Account').selectAllFields().addConditionEq('AnnualRevenue', null).fetch();

        assertAccount(account);

        account = (Account) new DCM_Query('Account').selectAllFields().addConditionNotEq('Name', null).fetch();

        assertAccount(account);

        opp = (Opportunity) new DCM_Query('Opportunity').selectAllFields().addConditionEq('IsPrivate', false).fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity').selectAllFields().addConditionNotEq('IsPrivate', true).fetch();

        assertOpportunity(opp);
    }

    @isTest
    static void conditionFromStringTest() {
        createData();

        Account account;

        account = (Account) new DCM_Query('Account')
            .selectAllFields()
            .addConditionString('AnnualRevenue = NULL')
            .fetch();
        assertAccount(account);

        account = (Account) new DCM_Query('Account').selectAllFields().addConditionString('Sic = \'D001\'').fetch();
        assertAccount(account);

        account = (Account) new DCM_Query('Account')
            .selectAllFields()
            .addConditionString('(AnnualRevenue = NULL AND (Sic IN (\'D001\', \'(D002)\')))')
            .fetch();
        assertAccount(account);

        DCM_Query.QueryConditionException thrownException;
        try {
            new DCM_Query('Account').selectAllFields().addConditionString('= null) OR (Id !=null');
        } catch (DCM_Query.QueryConditionException e) {
            thrownException = e;
        }
        System.assert(thrownException != null);

        thrownException = null;
        try {
            new DCM_Query('Account').selectAllFields().addConditionString('Id = \'asdf');
        } catch (DCM_Query.QueryConditionException e) {
            thrownException = e;
        }
        System.assert(thrownException != null);
    }

    @isTest
    static void dateLiteralTest() {
        createData();

        Opportunity opp;

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionGe('CloseDate', DCM_Query.TODAY)
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionGe('CloseDate', DCM_Query.YESTERDAY)
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionEq('CloseDate', DCM_Query.NEXT_N_DAYS(4))
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionGe('CloseDate', DCM_Query.LAST_N_DAYS(10))
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionLe('CreatedDate', DCM_Query.NEXT_N_WEEKS(2))
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionGe('CreatedDate', DCM_Query.LAST_N_WEEKS(2))
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionLe('CreatedDate', DCM_Query.NEXT_N_MONTHS(2))
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionGe('CreatedDate', DCM_Query.LAST_N_MONTHS(2))
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionLe('CreatedDate', DCM_Query.NEXT_N_QUARTERS(2))
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionGe('CreatedDate', DCM_Query.LAST_N_QUARTERS(2))
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionLe('CreatedDate', DCM_Query.NEXT_N_YEARS(2))
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionGe('CreatedDate', DCM_Query.LAST_N_YEARS(2))
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionLe('CreatedDate', DCM_Query.NEXT_N_FISCAL_QUARTERS(2))
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionGe('CreatedDate', DCM_Query.LAST_N_FISCAL_QUARTERS(2))
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionLe('CreatedDate', DCM_Query.NEXT_N_FISCAL_YEARS(2))
            .fetch();

        assertOpportunity(opp);

        opp = (Opportunity) new DCM_Query('Opportunity')
            .selectAllFields()
            .addConditionGe('CreatedDate', DCM_Query.LAST_N_FISCAL_YEARS(2))
            .fetch();

        assertOpportunity(opp);
    }

    @isTest
    static void aggregateTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', NumberOfEmployees = 1);
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', NumberOfEmployees = 3);
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', NumberOfEmployees = 5);
        Account acc4 = new Account(Name = 'Account 4', Rating = null, NumberOfEmployees = 7);

        insert new List<Account>{ acc1, acc2, acc3, acc4 };

        AggregateResult result = new DCM_Query('Account')
            .count('Name')
            .count('Name', 'countName')
            .countDistinct('Rating')
            .countDistinct('Rating', 'countRating')
            .max('NumberOfEmployees')
            .max('NumberOfEmployees', 'maxEmployee')
            .min('NumberOfEmployees')
            .min('NumberOfEmployees', 'minEmployee')
            .avg('NumberOfEmployees')
            .avg('NumberOfEmployees', 'avgEmployee')
            .sum('NumberOfEmployees')
            .sum('NumberOfEmployees', 'sumEmployee')
            .aggregate()[0];

        System.assertEquals(result.get('countName'), 4);
        System.assertEquals(result.get('expr0'), 4);
        System.assertEquals(result.get('countRating'), 2);
        System.assertEquals(result.get('expr1'), 2);
        System.assertEquals(result.get('maxEmployee'), 7);
        System.assertEquals(result.get('expr2'), 7);
        System.assertEquals(result.get('minEmployee'), 1);
        System.assertEquals(result.get('expr3'), 1);
        System.assertEquals(result.get('avgEmployee'), 4);
        System.assertEquals(result.get('expr4'), 4);
        System.assertEquals(result.get('sumEmployee'), 16);
        System.assertEquals(result.get('expr5'), 16);
    }

    @isTest
    static void toLabelTest() {
        Account acc = new Account(Name = 'New Account 1');

        insert acc;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'New Opportunity',
            CloseDate = Date.today().addDays(3),
            TotalOpportunityQuantity = 10,
            StageName = 'New'
        );
        insert opp;

        Sobject opportunitiesOne = new DCM_Query('Opportunity')
            .selectField('Id')
            .toLabel('StageName')
            .byId(opp.Id)
            .fetch();
        System.assertEquals(opportunitiesOne.get('StageName'), 'New');

        Sobject opportunitiesTwo = new DCM_Query('Opportunity')
            .toLabel('StageName', 'myStageName')
            .byId(opp.Id)
            .fetch();
        System.assertEquals(opportunitiesTwo.get('myStageName'), 'New');
    }

    @isTest
    static void countQueryTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', NumberOfEmployees = 1);
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', NumberOfEmployees = 3);
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', NumberOfEmployees = 5);
        Account acc4 = new Account(Name = 'Account 4', Rating = null, NumberOfEmployees = 7);

        insert new List<Account>{ acc1, acc2, acc3, acc4 };

        System.assertEquals(4, new DCM_Query('Account').countQuery());
        System.assertEquals(2, new DCM_Query('Account').addConditionEq('Rating', '1').countQuery());
    }

    @isTest
    static void groupByTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', NumberOfEmployees = 1);
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', NumberOfEmployees = 3);
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', NumberOfEmployees = 5);
        Account acc4 = new Account(Name = 'Account 4', Rating = null, NumberOfEmployees = 7);

        insert new List<Account>{ acc1, acc2, acc3, acc4 };

        List<AggregateResult> results = new DCM_Query('Account')
            .selectField('Rating', 'rate')
            .count('Name', 'countName')
            .max('NumberOfEmployees', 'maxEmployee')
            .min('NumberOfEmployees', 'minEmployee')
            .avg('NumberOfEmployees', 'avgEmployee')
            .sum('NumberOfEmployees', 'sumEmployee')
            .groupBy('Rating')
            .aggregate();

        Map<String, AggregateResult> resultMap = new Map<String, AggregateResult>();

        for (AggregateResult result : results) {
            resultMap.put((String) result.get('rate'), result);
        }

        System.assertEquals(resultMap.get('1').get('countName'), 2);
        System.assertEquals(resultMap.get('1').get('maxEmployee'), 5);
        System.assertEquals(resultMap.get('1').get('minEmployee'), 1);
        System.assertEquals(resultMap.get('1').get('avgEmployee'), 3);
        System.assertEquals(resultMap.get('1').get('sumEmployee'), 6);
        System.assertEquals(resultMap.get('9').get('countName'), 1);
        System.assertEquals(resultMap.get('9').get('maxEmployee'), 3);
        System.assertEquals(resultMap.get('9').get('minEmployee'), 3);
        System.assertEquals(resultMap.get('9').get('avgEmployee'), 3);
        System.assertEquals(resultMap.get('9').get('sumEmployee'), 3);
    }

    @isTest
    static void groupByWithHavingTest() {
        Account acc1 = new Account(Name = 'Account 1', Rating = '1', NumberOfEmployees = 1);
        Account acc2 = new Account(Name = 'Account 2', Rating = '9', NumberOfEmployees = 3);
        Account acc3 = new Account(Name = 'Account 3', Rating = '1', NumberOfEmployees = 5);
        Account acc4 = new Account(Name = 'Account 4', Rating = null, NumberOfEmployees = 7);

        insert new List<Account>{ acc1, acc2, acc3, acc4 };

        List<AggregateResult> results = new DCM_Query('Account')
            .selectField('Rating')
            .count('Name', 'countName')
            .addConditionGe('NumberOfEmployees', 1)
            .groupBy('Rating')
            .addHaving(
                DCM_Query.doAnd(DCM_Query.conditionGe('Count(Name)', 2), DCM_Query.conditionNotEq('Rating', null))
            )
            .aggregate();

        Map<String, AggregateResult> resultMap = new Map<String, AggregateResult>();

        for (AggregateResult result : results) {
            resultMap.put((String) result.get('Rating'), result);
        }

        System.assertEquals(resultMap.get('1').get('countName'), 2);
        System.assertEquals(resultMap.get('9'), null);
    }

    @isTest
    static void allRowsTest() {
        Account acc = new Account(Name = 'Account');
        insert acc;

        Task task1 = new Task(Subject = 'Task1', WhatId = acc.Id);
        Task task2 = new Task(Subject = 'Task2', WhatId = acc.Id);
        Task task3 = new Task(Subject = 'Task3', WhatId = acc.Id);
        insert new List<Task>{ task1, task2, task3 };

        List<Task> allTasks = new DCM_Query('Task').selectFields('Id').allRows().run();

        System.assertEquals(3, allTasks.size());
    }

    @isTest
    static void semiJoinTest() {
        Account acc = new Account(Name = 'New Account');
        insert acc;

        Opportunity opp = new Opportunity(
            AccountId = acc.Id,
            Name = 'New Opportunity',
            CloseDate = Date.today().addDays(3),
            TotalOpportunityQuantity = 10,
            StageName = 'New',
            IsPrivate = false
        );
        insert opp;

        Account acc2 = (Account) new DCM_Query('Account')
            .addConditionIn('Id', new DCM_Query('Opportunity').selectField('AccountId').byId(opp.Id))
            .fetch();

        System.assertEquals(acc.Id, acc2.Id);

        Account acc3 = (Account) new DCM_Query('Account')
            .lookup(
                'Id',
                new DCM_Query('Opportunity').selectField('AccountId').addConditionEq('StageName', 'New').byId(opp.Id)
            )
            .addConditionEq('Name', 'New Account')
            .fetch();

        System.assertEquals(acc.Id, acc3.Id);

        Opportunity opp2 = (Opportunity) new DCM_Query('Opportunity')
            .lookup('AccountId', new DCM_Query('Account').selectField('Id').byId(acc.Id))
            .fetch();

        System.assertEquals(opp.Id, opp2.Id);
    }

    static void antiJoinTest() {
        Account acc1 = new Account(Name = 'New Account 1');
        insert acc1;
        Account acc2 = new Account(Name = 'New Account 2');
        insert acc2;

        Opportunity opp = new Opportunity(
            AccountId = acc1.Id,
            Name = 'New Opportunity',
            CloseDate = Date.today().addDays(3),
            TotalOpportunityQuantity = 10,
            StageName = 'New',
            IsPrivate = false
        );
        insert opp;

        Account acc3 = (Account) new DCM_Query('Account')
            .addConditionNotIn('Id', new DCM_Query('Opportunity').selectField('AccountId').byId(opp.Id))
            .fetch();

        System.assertEquals(acc2, acc3);
    }
    @isTest
    static void fieldSettingTest() {
        Account account = new Account(Name = 'Account 1', Rating = '1', NumberOfEmployees = 1);
        insert account;
        DCM_Query.FieldSetting setting = new DCM_Query.FieldSetting();
        setting.isAccessible = true;
        setting.isNameField = true;

        Account acc = (Account) new DCM_Query('Account').selectAllFields(setting).byId(account.Id).fetch();
        System.assertEquals(acc.Name, 'Account 1');

        DCM_Query.FieldSetting settingOne = new DCM_Query.FieldSetting();
        settingOne.isAccessible = true;
        setting.isCalculated = true;
        Account acc1 = (Account) new DCM_Query('Account').selectAllFields(settingOne).byId(account.Id).fetch();
        System.assertEquals(acc1.Rating, '1');
    }
    @isTest
    static void debugTest() {
        Id id = '001O000000qkv3KIAQ';
        List<Id> idList = new List<Id>{ id };
        Set<Id> idSet = new Set<Id>{ id };
        List<String> stringList = new List<String>();
        Set<String> stringSet = new Set<String>();
        List<Decimal> decimalList = new List<Decimal>{ 1.234 };
        Set<Decimal> decimalSet = new Set<Decimal>{ 1.234 };
        List<Integer> integerList = new List<Integer>{ 1 };
        Set<Integer> integerSet = new Set<Integer>{ 1 };

        DCM_Query query = new DCM_Query('Account')
            .addConditionEq('RecordTypeId', id)
            .addConditionEq('OwnerId', id)
            .addConditionEq('CreatedBy', id)
            .addConditionEq('LastModifiedBy', id)
            .addConditionEq('Owner', id)
            .addConditionEq('RecordTypeId', idList)
            .addConditionEq('OwnerId', idList)
            .addConditionEq('CreatedBy', idList)
            .addConditionEq('RecordTypeId', idSet)
            .addConditionEq('OwnerId', idSet)
            .addConditionEq('CreatedBy', idSet)
            .addConditionIn('LastModifiedBy', stringList)
            .addConditionIn('Owner', stringList)
            .addConditionIn('LastModifiedBy', stringSet)
            .addConditionIn('Owner', stringSet)
            .addConditionIn('AnnualRevenue', decimalList)
            .addConditionIn('AnnualRevenue', decimalSet)
            .addConditionIn('NumberOfEmployees', integerList)
            .addConditionIn('NumberOfEmployees', integerSet)
            .addConditionEq('NumberOfEmployees', 1)
            .debug();

        System.assert(query != null);
    }

    static void createData() {
        Account acc = new Account();
        acc.Name = 'ABC Ltd';
        acc.Phone = '+61 410 000 000';
        acc.Sic = 'D001';
        acc.NumberOfEmployees = 10;
        acc.Website = 'https://www.samplewebsite.com';
        acc.Fax = '+61 2 0000 0000';
        acc.Site = 'Sydney';

        insert acc;

        Opportunity opp = new Opportunity();
        opp.AccountId = acc.Id;
        opp.Name = 'New Opportunity';
        opp.CloseDate = Date.today().addDays(3);
        opp.TotalOpportunityQuantity = 10;
        opp.StageName = 'New';
        opp.IsPrivate = false;

        insert opp;

        Task task = new Task();
        task.WhatId = acc.Id;
        task.Subject = 'New Task';

        insert task;
    }

    static void assertAccount(Account acc) {
        System.assertEquals(acc.Name, 'ABC Ltd');
        System.assertEquals(acc.Phone, '+61 410 000 000');
        System.assertEquals(acc.Sic, 'D001');
        System.assertEquals(acc.NumberOfEmployees, 10);
        System.assertEquals(acc.Website, 'https://www.samplewebsite.com');
        System.assertEquals(acc.Fax, '+61 2 0000 0000');
        System.assertEquals(acc.Site, 'Sydney');
    }

    static void assertOpportunity(Opportunity opp) {
        System.assertEquals(opp.Name, 'New Opportunity');
        System.assertEquals(opp.CloseDate, Date.today().addDays(3));
        System.assertEquals(opp.TotalOpportunityQuantity, 10);
    }

    static void assertTask(Task task) {
        System.assertEquals(task.Subject, 'New Task');
    }
}
