import module namespace csd_bl = "https://github.com/his-interop/openinfoman/csd_bl";
import module namespace csd_nhwrn = "http://www.health.gov.ng/csd";
import module namespace csd_blu = "https://github.com/his-interop/openinfoman/csd_blu";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:)   

let $provs := if (exists($careServicesRequest/id/@oid)) then	csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id) else ()
let $updCitizen :=  ($careServicesRequest/demographic/extension[@oid=$csd_nhwrn:rootoid and @type='citizenship'])[1]
let $existCitizen := ($provs[1]/demographic/extension[@oid=$csd_nhwrn:rootoid and @type='citizenship'])[1]
let $return := 
  <provider oid="{$provs[1]/@oid}">
    <demographic><extension type='citizenship' oid="{$csd_nhwrn:rootoid}"/></demographic>
  </provider>

return  
  if ( count($provs) = 1 and exists( $existCitizen ) and exists($updCitizen)) then
   (
     if (exists($updCitizen/residence))
       then 	    
       if (exists($existCitizen/residence))
	 then  replace value of node $existCitizen/residence with $updCitizen/residence
       else insert node  $updCitizen/residence into $existCitizen
     else (),
     if (exists($updCitizen/current))
       then 	    
       if (exists($existCitizen/current))
	 then  replace value of node $existCitizen/current with $updCitizen/current
       else insert node  $updCitizen/current into $existCitizen
     else (),
     if (exists($updCitizen/birth))
       then 	    
       if (exists($existCitizen/birth))
	 then  replace value of node $existCitizen/birth with $updCitizen/birth
       else insert node  $updCitizen/birth into $existCitizen
     else (),
     csd_blu:bump_timestamp($provs[1]),
     csd_blu:wrap_updating_providers($return)
    )
  else 	csd_blu:wrap_updating_providers(())

