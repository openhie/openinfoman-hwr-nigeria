import module namespace csd_bl = "https://github.com/his-interop/openinfoman/csd_bl";
import module namespace csd_blu = "https://github.com/his-interop/openinfoman/csd_blu";
import module namespace csd_nhwrn = "http://www.health.gov.ng/csd";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:)   
let $ext := $careServicesRequest/demographic/extension[@type='photograph' and @oid=$csd_nhwrn:rootoid]
let $provs := if (exists($careServicesRequest/id/@oid)) then	csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id) else ()
return  
  if ( exists($ext) and count($provs) = 1 )
    then
    let $provider:= $provs[1]
    let $position := count($provider/demographic/extension[@type='photograph' and @oid=$csd_nhwrn:rootoid]) +1
    let $return:=  
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
	  ,   csd_blu:wrap_updating_providers($return)
	)
  else  csd_blu:wrap_updating_providers(())
      
