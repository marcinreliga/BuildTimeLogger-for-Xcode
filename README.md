# BuildTimeLogger-for-Xcode
A console app for logging Xcode build times and presenting them in a notification right when the build finishes.
Optionally the app can upload each log entry to a REST API endpoint accepting POST requests.

Based on [BuildTimeAnalyzer-for-Xcode](https://github.com/RobertGummesson/BuildTimeAnalyzer-for-Xcode).
## Example notification
![notification](https://raw.githubusercontent.com/marcinreliga/BuildTimeLogger-for-Xcode/master/notification.png)
## Usage
1. Download BuildTimeLogger project, build and run it.
2. Copy the product (BuildTimeLogger app) into some easily accessible location.
3. In **your** Xcode project, edit scheme and add new Post-action in Build section:

![usage](https://raw.githubusercontent.com/marcinreliga/BuildTimeLogger-for-Xcode/master/usage.png)

If you want to upload each log entry to a remote endpoint just specify the URL as a param:

![usage](https://raw.githubusercontent.com/marcinreliga/BuildTimeLogger-for-Xcode/master/usage_remote.png)

As in the example, I tested that it works with [Firebase](https://firebase.google.com/), but it can potentially send the data to any REST API endpoint accepting POST requests.

## Viewing remotely stored logs

To see remotely stored results call the app (from terminal, outside the Xcode) with additional param:
```
$ /PATH/TO/BuildTimeLogger https://your-project-name.firebaseio.com/.json fetch
```

Example output:
```
Fetching remote data...
username: marcin.religa
build time today: 30m 26s
total build time: 165m 55s

username: test.user
build time today: 11m 23s
total build time: 45m 40s

```

This currently only works for results in JSON format fetched from Firebase. If you use different type of remote storage then you need to fetch/parse results yourself, as appriopriate.
