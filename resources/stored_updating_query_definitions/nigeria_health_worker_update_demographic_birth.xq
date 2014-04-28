import module namespace csd = "urn:ihe:iti:csd:2013" at "../repo/csd_base_library.xqm";
import module namespace csd_nhwrn = "http://www.health.gov.ng" at "../repo/csd_national_health_worker_registry_nigeria.xqm";
import module namespace csd_blu = "https://github.com/his-interop/openinfoman/csd_blu" at "../repo/csd_base_library_updating.xqm";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:)   

let $provs := if (exists($careServicesRequest/id/@oid)) then	csd:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id) else ()
let $updBirth :=  ($careServicesRequest/demographic/extension[@oid=$csd_nhwrn:rootoid and @type='birth'])[1]
let $existBirth := ($provs[1]/demographic/extension[@oid=$csd_nhwrn:rootoid and @type='birth'])[1]
let $return := 
  <provider oid="{$provs[1]/@oid}">
    <demographic><extension type="birth" oid="{$csd_nhwrn:rootoid}"/></demographic>
  </provider>

return  
  if ( count($provs) = 1 and exists( $existBirth ) and exists($updBirth)) then
   (
     if (exists($updBirth/country))
       then 	    
       if (exists($existBirth/country))
	 then  replace value of node $existBirth/country with $updBirth/country
       else insert node  $updBirth/country into $existBirth
     else (),
     if (exists($updBirth/town))
       then 	    
       if (exists($existBirth/town))
	 then  replace value of node $existBirth/town with $updBirth/town
       else insert node  $updBirth/town into $existBirth
     else (),
     if (exists($updBirth/motherName))
       then 	    
       if (exists($existBirth/motherName))
	 then  replace value of node $existBirth/motherName with $updBirth/motherName
       else insert node  $updBirth/motherName into $existBirth
     else (),
     if (exists($updBirth/fatherName))
       then 	    
       if (exists($existBirth/fatherName))
	 then  replace value of node $existBirth/fatherName with $updBirth/fatherName
       else insert node  $updBirth/fatherName into $existBirth
     else (),	    
     csd_blu:bump_timestamp($provs[1]),
     csd_blu:wrap_updating_providers($return)
    )
  else 	csd_blu:wrap_updating_providers(())

