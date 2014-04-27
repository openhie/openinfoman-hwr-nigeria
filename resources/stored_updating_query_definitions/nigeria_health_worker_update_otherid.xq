import module namespace csd = "urn:ihe:iti:csd:2013" at "../repo/csd_base_library.xqm";
import module namespace csd_blu = "https://github.com/his-interop/openinfoman/csd_blu" at "../repo/csd_base_library_updating.xqm";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:)   
let $provs0 := if (exists($careServicesRequest/otherID)) then /CSD/providerDirectory/*  else ()
let $provs1 := if (exists($careServicesRequest/id/@oid)) then csd:filter_by_primary_id($provs0,$careServicesRequest/id) else ()
let $id := $provs1[1]/otherID[position() = $careServicesRequest/otherID/@position]
return
  if (count($provs1) = 1 and exists($id)) 
    then
    let $provs2 := 
    <provider oid="{$provs1[1]/@oid}">
      <otherID position="{$careServicesRequest/otherID/@position}"/>
    </provider>
    return
      (
	csd_blu:bump_timestamp($provs1[1]),
	if ($careServicesRequest/otherID/@code) 
	  then 	    
	    if (exists($id/@code))
	      then  (replace value of node $id/@code with $careServicesRequest/otherID/@code)
	      else (insert node  $careServicesRequest/otherID/@code into $id)
	  else (),
	if (exists($careServicesRequest/otherID/@assigningAuthorityName) )
	  then 
	    if (exists($id/@assigningAuthorityName))
	      then replace value of node $id/@assigningAuthorityName with $careServicesRequest/otherID/@assigningAuthorityName
	      else insert node $careServicesRequest/otherID/@assigningAuthorityName into $id		
	  else (),
	if (exists($careServicesRequest/otherID/@issueDate) )
	  then 
	    if (exists($id/@issueDate))
	      then replace value of node $id/@issueDate with $careServicesRequest/otherID/@issueDate
	      else insert node $careServicesRequest/otherID/@issueDate into $id		
	  else (),
	if (exists($careServicesRequest/otherID/@expirationDate) )
	  then 
	    if (exists($id/@expirationDate))
	      then replace value of node $id/@expirationDate with $careServicesRequest/otherID/@expirationDate
	      else insert node $careServicesRequest/otherID/@expirationDate into $id		
	  else (),
	if (not(string($careServicesRequest/otherID) = '')) 
	  then (replace value of node $id with string($careServicesRequest/otherID))
	  else (),
	csd_blu:wrap_updating_providers($provs2)
     )
  else 	csd_blu:wrap_updating_providers(())

