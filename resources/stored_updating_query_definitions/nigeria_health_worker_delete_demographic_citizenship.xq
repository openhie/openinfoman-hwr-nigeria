import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
import module namespace csd_nhwrn = "http://www.health.gov.ng";
import module namespace csd_blu = "https://github.com/openhie/openinfoman/csd_blu";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 
let $providers := if (exists($careServicesRequest/id/@urn)) then csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id) else ()
return
  if ( count($providers) = 1 )
    then
    let $citizenship := ($providers[1]/demographic/extension[@urn='urn:who.int:hrh:mds' and @type='citizenship'])
    return if (exists($citizenship)) then (delete node $citizenship) else ()
  else  ()
else ()      
