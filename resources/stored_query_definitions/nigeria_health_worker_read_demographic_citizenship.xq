import module namespace csd = "urn:ihe:iti:csd:2013" at "../repo/csd_base_library.xqm";
import module namespace csd_nhwrn = "http://www.health.gov.ng" at "../repo/csd_national_health_worker_registry_nigeria.xqm";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 

let $provs1 := if (exists($careServicesRequest/id/@oid)) then csd:filter_by_primary_id(/CSD/providerDirectory/* ,$careServicesRequest/id) else ()
let $provs2 := 
  if (count($provs1) = 1) 
    then 
    <provider oid="{$provs1[1]/@oid}">
      <demographic>
	{($provs1[1]/demographic/extension[@oid=$csd_nhwrn:rootoid and @type='citizenship'])[1]}
      </demographic>
    </provider>
  else ()        
return csd:wrap_providers($provs2)
