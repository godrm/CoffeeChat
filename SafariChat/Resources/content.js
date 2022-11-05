browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
//    console.log("content --- Received request: ", request);
    browser.runtime.sendMessage({ greeting: "pass", location : window.location, body : document.documentElement.innerHTML }).then((response) => {
        console.log("Receive from background response: ", response);
    });
    sendResponse({"passed": true});
});
