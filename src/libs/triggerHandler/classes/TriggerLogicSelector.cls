/**
 * MIT License
 *
 * Copyright (c) 2019 Piotr Kożuchowski
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

/**
 * This class is responsible for querying custom metadata (DCM_TriggerHandler__mdt)
 * and creating instances of classes defined in ApexClass__c field.
 */
public with sharing class TriggerLogicSelector {
    @TestVisible
    static List<DCM_TriggerHandler__mdt> mockMetadata;

    /**
     * @param tc Trigger Context of running trigger
     * @return Trigger Logic for currently executing trigger
     */
    public List<TriggerHandler.Logic> getLogic(TriggerContext tc) {
        return (List<TriggerHandler.Logic>) getInstances(tc, new List<TriggerHandler.Logic>(), false);
    }

    /**
     * @param tc Trigger Context of running trigger
     * @return Trigger Logic for currently executing trigger
     */
    public List<TriggerHandler.AsyncLogic> getAsyncLogic(TriggerContext tc) {
        return (List<TriggerHandler.AsyncLogic>) getInstances(tc, new List<TriggerHandler.AsyncLogic>(), true);
    }

    /**
     * @param tc Current Trigger Context
     * @param instances Empty list of desired result type ex. `new List<TriggerValidationRule> ()`
     * @param async return sync/async logic
     *
     * @return New instances of classes defined in ApexClass__c field of the custom metadata.
     * @throws TypeException if Type.newInstance() failed.
     */
    private List<Object> getInstances(TriggerContext tc, List<Object> instances, Boolean async) {
        for (
            DCM_TriggerHandler__mdt setting : getCustomMetadataRecords(
                String.valueOf(tc.sObjectType),
                tc.operationType,
                async
            )
        ) {
            try {
                Type ruleClass = Type.forName(setting.ApexClass__c);
                TriggerHandler.Logic logic = (TriggerHandler.Logic) ruleClass.newInstance();

                if (logic instanceof TriggerHandler.Parameterizable) {
                    ((TriggerHandler.Parameterizable) logic).setParameters(setting.Parameters__c);
                }

                instances.add(logic);
            } catch (Exception ex) {
                throw new TypeException(
                    'Apex class defined in custom metadata DCM_TriggerHandler__mdt.' +
                    setting.DeveloperName +
                    ' (' +
                    setting.ApexClass__c +
                    ') is invalid. Please check if corresponding class is public and implements correct interface.'
                );
            }
        }

        return instances;
    }

    private List<DCM_TriggerHandler__mdt> getCustomMetadataRecords(
        String sObjectType,
        TriggerOperation op,
        Boolean async
    ) {
        SObjectField triggerField = new Map<TriggerOperation, SObjectField>{
                TriggerOperation.BEFORE_INSERT => DCM_TriggerHandler__mdt.BeforeInsert__c,
                TriggerOperation.BEFORE_UPDATE => DCM_TriggerHandler__mdt.BeforeUpdate__c,
                TriggerOperation.BEFORE_DELETE => DCM_TriggerHandler__mdt.BeforeDelete__c,
                TriggerOperation.AFTER_INSERT => DCM_TriggerHandler__mdt.AfterInsert__c,
                TriggerOperation.AFTER_UPDATE => DCM_TriggerHandler__mdt.AfterUpdate__c,
                TriggerOperation.AFTER_DELETE => DCM_TriggerHandler__mdt.AfterDelete__c,
                TriggerOperation.AFTER_UNDELETE => DCM_TriggerHandler__mdt.AfterUndelete__c
            }
            .get(op);

        if (mockMetadata == null) {
            return Database.query(
                'SELECT ApexClass__c, DeveloperName, Parameters__c' +
                ' FROM DCM_TriggerHandler__mdt' +
                ' WHERE Enabled__c = TRUE' +
                ' AND SObject__c = :sObjectType' +
                ' AND Async__c =:async' +
                ' AND ' +
                triggerField +
                ' = TRUE' +
                ' ORDER BY Order__c ASC NULLS LAST, ApexClass__c ASC'
            );
        } else {
            List<DCM_TriggerHandler__mdt> settings = new List<DCM_TriggerHandler__mdt>();

            for (DCM_TriggerHandler__mdt logic : mockMetadata) {
                if (
                    logic.Enabled__c =
                        true &&
                        logic.SObject__c == sObjectType &&
                        logic.get(triggerField) == true &&
                        logic.Async__c == async
                ) {
                    settings.add(logic);
                }
            }

            return settings;
        }
    }
}
