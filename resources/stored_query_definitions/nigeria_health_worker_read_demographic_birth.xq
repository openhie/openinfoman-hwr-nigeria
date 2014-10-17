import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";

declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 

let $provs1 := if (exists($careServicesRequest/id/@entityID)) then csd_bl:filter_by_primary_id(/CSD/providerDirectory/* ,$careServicesRequest/id) else ()
let $provs2 := 
  if (count($provs1) = 1) 
    then 
    <provider entityID="{$provs1[1]/@entityID}">
      <demographic>
	{($provs1[1]/demographic/extension[@urn='urn:who.int:hrh:mds' and @type='birth'])[1]}
      </demographic>
    </provider>
  else ()        
return csd_bl:wrap_providers($provs2)
