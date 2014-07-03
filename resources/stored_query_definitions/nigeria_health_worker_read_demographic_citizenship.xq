import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
import module namespace csd_nhwrn = "http://www.health.gov.ng";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 

let $provs1 := if (exists($careServicesRequest/id/@oid)) then csd_bl:filter_by_primary_id(/CSD/providerDirectory/* ,$careServicesRequest/id) else ()
let $provs2 := 
  if (count($provs1) = 1) 
    then 
    <provider oid="{$provs1[1]/@oid}">
      <demographic>
	{($provs1[1]/demographic/extension[@oid=$csd_nhwrn:rootoid and @type='citizenship'])[1]}
      </demographic>
    </provider>
  else ()        
return csd_bl:wrap_providers($provs2)
