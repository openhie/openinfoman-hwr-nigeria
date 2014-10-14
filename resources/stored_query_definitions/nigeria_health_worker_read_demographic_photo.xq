import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 

let $exts := $careServicesRequest/demographic/extension[@type='photograph' and @urn='urn:who.int:hrh:mds']
let $provs0 := if (count($exts) = 1 and exists($exts[1]/@position)) then /CSD/providerDirectory/*  else ()
let $provs1 := if (exists($careServicesRequest/id/@urn)) then csd_bl:filter_by_primary_id($provs0,$careServicesRequest/id) else ()
let $provs2 := 
  if (count($provs1) = 1) 
    then 
    let $provider :=  $provs1[1] 
    return 
    <provider urn="{$provider/@urn}">
      <demographic>
	{
	  for $ext in ($provider/demographic/extension[@type='photograph' and @urn='urn:who.int:hrh:mds'])[position() = $exts[1]/@position]
	  return      <extension type='photograph' urn='urn:who.int:hrh:mds'  position="{$exts[1]/@position}">{$ext/*}</extension>
	}
      </demographic>
      {$provider/record}
    </provider>
  else ()    
    
return csd_bl:wrap_providers($provs2)
