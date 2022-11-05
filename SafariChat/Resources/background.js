
browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    sendResponse({ farewell: "passed" });
    browser.runtime.sendNativeMessage('kr.letswift.CoffeeChat.SafariChat', {
        "body" : request.body,
        "location" : request.location.href});
});
