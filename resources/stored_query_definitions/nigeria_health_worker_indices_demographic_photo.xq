import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
declare default element  namespace   "urn:ihe:iti:csd:2013";

declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 
  let $provs0 := 
    if (exists($careServicesRequest/id/@urn)) then 
      csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id) 
    else (/CSD/providerDirectory/*)
  let $provs1:=     
      for $provider in  $provs0
      return
      <provider urn="{$provider/@urn}">
	<demographic>
	  {
	    for $name at $pos  in  $provider/demographic/extension[@type='photograph' and @urn='urn:who.int:hrh:mds']
	    return <extension type='photograph' urn='urn:who.int:hrh:mds'  position="{$pos}"/> 
	  }
	</demographic>
    </provider>
      
    return csd_bl:wrap_providers($provs1)
