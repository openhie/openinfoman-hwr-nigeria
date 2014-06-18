(:~
: This is a module contatining  stored queries for a Care Services Discovery compliant Health Worker Registry for Nigeria
: @version 1.0
: @see https://github.com/his-interop/openinfoman @see http://ihe.net
:
:)
module namespace csd_nhwrn = "http://www.health.gov.ng";

import module namespace csd = "urn:ihe:iti:csd:2013" at "csd_base_library.xqm";
declare default element  namespace   "urn:ihe:iti:csd:2013";


declare variable $csd_nhwrn:rootoid := "2.25.157947202849059375867107665357870616448";