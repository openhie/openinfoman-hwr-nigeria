import module namespace csd = "urn:ihe:iti:csd:2013" at "../repo/csd_base_library.xqm";
import module namespace csd_blu = "https://github.com/his-interop/openinfoman/csd_blu" at "../repo/csd_base_library_updating.xqm";
import module namespace csd_nhwrn = "http://www.health.gov.ng" at "../repo/csd_national_health_worker_registry_nigeria.xqm";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:)   
let $ext := $careServicesRequest/demographic/extension[@type='photograph' and @oid=$csd_nhwrn:rootoid]
let $provs0 := if (exists($careServicesRequest/id/@oid)) then	csd:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id) else ()
let $provs1 := if (count($provs0) = 1) then $provs0 else ()
let $provs2 := if (exists($ext))  then $provs1 else ()
return  
  if ( count($provs2) = 1 )
    then
    let $provider:= $provs2[1]
    let $position := count($provider/demographic/extension[@type='photograph' and @oid=$csd_nhwrn:rootoid]) +1
    let $provs3:=  
    <provider oid="{$provider/@oid}">
      <demographic>
	<extension type='photograph' oid='{$csd_nhwrn:rootoid}' position="{$position}"/>
      </demographic>
    </provider>
    return 
      (
	if (exists($provider/demographic))
	  then insert node $ext into $provider/demographic 
	else
	  insert node <demographic>{$ext}</demographic> into $provider
	  ,   csd_blu:wrap_updating_providers($provs3)
	)
  else  csd_blu:wrap_updating_providers((<a/>,$ext,$provs0))
      
