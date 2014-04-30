import module namespace csd = "urn:ihe:iti:csd:2013" at "../repo/csd_base_library.xqm";
import module namespace csd_blu = "https://github.com/his-interop/openinfoman/csd_blu" at "../repo/csd_base_library_updating.xqm";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:)   

let $provider := if (exists($careServicesRequest/id/@oid)) then	csd:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id)[1] else ()
let $new_id := $careServicesRequest/otherID
return  
  if ( exists($provider) and not($new_id/@code = ''))     
    then
    let $position := count($provider/otherID) +1
    let $return:=  
      <provider oid="{$provider/@oid}">
	<otherID position="{$position}"/>
      </provider>
    return 
      (
	insert node $new_id into $provider ,    
	csd_blu:wrap_updating_providers($return)
      )
  else  csd_blu:wrap_updating_providers(())
      
