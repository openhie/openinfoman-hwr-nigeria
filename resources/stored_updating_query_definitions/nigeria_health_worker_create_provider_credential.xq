import module namespace csd_bl = "https://github.com/openhie/openinfoman/csd_bl";
import module namespace csd_blu = "https://github.com/openhie/openinfoman/csd_blu";
declare default element  namespace   "urn:ihe:iti:csd:2013";
declare variable $careServicesRequest as item() external;

(: 
   The query will be executed against the root element of the CSD document.
   
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:)   

let $provider := if (exists($careServicesRequest/id/@entityID)) then	csd_bl:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id)[1] else ()
let $cred_request := $careServicesRequest/credential
let $code:= $cred_request/codedType/@code
let $codingScheme:= $cred_request/codedType/@codingScheme
let $creds := $provider/credential[@code = $code and @codingScheme = $codingScheme]
return  
  if ( exists($provider) and count($creds) = 0 and exists($code) and exists($codingScheme))  (:DO NOT ALLOW SAME CRED TWICE :)
    then
    let $return:=  
      <provider entityID="{$provider/@entityID}">
	<credential>
	  <codedType code="{$code}" codingScheme="{$codingScheme}"/>
	</credential>
      </provider>
    let $cred_new :=
      <credential>
	<codedType code="{$code}" codingScheme="{$codingScheme}"/>
	{(
	  if (exists($cred_request/number)) then $cred_request/number else (),
	  if (exists($cred_request/issuingAuthority)) then $cred_request/issuingAuthority else (),
	  if (exists($cred_request/credentialIssueDate)) then $cred_request/credentialIssueDate else (),
	  if (exists($cred_request/credentialRenewalDate)) then $cred_request/credentialRenewalDate else (),
	  if (exists($cred_request/extension[@urn='urn:who.int:hrh:mds' and @type='photograph']/image)) then $cred_request/extension[@urn='urn:who.int:hrh:mds' and @type='photograph'] else ()
	 )}
      </credential>
    return 
	(
	insert node $cred_new into $provider,
	csd_blu:wrap_updating_providers($return)
	)

  else  csd_blu:wrap_updating_providers(())
      
