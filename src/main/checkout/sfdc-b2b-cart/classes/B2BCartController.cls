/**
 * @description Demonstrates how to make Apex calls to ConnectApi.CommerceCart class
 * to perform Cart Operations for B2B Commerce on Lightning.
 *
 * @see B2BUtils
 */
public with sharing class B2BCartController {
    private static DCM_Logger logger = DCM_Logger.getInstance();

    /**
     * @description Demonstrates how to call ConnectApi.CommerceCart.getCartItems
     * @param  communityId The Id of the community from which the call originated
     * @param effectiveAccountId ID of the account for which the request is made. If null, defaults to the account ID for the context user.
     * @param activeCartOrId ID of the cart, active, or current.
     * @param pageParam Specifies the page token to be used to view a page of information.
     * @param sortParam Sort order for items in a cart.
     * @return CartItemCollection A collection of cart items
     */
    @AuraEnabled
    public static ConnectApi.CartItemCollection getCartItems(String communityId, String effectiveAccountId, String activeCartOrId, String pageParam, String sortParam) {
        // Lookup the webstore ID associated with the community
        ConnectApi.CartItemCollection result;
        try {
            String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

            // Get the ConnectApi.CartItemSortOrder enum value from string.
            // For the list of possible values, see:
            // see https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/connectAPI_enums.htm#cartItemSortOrderEnum
            ConnectApi.CartItemSortOrder resolvedSortParam = B2BUtils.resolveSortParam(sortParam);

            // For more details, see:
            // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
            result = ConnectApi.CommerceCart.getCartItems(webstoreId, effectiveAccountId, activeCartOrId, pageParam, resolvedSortParam);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }
}
