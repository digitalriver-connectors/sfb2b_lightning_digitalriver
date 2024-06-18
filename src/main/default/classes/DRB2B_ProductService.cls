public with sharing class DRB2B_ProductService {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.PRODUCT_SYNC);
    private static final Stringifier stringifier = new Stringifier();
    @TestVisible
    private static DRB2B_RequestService requestService = new DRB2B_RequestService();

    @TestVisible
    private static DRB2B_UpsertSkuModelService productSyncUpsertRequest = new DRB2B_UpsertSkuModelService();

    public DRB2B_ProductSyncUpsertSkuResponse upsertProduct(Id productId, String taxCode) {
        DRB2B_ProductSyncUpsertSkuRequest productRequest = productSyncUpsertRequest.getUpsertProductRequestModel(productId, taxCode);        
        DCM_HttpClient.Response response = requestService.getUpsertProductRequest(productRequest, productId).fetch();        
        DRB2B_ProductSyncUpsertSkuResponse upsertProductResponse = new DRB2B_ProductSyncUpsertSkuResponse();        
        if(response.getStatusCode() == DRB2B_DRApiConstants.SUCCESS_STATUS || response.getStatusCode() == DRB2B_DRApiConstants.UPSERT_SUCCESS_STATUS ){            
            upsertProductResponse = (DRB2B_ProductSyncUpsertSkuResponse) response.asType(DRB2B_ProductSyncUpsertSkuResponse.class);
            upsertProductResponse.isSuccess = true;
        }else{
            upsertProductResponse.isSuccess = false;
            DRB2B_ErrorResponse upsertProductErrorResponse = (DRB2B_ErrorResponse) response.asType(DRB2B_ErrorResponse.class);
            logger.debug(stringifier.toString(new Map<String, String> {
                'drproductSyncResponse' => response.getBody(),
                'drProductSyncErrorObj' => JSON.serialize(upsertProductErrorResponse)
            }));
            logger.flush();
        }
        return upsertProductResponse;
    }
}
