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

let $provider := if (exists($careServicesRequest/id/@oid)) then	csd:filter_by_primary_id(/CSD/providerDirectory/*,$careServicesRequest/id)[1] else ()
let $cred_request := $careServicesRequest/credential
let $code:= $cred_request/codedType/@code
let $codingSchema:= $cred_request/codedType/@codingSchema
let $creds := $provs2/credential[@code = $code and @codingSchema = $codingSchema]
return  
  if ( exisert($provider) and count($creds) = 0 and exists($code) and exists($codingScheme))  (:DO NOT ALLOW SAME CRED TWICE :)
    then
    let $return:=  
      <provider oid="{$provider/@oid}">
	<credential>
	  <codedType code="{$code}" codingSchema="{$codingSchema}"/>
	</credential>
      </provider>
    let $cred_new :=
      <credential>
	<codedType code="{$code}" codingSchema="{$codingSchema}"/>
	{(
	  if (exists($cred_request/number)) then $cred_request/number else (),
	  if (exists($cred_request/issuingAuthority)) then $cred_request/issuingAuthority else (),
	  if (exists($cred_request/credentialIssueDate)) then $cred_request/credentialIssueDate else (),
	  if (exists($cred_request/credentialRenewalDate)) then $cred_request/credentialRenewalDate else (),
	  if (exists($cred_request/extension[@oid=$csd_nhwrn:rootoid and @type='photograph']/image)) then $cred_request/extension[@oid=$csd_nhwrn:rootoid and @type='photograph'] else ()
	 )}
      </credential>
    return 
	(
	insert node $cred_new into $provider,
	csd_blu:wrap_updating_providers($return)
	)

  else  csd_blu:wrap_updating_providers(())
      
