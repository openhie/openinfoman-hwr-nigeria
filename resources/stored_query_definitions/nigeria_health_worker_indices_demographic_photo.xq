import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
declare default element  namespace   "urn:ihe:iti:csd:2013";
import module namespace csd_nhwrn = "http://www.health.gov.ng/csd";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 
  let $provs0 := 
    if (exists($careServicesRequest/id/@oid)) then 
      csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id) 
    else (/CSD/providerDirectory/*)
  let $provs1:=     
      for $provider in  $provs0
      return
      <provider oid="{$provider/@oid}">
	<demographic>
	  {
	    for $name at $pos  in  $provider/demographic/extension[@type='photograph' and @oid=$csd_nhwrn:rootoid]
	    return <extension type='photograph' oid='{$csd_nhwrn:rootoid}'  position="{$pos}"/> 
	  }
	</demographic>
    </provider>
      
    return csd_bl:wrap_providers($provs1)
