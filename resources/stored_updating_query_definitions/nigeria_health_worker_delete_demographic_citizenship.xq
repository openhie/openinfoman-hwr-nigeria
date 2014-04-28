import module namespace csd = "urn:ihe:iti:csd:2013" at "../repo/csd_base_library.xqm";
import module namespace csd_nhwrn = "http://www.health.gov.ng" at "../repo/csd_national_health_worker_registry_nigeria.xqm";
import module namespace csd_blu = "https://github.com/his-interop/openinfoman/csd_blu" at "../repo/csd_base_library_updating.xqm";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 
let $providers := if (exists($careServicesRequest/id/@oid)) then csd:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id) else ()
return
  if ( count($providers) = 1 )
    then
    let $citizenship := ($providers[1]/demographic/extension[@oid=$csd_nhwrn:rootoid and @type='citizenship'])
    return if (exists($citizenship)) then (delete node $citizenship) else ()
  else  ()
else ()      
