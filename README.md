# CoffeeChat 예제 프로젝트

> 이 프로젝트는 Let'Swift 2022 세션 데모를 위한 예제입니다

### 확장도구 Extension

- 가장 유명한 건 위젯 Widget. 홈화면이 동작시켜주는 특별한(?) 확장도구
- macOS나 iOS 앱 내에 Extension 타깃을 추가해서 같이 배포. `Containing App`이라고 부름
- 종류가 무지 많음 [앱 익스텐션 공식 문서](https://developer.apple.com/kr/app-extensions/)
	- 동작Action, 공유, 콘텐츠 차단, 메시지 필터, 알림 서비스, 맞춤형 키보드, 스티커팩, Intent(시리)...
- Containing App에서 App Extension을 포함해서 배포하지만, 각각 다른 앱에서 실행함. 
- Containing App와 App Extension이 리소스를 공유하려면 Group Container 설정 필수
- Containing App와 App Extension은 서로 다른 프로세스라서 IPC로 통신 가능

### 사파리 확장도구

- Safari Extension 타깃을 추가할 때 Type을 Web Extension 또는 App Extension 두 가지 중에 하나를 선택해야 함

#### I. 사파리 웹 익스텐션

- Safari Web Extension은 사파리 확장도구로 JS코드로 동작하는 브라우저 프로그램 표준. 
파폭이나 크롬 확장은 별도 배포가 가능하지만, macOS와 iOS는 보안상의 이유로 네이티브 앱과 같이 배포해야함
(예전의 Safari Extension과 동작 방식이 다름)

[사파리 웹 확장 개발문서](https://developer.apple.com/documentation/safariservices/safari_web_extensions)

- 사파리 확장도구와 NSExtensionRequestHandling 상속받은 네이티브 클래스 SafariWebExtensionHandler가 서로 소통할 수 있음
단, 웹 확장의 background.js에서만 네이티브와 소통이 가능

```js
browser.runtime.sendNativeMessage('kr.letswift.CoffeeChat.SafariChat', {
        "body" : request.body,
        "location" : request.location.href});
```

- 예제 코드는 다음과 같이 동작함 (👉SafariChat 타깃)
	- 사파리에서 확장도구 버튼을 누를 때 popup.js 실행. popup.js에서 활성화된 Tab에 browser.tabs.sendMessage() 보냄
	- 탭별로 콘텐츠에 접근가능한 content.js가 실행. 보안상 다른 탭에는 접근 안됨. document에 접근해서 body를 background.js로 보냄
	- 확장도구별로 네이티브 코드와 소통할 수 있는 별도 스레드로 동작하는 공용 background.js 실행. 여기서만 SafariWebExtensionHandler로 호출 가능. background.js에서 body는 Group Container에 파일로 저장
	- SafariWebExtensionHandler에서 Containing App으로 UDP로 파일 경로를 포함한 이벤트 전달
	- Containing App에서는 UDP 서버를 듣고 있다가 메시지 오면 Notification을 띄움

#### II. 사파리 웹 익스텐션

- Safari App Extension은 애플 규격으로 사파리 앱이 실행해주는 익스텐션 
마찬가지로 macOS와 iOS는 보안상의 이유로 네이티브 앱과 같이 배포해야함
 
[사파리 앱 확장 개발문서](https://developer.apple.com/documentation/safariservices/safari_app_extensions)

- 예제 코드는 다음과 같이 동작함 (👉SafariAppChat 타깃)
    - Info.plist 에 모든 설정이 들어감. 이걸 보고 사파리가 실행해줌
        - SFSafariContentScript : 사파리가 실행할 JS  
            - 현재는 사파리 웹 페이지와 동작하는 리소스 script.js        
        - SFSafariToolbarItem : 사파리에 표시될 툴바 정보. Command는 누르면 끝. Popover는 ViewController를 띄움        
        - SFSafariWebsiteAccess : 접근 허용할 사이트 주소. 현재 letswift.kr 만 
    - 익스텐션과 소통할 방법은 총 3가지
        - SFSafariContentScript -> page 관련 메시지 보내기 (현재 로그만 찍음)
        - SFSafariToolbarItem + Command 방식 -> 누를 때마다 처리 (지금 방식)
        - SFSafariToolbarItem + Popover + ViewController 방식 -> UI화면에서 연동 

- Web Extension과 다르게 네이티브 UI + 코드를 작성할 수 있음
- 권한관리가 모두 plist에서 관리되서 앱 개발자가 익숙함. js빼고는 모두 스위프트 코드로 가능!
- content 접근은 js로 할 수 있는데, 백그라운드 워커 동작은 안되는 듯 (모든 상황을 테스트해보지는 않았음)

---

### Xcode 확장도구 

- Xcode 소스편집기에서 선택된 소스를 전달할 수 있는 맥용 확장도구를 만들 수 있음
- 플러그인을 만들 수 있던 적이 있었는데, 보안상의 이유로 다 막히고 XcodeKit으로 소스편집기 확장도구만 가능
- 구조는 2단계로 구성됨
	- 1단계. Xcode 메뉴에 아이템 추가 XCSourceEditorExtension 상속
	- 2단계. 메뉴를 눌렀을 때 동작할 코드 XCSourceEditorCommand 상속

- 예제에서는 2가지 메뉴가 동작
	- SnapshotCommand : 선택된 소스 코드를 문법 하일라이트해서 이미지로 변환. 클립보드에 복사함
	- ChatCommand : 
		- Containing App이 떠있으면 UDP로 이벤트 전달
		- UDP는 MTU 사이즈 제한이 있음. 소스 코드는 Group Containter 폴더에 파일로 저장하고 경로+파일을 전달
		- Containing App에서는 UDP 서버를 듣고 있다가 메시지 오면 Notification을 띄움

### 기타

- Extension 확장도구는 디버깅하기 어렵다. Safari나 Xcode를 별도로 띄워서 실행은 가능하긴 함
- 디버깅이 아니라 앱 스토어에 배포하기 전에 사용하려면 아카이브하고, 아카이브 내에 실행 파일을 추출해서 가능함
- 거쳐가는 단계가 많다보니 어느 단계가 안되는지 판단하려면 os_log를 추천

