import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
import module namespace csd_blu = "https://github.com/openhie/openinfoman/csd_blu";

declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:)   
let $new_ext := $careServicesRequest/requestParams/demographic/extension[@type='photograph' and @urn='urn:who.int:hrh:mds']
let $provs0 := if (exists($new_ext/@position)) then /CSD/providerDirectory/*  else ()
let $provs1 := if (exists($careServicesRequest/requestParams/id/@entityID)) then csd_bl:filter_by_primary_id($provs0,$careServicesRequest/requestParams/id) else ()
let $ext := ($provs1[1]/demographic/extension[@type='photograph' and @urn='urn:who.int:hrh:mds'])[position() = $new_ext/@position]
return
  if (count($provs1) = 1 and exists($ext)) 
    then
    let $provs2 := 
    <provider entityID="{$provs1[1]/@entityID}">
      <demographic>
	<extension type='photograph' urn='urn:who.int:hrh:mds' position="{$new_ext/@position}"/>
      </demographic>
    </provider>
    return
      (
	csd_blu:bump_timestamp($provs1[1]),
	replace  node $ext with $new_ext,
	csd_blu:wrap_updating_providers($provs2)
     )
  else 	csd_blu:wrap_updating_providers(())

