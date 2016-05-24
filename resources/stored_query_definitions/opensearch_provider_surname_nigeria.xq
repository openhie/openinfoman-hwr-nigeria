import module namespace osf = "https://github.com/openhie/openinfoman/adapter/opensearch";
import module namespace functx = 'http://www.functx.com';

declare namespace csd =  "urn:ihe:iti:csd:2013";
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


(:Get the search terms passed in the request :)
let $search_terms := xs:string($careServicesRequest/csd:requestParams/os:searchTerms/text())
(:Find the matching providers -- to be customized for your search:)
let $matched_providers :=  
  for $provider in /csd:CSD/csd:providerDirectory/csd:provider
  let $surname := $provider/csd:demographic/csd:name/csd:surname
  where  exists($search_terms) and exists($surname) and functx:contains-case-insensitive($surname,  $search_terms)  
  return $provider  



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



let $processors := map{
  'html_wrap' : $html_wrap_func
}

(:Produce the feed in the neccesary format :)
return osf:create_feed_from_entities($matched_providers,$careServicesRequest,$processors)



