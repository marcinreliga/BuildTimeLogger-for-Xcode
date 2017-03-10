# BuildTimeLogger-for-Xcode
A console app for logging Xcode build times and presenting them in a notification.
Optionally the app can upload each result to a REST API endpoint accepting POST requests.

Based on [BuildTimeAnalyzer-for-Xcode](https://github.com/RobertGummesson/BuildTimeAnalyzer-for-Xcode).
## Example notification
![notification](https://raw.githubusercontent.com/marcinreliga/BuildTimeLogger-for-Xcode/master/notification.png)
## Usage
Edit scheme and add new Post-action in Build section:

![usage](https://raw.githubusercontent.com/marcinreliga/BuildTimeLogger-for-Xcode/master/usage.png)

If the URL is not provided then uploading is skipped.

To see remotely stored results call the app with additional param:
```
/PATH/TO/BuildTimeLogger https://your-project-name.firebaseio.com/.json fetch
```

Example output:
```
Fetching remote data...
username: marcin.religa
build time today: 30m 26s
total build time: 165m 55s

username: test.user
build time today: 0m 0s
total build time: 0m 4s

```
