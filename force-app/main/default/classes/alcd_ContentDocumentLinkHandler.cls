public class alcd_ContentDocumentLinkHandler {
    
    public alcd_ContentDocumentLinkHandler(){}
    
    public void callCDLFlow(List<ContentDocumentLink> cdlsNewList){
    
        Map<String,Object> inputs = new Map<String,Object>();
        inputs.put('ContentDocumentLinkCollection', cdlsNewList);
        Flow.Interview.alcd_Content_Document_Link_Automation CDLFlow = new Flow.Interview.alcd_Content_Document_Link_Automation(inputs);
        CDLFlow.start();
       
    }
}