# GoodPup
I made this iOS app as a fun way to "rate" dogs either good or bad. The app analyzes photos taken or selected from the library, and uses CoreML with the MobileNet ml model and an array of dog breeds to determine if the photo is a dog or not. If it is, it's a good dog, cause all dogs are good dogs. If it isn't a dog, the app will sold you (gently).

I also set this up so it connects to a simple rest api to update the breeds list and the array of positive responses so those can be more easily updated on the fly. This data is saved in user defaults so it only updates if the api has a new version and the app can still be used seamlessly with no internet connection.

After you've successfully captured your good pup, you can save the photo with it's special badge to your photo library to share.
