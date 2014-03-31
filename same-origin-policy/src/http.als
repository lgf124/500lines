/**
	* http.als
	* 	A model of the Hypertext Transfer Protocol.
	*/
module http

open message


/* Server-side components */
sig Host {}
sig Port {}
sig Protocol {}
sig Path {}

// Given an example URL "http://www.example.com/dir/page.html",
// "http" is the protocol,
// "www.example.com" is the host,
// "/dir/path.html" is the path, and
// the port is omitted.
sig URL {
	protocol : Protocol,
	host : Host,
	// port and path are optional
	port : lone Port,
	path : lone Path
}

sig Server extends message/EndPoint {	
	resMap : URL -> lone Resource		// maps each URL to at most one resource
}

/* Client-side components */
sig Browser extends message/EndPoint {
	frames : set Frame
}
sig Frame {
	location : URL,
	dom : DOM,
	script : lone Script
}{
	some script implies script.context = location
}
sig Script extends message/EndPoint {
	context : URL
}

/* HTTP Messages */
abstract sig HTTPReq extends message/Msg {
	url : URL
}{
	sender in Browser + Script
	receiver in Server
}
sig GET, POST, OPTIONS extends HTTPReq {}

sig XMLHTTPReq in HTTPReq {
}{
	sender in Script
}

abstract sig HTTPResp extends message/Msg {
	res : Resource,
	inResponseTo: HTTPReq
}{
	sender in Server
	receiver in Browser + Script
	payloads = res
}

/* Frame interactions */
sig DOM extends Resource {}

abstract sig DomAPI extends message/Msg {
	frame : Frame									// frame that contains the DOM
}{
	sender in Script
	receiver in Browser
	frame in Browser.frames
}
sig ReadDOM extends DomAPI {
	dom : DOM,
}{
	payloads = dom
}
sig WriteDOM extends DomAPI {
	newDOM : DOM
}{
	payloads = newDOM
}
