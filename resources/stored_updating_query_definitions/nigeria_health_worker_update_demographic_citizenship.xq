import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";

import module namespace csd_blu = "https://github.com/openhie/openinfoman/csd_blu";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:)   

let $provs := if (exists($careServicesRequest/id/@urn)) then	csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id) else ()
let $updCitizen :=  ($careServicesRequest/demographic/extension[@urn='urn:who.int:hrh:mds' and @type='citizenship'])[1]
let $existCitizen := ($provs[1]/demographic/extension[@urn='urn:who.int:hrh:mds' and @type='citizenship'])[1]
let $return := 
  <provider urn="urn:who.int:hrh:mds">
    <demographic><extension type='citizenship' urn="urn:who.int:hrh:mds"/></demographic>
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

