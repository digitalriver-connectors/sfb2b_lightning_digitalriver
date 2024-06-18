/**
 * @description       : 
 * @author            : Arun Sood
 * @group             : 
 * @last modified on  : 04-07-2021
 * @last modified by  : Arun Sood
 * Modifications Log 
 * Ver   Date         Author      Modification
 * 1.0   04-07-2021   Arun Sood   Initial Version
**/
public with sharing class DRB2B_ErrorResponse {
    public class Errors {
		public String code;
		public String parameter;
		public String message;
	}

	public String type;
	public List<Errors> errors;

	
	public static DRB2B_ErrorResponse parse(String json) {
		return (DRB2B_ErrorResponse) System.JSON.deserialize(json, DRB2B_ErrorResponse.class);
	}
}
