import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
import module namespace csd_nhwrn = "http://www.health.gov.ng/csd";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 
let $provs0 := 
  if (exists($careServicesRequest/id/@urn)) then 
    csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id) 
  else (/CSD/providerDirectory/*)
let $provs1:=     
  for $provider in  $provs0
  return
  <provider urn="{$provider/@urn}">
    <demographic>
     {
       if (exists(($provider/demographic/extension[@urn='urn:who.int:hrh:mds' and @type='citizenship'])[1])) then
	 <extension urn="urn:who.int:hrh:mds" type='citizenship'/>
       else ()
     }
    </demographic>
  </provider>
    
return csd_bl:wrap_providers($provs1)
