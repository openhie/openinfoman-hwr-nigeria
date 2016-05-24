import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
import module namespace csd_blu = "https://github.com/openhie/openinfoman/csd_blu";

declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:)   
let $ext := $careServicesRequest/requestParams/demographic/extension[@type='photograph' and urn ='urn:who.int:hrh:mds']
let $provs := if (exists($careServicesRequest/requestParams/id/@entityID)) then	csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/requestParams/id) else ()
return  
  if ( exists($ext) and count($provs) = 1 )
    then
    let $provider:= $provs[1]
    let $position := count($provider/demographic/extension[@type='photograph' and @urn='urn:who.int:hrh:mds']) +1
    let $return:=  
    <provider entityID="{$provider/@entityID}">
      <demographic>
	<extension type='photograph' urn='urn:who.int:hrh:mds' position="{$position}"/>
      </demographic>
    </provider>
    return 
      (
	if (exists($provider/demographic))
	  then insert node $ext into $provider/demographic 
	else
	  insert node <demographic>{$ext}</demographic> into $provider
	  ,   csd_blu:wrap_updating_providers($return)
	)
  else  csd_blu:wrap_updating_providers(())
      
