@IsTest(SeeAllData=false)
private class WDI_formdataTest {
  static testMethod void testWriteBodyParameter() {
    String key = '123';
    String value = '123';
    STRING result = WDI_Formdata.WriteBodyParameter(key, value);
  }

  static testMethod void testwriteFileBody() {
    String key = '123';
    Blob attachBody = blob.valueof('123');
    String filename = 'test.txt';
    STRING result = WDI_Formdata.writeFileBody(key, attachBody, filename);
  }

  static testMethod void testwriteFileBodyEquals() {
    String key = '123';
    Blob attachBody = blob.valueof('==========');
    String filename = 'test.txt';
    STRING result = WDI_Formdata.writeFileBody(key, attachBody, filename);
  }

  static testMethod void makeBlobWithFile() {
    String key = '123';
    Blob attachBody = blob.valueof('123');
    String filename = 'test.txt';
    String otherParams = '';
    Blob result = WDI_Formdata.makeBlobWithFile(
      key,
      attachBody,
      filename,
      otherParams
    );
  }

  static testMethod void testMakeBlob() {
    String key = '123';

    Blob result = WDI_Formdata.makeBlob(key);
  }

  static testMethod void testWriteBoundary() {

    String result = WDI_Formdata.WriteBoundary();
  }

  static testMethod void testAppend() {
String key = '123';
String value='123';
    String result = WDI_Formdata.Append(key,value);
  }
}