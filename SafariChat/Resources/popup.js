browser.tabs.getCurrent().then((tab) => {
    browser.tabs.sendMessage(tab.id, { greeting: "pass"}).then((response) => {
        console.log("Received response: ", response);
    });
});
