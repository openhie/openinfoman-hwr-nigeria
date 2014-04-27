import module namespace csd = "urn:ihe:iti:csd:2013" at "../repo/csd_base_library.xqm";
import module namespace csd_nhwrn = "http://www.health.gov.ng" at "../repo/csd_national_health_worker_registry_nigeria.xqm";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 
let $provs0 := 
  if (exists($careServicesRequest/id/@oid)) then 
    csd:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id) 
  else (/CSD/providerDirectory/*)
let $provs1:=     
  for $provider in  $provs0
  return
  <provider oid="{$provider/@oid}">
    <demographic>
     {
       if (exists(($provider/demographic/extension[@oid=$csd_nhwrn:rootoid and @type='birth'])[1])) then
	 <extension oid="{$csd_nhwrn:rootoid}" type='birth'/>
       else ()
     }
    </demographic>
  </provider>
    
return csd:wrap_providers($provs1)
