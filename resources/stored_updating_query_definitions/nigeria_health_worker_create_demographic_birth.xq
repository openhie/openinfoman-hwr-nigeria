import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";

import module namespace csd_blu = "https://github.com/openhie/openinfoman/csd_blu";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:)   

let $provs := if (exists($careServicesRequest/requestParams/id/@entityID)) then	csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/requestParams/id) else ()
let $birth :=  ($careServicesRequest/requestParams/demographic/extension[@urn='urn:who.int:hrh:mds' and @type='birth'])[1]
let $existingBirth :=  ($provs[1]/demographic/extension[@urn='urn:who.int:hrh:mds' and @type='birth'])[1]
let $demo := $provs[1]/demographic
let $insert := 
  if (not(exists($demo))) then <demographic>{$birth}</demographic> else $birth
    let $return := 
    <provider entityID="{$provs[1]/@entityID}">
      <demographic><extension type="birth" urn="urn:who.int:hrh:mds"/></demographic>
    </provider>
let $insertTo :=
  if (not(exists($demo))) then $provs[1] else $provs[1]/demographic

return  
  if ( count($provs) = 1 and not(exists($existingBirth)))
  then
     (
      insert node $insert into $insertTo,
      csd_blu:bump_timestamp($provs[1]),
      csd_blu:wrap_updating_providers($return)
      )
  else  csd_blu:wrap_updating_providers(())
      
