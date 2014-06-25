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
let $birth :=  ($careServicesRequest/demographic/extension[@oid=$csd_nhwrn:rootoid and @type='birth'])[1]
let $existingBirth :=  ($provs[1]/demographic/extension[@oid=$csd_nhwrn:rootoid and @type='birth'])[1]
let $demo := $provs[1]/demographic
let $insert := 
  if (not(exists($demo))) then <demographic>{$birth}</demographic> else $birth
    let $return := 
    <provider oid="{$provs[1]/@oid}">
      <demographic><extension type="birth" oid="{$csd_nhwrn:rootoid}"/></demographic>
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
      
