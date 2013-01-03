(function () {
 var frame = document.createElement("iframe");
 frame.setAttribute("width", "0px");
 frame.setAttribute("height", "0px");
 frame.setAttribute("id", "hori_bridge_frame");
 frame.setAttribute("src", "bridge://localhost/flush");
 document.documentElement.appendChild(frame);
 })();