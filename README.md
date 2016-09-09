# Applozic-Chat-iOS-Framework
Applozic Chat Framework for Cocoa Pod

##Installation

1) Open terminal and navigate to your project root directory and run code ```pod init``` in terminal


2) Go to project directory open pod file and add code in that

```
 pod 'Applozic', '3.2.5'
```


3) Download **ALChatManager** class and add to your project
  
[**ALChatManager.h**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sample-with-framework/applozicdemo/ALChatManager.h)        

[**ALChatManager.m**](https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/sample-with-framework/applozicdemo/ALChatManager.m)


4) Add import code

```
#import "ALChatManager.h"
#import <Applozic/Applozic.h>
```


5) In **ALChatManager.h** replace ``` #define APPLICATION_ID @"applozic-sample-app ``` with your appplication key.


6) For Registering user and other customization follow [**Applozic iOS DOCS**](https://www.applozic.com/docs/ios-chat-sdk.html#step-2-login-register-user)
