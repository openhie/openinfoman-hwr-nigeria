import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
import module namespace csd_blu = "https://github.com/openhie/openinfoman/csd_blu";
import module namespace csd_nhwrn = "http://www.health.gov.ng/csd";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 
let $pos := $careServicesRequest/demographic/extension[@type='photograph' and @oid=$csd_nhwrn:rootoid]/@position
return
  if (exists($pos)) 
    then 
    let $providers := if (exists($careServicesRequest/id/@oid)) then csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id) else ()
    return
      if ( count($providers) = 1 )
	then
	let  $ext :=  ($providers[1]/demographic/extension[@type='photograph' and @oid=$csd_nhwrn:rootoid])[position() = $pos]
	return if (exists($ext)) then (delete node $ext) else ()
      else  ()
    else ()      
