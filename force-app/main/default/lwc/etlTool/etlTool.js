import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import extractDocufyData from '@salesforce/apex/EtlToolHelper.extractDocufyData';
import loadNormalRecords from '@salesforce/apex/EtlToolHelper.loadNormalRecords';
import loadNormalRecordsWithLookups from '@salesforce/apex/EtlToolHelper.loadNormalRecordsWithLookups';
import loadJunctionRecords from '@salesforce/apex/EtlToolHelper.loadJunctionRecords';
import loadJunctionRecordsWithLookups from '@salesforce/apex/EtlToolHelper.loadJunctionRecordsWithLookups';
import loadInputRecords from '@salesforce/apex/EtlToolHelper.loadInputRecords';

class ArrayBatchMaker {
  array = [];

  batchSize = 100;

  currentIndex = 0;

  constructor(array, batchSize) {
    this.array = array;
    this.batchSize = batchSize;
  }

  getNextBatch() {
    if (this.currentIndex < this.array.length) {
      const batch = this.array.slice(this.currentIndex, this.currentIndex + this.batchSize);
      this.currentIndex = this.currentIndex + this.batchSize;
      return batch;
    } else {
      return null;
    }
  }
}

/**
 * ETL tool to aid in beta data migration for Document Generation SObject records.
 * @hideconstructor
 */
class etlTool extends LightningElement {
  @track loading = false;

  @track numLoadedObjects = 0;

  @track totalObjects = 12;

  /**
   * Clears the file input's value, allowing onchange to fire even if the name of
   * the file is the same as the previously selected file.
   * @param {Object} event 
   * @private
   */
  clearInputFileValue(event) {
    event.target.value = null;
  }

  doBatchCallouts(records, batchSize, etlToolFunction, etlToolFunctionArgs) {
    const batchMaker = new ArrayBatchMaker(records, batchSize);
    const recordIdMap = {};
    return new Promise((resolve, reject) => {
      const calloutFunction = () => {
        const currentBatch = batchMaker.getNextBatch();
        if (currentBatch !== null) {
          const args = Object.assign({serializedRecords: JSON.stringify(currentBatch)}, etlToolFunctionArgs);
          etlToolFunction(args)
              .then((result) => {
                if (result !== undefined && result !== null && result !== '') {
                  Object.assign(recordIdMap, result);
                }
                calloutFunction();
              })
              .catch((error) => {
                reject(error);
              });
        }
        else {
          resolve(recordIdMap);
        }
      };
      calloutFunction();
    });
  }

  /**
   * Runs multiple Apex queries to dump all Document Generation SObject records.
   * @private
   */
  performExtract() {
    extractDocufyData()
        .then(docufyData => {
          const a = document.createElement('a');
          const file = new Blob([docufyData], {type: 'text/plain'});
          a.href = URL.createObjectURL(file);
          a.download = 'docufyData.txt';
          a.click();

          this.showToast('Data Extraction Successful', null, 'success')
        })
        .catch(error => this.showToast('Data Extraction Error', error, 'error'));
  }

