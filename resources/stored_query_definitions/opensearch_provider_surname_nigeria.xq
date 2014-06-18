import module namespace csd = "urn:ihe:iti:csd:2013" at "../repo/csd_base_library.xqm";
import module namespace osf = "https://github.com/his-interop/openinfoman/opensearch_feed" at "../repo/opensearch_feed.xqm";
import module namespace functx = 'http://www.functx.com';

declare namespace rss = "http://backend.userland.com/rss2";
declare namespace atom = "http://www.w3.org/2005/Atom";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare namespace os  = "http://a9.com/-/spec/opensearch/1.1/";
declare variable $careServicesRequest as item() external;



(: 
   The query will be executed against the root element of the CSD document.    
   The dynamic context of this query has $careServicesRequest set to contain any of the search 
   and limit paramaters as sent by the Service Finder
:) 

(:Should match the UUID assigned to the care services function.  :)
let $search_name := "092d4f54-25fd-413e-a062-07f095792ac0"


(:Get the search terms passed in the request :)
let $search_terms := xs:string($careServicesRequest/os:searchTerms/text())
(:Find the matching providers -- to be customized for your search:)
let $matched_providers :=  
  for $provider in /csd:CSD/csd:providerDirectory/csd:provider
  let $surname := $provider/csd:demographic/csd:name/csd:surname
  where  exists($search_terms) and exists($surname) and functx:contains-case-insensitive($surname,  $search_terms)  
  return $provider  


(:function that produces the atom entry for a provider.:)
let $atom_func:= function($provider,$doc_name,$search_name) 
{
   let $demo:= $provider/csd:demographic[1]
   return
     <atom:entry>
       <atom:title>{$demo/csd:name[1]/csd:surname/text()}, {$demo/csd:name[1]/csd:forename/text()}</atom:title>
       <atom:link href="{osf:get_entity_link($provider,$search_name)}"/>
       <atom:id>urn:oid:{string($provider/@oid)}</atom:id>  
       <atom:updated>{string($provider/csd:record/@updated)}</atom:updated>
       <atom:content type="text">{osf:get_provider_desc($provider,$doc_name)}</atom:content>
     </atom:entry>

}

(:function that produces the rss entry for a provider.:)
let $rss_func := function($provider,$doc_name,$search_name) 
{
   let $demo:= $provider/csd:demographic[1]
   return 
     <rss:item>
       <rss:title>{$demo/csd:name[1]/csd:surname/text()}, {$demo/csd:name[1]/csd:forename/text()}</rss:title>
       <rss:link>{osf:get_entity_link($provider,$search_name)}</rss:link>
       <rss:pubDate>{string($provider/csd:record/@updated)}</rss:pubDate>
       <rss:source>{string($provider/csd:record/@sourceDirectory)}</rss:source>
       <rss:description type="text">{osf:get_provider_desc($provider,$doc_name)}</rss:description>
     </rss:item>
}

(:function that produces the html entry for a provider.:)
let $html_func := function($provider,$doc_name,$search_name) 
{
   let $demo:= $provider/csd:demographic[1]
   return 
     <html:li>
       <html:a href="{osf:get_entity_link($provider,$search_name)}">
	 {$demo/csd:name[1]/csd:surname/text()}, {$demo/csd:name[1]/csd:forename/text()}
       </html:a>
       <html:div class='description'>{osf:get_provider_desc($provider,$doc_name)}</html:div>
       <html:div class='description_html'>{osf:get_provider_desc_html($provider,$doc_name)}</html:div>
     </html:li>
     
}





let $html_wrap_func :=  function($meta,$content) {
  <html:html xml:lang="en" lang="en">
    <html:head profile="http://a9.com/-/spec/opensearch/1.1/" >    

      <html:link href="/static/bootstrap/css/bootstrap.css" rel="stylesheet"/>
      <html:link href="/static/bootstrap/css/bootstrap-theme.css" rel="stylesheet"/>
      
      <html:script src="https://code.jquery.com/jquery.js"/>
      <script src="/static/bootstrap/js/bootstrap.min.js"/>

      <html:script src="https://code.jquery.com/jquery.js"/>
      <html:script src="/static/bootstrap/js/bootstrap.min.js"/>
      {$meta}
    </html:head>
    <html:body>  
      <html:div class="navbar navbar-inverse navbar-static-top">
	<html:div class="container">
          <html:div class="navbar-header">
	    <html:img class='pull-left' height='38px' src='/static/FMOH_Nigeria_logo.png'/>
            <html:button type="button" class="navbar-toggle" data-toggle="collapse" data-target=".navbar-collapse">
              <html:span class="icon-bar"></html:span>
              <html:span class="icon-bar"></html:span>
              <html:span class="icon-bar"></html:span>
            </html:button>
            <html:a class="navbar-brand" href="/CSD">Nigeria Health Workforce Registry</html:a>
          </html:div>
	</html:div>
      </html:div>
      <html:div class="container">
	<html:p align="justify" class='bold'>
	The Nigeria Health Workforce Registry (NHWR) is an information system developed and managed by the Department of Planning, Research and Statistics,
	in the Federal Ministry of Health. The Nigeria Health Workforce Registry represents the Government of Nigeria's health workforce, aggregated from the three
	tiers of the country's health system - Local, State and Federal levels.
	</html:p>
	<html:p>
	The Nigeria Health Workforce Registry implements the Care Services Directory 
	(<html:a href="ftp://ftp.ihe.net/DocumentPublication/CurrentPublished/ITInfrastructure/IHE_ITI_Suppl_CSD.pdf">CSD</html:a>)
	profile from Integrating the Health Enterprise <html:a href="http://ihe.net">(IHE)</html:a> as recommened by OpenHIE.
	</html:p>
	

	<html:p>
	  <html:b>The Nigeria Health Workforce Registry is a free, Open Source software solution.</html:b>
	</html:p>
      </html:div>
      <html:div class='wrapper_search'>
	<html:div class="container">
	  {$content}
	</html:div>
      </html:div>


      <html:div id='site_footer' class='container'>
        © 2014 Department of Planning, Research and statistics, Federal Ministry of Health. 
      </html:div>
    </html:body>
  </html:html>

}





(:Produce the feed in the neccesary format :)
return osf:create_feed_from_entities($matched_providers,$careServicesRequest,$search_name,$rss_func,$atom_func,$html_func,$html_wrap_func) 



