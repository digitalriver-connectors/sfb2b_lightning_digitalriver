@IsTest
public with sharing class DRB2B_CheckoutSummaryControllerTest {
    @TestSetup
    static void setup() {
        DRB2B_TestEnvironment.prepareStoreWithNonDigitalCart();
    }

    @IsTest
    static void getFeeandTaxTest() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            ATK.prepare(WebCart.SObjectType, new List<WebCart>{ DRB2B_TestEnvironment.shopperCart })
                .withChildren(CartItem.SObjectType, CartItem.CartId, 2)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .also()
                .withChildren(CartItem.SObjectType, CartItem.CartId, 1)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.Type)
                .repeat('Charge')
                .field(CartItem.Sku)
                .repeat('Charge {0000}')
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .save();

            Test.startTest();
            DRB2B_CartModel webCart = DRB2B_CheckoutSummaryController.getTaxAndFee(
                [SELECT Id FROM Webcart LIMIT 1]
                ?.Id
            );
            system.assertEquals(webCart.cart.DR_Total_IOR_Tax__c, webCart.IOR);
            system.assertEquals(webCart.cart.Has_Landed_Cost__c, webCart.hasLandedCost);
            system.assertEquals(webCart.cart.DR_Total_Fees__c, webCart.totaFee);
            system.assertEquals(webCart.cart.TotalChargeAmount + webCart.cart.TotalChargeTaxAmount, webCart.shipping);
            system.assertEquals(webCart.cart.TotalTaxAmount, webCart.totalTax);
            Test.stopTest();
        }
    }

    @IsTest
    static void getCartByOrderSummaryIdTest() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            ATK.prepare(WebCart.SObjectType, new List<WebCart>{ DRB2B_TestEnvironment.shopperCart })
                .withChildren(CartItem.SObjectType, CartItem.CartId, 2)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .also()
                .withChildren(CartItem.SObjectType, CartItem.CartId, 1)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.Type)
                .repeat('Charge')
                .field(CartItem.Sku)
                .repeat('Charge {0000}')
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .save();

            Test.startTest();
            try {
                DRB2B_CartModel webCart = DRB2B_CheckoutSummaryController.getCartByOrderSummaryId(
                    [SELECT Id FROM Webcart LIMIT 1]
                    ?.Id
                );
            } catch (Exception e) {
                System.assertNotEquals(null, e, 'Exception Must be thrown.');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void getCartByIdTest() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            ATK.prepare(WebCart.SObjectType, new List<WebCart>{ DRB2B_TestEnvironment.shopperCart })
                .withChildren(CartItem.SObjectType, CartItem.CartId, 2)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .also()
                .withChildren(CartItem.SObjectType, CartItem.CartId, 1)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.Type)
                .repeat('Charge')
                .field(CartItem.Sku)
                .repeat('Charge {0000}')
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .save();

            Test.startTest();
            DRB2B_CartModel webCart = DRB2B_CheckoutSummaryController.getCartById([SELECT Id FROM Webcart LIMIT 1]?.Id);
            System.assertEquals(webCart.cart.DR_Source_Id__c, webCart.sourceId);
            Test.stopTest();
        }
    }
    @IsTest
    static void getCartByIdNegativeTest() {
        DRB2B_TestEnvironment.assignPermissionSet(
            DRB2B_TestEnvironment.shopperUser,
            DRB2B_Constants.PermissionSet.SHOPPER
        );

        System.runAs(DRB2B_TestEnvironment.shopperUser) {
            ATK.prepare(WebCart.SObjectType, new List<WebCart>{ DRB2B_TestEnvironment.shopperCart })
                .withChildren(CartItem.SObjectType, CartItem.CartId, 2)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .also()
                .withChildren(CartItem.SObjectType, CartItem.CartId, 1)
                .build(EntityBuilderFactory.cartItemBuilder)
                .field(CartItem.Type)
                .repeat('Charge')
                .field(CartItem.Sku)
                .repeat('Charge {0000}')
                .field(CartItem.CartDeliveryGroupId)
                .repeat(DRB2B_TestEnvironment.shopperCartDeliveryGroup.Id)
                .save();

            Test.startTest();
            try {
                DRB2B_CartModel webCart = DRB2B_CheckoutSummaryController.getCartById(Id.valueOf(''));
            } catch (Exception e) {
                System.assertNotEquals(null, e, 'Exception must be throwen');
            }
            Test.stopTest();
        }
    }
}