  /**
   * Reads in a previously extracted file, loading the data back into the database.
   * This function creates actual record data.
   * @param {Object} event 
   * @private
   */
  performLoad(event) {
    const file = event.target.files[0]; 
    var fileReader = new FileReader();
    fileReader.onload = (() => {
      return async (e) => {
        try {
          this.loading = true;
          this.numLoadedObjects = 0;

          const serializedDocufyData = e.target.result;
          const docufyData = JSON.parse(serializedDocufyData);
          for (let propertyName in docufyData) {
            for (let record of docufyData[propertyName]) {
              delete record.CreatedById;
              delete record.LastModifiedById;
            }
          }
          for (let templateRecord of docufyData.templateRecords) {
            templateRecord.litify_docs__Has_File__c = false;
          }
          const batchSize = 200;

          // litify_docs__Packet__c
          const packetRecordOldIdToNewId = await this.doBatchCallouts(docufyData.packetRecords, batchSize, loadNormalRecords, {});
          this.numLoadedObjects++;

          // litify_docs__Template__c
          const templateRecordOldIdToNewId = await this.doBatchCallouts(docufyData.templateRecords, batchSize, loadNormalRecords, {});
          this.numLoadedObjects++;

          // litify_docs__Packet_Template_Junction__c
          await this.doBatchCallouts(docufyData.packetTemplateJunctionRecords, batchSize, loadJunctionRecords, {
            detailOneKey: 'litify_docs__Packet__c',
            detailOneOldIdToNewId: packetRecordOldIdToNewId,
            detailTwoKey: 'litify_docs__Template__c',
            detailTwoOldIdToNewId: templateRecordOldIdToNewId
          });
          this.numLoadedObjects++;

          // litify_docs__Node__c
          const nodeRecordOldIdToNewId = await this.doBatchCallouts(docufyData.nodeRecords, batchSize, loadNormalRecords, {});
          this.numLoadedObjects++;

          // litify_docs__Template_Node_Junction__c
          await this.doBatchCallouts(docufyData.templateNodeJunctionRecords, batchSize, loadJunctionRecords, {
            detailOneKey: 'litify_docs__Template__c',
            detailOneOldIdToNewId: templateRecordOldIdToNewId,
            detailTwoKey: 'litify_docs__Node__c',
            detailTwoOldIdToNewId: nodeRecordOldIdToNewId
          });
          this.numLoadedObjects++;

          // litify_docs__Input__c
          const inputRecordOldIdToNewId = await loadInputRecords({serializedRecords: JSON.stringify(docufyData.inputRecords)});
          this.numLoadedObjects++;

          // litify_docs__Node_Input_Junction__c
          await this.doBatchCallouts(docufyData.nodeInputJunctionRecords, batchSize, loadJunctionRecords, {
            detailOneKey: 'litify_docs__Node__c',
            detailOneOldIdToNewId: nodeRecordOldIdToNewId,
            detailTwoKey: 'litify_docs__Input__c',
            detailTwoOldIdToNewId: inputRecordOldIdToNewId
          });
          this.numLoadedObjects++;

          // litify_docs__Input_Option__c
          await this.doBatchCallouts(docufyData.inputOptionRecords, batchSize, loadNormalRecordsWithLookups, {
            lookupKeyToLookupRecordOldIdToNewId: {
              litify_docs__Input__c: inputRecordOldIdToNewId
            }
          });
          this.numLoadedObjects++;

          // litify_docs__Input_Format_Option__c
          await this.doBatchCallouts(docufyData.inputFormatOptionRecords, batchSize, loadNormalRecordsWithLookups, {
            lookupKeyToLookupRecordOldIdToNewId: {
              litify_docs__Input__c: inputRecordOldIdToNewId,
              litify_docs__Template_Scope__c: templateRecordOldIdToNewId
            }
          });
          this.numLoadedObjects++;

          // litify_docs__Rule_Group__c
          const ruleGroupRecordOldIdToNewId = await this.doBatchCallouts(docufyData.ruleGroupRecords, batchSize, loadNormalRecords, {});
          this.numLoadedObjects++;

          // litify_docs__Input_Rule_Group_Junction__c
          await this.doBatchCallouts(docufyData.inputRuleGroupJunctionRecords, batchSize, loadJunctionRecordsWithLookups, {
            detailOneKey: 'litify_docs__Input__c',
            detailOneOldIdToNewId: inputRecordOldIdToNewId,
            detailTwoKey: 'litify_docs__Rule_Group__c',
            detailTwoOldIdToNewId: ruleGroupRecordOldIdToNewId,
            lookupKeyToLookupRecordOldIdToNewId: {
              litify_docs__Template_Scope__c: templateRecordOldIdToNewId
            }
          });
          this.numLoadedObjects++;

          // litify_docs__Rule__c
          await this.doBatchCallouts(docufyData.ruleRecords, batchSize, loadNormalRecordsWithLookups, {
            lookupKeyToLookupRecordOldIdToNewId: {
              litify_docs__Rule_Group__c: ruleGroupRecordOldIdToNewId,
              litify_docs__X_Input__c: inputRecordOldIdToNewId,
              litify_docs__Y_Input__c: inputRecordOldIdToNewId
            }
          });
          this.numLoadedObjects++;
          this.loading = false;
          this.showToast('Data Load Successful', null, 'success');
        }
        catch (error) {
          this.showToast('Data Load Error', error, 'error');
        }
      };
    })(file);
    fileReader.readAsText(file);
  }

  /**
   * Shows a toast message to the user.
   * @param {String} title - The toast title
   * @param {String} message - The toast message
   * @param {'error'|'info'|'success'|'warning'} variant - The type of toast to display
   * @private
   */
  showToast(title, message, variant) {
    dispatchEvent(
      new ShowToastEvent({
        'title': title,
        'message': message,
        'variant': variant,
        'mode': 'sticky'
      })
    );
  }

  /**
   * Triggers the display of the file selection prompt.
   * @private
   */
  triggerFileSelection() {
    this.template.querySelector('input[type="file"]').click();
  }
}

export default etlTool;