/**
 * Email Utility Class
**/
public with sharing class DCM_EmailUtil {
    private static final DCM_Logger logger = DCM_Logger.getInstance(DRB2B_Constants.Module.EMAIL);

    @TestVisible
    private static DRB2B_ConnectorConfigurationSelector configurationSelector = new DRB2B_ConnectorConfigurationSelector();

    public static void sendMail(String subject, String emailBody, String toEmail, String ccEmail) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        try {
            email.setSubject(configurationSelector.getEnvironmentName() + ' - ' + subject); // Set Email Subject. Specify Environment name in subject
            if(String.isNotBlank(toEmail)) {
                List<String> toEmailList = toEmail.split(',');
                email.setToAddresses(toEmailList);
                if(String.isNotBlank(ccEmail)) {
                    List<String> ccEmailList = ccEmail.split(',');
                    email.setCcAddresses(ccEmailList);
                }
                email.setHtmlBody(emailBody); // Set Email Body
                String emailFromAddress = configurationSelector.getEmailFromAddress();
                String queryString = 'select Id from OrgWideEmailAddress where Address =:emailFromAddress';
                OrgWideEmailAddress[] owea  = Database.query(queryString);
                if ( owea.size() > 0 ) {
                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                if(!Test.isRunningTest()){
                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email }); // Send Email
                }
            }
            else {
                logger.error('Email ToAddress cannot be empty');
            }
        }
        catch(Exception ex) {
            logger.error(null, 'Encountered Error while sending email', ex);
        }
        finally {
            logger.flush();
        }
    }
}