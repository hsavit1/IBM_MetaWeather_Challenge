# IBM_MetaWeather_Challenge


Note: To run this app, please first run `pod install` to get the cocoapods dependencies

---

This is a native Swift project that loosely utilizes the [ReSwift framework](https://github.com/ReSwift/ReSwift) and the MetaWeather API to create a basic Weather app, with saving capabilities

I have been working lots with React Native as of late, and I wanted to attempt bring the Redux unidirectional data flow mindset over to native Swift. ReSwift is the leading library candidate to do just this

For more on ReSwift, check out these links:

- [Real World Flux - iOS](http://blog.benjamin-encz.de/post/real-world-flux-ios/)
- [ReSwift Docs](https://reswift.github.io/ReSwift/master/index.html)
- [Flux and Redux on Mobile](https://speakerdeck.com/benjamin_encz/flux-and-redux-on-mobile)


The idea behind ReSwift is that you can model your state easily, and you can just dispatch actions from your views to update the state accordingly. Updates are made through a reducer, which is a pure function that returns a new state object. This means your app should be very predictable and free of side effects. No side effects means that mocking and testing should be quite easy. This is why I wanted to give this framework a go!

I would have submitted this challenge as a React Native project in Javascript, however I was not sure of the requirements and I was handed the assignment on very very short notice. I was given the assignment Friday at 5pm and was asked to have it completed by Monday at 9am. I was also given no advance notice that this project was coming.

So I stuck to my guts. My experience with Redux and React Native has only been good to me, so I decided to give it's closed Swift cousin, ReSwift, my best shot. 

It was going well at first, especially with Core Data, and I decided to just push forwards and work with it. I even added a feature to swipe to delete a searched city from your history, as my immutable Core Data store made updates trivial. Unfortunately, I did run into a few roadblocks. Most notably, I needed to experiment with a few middlewares to dispatch asynchronous requests and didn't have the time so I ended up utilizing with a classic antipattern, **a singleton** api manager, to get the job done. I was very unhappy with the solution. Additionally, I wasn't able to manage routing with ReSwift or the ReSwiftRouter, would have been a very helpful bonus.

Unfortunately, I discovered that there are just a few differences between ReSwift and Redux that caused me some trouble, and I was forced to go with what comes off as a hacky solution to finish on time. However, it does mostly work. 

The architecture should be easy to follow if you take a look at the AppState.swift file and the Main.storyboard file. 

Overall, I would not go back to using ReSwift unless I had a proper thunk middleware to use for my asynchronous actions. I was not able to implement any unit testing or even time-travel debugging in the amount of time that I had. I assumed that ReSwift would allow me to model my state very easily - and if so, allow me to fully automate my tests. In short, in my experience this was not the case at all. There is a much weaker community around ReSwift and I didn't have time to research how to properly write my own ReSwift middlewares. 

The code is decently documented with my notes on where I could have improved my code.
