import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
import module namespace csd_blu = "https://github.com/openhie/openinfoman/csd_blu";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:)   

let $provider := if (exists($careServicesRequest/requestParams/id/@entityID)) then	csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/requestParams/id)[1] else ()
let $new_id := $careServicesRequest/requestParams/otherID
return  
  if ( exists($provider) and not($new_id/@code = ''))     
    then
    let $position := count($provider/otherID) +1
    let $return:=  
      <provider entityID="{$provider/@entityID}">
	<otherID position="{$position}"/>
      </provider>
    return 
      (
	insert node $new_id into $provider ,    
	csd_blu:wrap_updating_providers($return)
      )
  else  csd_blu:wrap_updating_providers(())
      
